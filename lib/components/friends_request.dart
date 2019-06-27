import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geosquad/components/websocket_client.dart';

class FriendRequest extends StatelessWidget {
  final String friendName;
  const FriendRequest({Key key, this.friendName}) : super(key: key);

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
              new IconButton(
                icon: new Icon(Icons.check),
                iconSize: 32.0,
                onPressed: () {
                  WebsocketClient.of(context).acceptFriendRequest(this.friendName);
                },
              ),
              new IconButton(
                  icon: new Icon(Icons.block),
                  iconSize: 32.0,
                  onPressed: () {
                    WebsocketClient.of(context).declineFriendRequest(this.friendName);
                  }),
            ],
          ),
        ],
      ),
    );
  }
}

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
        return response.data as List;
      } catch (Exception) {
        return [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: WebsocketClient.of(context).serverBroadcast.stream.where(
            (response) => ['FRIEND_REQUEST_LIST_CHANGED', 'FRIEND_REQUEST'].contains(response.code)),
        builder: (context, snapshot) => SingleChildScrollView(
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
                              itemBuilder: (context, index) => FriendRequest(
                                  friendName: snapshot.data[index]),
                            ),
                          );
                        }
                        break;

                      default:
                        return new CircularProgressIndicator();
                    }
                  }),
            ));
  }
}
