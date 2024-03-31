import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_assignment/global_event_bus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BaseService {
  Dio dio = Dio();
  final storage = const FlutterSecureStorage();
  BaseService() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://dummyjson.com/auth',
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 3000),
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            String? username = await storage.read(key: 'username');
            String? password = await storage.read(key: 'password');
            // This would usualy be implemented with a refresh endpoint
            var response = await dio.post(
              'https://dummyjson.com/auth/login',
              data: {
                'username': username,
                'password': password,
              },
            );
            if (response.statusCode == 200) {
              await storage.write(key: 'token', value: response.data['token']);
              await storage.write(
                  key: 'userImage', value: response.data['image']);

              final opts = error.response!.requestOptions;
              return dio.fetch(opts).then(
                    (r) => handler.resolve(r),
                    onError: (e) => handler.reject(e),
                  );
            } else {
              //if loging in the user with the same credentials fails then trigger a logout event
              eventBus.fire(LogoutEvent());
            }
          } catch (e) {
            return handler.next(error);
          }
        } else {
          return handler.next(error);
        }
      },
    ));
  }
}
