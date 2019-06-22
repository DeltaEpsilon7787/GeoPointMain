import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'websocket_client.dart';
import '../main.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _waitingForResponse = false;

  final _passController = TextEditingController();
  final formKey = new GlobalKey<FormState>();

  String _username;
  String _email;
  String _password;
  String _key;

  void initState() {
    super.initState();
    this._waitingForResponse = false;
  }

  @override
  Widget build(BuildContext context) {
    if (this._waitingForResponse) {
      return new Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      bottomNavigationBar: new BottomAppBar(
        color: Colors.white,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text("Have account?"),
            new FlatButton(
              padding: EdgeInsets.only(
                  left: 2.0, top: 0.0, right: 0.0, bottom: 0.0),
              child: new Text("Sign in now",
                style: new TextStyle(fontWeight: FontWeight.bold),),
              onPressed: () {
                Navigator.of(this.context)
                    .pushReplacementNamed('/login');
              },
              splashColor: Colors.white,
              highlightColor: Colors.white,
            ),
          ],
        ),
      ),
      body: Container(
        padding: new EdgeInsets.all(20.0),
        child: new SingleChildScrollView(
          child: new Form(
            key: this.formKey,
            child: new Column(
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
                new TextFormField(
                  decoration: new InputDecoration(labelText: "Login"),
                  validator: (value) => value.length < 4 || value.length > 20 ? "Login is incorrect" : null,
                  autovalidate: true,
                  onSaved: (String value) =>
                      this._username = value,
                ),
                new TextFormField(
                  decoration: new InputDecoration(labelText: "E-mail"),
                  validator: validateEmail,
                  autovalidate: true,
                  onSaved: (String value) =>
                      this._email = value,
                ),
                new TextFormField(
                  controller: _passController,
                  decoration: new InputDecoration(labelText: "Password"),
                  validator: (value) => value.length < 4 ? "Password too short" : null,
                  obscureText: true,
                  autovalidate: true,
                  onSaved: (String value) =>
                      this._password = sha256.convert(utf8.encode(value)).toString(),
                ),
                new TextFormField(
                  decoration: new InputDecoration(labelText: "Repeat password"),
                  validator: (value) => value != _passController.text ? "Incorrect password" : null,
                  obscureText: true,
                  autovalidate: true,
                ),
                new Padding(
                  padding: new EdgeInsets.only(top: 20.0),
                ),
                new RaisedButton(
                  color: new Color(0xff75bbfd),
                  child: new Text(
                    "Registrate",
                  ),
                  onPressed: () {
                    if (this.formKey.currentState.validate()) {
                      this.formKey.currentState.save();
                      App.socketClient.attemptRegister(this._username, this._password, this._email).then(
                          (ServerResponse response) {
                            return new Container(
                              padding: new EdgeInsets.all(20.0),
                              child: new SingleChildScrollView(
                                child: new Column(
                                  children: <Widget>[
                                    new TextFormField(
                                      decoration: new InputDecoration(labelText: "Enter a key"),
                                      onSaved: (String value) =>
                                        this._key = value,
                                    ),
                                    new Padding(padding: EdgeInsets.all(5.0)),
                                    new RaisedButton(
                                      color: new Color(0xff75bbfd),
                                      child: new Text(
                                        "Confirm",
                                      ),
                                      onPressed: () {
                                        App.socketClient.attemptActivation(this._key).then(
                                            (ServerResponse response) {
                                              Navigator.of(this.context)
                                                  .pushReplacementNamed('/login');
                                            },
                                         onError: (ServerResponse response) {
                                           Scaffold.of(this.context).showSnackBar(
                                             SnackBar(content: Text(
                                                 'Invalid login or password')
                                             ),
                                           );
                                         }
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          onError: (ServerResponse response) {
                            Scaffold.of(context).showSnackBar(new SnackBar(
                                content: Text(response.data)));
                          },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String validateEmail(String value) {
  Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return "Enter Valid Email";
  else
    return null;
}