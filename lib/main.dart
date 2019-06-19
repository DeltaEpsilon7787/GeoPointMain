import 'package:flutter/material.dart';
import 'package:geosquad/components/websocket_client.dart';
import 'package:geosquad/components/login_page.dart';
import 'package:geosquad/components/register_page.dart';
import 'package:geosquad/components/map_page.dart';
import 'package:geosquad/components/profile.dart';
import 'package:geosquad/components/auth_page.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  static final WebsocketClient socketClient = new WebsocketClient();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Geopoint Squad',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => new MainPage(),
          '/auth': (context) => new LoginPage(),
          '/register': (context) => new RegisterPage(),
          '/map': (context) => new MapPage(),
          '/profile': (context) => new Profile()
        });
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Profile());
  }
}
