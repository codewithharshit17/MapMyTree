import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Request location permission and return current GPS coordinates.
  Future<Position?> getCurrentPosition() async {
    try {
      // Check and request permission
      var status = await Permission.location.status;
      if (!status.isGranted) {
        status = await Permission.location.request();
        if (!status.isGranted) {
          debugPrint('Location permission denied');
          return null;
        }
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      return position;
    } catch (e) {
      debugPrint('LocationService getCurrentPosition error: $e');
      return null;
    }
  }

  /// Reverse geocode coordinates to a human-readable address.
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if (place.name != null && place.name!.isNotEmpty) place.name!,
          if (place.subLocality != null && place.subLocality!.isNotEmpty)
            place.subLocality!,
          if (place.locality != null && place.locality!.isNotEmpty)
            place.locality!,
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty)
            place.administrativeArea!,
          if (place.country != null && place.country!.isNotEmpty)
            place.country!,
        ];
        return parts.join(', ');
      }
      return 'Unknown location';
    } catch (e) {
      debugPrint('LocationService getAddress error: $e');
      return 'Unable to get address';
    }
  }

  /// Request camera permission.
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
}
