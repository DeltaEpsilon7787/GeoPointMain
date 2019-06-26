import 'dart:async';

import 'package:flutter/material.dart';
import '../main.dart';
import 'package:geosquad/components/websocket_client.dart';

class FriendListRow extends StatelessWidget {
  final String friendName;
  const FriendListRow({Key key, this.friendName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: new CircleAvatar(
        backgroundColor: Colors.blue,
      ),
      title: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(friendName,
              style: new TextStyle(fontWeight: FontWeight.bold)),
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
                onPressed: () {
                  return showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return new AlertDialog(
                          title: new Text("Delete friend",
                              style:
                                  new TextStyle(fontWeight: FontWeight.bold)),
                          content: new Text(
                              "Are you sure you want to remove $friendName from your friends?"),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("Yes"),
                              onPressed: () {
                                WebsocketClient.of(context)
                                    .deleteFriend(friendName);
                                Navigator.of(context).pop();
                              },
                            ),
                            new FlatButton(
                              child: new Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                },
                iconSize: 32.0,
              ),
            ],
          ),
        ],
      ),
      subtitle: new Text("huy"),
    );
  }
}

class FriendsListPage extends StatefulWidget {
  @override
  _FriendsListState createState() => new _FriendsListState();
}

class _FriendsListState extends State<FriendsListPage> {
  Future<List> _listFriends() async {
    return WebsocketClient.of(context)
        .getMyFriends()
        .then((ServerResponse response) {
      return response.data as List;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WebsocketFriendChangeListener(
        context: context,
        child: SingleChildScrollView(
          child: FutureBuilder<List>(
              future: _listFriends(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Container(
                      child: new Center(
                        child: new Text("LOADING..."),
                      ),
                    );

                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return new Container(
                        child: new Center(
                          child: new Text("ERROR"),
                        ),
                      );
                    }
                    return new Container(
                      child: new ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) =>
                              FriendListRow(friendName: snapshot.data[index])),
                    );
                  default:
                    return null;
                }
              }),
        ));
  }
}
