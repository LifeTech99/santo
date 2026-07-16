import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';

import 'services/mbtiles_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMbtiles();
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

  @override
  void dispose() {
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
            ],
          ),
        ],
      ),
    );
  }
}