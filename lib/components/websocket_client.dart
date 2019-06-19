import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

class WebsocketClient {
  IOWebSocketChannel channel;

  String username;
  String sessionId;

  Map<String, List> _callbacks = {};

  WebsocketClient() {
    channel = IOWebSocketChannel.connect('ws://31.25.28.142:8010',
        pingInterval: Duration(seconds: 5));

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

  void geopointPost(bg.Location location) {
    channel.sink.add(jsonEncode({
      'action': 'geopoint_post',
      'username': this.username,
      'session_id': this.sessionId,
      'lat': location.coords.latitude,
      'lon': location.coords.longitude
    }));
  }

  void geopointGet() {
    channel.sink.add(jsonEncode({
      'action': 'geopoint_get',
      'username': this.username,
      'session_id': this.sessionId
    }));
  }

  void pingServer() {
    channel.sink.add(jsonEncode({
      'action': 'get_stat',
      'username': this.username,
      'session_id': this.sessionId,
    }));
  }

  void attemptRegister(String username, String password, String email) {
    channel.sink.add(jsonEncode({
      'action': 'register',
      'username': username,
      'password': password,
      'email': email
    }));
  }

  void attemptLogin(String username, String password) {
    this.username = username;
    channel.sink.add(jsonEncode(
        {'action': 'auth', 'username': username, 'password': password}));
  }
}
