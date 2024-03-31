import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  UserInfoScreenState createState() => UserInfoScreenState();
}

class UserInfoScreenState extends State<UserInfoScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  _fetchUserData() async {
    user = await UserService().fetchUserData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Info'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Image.network(user!.image),
                Text('${user!.firstName} ${user!.lastName}'),
                Text('Age: ${user!.age}'),
                Text('Email: ${user!.email}'),
                ElevatedButton(
                  onPressed: () {
                    _signOut(context);
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
    );
  }

  void _signOut(BuildContext context) async {
    var navigator = Navigator.of(context);
    var storage = const FlutterSecureStorage();
    await storage.delete(key: 'token');
    await storage.delete(key: 'userImage');

    // Navigate to the login screen
    navigator.pushNamedAndRemoveUntil(
        '/login', (Route<dynamic> route) => false);
  }
}
