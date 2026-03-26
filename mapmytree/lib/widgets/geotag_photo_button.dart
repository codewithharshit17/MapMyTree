import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';

class GeotagPhotoButton extends StatefulWidget {
  final Function(File photo, Position position, String address) onCapture;

  const GeotagPhotoButton({super.key, required this.onCapture});

  @override
  State<GeotagPhotoButton> createState() => _GeotagPhotoButtonState();
}

class _GeotagPhotoButtonState extends State<GeotagPhotoButton> {
  final _locationService = LocationService();
  bool _isCapturing = false;

  Future<void> _capturePhoto() async {
    setState(() => _isCapturing = true);
    try {
      // Check permissions
      final camGranted = await _locationService.requestCameraPermission();
      if (!camGranted) {
        _showError('Camera permission denied.');
        setState(() => _isCapturing = false);
        return;
      }

      // Open camera
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          source: ImageSource.camera, imageQuality: 85);

      if (pickedFile == null) {
        setState(() => _isCapturing = false);
        return;
      }

      // Get location
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        _showError('Could not fetch GPS location.');
        setState(() => _isCapturing = false);
        return;
      }

      // Reverse geocode
      final address = await _locationService.getAddressFromCoordinates(
          position.latitude, position.longitude);

      widget.onCapture(File(pickedFile.path), position, address);
    } catch (e) {
      _showError('Error capturing photo: $e');
    }
    if (mounted) setState(() => _isCapturing = false);
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade700,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isCapturing ? null : _capturePhoto,
        icon: _isCapturing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.camera_alt),
        label: const Text('📷 Click Geotagged Photo'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1B4332),
          side: const BorderSide(color: Color(0xFF1B4332)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
