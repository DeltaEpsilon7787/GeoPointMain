import 'package:flutter/material.dart';
import '../main.dart';
import 'websocket_client.dart';

class FriendsPage extends StatefulWidget{
  @override
  _FriendsPage createState() => new _FriendsPage();
}

class _FriendsPage extends State<FriendsPage> {

  List list = new List();

  void initState() {
    super.initState();

    App.socketClient.getMyFriends().then(
        (ServerResponse response) {
            this.list = response.data;
        }
    );
  }


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