import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class ServerResponse {
  String code;
  dynamic data;

  ServerResponse(this.code, this.data);
}

class WebsocketClient {
  String _username;

  String _password;

  String _sessionId;

  final IOWebSocketChannel channel = IOWebSocketChannel.connect(
      'ws://31.25.28.142:8010',
      pingInterval: Duration(seconds: 5));

  final StreamController<List<String>> friendRequestStream =
      StreamController.broadcast();

  final StreamController<bool> sessionAcquiredStream =
      StreamController.broadcast();

  Timer _timeUpdaterTimer;

  Timer _friendPollerTimer;

  double serverTime = 0;

  int _id = 0;

  bool acquiringSession = false;

  WebsocketClient() {
    // Set up time poller
    this._timeUpdaterTimer = Timer.periodic(Duration(seconds: 1), (_) {
      this._sendMessage('get_time').then((ServerResponse response) {
        this.serverTime = response.data;
      }, onError: this._handleDefaultErrors);
    });

    // Friend requests poller
    this._friendPollerTimer = Timer.periodic(Duration(seconds: 10), (_) {
      if (this.username != null && this._sessionId != null) {
        this._sendMessage('get_my_friends').then((ServerResponse response) {
          List<String> friends = List.castFrom(response.data);
          if (friends.length > 0) {
            this.friendRequestStream.sink.add(friends);
          }
        });
      }
    });

    this._persistentGet();
    this._acquireNewSession();
  }
  String get password => this._password;
  set password(String password) {
    this._password = password;
    this._persistentSave();
  }

  String get sessionId => this._sessionId;

  set sessionId(String sessionId) {
    this._sessionId = sessionId;
    this.sessionAcquiredStream.add(sessionId != null);
  }

  String get username => this._username;

  set username(String username) {
    this._username = username;
    this._persistentSave();
  }

  Future<ServerResponse> attemptLogin() async => this._sendMessage('auth',
      data: {'username': this._username, 'password': this._password});

  Future<ServerResponse> attemptRegister(
          String username, String password, String email) async =>
      this._sendMessage('register',
          data: {'username': username, 'password': password, 'email': email});

  Future<ServerResponse> attemptActivation(String key) =>
      this._sendMessage('activate', data: {'key': key});

  Future<ServerResponse> geopointGet() async =>
      this._sendMessage('geopoint_get');

  Future<ServerResponse> geopointPost(double lat, double lon) async =>
      this._sendMessage('geopoint_post', data: {'lat': lat, 'lon': lon});

  void _acquireNewSession() {
    if (this.acquiringSession) {
      return;
    }

    if (this._username == null || this._password == null) {
      return;
    }

    if (this.sessionId == null) {
      this.acquiringSession = true;
      this._sendMessage('auth', data: {
        'username': username,
        'password': password
      }).then((ServerResponse response) {
        this.sessionId = response.data;
      }).whenComplete(() {
        this.acquiringSession = false;
      });
    }
  }

  void _handleDefaultErrors(ServerResponse response) {
    switch (response.code) {
      case 'SESSION_EXPIRED':
        this._sessionId = null;
        this._acquireNewSession();
        break;
      case 'USER_NOT_LOGGED':
        if (this._sessionId != null) {
          this._sessionId = null;
        }
        break;
      default:
        break;
    }
  }

  void _persistentGet() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      this._username = prefs.getString('username');
      this._password = prefs.getString('password');
    });
  }

  void _persistentSave() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      prefs.setString("username", this.username);
      prefs.setString("password", this.password);
    });
  }

  int _reserveId() => this._id++;

  Future<ServerResponse> _sendMessage(String action,
      {Map<String, dynamic> data}) async {
    int reservedId = this._reserveId();

    var actionInfo = {'action': action, 'id': reservedId};

    var sessionInfo = {
      'username': this._username,
      'session_id': this._sessionId
    };

    var serverRequest = actionInfo;
    if (this._username != null && this._sessionId != null) {
      serverRequest.addAll(sessionInfo);
    }
    if (data != null) {
      serverRequest.addAll(data);
    }

    this.channel.sink.add(jsonEncode(serverRequest));

    return this
        .channel
        .stream
        .where((dynamic stringData) {
          dynamic data = jsonDecode(stringData);
          return data['id'] == reservedId;
        })
        .first
        .then((dynamic stringData) {
          dynamic data = jsonDecode(stringData);
          ServerResponse response = ServerResponse(data['code'], data['data']);
          if (data['status'] == 'fail') {
            return Future.error(response);
          } else {
            return Future.value(response);
          }
        })
        .catchError(this._handleDefaultErrors);
  }
}
