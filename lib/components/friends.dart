import 'package:flutter/material.dart';

class Friends extends StatefulWidget{
  @override
  _Friends createState() => new _Friends();
}

class _Friends extends State<Friends> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new ListView(
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Divider(height: 10.0,),
              new ListTile(
                leading: new CircleAvatar(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.blue,
                ),
                title: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text("GooDRandall", style: new TextStyle(fontWeight: FontWeight.bold),),
                    new Row(
                      children: <Widget>[
                        new CircleAvatar(backgroundColor: Colors.yellow,),
                        new Padding(
                          padding: EdgeInsets.only(left: 15.0),
                        ),
                        new IconButton(icon: new Icon(Icons.block), onPressed: () {}, iconSize: 32.0,),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}