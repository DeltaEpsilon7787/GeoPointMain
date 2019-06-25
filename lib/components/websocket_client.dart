import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

const String WEBSERVER_LOCATION = "31.25.28.142:8010";

class ServerResponse {
  int id;
  bool status;
  String code;
  dynamic data;

  ServerResponse(this.id, this.status, this.code, this.data);
  ServerResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        status = json['status'] == 'success',
        code = json['code'] as String,
        data = json['data'];
}

class WebsocketClient {
  IOWebSocketChannel _authorizedChannel;

  IOWebSocketChannel _guestChannel;

  int _id = 0;

  final StreamController<List<String>> friendRequestStream =
      StreamController.broadcast();

  final StreamController<ServerResponse> _responder =
      StreamController.broadcast();

  Duration serverTimeOffset = Duration.zero;
  double get ourTime =>
      (this.timer.elapsed + this.serverTimeOffset).inMicroseconds / 10e6;

  bool acquiringSession = false;

  final Stopwatch timer = Stopwatch()..start();

  String username;
  String email;

  WebsocketClient() {
    this._establishServerOffset();
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
      return Future.value(true);
    }

    this._guestChannel =
        IOWebSocketChannel.connect('ws://$WEBSERVER_LOCATION/websocket');

    this._guestChannel.stream.listen(this._processResponse);

    this.acquiringSession = true;

    return this
        ._responder
        .stream
        .firstWhere((ServerResponse response) {
          return response.code == 'GUEST_SESSION';
        })
        .then((ServerResponse response) => Future.value(true))
        .timeout(Duration(seconds: 2), onTimeout: () => Future.value(false))
        .then((var result) {
          this.acquiringSession = false;
          return result;
        });
  }

  Future<ServerResponse> sendFriendsRequest(String username) async =>
      this._sendMessage('send_friend_request', data: {'target': username});

  Future<ServerResponse> geopointGetFriendsCoords() async =>
      this._sendMessage('geopoint_get_friends');

  Future<ServerResponse> geopointGetMyCoords() async =>
      this._sendMessage('geopoint_get');

  Future<ServerResponse> geopointPostCoords(double lat, double lon) async =>
      this._sendMessage('geopoint_post', data: {'lat': lat, 'lon': lon});

  Future<ServerResponse> getMyFriends() async =>
      this._sendMessage('get_my_friends');

  Future<bool> tryToAuth({String username, String password}) async {
    if (username == null && password == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      username = prefs.getString('username');
      password = prefs.getString('password');

      if (username == null || password == null) {
        return Future.value(false);
      }
    }
    return this._tryToEstablishSession(username, password);
  }

  void logOut() => this._authorizedChannel != null ? this._authorizedChannel.sink.close() : null;

  void _establishServerOffset() async {
    await this._sendMessage('get_time', authorized: false).then(
        (ServerResponse response) => this.serverTimeOffset =
            Duration(microseconds: (10e6 * response.data) as int));
  }

  void _processResponse(dynamic stringData) {
    dynamic data;
    try {
      data = jsonDecode(stringData);
    } catch (Exception) {
      this._responder.add(ServerResponse(-1, true, stringData, null));
      return null;
    }

    this._responder.add(ServerResponse(
        data['id'], data['status'] == 'success', data['code'], data['data']));
  }

  Future<ServerResponse> _sendMessage(String action,
      {Map<String, dynamic> data, bool authorized: true}) async {
    int reservedId = this._id++;

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
    return this._responder.stream.firstWhere((ServerResponse response) {
      return response.id == reservedId;
    });
  }

  Future<bool> _tryToEstablishSession(String username, String password) async {
    if (this._authorizedChannel != null) {
      this._authorizedChannel.sink.close();
    }

    var temporary = IOWebSocketChannel.connect(
        'ws://$WEBSERVER_LOCATION/websocket/$username/$password');

    this.acquiringSession = true;

    temporary.stream.listen(this._processResponse);

    return this._responder.stream.firstWhere((ServerResponse response) {
      return ['AUTH_SUCCESSFUL', 'AUTH_FAILED'].contains(response.code);
    }).then((ServerResponse response) {
      this.acquiringSession = false;
      switch (response.code) {
        case ('AUTH_SUCCESSFUL'):
          this._authorizedChannel = temporary;
          this.username = username;
          return Future.value(true);
        case ('AUTH_FAILED'):
          return Future.value(false);
      }
    });
  }
}
