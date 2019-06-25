import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geosquad/components/websocket_client.dart';
import 'package:geosquad/components/friends_list.dart';
import 'package:geosquad/components/friends_request.dart';

import '../main.dart';

class FriendsPage extends StatefulWidget {
  @override
  FriendsState createState() => new FriendsState();
}

class FriendsState extends State<FriendsPage> with SingleTickerProviderStateMixin{
  final _addFriend = TextEditingController();
  TabController _tabController;

  @override
  void initState(){
    super.initState();
    _tabController = new TabController(vsync: this, initialIndex: 0, length: 2);
  }

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
          "Friends",
          style: new TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: new TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          tabs: <Widget>[
            new Tab(text: "Friends"),
            new Tab(text: "Friend requests")
          ],
        ),
      ),
      body: new TabBarView(
        controller: _tabController,
        children: <Widget>[
          new FriendsListPage(),
          new FriendsRequestPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person_add),
          backgroundColor: Colors.green,
          onPressed: () {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    title: new Text("Add to friends",
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    content: new TextFormField(
                      controller: _addFriend,
                      decoration: new InputDecoration(
                          labelText: "Enter friend\'s login"),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text('Add'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          WebsocketClient.of(context)
                              .socketClient
                              .sendFriendsRequest(this._addFriend.text)
                              .then(
                            (ServerResponse response) {
                              if (response.status) {
                                return showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return new AlertDialog(
                                      title: new Text("Add to friends",
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      content:
                                          new Text("Request successfully sent"),
                                      actions: <Widget>[
                                        new FlatButton(
                                          child: new Text("OK"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                return showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return new AlertDialog(
                                      title: new Text("An error occurred",
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      content: new Text(response.code),
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
                            },
                          );
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
          }),
    );
  }

  Future<List> _listFriends() async {
    return WebsocketClient.of(context)
        .socketClient
        .getMyFriends()
        .then((ServerResponse response) {
      return response.data as List;
    });
  }
}
