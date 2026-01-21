import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../providers/geo_fence_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GeofenceProvider>().initUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tap to Create Geofence')),
      body: Stack(
        children: [
          Consumer<GeofenceProvider>(
            builder: (context, provider, _) {
              if (provider.userLocation == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final circles = <CircleMarker>[];

              if (provider.userAccuracy != null) {
                circles.add(
                  CircleMarker(
                    point: provider.userLocation!,
                    radius: provider.userAccuracy!,
                    useRadiusInMeter: true,
                    // color: Colors.blue.withOpacity(0.15),
                    color: Colors.blue.withOpacity(0.5),
                    borderStrokeWidth: 0,
                  ),
                );
              }

              if (provider.fenceCenter != null) {
                circles.add(
                  CircleMarker(
                    point: provider.fenceCenter!,
                    radius: provider.radius,
                    useRadiusInMeter: true,
                    color: Colors.red.withOpacity(0.2),
                    borderColor: Colors.red,
                    borderStrokeWidth: 2,
                  ),
                );
              }

              return FlutterMap(
                options: MapOptions(
                  initialCenter: provider.userLocation!,
                  initialZoom: 16,
                  onTap: (_, point) => provider.createFence(point),
                  keepAlive: true,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    // tileProvider: const NonCachingNetworkTileProvider(),
                    keepBuffer: 2,
                  ),
                  if (circles.isNotEmpty) CircleLayer(circles: circles),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: provider.userLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          // Bottom buttons to change radius
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [200, 300, 400, 500].map((r) {
                return ElevatedButton(
                  onPressed: () {
                    context.read<GeofenceProvider>().updateRadius(r.toDouble());
                  },
                  child: Text('$r m'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
