import 'package:flutter/material.dart';

class Settings extends StatefulWidget{
  @override
  _Settings createState() => new _Settings();
}

class _Settings extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          onPressed: () {
            Navigator.of(this.context)
                .pushReplacementNamed('/map');
          },
          icon: new Icon(Icons.arrow_back_ios, color: Colors.black,),
        ),
        title: new Text(
          "Settings",
          style: new TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
    );
  }
}