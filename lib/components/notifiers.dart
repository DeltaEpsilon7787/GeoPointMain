import 'package:flutter/material.dart';
import './websocket_client.dart';

class ServerNotifier extends StatelessWidget {
  final BuildContext context;
  final Widget child;

  ServerNotifier({@required this.context, @required this.child}) {
    WebsocketClient.of(context)
        .serverBroadcast
        .stream
        .listen(_processServerBroadcast);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) => this.child);
  }

  void _needAuth() {
    Navigator.of(this.context).pushReplacementNamed('/login');
  }

  void _processFriendRequest(String data) {
    showDialog(
        context: this.context,
        builder: (context) {
          return AlertDialog(
            title: Text('Friend request'),
            content: Text('$data wants to add you as a friend...'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Accept'),
                  onPressed: () {
                    WebsocketClient.of(context).acceptFriendRequest(data);
                    Navigator.of(context).pop();
                  }),
              FlatButton(
                  child: Text('Decline'),
                  onPressed: () {
                    WebsocketClient.of(context).declineFriendRequest(data);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  void _processServerBroadcast(ServerResponse broadcast) {
    switch (broadcast.code) {
      case 'NEED_AUTH':
        this._needAuth();
        break;
      case 'FRIEND_REQUEST':
        this._processFriendRequest(broadcast.data);
        break;
    }
  }
}

class FriendNotifierWrapper extends StatefulWidget {
  final BuildContext context;
  final Widget child;

  FriendNotifierWrapper({@required this.context, @required this.child});

  @override
  _FriendNotifierWrapperState createState() => _FriendNotifierWrapperState();

  static FriendNotifierWrapper of(BuildContext context) {
    return context.ancestorWidgetOfExactType(FriendNotifierWrapper);
  }
}

class _FriendNotifierWrapperState extends State<FriendNotifierWrapper> {
  @override
  Widget build(BuildContext context) {
    return ServerNotifier(
        context: this.widget.context,
        child: Builder(builder: (context) => this.widget.child));
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    WebsocketClient.of(context)
        .serverBroadcast
        .stream
        .listen(_processServerBroadcast);
  }

  void _processServerBroadcast(ServerResponse broadcast) {
    switch (broadcast.code) {
      case 'FRIEND_LIST_CHANGED':
        if (this.mounted) setState(() {});
        break;
    }
  }
}
