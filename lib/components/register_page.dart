import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
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

  void initState() {
    super.initState();
    //huy huy huy huy
  }

  void tryToRegister(String username, String password, String email) {
    setState(() {
      this._waitingForResponse = true;
    });
    App.socketClient.attemptRegister(username, password, email);
  }

  @override
  Widget build(BuildContext context) {
    if (this._waitingForResponse) {
      return new Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: new EdgeInsets.all(20.0),
      child: new SingleChildScrollView(
        child: new Form(
          child: new Column(
            children: <Widget>[
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
                    this.tryToRegister(this._username, this._password, this._email);
                  }
                },
              ),
            ],
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