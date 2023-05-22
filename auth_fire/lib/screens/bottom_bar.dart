import 'package:auth_fire/screens/user_info.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'cart.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BottomBarScreen extends StatefulWidget {
  @override
  _BottomBarScreenState createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  late List<Map<String, Widget>> _pages;
  int _selectedPageIndex = 1;
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    _pages = [
      {
        'page': Cart(),
      },
      {
        'page': HomeScreen(),
      },
      {
        'page': profile(user: currentUser),
      },
    ];
    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages[_selectedPageIndex]['page'],
      ),
      bottomNavigationBar: BottomAppBar(
        // color: Colors.white,
        shape: CircularNotchedRectangle(),
        notchMargin: 0.01,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: kBottomNavigationBarHeight * 0.98,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              onTap: _selectPage,
              backgroundColor: Colors.white,
              unselectedItemColor: Theme.of(context).primaryColor,
              selectedItemColor: Colors.purple,
              currentIndex: _selectedPageIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: 'Order',
                ),
                BottomNavigationBarItem(
                  activeIcon: null,
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'User',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          hoverElevation: 10,
          splashColor: Colors.grey,
          tooltip: 'home',
          elevation: 4,
          child: Icon(Icons.home),
          onPressed: () => setState(() {
            _selectedPageIndex = 1;
          }),
        ),
      ),
    );
  }
}
