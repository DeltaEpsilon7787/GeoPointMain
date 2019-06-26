import 'package:flutter/material.dart';
import 'websocket_client.dart';
import '../main.dart';

var _validateFormKey = new GlobalKey<FormState>();

class ValidatePage extends StatelessWidget {
  const ValidatePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _key;
    return Scaffold(
      body: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Form(
          key: _validateFormKey,
          child: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                new TextFormField(
                  decoration: new InputDecoration(labelText: "Enter a key"),
                  onSaved: (String value) => _key = value,
                ),
                new Padding(padding: EdgeInsets.all(5.0)),
                new RaisedButton(
                  color: new Color(0xff75bbfd),
                  child: new Text(
                    "Confirm",
                  ),
                  onPressed: () {
                    if (_validateFormKey.currentState.validate()) {
                      _validateFormKey.currentState.save();
                      WebsocketClient.of(context)
                          .attemptActivation(_key)
                          .then((ServerResponse response) {
                        if (response.status) {
                          Navigator.of(context)..pop()..pop();
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
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
