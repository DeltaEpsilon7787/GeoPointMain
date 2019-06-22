import 'package:flutter/material.dart';
import 'websocket_client.dart';
import '../main.dart';

class ValidatePage extends StatefulWidget {
  @override
  _ValidatePageState createState() => _ValidatePageState();
}

class _ValidatePageState extends State<ValidatePage> {
  String _key;

  final formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Form(
          key: formKey,
          child: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                new TextFormField(
                  decoration: new InputDecoration(labelText: "Enter a key"),
                  onSaved: (String value) => this._key = value,
                ),
                new Padding(padding: EdgeInsets.all(5.0)),
                new RaisedButton(
                  color: new Color(0xff75bbfd),
                  child: new Text(
                    "Confirm",
                  ),
                  onPressed: () {
                    if (this.formKey.currentState.validate()) {
                      this.formKey.currentState.save();
                      App.socketClient
                          .attemptActivation(this._key)
                          .then((ServerResponse response) {
                        if (response.code == "GENERIC_SUCCESS") {
                          Navigator.of(this.context)
                              .pushReplacementNamed('/login');
                        } else {
                          Scaffold.of(this.context).showSnackBar(
                            SnackBar(content: Text('Invalid key')),
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