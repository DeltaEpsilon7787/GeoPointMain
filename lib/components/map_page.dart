//import 'package:flutter/material.dart';
//import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
//    as bg;
//
//import 'package:flutter_map/flutter_map.dart';
//import 'dart:convert';
//import 'package:crypto/crypto.dart';
//import 'package:flutter_map/plugin_api.dart';
//import 'package:latlong/latlong.dart';
//
//import '../main.dart';
//import 'package:geolocator/geolocator.dart';
//
//const String MAP_TOKEN =
//    'pk.eyJ1IjoiY2hyaXN0b2NyYWN5IiwiYSI6ImVmM2Y2MDA1NzIyMjg1NTdhZGFlYmZiY2QyODVjNzI2In0.htaacx3ZhE5uAWN86-YNAQ';
//
//class MapPage extends StatefulWidget {
//  @override
//  _MapPageState createState() => _MapPageState();
//}

//class _MapPageStateNew extends State<MapPage> {
//  List<CircleMarker> _myPositions = [];
//  Map<String, List<CircleMarker>> _friendPositions = {};
//
//  MapController _mapController;
//  MapOptions _mapOptions;
//
//  @override
//  bool get wantKeepAlive => true;
//
//  void initState() {
//    super.initState();
//
//    this._mapController = new MapController();
//    this._mapOptions = new MapOptions(
//      onPositionChanged: this._onPositionChanged,
//      center: LatLng(51.5, -0.09),
//      zoom: 16.0,
//    );
//
//    Geolocator()
//        .getPositionStream(LocationOptions(
//            accuracy: LocationAccuracy.high, distanceFilter: 10))
//        .listen(this._registerPosition);
//  }
//
//  void _registerPosition(Position position) {
//    App.socketClient.geopointPost(position.latitude, position.longitude);
//  }
//
//  void _onPositionChanged(MapPosition pos, bool hasGesture, bool isGesture) {
//    this._mapOptions.crs.scale(_mapController.zoom);
//  }
//
//  static CircleMarker transformPosition(Position position, {String username, @required double time}) {
//    List<int> digest = username == null
//        ? [173, 0, 255]
//        : sha256.convert(utf8.encode(username)).bytes.getRange(0, 2).toList();
//
//    double lerp = 5 * (App.socketClient.serverTime - time) / (60*5);
//    if (lerp < 5) {
//      return CircleMarker(
//        color: Color.fromRGBO(digest[0], digest[1], digest[2], 1.0),
//        point: LatLng(position.latitude, position.longitude),
//        radius: 5 - lerp
//      );
//    }
//    else {
//      return null;
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return null;
//  }
//}
//
//class _MapPageState extends State<MapPage>
//    with AutomaticKeepAliveClientMixin<MapPage> {
//  @override
//  bool get wantKeepAlive {
//    return true;
//  }
//
//  bg.Location _stationaryLocation;
//
//  List<CircleMarker> _currentPosition = [];
//  List<LatLng> _polyline = [];
//  List<CircleMarker> _primaryLocations = [];
//  List<CircleMarker> _secondaryLocations = [];
//  List<CircleMarker> _stopLocations = [];
//  List<Polyline> _motionChangePolylines = [];
//  List<CircleMarker> _stationaryMarker = [];
//
//  LatLng _center = new LatLng(51.5, -0.09);
//  MapController _mapController;
//  MapOptions _mapOptions;
//
//  @override
//  void initState() {
//    super.initState();
//    _mapOptions = new MapOptions(
//      onPositionChanged: _onPositionChanged,
//      center: _center,
//      zoom: 16.0,
//    );
//    _mapController = new MapController();
//
//    bg.BackgroundGeolocation.onLocation(_onLocation);
//    bg.BackgroundGeolocation.onLocation((bg.Location loc) {
//      App.socketClient.geopointPost(loc.coords.latitude, loc.coords.longitude);
//    });
//    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
//    bg.BackgroundGeolocation.onHeartbeat((bg.HeartbeatEvent hb) {
//      App.socketClient.geopointGet();
//      App.socketClient.getStats();
//    });
//
//    App.socketClient.addListener('geopoint_get', populateMyself);
//    App.socketClient.addListener('geopoint_get_friends', populateFriends);
//    App.socketClient.addListener('get_stat', (_, __, ___) {}); // TODO: Add this
//
//    bg.BackgroundGeolocation.ready(bg.Config(
//            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
//            distanceFilter: 5.0,
//            stopOnTerminate: false,
//            debug: true,
//            heartbeatInterval: 5))
//        .then((bg.State state) {
//      bg.BackgroundGeolocation.start();
//    });
//  }
//
//  void populateMyself(String status, String data, _) {
//    this._primaryLocations.clear();
//    List locations = jsonDecode(data);
//
//    for (dynamic loc in locations) {
//      LatLng ll = new LatLng(loc['lat'], loc['lon']);
//
//      this._primaryLocations.add(CircleMarker(
//          point: ll, color: Color.fromRGBO(150, 0, 255, 1.0), radius: 3.0));
//    }
//    setState(() {});
//  }
//
//  void populateFriends(String status, String data, _) {
//    this._secondaryLocations.clear();
//    List locations = jsonDecode(data);
//    for (dynamic loc in locations) {
//      var friend_hash = sha1.convert(utf8.encode(loc['friend'])).bytes;
//      var ll = LatLng(loc['lat'], loc['lon']);
//      this._secondaryLocations.add(CircleMarker(
//          point: ll,
//          color: Color.fromRGBO(friend_hash[0] % 255, friend_hash[1] % 255,
//              friend_hash[2] % 255, 1.0),
//          radius: 2.0));
//    }
//    setState(() {});
//  }
//
//  void _onMotionChange(bg.Location location) async {
//    LatLng ll = new LatLng(location.coords.latitude, location.coords.longitude);
//
//    _updateCurrentPositionMarker(ll);
//
//    _mapController.move(ll, _mapController.zoom);
//
//    // clear the big red stationaryRadius circle.
//    _stationaryMarker.clear();
//
//    if (location.isMoving) {
//      if (_stationaryLocation == null) {
//        _stationaryLocation = location;
//      }
//      // Add previous stationaryLocation as a small red stop-circle.
//      _stopLocations.add(_buildStopCircleMarker(_stationaryLocation));
//      // Create the green motionchange polyline to show where tracking engaged from.
//      _motionChangePolylines
//          .add(_buildMotionChangePolyline(_stationaryLocation, location));
//    } else {
//      // Save a reference to the location where we became stationary.
//      _stationaryLocation = location;
//      // Add the big red stationaryRadius circle.
//      bg.State state = await bg.BackgroundGeolocation.state;
//      _stationaryMarker.add(_buildStationaryCircleMarker(location, state));
//    }
//  }
//
//  void _onLocation(bg.Location location) {
//    LatLng ll = new LatLng(location.coords.latitude, location.coords.longitude);
//
//    _mapController.move(ll, _mapController.zoom);
//
//    _updateCurrentPositionMarker(ll);
//
//    if (location.sample) {
//      return;
//    }
//
//    // Add a point to the tracking polyline.
//    _polyline.add(ll);
//    // Add a marker for the recorded location.
//    //_locations.add(_buildLocationMarker(location));
//    _primaryLocations
//        .add(CircleMarker(point: ll, color: Colors.black, radius: 5.0));
//  }
//
//  /// Update Big Blue current position dot.
//  void _updateCurrentPositionMarker(LatLng ll) {
//    _currentPosition.clear();
//
//    // White background
//    _currentPosition
//        .add(CircleMarker(point: ll, color: Colors.white, radius: 10));
//    // Blue foreground
//    _currentPosition
//        .add(CircleMarker(point: ll, color: Colors.blue, radius: 7));
//  }
//
//  CircleMarker _buildStationaryCircleMarker(
//      bg.Location location, bg.State state) {
//    return new CircleMarker(
//        point: LatLng(location.coords.latitude, location.coords.longitude),
//        color: Color.fromRGBO(255, 0, 0, 0.5),
//        useRadiusInMeter: true,
//        radius: (state.trackingMode == 1)
//            ? 200
//            : (state.geofenceProximityRadius / 2));
//  }
//
//  Polyline _buildMotionChangePolyline(bg.Location from, bg.Location to) {
//    return new Polyline(points: [
//      LatLng(from.coords.latitude, from.coords.longitude),
//      LatLng(to.coords.latitude, to.coords.longitude)
//    ], strokeWidth: 10.0, color: Color.fromRGBO(22, 190, 66, 0.7));
//  }
//
//  CircleMarker _buildStopCircleMarker(bg.Location location) {
//    return new CircleMarker(
//        point: LatLng(location.coords.latitude, location.coords.longitude),
//        color: Color.fromRGBO(200, 0, 0, 0.3),
//        useRadiusInMeter: false,
//        radius: 20);
//  }
//
//  void _onPositionChanged(MapPosition pos, bool hasGesture, bool isGesture) {
//    _mapOptions.crs.scale(_mapController.zoom);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    List all_locations = _primaryLocations + _secondaryLocations;
//
//    return FlutterMap(
//      mapController: _mapController,
//      options: _mapOptions,
//      layers: [
//        new TileLayerOptions(
//          urlTemplate:
//              "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
//          additionalOptions: {
//            'accessToken': MAP_TOKEN,
//            'id': 'mapbox.streets',
//          },
//        ),
//        new PolylineLayerOptions(
//          polylines: [
//            new Polyline(
//              points: _polyline,
//              strokeWidth: 10.0,
//              color: Color.fromRGBO(0, 179, 253, 0.8),
//            ),
//          ],
//        ),
//        // Active geofence circles
//        // Big red stationary radius while in stationary state.
//        new CircleLayerOptions(circles: _stationaryMarker),
//        // Polyline joining last stationary location to motionchange:true location.
//        new PolylineLayerOptions(polylines: _motionChangePolylines),
//        // Recorded locations.
//        new CircleLayerOptions(circles: all_locations),
//        // Small, red circles showing where motionchange:false events fired.
//        new CircleLayerOptions(circles: _stopLocations),
//        new CircleLayerOptions(circles: _currentPosition),
//      ],
//    );
//  }
//}
