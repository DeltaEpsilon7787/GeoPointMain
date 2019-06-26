import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geosquad/components/websocket_client.dart';
import 'package:geosquad/components/login_page.dart';
import 'package:geosquad/components/register_page.dart';
import 'package:geosquad/components/map_page.dart';
import 'package:geosquad/components/profile.dart';
import 'package:geosquad/components/validate_page.dart';

import 'components/friends.dart';

void main() => runApp(App());

class WebsocketClient extends InheritedWidget {
  final WebsocketService client = new WebsocketService();

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

  void _processServerBroadcast(ServerResponse broadcast) {
    switch (broadcast.code) {
      case 'NEED_AUTH':
        this._needAuth();
        break;
      case 'FRIEND_REQUEST':
        this._processFriendRequest(broadcast.data);
        break;
    }
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
}

class WebsocketFriendChangeListener extends StatefulWidget {
  final BuildContext context;
  final Widget child;

  WebsocketFriendChangeListener({@required this.context, @required this.child});

  @override
  _WebsocketFriendChangeListenerState createState() =>
      _WebsocketFriendChangeListenerState();
}

class _WebsocketFriendChangeListenerState
    extends State<WebsocketFriendChangeListener> {
  void didChangeDependencies() {
    WebsocketClient.of(context)
        .serverBroadcast
        .stream
        .listen(_processServerBroadcast);
  }

  @override
  Widget build(BuildContext context) {
    return WebsocketBasicServerWhines(
        context: this.widget.context, child: this.widget.child);
  }

  void _processServerBroadcast(ServerResponse broadcast) {
    switch (broadcast.code) {
      case 'FRIEND_LIST_CHANGED':
        if (this.mounted) setState(() {});
        break;
    }
  }
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new WebsocketClient(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
            title: 'Geopoint Squad',
            theme: ThemeData(
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
        }));
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
          return new LoginPage();
      }
    }));
  }
}
