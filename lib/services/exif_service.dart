import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';

/// Service to extract GPS coordinates from a photo's EXIF metadata.
class ExifService {
  /// Extract GPS coordinates from an image file's EXIF data.
  ///
  /// Returns a record `(double lat, double lng)` if GPS tags are present,
  /// or `null` if the image has no embedded GPS information.
  static Future<({double lat, double lng})?> extractGpsFromFile(
      File file) async {
    try {
      final bytes = await file.readAsBytes();
      final data = await readExifFromBytes(bytes);

      if (data.isEmpty) {
        debugPrint('ExifService: No EXIF data found in image');
        return null;
      }

      // Check for GPS tags
      final latTag = data['GPS GPSLatitude'];
      final lngTag = data['GPS GPSLongitude'];
      final latRef = data['GPS GPSLatitudeRef'];
      final lngRef = data['GPS GPSLongitudeRef'];

      if (latTag == null || lngTag == null) {
        debugPrint('ExifService: No GPS tags in EXIF data');
        return null;
      }

      // Convert DMS (Degrees, Minutes, Seconds) to decimal degrees
      final lat = _dmsToDecimal(latTag.values, latRef?.printable ?? 'N');
      final lng = _dmsToDecimal(lngTag.values, lngRef?.printable ?? 'E');

      if (lat == null || lng == null) {
        debugPrint('ExifService: Failed to parse GPS values');
        return null;
      }

      debugPrint(
          'ExifService: Extracted GPS from EXIF → lat: $lat, lng: $lng');
      return (lat: lat, lng: lng);
    } catch (e) {
      debugPrint('ExifService extractGpsFromFile error: $e');
      return null;
    }
  }

  /// Convert EXIF GPS DMS (Degrees/Minutes/Seconds) rational values
  /// to a single decimal degree value.
  ///
  /// [values] is the IfdValues from the EXIF tag (list of Rationals).
  /// [ref] is 'N'/'S' for latitude or 'E'/'W' for longitude.
  static double? _dmsToDecimal(IfdValues values, String ref) {
    try {
      final rationals = values.toList();
      if (rationals.length < 3) return null;

      // Each value is a Ratio (numerator/denominator)
      final degrees = _ratioToDouble(rationals[0]);
      final minutes = _ratioToDouble(rationals[1]);
      final seconds = _ratioToDouble(rationals[2]);

      if (degrees == null || minutes == null || seconds == null) return null;

      double decimal = degrees + (minutes / 60.0) + (seconds / 3600.0);

      // South and West are negative
      if (ref == 'S' || ref == 'W') {
        decimal = -decimal;
      }

      return decimal;
    } catch (e) {
      debugPrint('ExifService _dmsToDecimal error: $e');
      return null;
    }
  }

  /// Convert a single EXIF Ratio value to a double.
  static double? _ratioToDouble(dynamic ratio) {
    try {
      if (ratio is Ratio) {
        if (ratio.denominator == 0) return 0.0;
        return ratio.numerator.toDouble() / ratio.denominator.toDouble();
      }
      // Fallback: try parsing as number
      return double.tryParse(ratio.toString());
    } catch (e) {
      return null;
    }
  }
}
