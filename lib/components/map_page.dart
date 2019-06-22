import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

import './websocket_client.dart';
import '../main.dart';

const String MAP_TOKEN =
    'pk.eyJ1IjoiY2hyaXN0b2NyYWN5IiwiYSI6ImVmM2Y2MDA1NzIyMjg1NTdhZGFlYmZiY2QyODVjNzI2In0.htaacx3ZhE5uAWN86-YNAQ';

class MapPage extends StatefulWidget {
  @override
  _MapPageStateNew createState() => _MapPageStateNew();
}

/*
class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  bg.Location _stationaryLocation;

  List<CircleMarker> _currentPosition = [];

  List<LatLng> _polyline = [];
  List<CircleMarker> _primaryLocations = [];
  List<CircleMarker> _secondaryLocations = [];
  List<CircleMarker> _stopLocations = [];
  List<Polyline> _motionChangePolylines = [];
  List<CircleMarker> _stationaryMarker = [];
  LatLng _center = new LatLng(51.5, -0.09);

  MapController _mapController;
  MapOptions _mapOptions;
  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    List all_locations = _primaryLocations + _secondaryLocations;

    return FlutterMap(
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
        new PolylineLayerOptions(
          polylines: [
            new Polyline(
              points: _polyline,
              strokeWidth: 10.0,
              color: Color.fromRGBO(0, 179, 253, 0.8),
            ),
          ],
        ),
        // Active geofence circles
        // Big red stationary radius while in stationary state.
        new CircleLayerOptions(circles: _stationaryMarker),
        // Polyline joining last stationary location to motionchange:true location.
        new PolylineLayerOptions(polylines: _motionChangePolylines),
        // Recorded locations.
        new CircleLayerOptions(circles: all_locations),
        // Small, red circles showing where motionchange:false events fired.
        new CircleLayerOptions(circles: _stopLocations),
        new CircleLayerOptions(circles: _currentPosition),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _mapOptions = new MapOptions(
      onPositionChanged: _onPositionChanged,
      center: _center,
      zoom: 16.0,
    );
    _mapController = new MapController();

    bg.BackgroundGeolocation.onLocation(_onLocation);
    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);

    bg.BackgroundGeolocation.ready(bg.Config(
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 5.0,
            stopOnTerminate: false,
            debug: true,
            heartbeatInterval: 5))
        .then((bg.State state) {
      bg.BackgroundGeolocation.start();
    });
  }

  void populateFriends(String status, String data, _) {
    this._secondaryLocations.clear();
    List locations = jsonDecode(data);
    for (dynamic loc in locations) {
      var friendHash = sha1.convert(utf8.encode(loc['friend'])).bytes;
      var ll = LatLng(loc['lat'], loc['lon']);
      this._secondaryLocations.add(CircleMarker(
          point: ll,
          color: Color.fromRGBO(friendHash[0] % 255, friendHash[1] % 255,
              friendHash[2] % 255, 1.0),
          radius: 2.0));
    }
    setState(() {});
  }

  void populateMyself(String status, String data, _) {
    this._primaryLocations.clear();
    List locations = jsonDecode(data);

    for (dynamic loc in locations) {
      LatLng ll = new LatLng(loc['lat'], loc['lon']);

      this._primaryLocations.add(CircleMarker(
          point: ll, color: Color.fromRGBO(150, 0, 255, 1.0), radius: 3.0));
    }
    setState(() {});
  }

  Polyline _buildMotionChangePolyline(bg.Location from, bg.Location to) {
    return new Polyline(points: [
      LatLng(from.coords.latitude, from.coords.longitude),
      LatLng(to.coords.latitude, to.coords.longitude)
    ], strokeWidth: 10.0, color: Color.fromRGBO(22, 190, 66, 0.7));
  }

  CircleMarker _buildStationaryCircleMarker(
      bg.Location location, bg.State state) {
    return new CircleMarker(
        point: LatLng(location.coords.latitude, location.coords.longitude),
        color: Color.fromRGBO(255, 0, 0, 0.5),
        useRadiusInMeter: true,
        radius: (state.trackingMode == 1)
            ? 200
            : (state.geofenceProximityRadius / 2));
  }

  CircleMarker _buildStopCircleMarker(bg.Location location) {
    return new CircleMarker(
        point: LatLng(location.coords.latitude, location.coords.longitude),
        color: Color.fromRGBO(200, 0, 0, 0.3),
        useRadiusInMeter: false,
        radius: 20);
  }

  void _onLocation(bg.Location location) {
    LatLng ll = new LatLng(location.coords.latitude, location.coords.longitude);

    _mapController.move(ll, _mapController.zoom);

    _updateCurrentPositionMarker(ll);

    if (location.sample) {
      return;
    }

    // Add a point to the tracking polyline.
    _polyline.add(ll);
    // Add a marker for the recorded location.
    //_locations.add(_buildLocationMarker(location));
    _primaryLocations
        .add(CircleMarker(point: ll, color: Colors.black, radius: 5.0));
  }

  void _onMotionChange(bg.Location location) async {
    LatLng ll = new LatLng(location.coords.latitude, location.coords.longitude);

    _updateCurrentPositionMarker(ll);

    _mapController.move(ll, _mapController.zoom);

    // clear the big red stationaryRadius circle.
    _stationaryMarker.clear();

    if (location.isMoving) {
      if (_stationaryLocation == null) {
        _stationaryLocation = location;
      }
      // Add previous stationaryLocation as a small red stop-circle.
      _stopLocations.add(_buildStopCircleMarker(_stationaryLocation));
      // Create the green motionchange polyline to show where tracking engaged from.
      _motionChangePolylines
          .add(_buildMotionChangePolyline(_stationaryLocation, location));
    } else {
      // Save a reference to the location where we became stationary.
      _stationaryLocation = location;
      // Add the big red stationaryRadius circle.
      bg.State state = await bg.BackgroundGeolocation.state;
      _stationaryMarker.add(_buildStationaryCircleMarker(location, state));
    }
  }

  void _onPositionChanged(MapPosition pos, bool hasGesture, bool isGesture) {
    _mapOptions.crs.scale(_mapController.zoom);
  }

  /// Update Big Blue current position dot.
  void _updateCurrentPositionMarker(LatLng ll) {
    _currentPosition.clear();

    // White background
    _currentPosition
        .add(CircleMarker(point: ll, color: Colors.white, radius: 10));
    // Blue foreground
    _currentPosition
        .add(CircleMarker(point: ll, color: Colors.blue, radius: 7));
  }
}
*/
class _MapPageStateNew extends State<MapPage> {
  List<CircleMarker> _myPositions = [];
  Map<String, List<CircleMarker>> _friendPositions = {};

