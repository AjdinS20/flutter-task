import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();

  Future<void> login(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      var response = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );
      if (response.statusCode == 200) {
        await storage.write(key: 'token', value: response.data['token']);
        await storage.write(key: 'userImage', value: response.data['image']);
        await storage.write(key: 'username', value: _usernameController.text);
        await storage.write(key: 'password', value: _passwordController.text);
        navigator.pushReplacementNamed('/home');
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
                'Login Failed: ${response.data['message'] ?? 'Error occurred'}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      String message = 'Login failed: $e'; //Default message
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          message = e.response?.data['message'] ?? 'Invalid credentials';
        } else {
          message =
              'Login failed with status code: ${e.response?.statusCode ?? 'unknown'}';
        }
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: screenWidth * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                  onPressed: () {
                    login(context);
                  },
                  child: const Text('Login')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
