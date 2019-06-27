import 'dart:async';

import 'package:flutter/material.dart';
import './websocket_client.dart';

class ServerNotifier extends StatelessWidget {
  final Widget child;

  ServerNotifier({@required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ServerResponse>(
        stream: WebsocketClient.of(context).serverBroadcast.stream.where(
            (ServerResponse response) =>
                ['FRIEND_REQUEST', 'NEED_AUTH'].contains(response.code)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.code == 'FRIEND_REQUEST') {
              Future.delayed(Duration.zero).then((_) => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Friend request'),
                        content: Text(
                            '${snapshot.data.data} wants to add you as a friend...'),
                        actions: <Widget>[
                          FlatButton(
                              child: Text('Accept'),
                              onPressed: () {
                                WebsocketClient.of(context)
                                    .acceptFriendRequest(snapshot.data.data);
                                Navigator.of(context).pop();
                              }),
                          FlatButton(
                              child: Text('Decline'),
                              onPressed: () {
                                WebsocketClient.of(context)
                                    .declineFriendRequest(snapshot.data.data);
                                Navigator.of(context).pop();
                              }),
                        ],
                      )));
            }
            if (snapshot.data.code == 'NEED_AUTH') {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          }
          return this.child;
        });
  }
}