  List<LatLng> _polyline = [];

  MapController _mapController;
  MapOptions _mapOptions;

  Timer updateTimer;

  final Geolocator geo = Geolocator();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
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
        new PolylineLayerOptions(
          polylines: [
            new Polyline(
              points: _polyline,
              strokeWidth: 10.0,
              color: Color.fromRGBO(0, 179, 253, 0.8),
            ),
          ],
        ),
        // Big red stationary radius while in stationary state.
        new CircleLayerOptions(
            circles:
                this._myPositions.length > 0 ? [this._myPositions.last] : []),
        // Recorded locations.
        new CircleLayerOptions(circles: this._myPositions)
      ],
    );
  }

  void initState() {
    super.initState();

    this._mapController = new MapController();
    this._mapOptions = new MapOptions(
      center: LatLng(51.5, -0.09),
      zoom: 16.0,
    );

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
    print('Register Position');
    this._myPositions.add(_MapPageStateNew.transformPosition(
        lat: position.latitude,
        lon: position.longitude,
        time: App.socketClient.ourTime));
    this._mapOptions.center = LatLng(position.latitude, position.longitude);
    this._mapOptions.crs.scale(_mapController.zoom);

    setState(() {});
    await App.socketClient
        .geopointPostCoords(position.latitude, position.longitude);
  }

  void _updatePoints() async {
    List<Future> futures = [];
    futures.add(
        App.socketClient.geopointGetMyCoords().then((ServerResponse response1) {
      final myCoords = response1.data;
      print(myCoords.toString());

      if (myCoords.length > 0) {
        this._myPositions.clear();
      }
      myCoords.forEach((var datum) {
        CircleMarker marker = _MapPageStateNew.transformPosition(
            lat: datum['lat'] as double,
            lon: datum['lon'] as double,
            time: datum['time'] as double);
        if (marker != null) {
          this._myPositions.add(marker);
        }
      });
    }));

    futures.add(App.socketClient
        .geopointGetFriendsCoords()
        .then((ServerResponse response2) {
      var friendCoords = [];
      try {
        friendCoords = response2.data as List<dynamic>;
      } catch (Exception) {}

      if (friendCoords.length > 0) {
        this._friendPositions.clear();
      }

      friendCoords.forEach((var datum) {
        if (!this._friendPositions.containsKey(datum['friend'])) {
          this._friendPositions[datum['friend']] = [];
        }
        CircleMarker marker = _MapPageStateNew.transformPosition(
            lat: datum['lat'] as double,
            lon: datum['lon'] as double,
            time: datum['time'] as double,
            username: datum['friend'] as String);
        if (marker != null) {
          this._friendPositions[datum['friend']].add(marker);
        }
      });
    }));

    await Future.wait(futures).then((_) {
      this._buildPolylines();
      setState(() {});
    });
  }

  void _buildPolylines() {}

  static CircleMarker transformPosition(
      {@required double lat,
      @required double lon,
      @required double time,
      String username}) {
    username ??= App.socketClient.username;
    username ??= 'BLANK';
    List<int> digest = sha1.convert(utf8.encode(username)).bytes;

    double lerp = 3;
    if (lerp < 5) {
      return CircleMarker(
          color: Color.fromRGBO(digest[0], digest[1], digest[2], 1.0),
          point: LatLng(lat, lon),
          radius: 5 - lerp);
    } else {
      return null;
    }
  }
}
