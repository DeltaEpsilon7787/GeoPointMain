import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './websocket_client.dart';

var _loginFormKey = GlobalKey<FormState>();

class LoginPage extends StatelessWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _username;
    String _password;

    return new Scaffold(
      bottomNavigationBar: new BottomAppBar(
        color: Colors.white,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text("No account?"),
            new FlatButton(
              padding:
                  EdgeInsets.only(left: 2.0, top: 0.0, right: 0.0, bottom: 0.0),
              child: new Text(
                "Sign up now",
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/auth/register');
              },
              splashColor: Colors.white,
              highlightColor: Colors.white,
            ),
          ],
        ),
      ),
      body: new Center(
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            new Container(
              child: new Text(
                "CATFISH-GEO",
                textAlign: TextAlign.center,
                style: new TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.05,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Times new roman',
                ),
              ),
            ),
            new Container(
              child: new Padding(
                padding: const EdgeInsets.all(28.0),
                child: new Center(
                  child: new Form(
                    key: _loginFormKey,
                    child: new Center(
                      child: new ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          new TextFormField(
                            decoration: new InputDecoration(labelText: "Login"),
                            validator: (value) =>
                                value.length < 4 || value.length > 20
                                    ? "Login is incorrect"
                                    : null,
                            initialValue: _username ?? "",
                            autovalidate: true,
                            onSaved: (String value) => _username = value,
                          ),
                          new TextFormField(
                            decoration:
                                new InputDecoration(labelText: "Password"),
                            validator: (value) =>
                                value.length <= 4 ? "Password too short" : null,
                            autovalidate: true,
                            obscureText: true,
                            onSaved: (String value) => _password =
                                sha256.convert(utf8.encode(value)).toString(),
                          ),
                          new Padding(
                            padding: EdgeInsets.only(top: 20.0),
                          ),
                          new RaisedButton(
                            color: new Color.fromARGB(80, 255, 255, 255),
                            child: new Text("Sign in",
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              if (_loginFormKey.currentState.validate()) {
                                _loginFormKey.currentState.save();
                                WebsocketClient.of(context)
                                    .tryToAuth(
                                        username: _username,
                                        password: _password)
                                    .then((bool status) {
                                  Navigator.of(context).pop();
                                  if (status) {
                                    this._saveCredentials(_username, _password);
                                    Navigator.of(context)
                                        .pushReplacementNamed('/map');
                                  } else {
                                    return showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return new AlertDialog(
                                          title: new Text("An error occurred",
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          content: new Text(
                                              'Invalid login or password'),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                });
                                Navigator.of(context).pushNamed('/loading');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('username', username);
    prefs.setString('password', password);
  }
}

/*
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (WebsocketClient.of(context).acquiringSession) {
      // Could've used a stream for session status, but meh
      Timer.periodic(Duration(milliseconds: 100), (Timer that) {
        if (!WebsocketClient.of(context).acquiringSession) {
          that.cancel();
          setState(() {});
        }
      });
      return new Center(child: CircularProgressIndicator());
    }

    String _username;
    String _password;

    return new Scaffold(
      bottomNavigationBar: new BottomAppBar(
        color: Colors.white,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text("No account?"),
            new FlatButton(
              padding:
                  EdgeInsets.only(left: 2.0, top: 0.0, right: 0.0, bottom: 0.0),
              child: new Text(
                "Sign up now",
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(this.context).pushReplacementNamed('/auth');
              },
              splashColor: Colors.white,
              highlightColor: Colors.white,
            ),
          ],
        ),
      ),
      body: new Center(
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            new Container(
              child: new Text(
                "CATFISH-GEO",
                textAlign: TextAlign.center,
                style: new TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.05,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Times new roman',
                ),
              ),
            ),
            new Container(
              child: new Padding(
                padding: const EdgeInsets.all(28.0),
                child: new Center(
                  child: new Form(
                    key: formKey,
                    child: new Center(
                      child: new ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          new TextFormField(
                            decoration: new InputDecoration(labelText: "Login"),
                            validator: (value) =>
                                value.length < 4 || value.length > 20
                                    ? "Login is incorrect"
                                    : null,
                            initialValue: _username ?? "",
                            autovalidate: true,
                            onSaved: (String value) => _username = value,
                          ),
                          new TextFormField(
                            decoration:
                                new InputDecoration(labelText: "Password"),
                            validator: (value) =>
                                value.length <= 4 ? "Password too short" : null,
                            autovalidate: true,
                            obscureText: true,
                            onSaved: (String value) => _password =
                                sha256.convert(utf8.encode(value)).toString(),
                          ),
                          new Padding(
                            padding: EdgeInsets.only(top: 20.0),
                          ),
                          new RaisedButton(
                            color: new Color.fromARGB(80, 255, 255, 255),
                            child: new Text("Sign in",
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              if (this.formKey.currentState.validate()) {
                                this.formKey.currentState.save();
                                WebsocketClient.of(context)
                                    .tryToAuth(
                                        username: _username,
                                        password: _password)
                                    .then((bool status) {
                                  if (status) {
                                    this._saveCredentials(_username, _password);
                                    Navigator.of(this.context)
                                        .pushReplacementNamed('/map');
                                  } else {
                                    return showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return new AlertDialog(
                                          title: new Text("An error occurred",
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          content: new Text(
                                              'Invalid login or password'),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('username', username);
    prefs.setString('password', password);
  }
}
*/
