import 'package:flutter/material.dart';
import '../main.dart';
import 'package:geosquad/components/websocket_client.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  String _username;
  String _mail;
  String _speed;
  String _distance;

  void didChangeDependencies() {
    this._username = WebsocketClient.of(context).username;
    WebsocketClient.of(context).getUserInfo(this._username).then(
        (ServerResponse response) {
          print(response.data['email']);
          if (response.status){
            this._mail = response.data['email'];
            this._speed = response.data[1];
            this._distance = response.data[2];
          }
          else {
            print("huy");
          }
        }
    );
    super.didChangeDependencies();
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
          "Profile",
          style: new TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: new ListView(
        children: <Widget>[
          new Stack(
            //alignment: Alignment.center,
            children: <Widget>[
              new Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width,
                color: Colors.blue,
                child: new Padding(
                  padding: new EdgeInsets.all(25.0),
                  child: new Container(
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      border: new Border.all(
                        color: Colors.white,
                      ),
                    ),
                    child: new ClipOval(
                      child: new Image.asset(""),
                    ),
                  ),
                ),
              ),
            ],
          ),
          new Container(
            padding: EdgeInsets.all(15.0),
            height: MediaQuery.of(context).size.height * 0.07,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  '${this._mail}',
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                new FlatButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    WebsocketClient.of(context).logOut();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: new Row(
                    children: <Widget>[
                      new Text("LOG OUT",
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,

                          )),
                      new Padding(
                        padding: EdgeInsets.all(2.0),
                      ),
                      new Icon(
                        Icons.arrow_forward_ios,
                        size: 15.5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.all(15.0),
            alignment: Alignment.centerLeft,
            height: MediaQuery.of(context).size.height * 0.07,
            color: Colors.black,
            child: new Row(
              children: <Widget>[
                new Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
                new Padding(
                  padding: EdgeInsets.only(left: 10.0),
                ),
                new Text("ABOUT ME",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.all(15.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text("NICKNAME",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0)),
                new Text('$_username'),
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.all(15.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text("AVERAGE SPEED",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0)),
                new Text('$_speed'),
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.all(15.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text("DISTANCE TRAVELED",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0)),
                new Text('$_distance'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
