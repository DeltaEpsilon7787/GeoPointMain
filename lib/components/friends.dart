import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'model/FriendsModel.dart';
import '../main.dart';
import 'package:geosquad/components/websocket_client.dart';

class FriendsPage extends StatefulWidget {
  FriendsPage({Key key}) : super(key: key);

  @override
  FriendsState createState() => new FriendsState();
}

class FriendsState extends State<FriendsPage> {

  bool _isProgressBarShown = true;
  List<FriendsModel> _listFriends;

  @override
  void initState() {
    super.initState();

    App.socketClient.getMyFriends().then(
            (ServerResponse response) {
          this._listFriends = response.data;
        }
    );

    _fetchFriendsList();
  }

  @override
  Widget build(BuildContext context) {

    Widget widget;

    if(_isProgressBarShown) {
      widget = new Center(
          child: new Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: new CircularProgressIndicator()
          )
      );
    }else {
      //TODO: search how to stop ListView going infinite list
      widget =  new ListView.builder(
          shrinkWrap:true,
          padding: const EdgeInsets.all(0.0),
          itemCount: _listFriends.length,
          itemBuilder: (context, i) {
            return _buildRow(_listFriends[i]);
          }
      );
    }

    return new Scaffold(
      body: widget,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person_add),
          backgroundColor: Colors.green,
          onPressed: (){},),
    );
  }

  Widget _buildRow(FriendsModel friendsModel) {

    return new ListTile(

      leading: new CircleAvatar(
        backgroundColor: Colors.blue,
        backgroundImage: new NetworkImage(friendsModel.profileImageUrl),
      ),
      title: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(friendsModel.name, style: new TextStyle(fontWeight: FontWeight.bold),),
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
      subtitle: new Text(friendsModel.email),

      onTap: () {
        setState(() {
        });
      },
    );
  }

  _fetchFriendsList() async {

    _isProgressBarShown = true;
    //var url = 'https://api.myjson.com/bins/12llbh';

    //var httpClient = new HttpClient();

    List<FriendsModel> listFriends = new List<FriendsModel>();
    try {

      var data = _listFriends;
      //var request = await httpClient.getUrl(Uri.parse(url));
      //var response = await request.close();
      //var json = await response.transform(utf8.decoder).join();
      //var data = jsonDecode(json);
      for (var res in data['results']) {
        var objName = res['name'];
        String name = objName['first'].toString() + " " +objName['last'].toString();

        var objImage = res['picture'];
        String profileUrl = objImage['large'].toString();

        FriendsModel friendsModel = new FriendsModel(name, res['email'], profileUrl);
        listFriends.add(friendsModel);
      }

    } catch (exception) {
      print(exception.toString());
    }

    if (!mounted) return;

    setState(() {
      _listFriends = listFriends;
      _isProgressBarShown = false;
    });

  }
}