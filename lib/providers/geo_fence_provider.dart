import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_services.dart';
import '../services/notification_services.dart';

enum GeofenceState { inside, outside, unknown }

class GeofenceProvider extends ChangeNotifier {
  LatLng? fenceCenter;
  LatLng? userLocation;
  double? userAccuracy;

  double radius = 200;
  final double buffer = 20;

  GeofenceState _state = GeofenceState.unknown;

  StreamSubscription? _sub;
  final Distance _distance = const Distance();

  Future<void> initUserLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) return;

    userLocation = LatLng(pos.latitude, pos.longitude);
    userAccuracy = pos.accuracy;

    notifyListeners();
    _listenLocation();
  }

  /// Called ONLY on map tap
  void createFence(LatLng center) {
    fenceCenter = center;
    _state = GeofenceState.unknown;
    notifyListeners();

    if (userLocation != null) {
      _evaluateFence(userLocation!);
    }
  }

  void _listenLocation() {
    _sub?.cancel();
    _sub = LocationService.getPositionStream().listen((pos) {
      userLocation = LatLng(pos.latitude, pos.longitude);
      userAccuracy = pos.accuracy;

      if (fenceCenter != null) {
        _evaluateFence(userLocation!);
      }

      notifyListeners();
    });
  }

  void _evaluateFence(LatLng position) {
    final meters = _distance.as(LengthUnit.Meter, fenceCenter!, position);

    debugPrint("Distance: ${meters.toStringAsFixed(2)}");
    debugPrint("Accuracy: ${userAccuracy?.toStringAsFixed(1)}");

    final bool inside = meters <= radius;
    final bool outside = meters > radius + buffer;

    if (inside && _state != GeofenceState.inside) {
      _state = GeofenceState.inside;
      debugPrint("USER ENTERED GEOFENCE");

      // Show notification
      NotificationService.showNotification(
        title: "Geofence Alert",
        body: "You ENTERED the geofence",
      );
    }

    if (outside && _state != GeofenceState.outside) {
      _state = GeofenceState.outside;
      debugPrint("USER EXITED GEOFENCE");

      // Show notification
      NotificationService.showNotification(
        title: "Geofence Alert",
        body: "You EXITED the geofence",
      );
    }
  }

  void updateRadius(double newRadius) {
    radius = newRadius;
    notifyListeners(); // rebuild map circles
    // Optional: re-evaluate geofence immediately
    if (userLocation != null && fenceCenter != null) {
      _evaluateFence(userLocation!);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
