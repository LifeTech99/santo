import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';

import 'services/mbtiles_service.dart';
import 'package:geolocator/geolocator.dart';
//import 'services/location_service.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OfflineMapScreen(),
    );
  }
}

class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  State<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  MbTilesTileProvider? tileProvider;
  LatLng? shepherdLocation;
  StreamSubscription<Position>? positionStream;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadMbtiles();
    startLocationTracking();
  }

  Future<void> _loadMbtiles() async {
    final path = await MbtilesService.getMbtilesPath();

    final provider = MbTilesTileProvider.fromPath(
      path: path,
    );

    setState(() {
      tileProvider = provider;
    });
  }



  Future<void> startLocationTracking() async {
    const locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 1,
    );

    positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {

      final newLocation = LatLng(
      position.latitude,
      position.longitude,
      );

      setState(() {
      shepherdLocation = newLocation;
      });

      mapController.move(
      newLocation,
      mapController.camera.zoom,
      );

      debugPrint(
        'Location: ${position.latitude}, ${position.longitude}',
      );
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    tileProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (tileProvider == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Map'),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: const MapOptions(
          initialCenter: LatLng(
            27.68665,
            85.29280,
          ),
          initialZoom: 17,
        ),
        children: [
          TileLayer(
            tileProvider: tileProvider!,
          ),

          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(
                  27.68665,
                  85.29280,
                ),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  size: 40,
                ),
              ),
              if (shepherdLocation != null)
                Marker(
                  point: shepherdLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.person_pin_circle,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}