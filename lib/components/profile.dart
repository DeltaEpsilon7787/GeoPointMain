import 'package:flutter/material.dart';
import 'package:geosquad/components/friends.dart';
import 'package:geosquad/components/home.dart';
import 'package:geosquad/components/settings.dart';

import './notifiers.dart';

class Profile extends StatefulWidget {
  @override
  _Profile createState() => new _Profile();
}

int _selectedIndex = 1;
List<Widget> _widgetList = <Widget>[
  new FriendsPage(),
  new HomePage(),
  new Settings(),
];

class _Profile extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return new ServerNotifier(
        context: context,
        child: Scaffold(
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
              }),
        ));
  }
}
