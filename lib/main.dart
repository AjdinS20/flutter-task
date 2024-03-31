import 'package:flutter/material.dart';
import 'package:flutter_assignment/global_event_bus.dart';
import 'package:flutter_assignment/screens/home_screen.dart';
import 'package:flutter_assignment/screens/login_page.dart';
import 'package:flutter_assignment/screens/splash_screen.dart';
import 'package:flutter_assignment/screens/user_info_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp(key: UniqueKey()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final storage = const FlutterSecureStorage();
  //global navigation key to enable logout after the logout event
  // this can also be done thorugh riverpod and using a consumerwidget to rebuild UI based on authentication state
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // listening for a logout event that is emitted from the interceptor
    eventBus.on<LogoutEvent>().listen((event) {
      _handleLogout();
    });
  }

  Future<void> _handleLogout() async {
    await storage.delete(key: "token");
    await storage.delete(key: "userImage");
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      navigatorKey: navigatorKey,
      initialRoute: '/',
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context)!.size.width * 0.05,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade500),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF37db81),
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 20),
            backgroundColor: Color(0xFF37db81),
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 36),
            padding: EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomeScreen(),
        '/userInfo': (context) => UserInfoScreen()
      },
    );
  }
}
