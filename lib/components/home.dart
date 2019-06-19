import 'package:flutter/material.dart';

class Home extends StatefulWidget{
  @override
  _Home createState() => new _Home();
}

class _Home extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new ListView(
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
                      child: new Image.asset("assets/profile.png"),
                    ),
                  ),
                ),
              ),
            ],
          ),
          new Container(
            padding: EdgeInsets.all(15.0),
            height: MediaQuery.of(context).size.height * 0.1,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  "barsik@gmail.com",
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                new FlatButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {},
                  child: new Row(
                    children: <Widget>[
                      new Text( "LOG OUT", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0,)),
                      new Padding(padding: EdgeInsets.all(2.0),),
                      new Icon(Icons.arrow_forward_ios, size: 15.5,),
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
                new Icon(Icons.account_circle, color: Colors.white,),
                new Padding(padding: EdgeInsets.only(left: 10.0),),
                new Text("ABOUT ME", style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.all(15.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text("NICKNAME", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                new Text("Barsik"),
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.all(15.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text("AVERAGE SPEED", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                new Text("100"),
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.all(15.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text("DISTANCE TRAVELED", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                new Text("10000"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}