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
                                  new CircleAvatar(
                                    backgroundColor: Colors.yellow,
                                  ),
                                  new Padding(
                                    padding: EdgeInsets.only(left: 15.0),
                                  ),
                                  new IconButton(
                                    icon: new Icon(Icons.block),
                                    iconSize: 32.0,
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
