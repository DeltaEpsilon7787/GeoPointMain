import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geosquad/components/websocket_client.dart';
import 'package:geosquad/components/friends_list.dart';
import 'package:geosquad/components/friends_request.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
            leading: new IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: new Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
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
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: <Widget>[
                new Tab(text: "Friends"),
                new Tab(text: "Friend requests")
              ],
            ),
          ),
          body: new TabBarView(
            children: <Widget>[
              new FriendsListPage(),
              new FriendsRequestPage(),
            ],
          ),
          floatingActionButton: new AddFriendButton(),
        ));
  }
}

final _friendRequestKey = GlobalKey<FormState>();

class AddFriendButton extends StatelessWidget {
  const AddFriendButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String friendLogin;
    return FloatingActionButton(
        child: Icon(Icons.person_add),
        backgroundColor: Colors.green,
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return new AlertDialog(
                  title: new Text("Add to friends",
                      style: new TextStyle(fontWeight: FontWeight.bold)),
                  content: new Form(
                      key: _friendRequestKey,
                      child: new TextFormField(
                          decoration: new InputDecoration(
                              labelText: "Enter friend\'s login"),
                          onSaved: (String value) => friendLogin = value)),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text('Add'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _friendRequestKey.currentState.save();
                        WebsocketClient.of(context)
                            .sendFriendsRequest(friendLogin)
                            .then((ServerResponse response) {
                          if (response.status) {
                            showDialog(
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
                            showDialog(
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
                        });
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
        });
  }
}
