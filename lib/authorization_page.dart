import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context){
    return new Scaffold(
      bottomNavigationBar: new BottomAppBar(
        child: new Text("hut"),
      ),
      body: new Center(
        child: new Container(
          height: 200.0,
          color: Colors.black,
        ),
      ),
    );
  }
}