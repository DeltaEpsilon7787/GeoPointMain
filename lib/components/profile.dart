import 'package:flutter/material.dart';
import 'friends.dart';
import 'home.dart';
import 'settings.dart';

class Profile extends StatefulWidget {
  @override
  _Profile createState() => new _Profile();
}

int _selectedIndex = 1;
List<Widget> _widgetList = <Widget>[
  new FriendsPage(),
  new Home(),
  new Settings(),
];

class _Profile extends State<Profile> {
  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          onPressed: () {},
          icon: new Icon(Icons.arrow_back_ios, color: Colors.black,),
        ),
        title: new Text(
          "Profile",
          style: new TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: _widgetList.elementAt(_selectedIndex),
      bottomNavigationBar: new BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.account_circle,
                color: Colors.white,
              ),
              title: Text("Friends"),
              activeIcon: Icon(
                Icons.account_circle,
                color: Colors.yellow,
              ),

            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Colors.white,
              ),
              title: Text("Home"),
              activeIcon: Icon(
                Icons.home,
                color: Colors.yellow,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              title: Text("Settings"),
              activeIcon: Icon(
                Icons.settings,
                color: Colors.yellow,
              ),
            ),
          ],
          backgroundColor: Colors.black,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.yellow,
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          }
      ),
    );
  }
}
