import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _automaticLogin = false;
  bool _waitingForResponse = false;

  final formKey = new GlobalKey<FormState>();

  String _username;
  String _password;

  void initState() {
    super.initState();
    App.socketClient.addListener('auth', this.loginResponse);
    this._waitingForResponse = true;
    this.injectPersistent().whenComplete(() {
      setState(() {
        _waitingForResponse = false;
      });
    });
  }

  void storePersistent(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(key, value);
  }

  Future<String> getPersistent(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  void loginResponse(String status, String reason, dynamic data) {
    setState(() {
      this._waitingForResponse = false;
    });

    if (status == 'success') {
      App.socketClient.setSessionId(data['session_id']);
      this.storePersistent('username', this._username);
      this.storePersistent('password', this._password);
    } else {
      if (this._automaticLogin) {
        this.storePersistent('password', null);
        setState(() {
          this._automaticLogin = false;
          _password = null;
        });
      }
      Scaffold.of(context).showSnackBar(new SnackBar(content: Text(reason)));
    }

    if (status == 'success') {
      Navigator.of(context).pushNamed('/map').then((_) {
        if (!this._automaticLogin) {
          Scaffold.of(context)
              .showSnackBar(new SnackBar(content: Text(reason)));
        }
      });
    }
  }

  void tryToLogin(String username, String password) {
    setState(() {
      this._waitingForResponse = true;
    });
    App.socketClient.attemptLogin(username, password);
  }

  Future injectPersistent() async {
    await this.getPersistent('username').then((value) {
      this._username = value;
    }).whenComplete(() {
      this.getPersistent('password').then((value) {
        this._password = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_automaticLogin || _waitingForResponse) {
      return new Center(child: CircularProgressIndicator());
    }

    if (_password != null) {
      setState(() {
        this._automaticLogin = true;
      });
      this.tryToLogin(_username, _password);
    }

    return new Container(
      padding: new EdgeInsets.all(20.0),
      child: new Form(
        key: formKey,
        child: new Column(
          children: <Widget>[
            new TextFormField(
                decoration: new InputDecoration(labelText: "Login"),
                validator: (value) => value.length < 4 || value.length > 20
                    ? "Login is incorrect"
                    : null,
                initialValue: _username ?? "",
                autovalidate: true,
                onSaved: (String value) => _username = value),
            new TextFormField(
              decoration: new InputDecoration(labelText: "Password"),
              validator: (value) =>
                  value.length <= 4 ? "Password too short" : null,
              autovalidate: true,
              obscureText: true,
              onSaved: (String value) =>
                  _password = sha256.convert(utf8.encode(value)).toString(),
            ),
            new RaisedButton(
              color: new Color(0xff75bbfd),
              child: new Text("Register"),
              onPressed: () {
                Navigator.of(context).pushNamed('/auth');
              },
            ),
            new Padding(
              padding: new EdgeInsets.only(top: 20.0),
            ),
            new RaisedButton(
              color: new Color(0xff75bbfd),
              child: new Text(
                "Sign in",
              ),
              onPressed: () {
                if (this.formKey.currentState.validate()) {
                  this.formKey.currentState.save();
                  this.storePersistent('username', this._username);
                  this.storePersistent('password', this._password);
                  this.tryToLogin(this._username, this._password);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
