import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geosquad/components/notifiers.dart';
import 'package:geosquad/components/login_page.dart';
import 'package:geosquad/components/map_page.dart';
import 'package:geosquad/components/profile.dart';
import 'package:geosquad/components/register_page.dart';
import 'package:geosquad/components/validate_page.dart';
import 'package:geosquad/components/websocket_client.dart';

import 'components/loading_screen.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new WebsocketClient(
        child: MaterialApp(
            title: 'Geopoint Squad',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            routes: {
              '/loading': (context) => new LoadingScreen(),
              '/auth': (context) => new LoginPage(),
              '/auth/register': (context) => new RegisterPage(),
              '/auth/register/validate': (context) => new ValidatePage(),
              '/map': (context) => new MapPage(),
              '/map/profile': (context) => new Profile(),
            },
            home: FirstPage()));
  }
}

enum APP_STATE {
  INITIAL,
  FIRST_CONNECTION_FAILED,
  FIRST_CONNECTION_SUCCESS,
  AUTO_LOGIN_SUCCESS,
  AUTO_LOGIN_FAILED
}

class FirstPage extends StatelessWidget {
  const FirstPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: this._preload(context),
            initialData: APP_STATE.INITIAL,
            builder: (context, snapshot) {
              switch (snapshot.data) {
                case APP_STATE.FIRST_CONNECTION_FAILED:
                  return Scaffold(
                      body: Center(
                          child: Column(
                    children: <Widget>[
                      Text('We were unable to connect to GeoPoint server'),
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () {
                          exit(0);
                        },
                      )
                    ],
                  )));
                case APP_STATE.FIRST_CONNECTION_SUCCESS:
                  return Scaffold(
                      body: Center(child: Text('Trying to log in...')));
                case APP_STATE.AUTO_LOGIN_FAILED:
                  Future.delayed(Duration(seconds: 2)).then(
                      (_) => Navigator.pushReplacementNamed(context, '/auth'));
                  return Scaffold(
                      body: Center(
                          child: Text(
                              'We were unable to log in automatically, redirecting to Login page...')));
                case APP_STATE.AUTO_LOGIN_SUCCESS:
                  Future.delayed(Duration(seconds: 0)).then(
                      (_) => Navigator.pushReplacementNamed(context, '/map'));
                  break;
                default:
                  return Center(child: CircularProgressIndicator());
              }
              return Center(child: CircularProgressIndicator());
            }));
  }

  Stream<APP_STATE> _preload(BuildContext context) async* {
    yield* WebsocketClient.of(context)
        .establishGuestSession()
        .then((bool status) {
      return status
          ? APP_STATE.FIRST_CONNECTION_SUCCESS
          : APP_STATE.FIRST_CONNECTION_FAILED;
    }).asStream();

    yield* WebsocketClient.of(context).tryToAuth().then((bool status) {
      return status
          ? APP_STATE.AUTO_LOGIN_SUCCESS
          : APP_STATE.AUTO_LOGIN_FAILED;
    }).asStream();
  }
}
