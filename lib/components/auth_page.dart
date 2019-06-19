import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class Authentication extends StatefulWidget{
  @override
  _AuthenticationState createState() => new _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> with SingleTickerProviderStateMixin{

  TabController _tabController;

  @override
  void initState(){
    super.initState();
    _tabController = new TabController(vsync: this, initialIndex: 0, length: 2);
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios),
          onPressed: () {},
        ),
        title: new Text("Sign in/Sign up"),
        elevation: 0.7,
        bottom: new TabBar(
          controller: this._tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            new Tab(
              text: "Authorization",
            ),
            new Tab(text: "Registration")
          ],
        ),
      ),
      body: new TabBarView(
        controller: this._tabController,
        children: <Widget>[
          new LoginPage(),
          new RegisterPage(),
        ],
      ),
    );
  }
}