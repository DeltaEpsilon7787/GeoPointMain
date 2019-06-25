import 'package:flutter/material.dart';
import '../main.dart';
import 'package:geosquad/components/websocket_client.dart';

class FriendsPage extends StatefulWidget {
  @override
  FriendsState createState() => new FriendsState();
}

class FriendsState extends State<FriendsPage> {
  bool _isProgressBarShown = false;
  List<String> _listFriends;

  @override
  void initState() {
    super.initState();

    App.socketClient.getMyFriends().then((ServerResponse response) {
      this._listFriends = response.data as List<String>;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this._isProgressBarShown) {
      return new Center(child: CircularProgressIndicator());
    }

    return new Scaffold(
      body: new ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(0.0),
          itemCount: _listFriends.length,
          itemBuilder: (context, index) {
            return new ListTile(
              leading: new CircleAvatar(
                backgroundColor: Colors.blue,
              ),
              title: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(_listFriends[index],
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
                        onPressed: () {},
                        iconSize: 32.0,
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: new Text("huy"),
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        backgroundColor: Colors.green,
        onPressed: () {},
      ),
    );
  }
}