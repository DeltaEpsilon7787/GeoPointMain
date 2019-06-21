import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ServerResponse {
  int id;
  bool status;
  String code;
  dynamic data;

  ServerResponse(this.id, this.status, this.code, this.data);
}

class WebsocketClient {
  IOWebSocketChannel _authorizedChannel;

  IOWebSocketChannel _guestChannel;

  int _id = 0;

  final StreamController<List<String>> friendRequestStream =
      StreamController.broadcast();

  final StreamController<ServerResponse> responder =
      StreamController.broadcast();

  double serverTime = 0;

  bool acquiringSession = false;

  WebsocketClient() {
    // Set up time poller
    Timer.periodic(Duration(seconds: 1), (_) {
      this
          ._sendMessage('get_time', authorized: false)
          .then((ServerResponse response) {
        this.serverTime = response.data;
      });
    });
  }

  void processData(dynamic stringData) {
    dynamic data;
    try {
      data = jsonDecode(stringData);
    } catch (Exception) {
      this.responder.add(ServerResponse(-1, true, stringData, null));
      return null;
    }

    this.responder.add(ServerResponse(
        data['id'], data['status'] == 'success', data['code'], data['data']));
  }

  Future<ServerResponse> attemptActivation(String key) async =>
      this._sendMessage('activate', data: {'key': key}, authorized: false);

  Future<ServerResponse> attemptRegister(
          String username, String password, String email) async =>
      this._sendMessage('register',
          data: {'username': username, 'password': password, 'email': email},
          authorized: false);

  Future<bool> establishGuestSession() async {
    if (this._guestChannel != null) {
      return Future.value();
    }

    this._guestChannel =
        IOWebSocketChannel.connect('ws://31.25.28.142:8010/websocket');

    this._guestChannel.stream.listen(this.processData);

    return this
        .responder
        .stream
        .firstWhere((ServerResponse response) {
          return response.code == 'GUEST_SESSION';
        })
        .then((ServerResponse response) => Future.value(true))
        .timeout(Duration(seconds: 5), onTimeout: () => Future.value(false));
  }

  Future<ServerResponse> geopointGet() async =>
      this._sendMessage('geopoint_get');

  Future<ServerResponse> geopointGetFriends() async =>
      this._sendMessage('geopoint_get_friends');

  Future<ServerResponse> geopointPost(double lat, double lon) async =>
      this._sendMessage('geopoint_post', data: {'lat': lat, 'lon': lon});

  Future<bool> tryLogin({String username, String password}) async {
    if (username == null && password == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      username = prefs.getString('username');
      password = prefs.getString('password');

      if (username == null || password == null) {
        return Future.value(false);
      }
    }
    return this._tryEstablishSession(username, password);
  }

  int _reserveId() => this._id++;

  Future<ServerResponse> _sendMessage(String action,
      {Map<String, dynamic> data, bool authorized: true}) async {
    int reservedId = this._reserveId();

    var actionInfo = {'action': action, 'id': reservedId};

    var serverRequest = actionInfo;
    if (data != null) {
      serverRequest.addAll(data);
    }

    if (authorized) {
      this._authorizedChannel.sink.add(jsonEncode(serverRequest));
    } else {
      this._guestChannel?.sink?.add(jsonEncode(serverRequest));
    }
    return this.responder.stream.firstWhere((ServerResponse response) {
      return response.id == reservedId;
    });
  }

  Future<bool> _tryEstablishSession(String username, String password) async {
    if (this._authorizedChannel != null) {
      this._authorizedChannel.sink.close();
    }

    var temporary = IOWebSocketChannel.connect(
        'ws://31.25.28.142:8010/websocket/$username/$password');

    this.acquiringSession = true;

    temporary.stream.listen(this.processData);

    return this.responder.stream.firstWhere((ServerResponse response) {
      return ['AUTH_SUCCESSFUL', 'AUTH_FAILED'].contains(response.code);
    }).then((ServerResponse response) {
      switch (response.code) {
        case ('AUTH_SUCCESSFUL'):
          this._authorizedChannel = temporary;
          return Future.value(true);
        case ('AUTH_FAILED'):
          return Future.value(false);
      }
    });
  }
}
