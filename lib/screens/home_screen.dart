import 'package:flutter/material.dart';
import 'package:flutter_assignment/screens/log_screen.dart';
import 'package:flutter_assignment/screens/products_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'screens/products_screen.dart';
// import 'screens/log_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    ProductScreen(),
    LogScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final storage = const FlutterSecureStorage();
  final titles = ['Products', 'Log'];
  Future<String?> getUserImage() async {
    return await storage.read(key: 'userImage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: <Widget>[
          FutureBuilder<String?>(
            future: getUserImage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/userInfo');
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(snapshot.data!),
                    backgroundColor: Colors.transparent,
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {
                  Navigator.pushNamed(context, '/userInfo');
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Log',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
