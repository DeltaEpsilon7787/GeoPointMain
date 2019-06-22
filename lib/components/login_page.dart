import 'package:flutter/material.dart';
import '../main.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';


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

    return new Scaffold(
      bottomNavigationBar: new BottomAppBar(
        color: Colors.white,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text("No account?"),
            new FlatButton(
              padding: EdgeInsets.only(
                  left: 2.0, top: 0.0, right: 0.0, bottom: 0.0),
              child: new Text("Sign up now",
                style: new TextStyle(fontWeight: FontWeight.bold),),
              onPressed: () {
                Navigator.of(this.context)
                    .pushReplacementNamed('/auth');
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
                  fontSize: MediaQuery
                      .of(context)
                      .size
                      .height * 0.07,
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
                            initialValue: this._username ?? "",
                            autovalidate: true,
                            onSaved: (String value) => this._username = value,
                          ),
                          new TextFormField(
                            decoration: new InputDecoration(
                                labelText: "Password"),
                            validator: (value) =>
                            value.length <= 4 ? "Password too short" : null,
                            autovalidate: true,
                            obscureText: true,
                            onSaved: (String value) =>
                            _password =
                                sha256.convert(utf8.encode(value)).toString(),
                          ),
                          new Padding(
                            padding: EdgeInsets.only(top: 20.0),
                          ),
                          new RaisedButton(
                            color: new Color.fromARGB(80, 255, 255, 255),

                            child: new Text("Sign in", style: new TextStyle(
                                fontWeight: FontWeight.bold)),
                            onPressed: () {
                              if (this.formKey.currentState.validate()) {
                                this.formKey.currentState.save();
                                App.socketClient
                                    .tryToAuth(
                                    username: this._username,
                                    password: this._password)
                                    .then((bool status) {
                                  if (status) {
                                    this._saveCredentials(
                                        this._username, this._password);
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
                                          content: new Text('Invalid login or password'),
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