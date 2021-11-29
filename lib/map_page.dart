// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, unused_field, prefer_final_fields, prefer_collection_literals, unnecessary_null_comparison, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  final currentFolderName;
  MapPage({Key? key, @required this.currentFolderName}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Variables
  Set<Marker> _mapMarkers = Set();
  late GoogleMapController _mapController; // Will be initialized later
  Position? _currentPosition;
  Position _defaultPosition = Position(
    longitude: 20.608148,
    latitude: -103.417576,
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    timestamp: DateTime.now(),
  ); // ITESO
  @override
  Widget build(BuildContext context) {
    _currentPosition ??=
        _defaultPosition; // if(_currentPosition == null) _currentPosition = _defaultPosition
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.currentFolderName),
        backgroundColor: Colors.transparent,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
        ),
        markers: _mapMarkers,
        onMapCreated: _onMapCreated,
        onLongPress: _setMarker,
      ),
    );
  }

  // Initialize map content
  void _onMapCreated(controller) async {
    _mapController = controller;
    await getcurrentPosition();
    setState(() {});
  }

  Future<void> getcurrentPosition() async {
    // Ask for permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // Get current position
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Get address
    String _currentAddress = await _getGeocodingAddress(_currentPosition!);

    // Add marker with current user location
    _mapMarkers.add(
      Marker(
        markerId: MarkerId(
          _currentPosition.toString(),
        ),
        position: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        infoWindow: InfoWindow(
          title: _currentPosition.toString(),
          snippet: _currentAddress,
        ),
      ),
    );

    // Move camera
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 15, // Recommended zoom
        ),
      ),
    );
  }

  Future<String> _getGeocodingAddress(Position position) async {
    // Geocoding
    var places = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (places != null && places.isNotEmpty) {
      var place = places.first;
      return "${place.thoroughfare} #${place.subThoroughfare}, ${place.locality}, ${place.subLocality}, ${place.country}.";
    }
    return "No address available";
  }

  void _setMarker(LatLng coord) async {
    // Get address
    String _markerAddress = await _getGeocodingAddress(
      Position(
        longitude: coord.longitude,
        latitude: coord.latitude,
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        timestamp: DateTime.now(),
      ),
    );
    _mapMarkers.add(
      Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
        markerId: MarkerId(
          coord.toString(),
        ),
        position: coord,
        infoWindow: InfoWindow(
          title: coord.toString(),
          snippet: _markerAddress,
        ),
      ),
    );

    setState(() {});
  }
}
