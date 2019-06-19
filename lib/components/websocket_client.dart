import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart';
import 'dart:async';

class WebsocketClient {
  String username;
  String sessionId;

  final IOWebSocketChannel channel = IOWebSocketChannel.connect(
      'ws://31.25.28.142:8010',
      pingInterval: Duration(seconds: 5));

  final Map<String, List> _callbacks = {};
  final StreamController<List<String>> friendRequestStream =
      StreamController.broadcast();

  Timer timeUpdaterTimer;
  Timer friendPollerTimer;
  double serverTime = 0;

  WebsocketClient() {
    channel.stream.listen((dynamic response) {
      var responseObject = jsonDecode(response);
      String action = responseObject['action'];
      String status = responseObject['status'];
      String reason = responseObject['reason'];

      if (_callbacks.containsKey(action)) {
        for (dynamic listener in _callbacks[action]) {
          listener(status, reason, responseObject);
        }
      }
      return;
    });
    this.timeUpdaterTimer = Timer.periodic(Duration(seconds: 1), (_) {
      this.channel.sink.add(jsonEncode({'action': 'time'}));
    });
    this.addListener('time', (_, __, dynamic data) {
      this.serverTime = data['time'];
    });

    this.friendPollerTimer = Timer.periodic(Duration(seconds: 10), (_) {
      if (this.username != null && this.sessionId != null) {
        this.channel.sink.add(jsonEncode({
              'action': 'get_stat',
              'username': this.username,
              'session_id': this.sessionId
            }));
      }
    });
    this.addListener('get_stat', (String status, List data, _) {
      if (status == 'success') {
        List<String> dataFragment = data;
        if (data.length > 0) {
          this.friendRequestStream.sink.add(dataFragment);
        }
      }
      // TODO: Lost session ID
    });
  }

  bool isNotConnected() {
    return channel.closeCode == goingAway;
  }

  void addListener(String action, dynamic callback) {
    if (!_callbacks.containsKey(action)) {
      _callbacks[action] = [];
    }
    _callbacks[action].add(callback);
  }

  void setSessionId(String sessionId) {
    this.sessionId = sessionId;
  }

  void geopointPost(double lat, double lon) {
    this.channel.sink.add(jsonEncode({
          'action': 'geopoint_post',
          'username': this.username,
          'session_id': this.sessionId,
          'lat': lat,
          'lon': lon
        }));
  }

  void geopointGet() {
    this.channel.sink.add(jsonEncode({
          'action': 'geopoint_get',
          'username': this.username,
          'session_id': this.sessionId
        }));
  }

  void getStats() {
    this.channel.sink.add(jsonEncode({
          'action': 'get_stat',
          'username': this.username,
          'session_id': this.sessionId,
        }));
  }

  void attemptRegister(String username, String password, String email) {
    this.channel.sink.add(jsonEncode({
          'action': 'register',
          'username': username,
          'password': password,
          'email': email
        }));
  }

  void attemptLogin(String username, String password) {
    this.username = username;
    this.channel.sink.add(jsonEncode({
      'action': 'auth', 
      'username': username,
      'password': password
    }));
  }
}
