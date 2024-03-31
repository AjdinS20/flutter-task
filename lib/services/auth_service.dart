import 'dart:convert';

import 'base_service.dart';
import 'package:dio/dio.dart';

class AuthService extends BaseService {
  Future<Response> login(String username, String password) async {
    return dio.post(
      '/login',
      data: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 1,
      }),
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response> refresh(String token) async {
    return dio.post('/refresh', data: {
      'expiresInMins': 10,
    });
  }
}
