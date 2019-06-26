import 'dart:async';

import 'package:flutter/material.dart';
import '../main.dart';
import 'package:geosquad/components/websocket_client.dart';

class FriendsRequestPage extends StatefulWidget {
  @override
  _FriendsRequestState createState() => new _FriendsRequestState();
}

class _FriendsRequestState extends State<FriendsRequestPage> {
  Future<List> _listRequest() async {
    return WebsocketClient.of(context)
        .getFriendRequests()
        .then((ServerResponse response) {
      try {
        print(response.data.length);
        return response.data as List;
      } catch (Exception) {
        return [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: FutureBuilder<List>(
          future: _listRequest(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Container(
                  child: new Center(
                    child: new Text("LOADING..."),
                  ),
                );

              case ConnectionState.active:
                return new Container(
                  child: new Center(
                    child: new Text("ACTIVE"),
                  ),
                );

              case ConnectionState.none:
                return new Container(
                  child: new Center(
                    child: new Text("NONE"),
                  ),
                );

              case ConnectionState.done:
                if (snapshot.hasError) {
                  return new Container(
                    child: new Center(
                      child: new Text("ERROR"),
                    ),
                  );
                } else {
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
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold)),
                              new Row(
                                children: <Widget>[
                                  new IconButton(
                                      icon: new Icon(Icons.check),
                                      iconSize: 32.0,
                                      onPressed: () {

                                      },
                                  ),
                                  new IconButton(
                                    icon: new Icon(Icons.block),
                                    iconSize: 32.0,
<<<<<<< HEAD
                                    onPressed: () {}
=======
                                    onPressed: () {

                                    },
>>>>>>> 6d010d20e6b680731d567b815ee00c0df69a589d
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
            }
          }),
    );
  }
}
