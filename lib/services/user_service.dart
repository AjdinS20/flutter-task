import 'base_service.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';

class UserService extends BaseService {
  Future<User> fetchUserData() async {
    try {
      Response response = await dio.get('/me');
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch user data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch user data: ${e.message}');
    }
  }
}
