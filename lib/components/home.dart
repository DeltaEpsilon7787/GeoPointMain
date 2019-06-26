import 'package:flutter/material.dart';
import 'package:geosquad/components/websocket_client.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          onPressed: () {
            Navigator.of(context)..pop();
          },
          icon: new Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
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
                  '${WebsocketClient.of(context).email}',
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
                new Text("${WebsocketClient.of(context).username}"),
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
                // Future Builder используй для этих двух контейнеров
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
                // Future Builder используй для этих двух контейнеров
              ],
            ),
          ),
        ],
      ),
    );
  }
}
