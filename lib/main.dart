import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geosquad/components/login_page.dart';
import 'package:geosquad/components/map_page.dart';
import 'package:geosquad/components/profile.dart';
import 'package:geosquad/components/register_page.dart';
import 'package:geosquad/components/validate_page.dart';
import 'package:geosquad/components/websocket_client.dart';

import 'components/loading_screen.dart';

void main() => runApp(App());

class WebsocketClient extends InheritedWidget {
  final WebsocketService client = WebsocketService();

  WebsocketClient({Key key, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static WebsocketService of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(WebsocketClient)
            as WebsocketClient)
        .client as WebsocketService;
  }
}

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
              return Builder(builder: (context) {
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
                    Future.delayed(Duration(seconds: 2)).then((_) =>
                        Navigator.pushReplacementNamed(context, '/auth'));
                    return Scaffold(
                        body: Center(
                            child: Text(
                                'We were unable to log in automatically, redirecting to Login page...')));
                  case APP_STATE.AUTO_LOGIN_SUCCESS:
                    Navigator.pushReplacementNamed(context, '/map');
                    break;
                  default:
                    return Center(child: CircularProgressIndicator());
                }
              });
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

class WebsocketBasicServerWhines extends StatelessWidget {
  final BuildContext context;
  final Widget child;

  WebsocketBasicServerWhines({@required this.context, @required this.child}) {
    WebsocketClient.of(context)
        .serverBroadcast
        .stream
        .listen(_processServerBroadcast);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) => this.child);
  }

  void _needAuth() {
    Navigator.of(this.context).pushReplacementNamed('/login');
    Scaffold.of(this.context)
        .showSnackBar(SnackBar(content: Text('You need to authorize again.')));
  }

  void _processFriendRequest(String data) {
    showDialog(
        context: this.context,
        builder: (context) {
          return AlertDialog(
            title: Text('Friend request'),
            content: Text('$data wants to add you as a friend...'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Accept'),
                  onPressed: () {
                    WebsocketClient.of(context)
                        .acceptFriendRequest(data)
                        .then((ServerResponse response) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('You have added $data as a friend.')));
                    });
                    Navigator.of(context).pop();
                  }),
              FlatButton(
                  child: Text('Decline'),
                  onPressed: () {
                    WebsocketClient.of(context)
                        .declineFriendRequest(data)
                        .then((ServerResponse response) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "You have declined $data's friend request.")));
                    });
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  void _processServerBroadcast(ServerResponse broadcast) {
    // switch (broadcast.code) {
    //   case 'NEED_AUTH':
    //     this._needAuth();
    //     break;
    //   case 'FRIEND_REQUEST':
    //     this._processFriendRequest(broadcast.data);
    //     break;
    // }
  }
}

class WebsocketFriendChangeListener extends StatefulWidget {
  final BuildContext context;
  final Widget child;

  WebsocketFriendChangeListener({@required this.context, @required this.child});

  @override
  _WebsocketFriendChangeListenerState createState() =>
      _WebsocketFriendChangeListenerState();
}

/*
class _FirstPageState extends State<FirstPage> {
  APP_STATE _currentState = APP_STATE.INITIAL;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(body: Builder(builder: (context) {
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
          return new LoginPageExperiment(); // LoginPage();
        default:
          return CircularProgressIndicator();
      }
    }));
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    WebsocketClient.of(context).establishGuestSession().then((bool status) {
      if (!status) {
        this._currentState = APP_STATE.FIRST_CONNECTION_FAILED;
        return null;
      }
      return Future.value();
    }).then((_) {
      return WebsocketClient.of(context).tryToAuth().then((bool status) {
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
}
*/
class _WebsocketFriendChangeListenerState
    extends State<WebsocketFriendChangeListener> {
  @override
  Widget build(BuildContext context) {
    return WebsocketBasicServerWhines(
        context: this.widget.context, child: this.widget.child);
  }

  void didChangeDependencies() {
    WebsocketClient.of(context)
        .serverBroadcast
        .stream
        .listen(_processServerBroadcast);
  }

  void _processServerBroadcast(ServerResponse broadcast) {
    switch (broadcast.code) {
      case 'FRIEND_LIST_CHANGED':
        if (this.mounted) setState(() {});
        break;
    }
  }
}
