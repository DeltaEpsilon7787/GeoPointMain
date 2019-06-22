import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geosquad/components/websocket_client.dart';
import 'package:geosquad/components/login_page.dart';
import 'package:geosquad/components/register_page.dart';
import 'package:geosquad/components/map_page.dart';
import 'package:geosquad/components/profile.dart';
import 'package:geosquad/components/validate_page.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  static final WebsocketClient socketClient = new WebsocketClient();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
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
          '/': (context) => new Home(),
          '/login': (context) => new LoginPage(),
          '/auth': (context) => new RegisterPage(),
          '/map': (context) => new MapPage(),
          '/profile': (context) => new Profile(),
          '/validate': (context) => new ValidatePage(),
        });
  }
}

enum APP_STATE {
  INITIAL,
  FIRST_CONNECTION_FAILED,
  AUTO_LOGIN_SUCCESS,
  AUTO_LOGIN_FAILED
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  APP_STATE _currentState = APP_STATE.INITIAL;

  void initState() {
    super.initState();

    App.socketClient.establishGuestSession().then((bool status) {
      if (!status) {
        this._currentState = APP_STATE.FIRST_CONNECTION_FAILED;
        return null;
      }
      return Future.value();
    }).then((_) {
      return App.socketClient.tryToAuth().then((bool status) {
        if (status) {
          this._currentState = APP_STATE.AUTO_LOGIN_SUCCESS;
        } else {
          this._currentState = APP_STATE.AUTO_LOGIN_FAILED;
        }
        return Future.value();
      });
    }).whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: () {
          switch (this._currentState) {
            case APP_STATE.INITIAL:
              return new Center(child: CircularProgressIndicator());
            case APP_STATE.FIRST_CONNECTION_FAILED:
              return new Dialog(
                  child: Column(
                    children: <Widget>[
                      Text('We were unable to connect to GeoPoint server'),
                      RaisedButton(
                          child: Text('OK'),
                          onPressed: () {
                            exit(0);
                          })
                    ],
                  ));
            case APP_STATE.AUTO_LOGIN_SUCCESS:
              return new MapPage();
            case APP_STATE.AUTO_LOGIN_FAILED:
              return new LoginPage();
          }
        }()
    );
  }
}
