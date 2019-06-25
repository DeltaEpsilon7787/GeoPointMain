import 'dart:async';

import 'package:flutter/material.dart';
import '../main.dart';
import 'package:geosquad/components/websocket_client.dart';

class FriendsPage extends StatefulWidget {
  @override
  FriendsState createState() => new FriendsState();
}

class FriendsState extends State<FriendsPage> {
  Future<List<String>> _listFriends() async {
    return App.socketClient.getMyFriends().then((ServerResponse response) {
      return response.data as List<String>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new SingleChildScrollView(
        child: FutureBuilder(
          initialData: new Center(child: CircularProgressIndicator()),
          future: _listFriends(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return new Container(
                child: new ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return new ListTile(
                      leading: new CircleAvatar(
                        backgroundColor: Colors.blue,
                      ),
                      title: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(snapshot.data[index],
                              style:
                                  new TextStyle(fontWeight: FontWeight.bold)),
                          new Row(
                            children: <Widget>[
                              new CircleAvatar(
                                backgroundColor: Colors.yellow,
                              ),
                              new Padding(
                                padding: EdgeInsets.only(left: 15.0),
                              ),
                              new IconButton(
                                icon: new Icon(Icons.block),
                                onPressed: () {},
                                iconSize: 32.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: new Text("huy"),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        backgroundColor: Colors.green,
        onPressed: () {},
      ),
    );
  }
}
