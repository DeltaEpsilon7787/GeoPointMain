import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

import './websocket_client.dart';
import './notifiers.dart';

const String MAP_TOKEN =
    'pk.eyJ1IjoiY2hyaXN0b2NyYWN5IiwiYSI6ImVmM2Y2MDA1NzIyMjg1NTdhZGFlYmZiY2QyODVjNzI2In0.htaacx3ZhE5uAWN86-YNAQ';

class MapPage extends StatefulWidget {
  @override
  _MapPageStateNew createState() => _MapPageStateNew();
}

class CircleMarkerDatum {
  CircleMarker marker;
  String username;
  double time;
  Color color;

  CircleMarkerDatum({this.marker, this.username, this.time, this.color});
}

class _MapPageStateNew extends State<MapPage> {
  List<CircleMarkerDatum> _positions = [];

  List<Polyline> _polylines = [];

  MapController _mapController;
  MapOptions _mapOptions;

  Timer updateTimer;

  final Geolocator geo = Geolocator();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    if (this._mapOptions == null) {
      return Center(child: CircularProgressIndicator());
    }
    return new ServerNotifier(
        child: Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: new Text(
          "CATFISH-GEO",
          style: new TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.black,
          ),
        ),
        leading: new IconButton(
          icon: new Icon(
            Icons.home,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pushNamed('/map/profile');
          },
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: _mapOptions,
        layers: [
          new TileLayerOptions(
            urlTemplate:
                "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
            additionalOptions: {
              'accessToken': MAP_TOKEN,
              'id': 'mapbox.streets',
            },
          ),
          new PolylineLayerOptions(polylines: this._polylines),
          new CircleLayerOptions(
              circles: this._positions.length > 0
                  ? this._positions.map((elem) => elem.marker).toList()
                  : [])
        ],
      ),
    ));
  }

  void initState() {
    super.initState();

    this._mapController = new MapController();

    this.updateTimer = Timer.periodic(Duration(seconds: 5), (Timer that) {
      this._updatePoints();
    });

    this
        .geo
        .getPositionStream(LocationOptions(
            accuracy: LocationAccuracy.best, distanceFilter: 10))
        .listen(this._registerPosition);

    this._getFirstPosition();
  }

  void _getFirstPosition() async {
    await this
        .geo
        .getCurrentPosition()
        .then((Position pos) => this._registerPosition(pos));
  }

  void _registerPosition(Position position) async {
    setState(() {
      this._positions.add(this.transformPosition(
          lat: position.latitude,
          lon: position.longitude,
          time: WebsocketClient.of(context).ourTime));

      this._mapOptions = new MapOptions(
          center: LatLng(position.latitude, position.longitude),
          zoom: this._mapOptions?.zoom ?? 16);
    });
    WebsocketClient.of(context)
        .geopointPostCoords(position.latitude, position.longitude);
  }

  void _updatePoints() async {
    List<Future<List<CircleMarkerDatum>>> futures = [];
    futures.add(WebsocketClient.of(context)
        .geopointGetMyCoords()
        .then((ServerResponse response1) {
      var myCoords = [];
      try {
        myCoords = response1.data as List;
      } catch (Exception) {
        return [];
      }

      return myCoords
          .map((var datum) {
            return this.transformPosition(
                lat: datum['lat'], lon: datum['lon'], time: datum['time']);
          })
          .where((point) => point != null)
          .toList();
    }));

    futures.add(WebsocketClient.of(context)
        .geopointGetFriendsCoords()
        .then((ServerResponse response2) {
      var friendCoords = [];
      try {
        friendCoords = response2.data as List<dynamic>;
      } catch (Exception) {
        return [];
      }

      return friendCoords
          .map((var datum) {
            return this.transformPosition(
                lat: datum['lat'] as double,
                lon: datum['lon'] as double,
                time: datum['time'] as double,
                username: datum['friend'] as String);
          })
          .where((point) => point != null)
          .toList();
    }));

    Future.wait(futures)
        .then((lst) {
          this._positions.clear();
          return lst;
        })
        .then((lst) => lst.forEach((sublst) => this._positions?.addAll(sublst)))
        .then((_) => this._buildPolylines());
  }

  void _buildPolylines() {
    final map =
        groupBy(this._positions, (CircleMarkerDatum elem) => elem.username);

    this._polylines.clear();

    setState(() {
      map.forEach((String username, List<CircleMarkerDatum> points) => this
          ._polylines
          .add(Polyline(
              points: points.map((var elem) => elem.marker.point).toList(),
              color: points.first.color,
              isDotted: username != WebsocketClient.of(context).username)));
    });
  }

  CircleMarkerDatum transformPosition(
      {@required double lat,
      @required double lon,
      @required double time,
      String username}) {
    username ??= WebsocketClient.of(context).username;
    username ??= 'BLANK';
    List<int> digest = sha1.convert(utf8.encode(username)).bytes;

    double lerp = 10 - (WebsocketClient.of(context).ourTime - time) / 15;

    final color = Color.fromRGBO(digest[0], digest[1], digest[2], 1.0);
    if (lerp <= 10) {
      return CircleMarkerDatum(
          marker:
              CircleMarker(color: color, point: LatLng(lat, lon), radius: lerp),
          username: username,
          color: color,
          time: time);
    } else {
      return null;
    }
  }
}
