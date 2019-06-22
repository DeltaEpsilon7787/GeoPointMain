import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();

  String _username;
  String _password;

  @override
  Widget build(BuildContext context) {
    if (App.socketClient.acquiringSession) {
      return new Center(child: CircularProgressIndicator());
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
                initialValue: this._username ?? "",
                autovalidate: true,
                onSaved: (String value) => this._username = value),
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
                  App.socketClient
                      .tryToAuth(
                          username: this._username, password: this._password)
                      .then((bool status) {
                    if (status) {
                      this._saveCredentials(this._username, this._password);
                      Navigator.of(this.context).pushReplacementNamed('/map');
                    } else {
                      Scaffold.of(this.context).showSnackBar(
                          SnackBar(content: Text('Invalid login or password')));
                    }
                  });
                }
              },
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
