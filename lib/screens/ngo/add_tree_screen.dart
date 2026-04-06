import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/session_helper.dart';
import '../../models/request_model.dart';
import '../../services/new_tree_service.dart';
import '../../services/request_service.dart';
import '../../services/storage_service.dart';
import '../../services/location_service.dart';
import '../../services/exif_service.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
class AddTreeScreen extends StatefulWidget {
  final RequestModel? prefilledRequest;
  const AddTreeScreen({super.key, this.prefilledRequest});

  @override
  State<AddTreeScreen> createState() => _AddTreeScreenState();
}

class _AddTreeScreenState extends State<AddTreeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _treeNameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _notesController = TextEditingController();
  final _coordsController = TextEditingController();
  final _locationController = TextEditingController();

  final _treeService = NewTreeService();
  final _requestService = RequestService();
  final _storageService = StorageService();
  final _locationService = LocationService();

  DateTime _selectedDate = DateTime.now();
  File? _capturedPhoto;
  double? _latitude;
  double? _longitude;
  bool _isSubmitting = false;
  bool _isCapturing = false;
  String _gpsSource = ''; // 'exif' or 'device'

  // Request dropdown
  List<RequestModel> _pendingRequests = [];
  RequestModel? _selectedRequest;
  bool _loadingRequests = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
    // Note: _selectedRequest is set AFTER loading so we can match against list items
  }

  Future<void> _loadPendingRequests() async {
    try {
      final requests = await _requestService.getPendingRequests();
      if (mounted) {
        setState(() {
          // Filter out duplicates by ID to avoid Dropdown assertion crashes
          final uniqueRequests = <String, RequestModel>{};
          for (final r in requests) {
            uniqueRequests[r.id] = r;
          }
          _pendingRequests = uniqueRequests.values.toList();
          _loadingRequests = false;
          // Match the prefilled request against the loaded list by ID
          // so DropdownButtonFormField gets the exact same instance
          if (widget.prefilledRequest != null) {
            final found = _pendingRequests.any((r) => r.id == widget.prefilledRequest!.id);
            if (!found) {
              _pendingRequests.insert(0, widget.prefilledRequest!);
            }
            _selectedRequest = _pendingRequests.firstWhere((r) => r.id == widget.prefilledRequest!.id);
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingRequests = false);
    }
  }

  @override
  void dispose() {
    _treeNameController.dispose();
    _speciesController.dispose();
    _notesController.dispose();
    _coordsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickGeotaggedPhoto(ImageSource source) async {
    setState(() => _isCapturing = true);
    try {
      if (source == ImageSource.camera) {
        // Request camera and location permissions BEFORE leaving the app for the camera
        final camGranted = await _locationService.requestCameraPermission();
        final locGranted = await _locationService.requestLocationPermission();
        
        if (!camGranted) {
          _showError('Camera permission is required');
          setState(() => _isCapturing = false);
          return;
        }
        if (!locGranted) {
          _showError('Location permission is heavily recommended to accurately map the tree.');
          // We do not return here, we still try to get EXIF GPS. If both fail, we'll error out later.
        }
      }

      // Open camera or gallery — do NOT set imageQuality for camera, it strips EXIF metadata
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) {
        setState(() => _isCapturing = false);
        return;
      }

      final photoFile = File(pickedFile.path);
      double? lat;
      double? lng;
      String gpsSource = '';

      // Strategy: EXIF first, device GPS fallback
      // 1) Try extracting GPS from the photo's EXIF metadata
      final exifGps = await ExifService.extractGpsFromFile(photoFile);
      if (exifGps != null) {
        lat = exifGps.lat;
        lng = exifGps.lng;
        gpsSource = 'exif';
        debugPrint('GPS from photo EXIF: $lat, $lng');
      }

      // 2) If no EXIF GPS, fall back to device GPS
      if (lat == null || lng == null) {
        final position = await _locationService.getCurrentPosition();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
          gpsSource = 'device';
          debugPrint('GPS from device: $lat, $lng');
        }
      }

      // 3) If we still have no GPS, warn the user but keep the photo
      if (lat == null || lng == null) {
        if (mounted) {
          _showError(
              'Could not get GPS from photo or device. Please enable location services and try again.');
          setState(() {
            _capturedPhoto = photoFile;
            _isCapturing = false;
            _gpsSource = '';
          });
        }
        return;
      }

      // Reverse geocode the coordinates to a human-readable address
      final address =
          await _locationService.getAddressFromCoordinates(lat, lng);

      if (mounted) {
        setState(() {
          _capturedPhoto = photoFile;
          _latitude = lat;
          _longitude = lng;
          _gpsSource = gpsSource;
          _coordsController.text =
              'Lat: ${lat!.toStringAsFixed(4)}, Lng: ${lng!.toStringAsFixed(4)}';
          _locationController.text = address;
          _isCapturing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Error capturing photo: $e');
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B4332),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      // Show a warning but allow submission for testing
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No GPS Location'),
          content: const Text(
              'No geotagged photo was taken. The tree will be saved without precise coordinates.\n\nDo you want to continue?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Continue',
                    style: TextStyle(color: Color(0xFF1B4332)))),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Upload photo
      String? photoUrl;
      if (_capturedPhoto != null) {
        photoUrl = await _storageService.uploadTreePhoto(
            _capturedPhoto!, 'new-tree');
      }

      final uuid = const Uuid().v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final generatedTreeId = 'MMT-$timestamp-${uuid.substring(0, 4)}';
      final qrCodeUrl = 'https://mapmytree.app/tree/$generatedTreeId';

      // Insert tree
      final treeData = <String, dynamic>{
        'tree_id': generatedTreeId,
        'qr_code_url': qrCodeUrl,
        'planted_by': SessionHelper.userName,
        'scientific_name': _speciesController.text.trim(),
        'ngo_id': SessionHelper.userId,
        'tree_name': _treeNameController.text.trim(),
        'tree_species': _speciesController.text.trim(),
        'planted_date': _selectedDate.toIso8601String().split('T')[0],
        'latitude': _latitude,
        'longitude': _longitude,
        'exact_location': _locationController.text,
        'photo_urls': photoUrl != null ? [photoUrl] : [],
        'notes': _notesController.text.trim(),
        'health_status': 'healthy',
      };
      
      if (_selectedRequest != null) {
        treeData['request_id'] = _selectedRequest!.id;
        treeData['planted_for_user_id'] = _selectedRequest!.userId;
      }
      
      await _treeService.insertTree(treeData);

      // Update linked request status
      if (_selectedRequest != null) {
        await _requestService.updateRequestStatus(
            _selectedRequest!.id, 'completed');
      }

      if (mounted) {
        // Reset form immediately
        _formKey.currentState!.reset();
        _treeNameController.clear();
        _speciesController.clear();
        _notesController.clear();
        _coordsController.clear();
        _locationController.clear();
        setState(() {
          _capturedPhoto = null;
          _latitude = null;
          _longitude = null;
          _gpsSource = '';
          _selectedRequest = null;
          _selectedDate = DateTime.now();
          _isSubmitting = false;
        });

        // Show Success Info Card with QR and direct Share capability
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
                    ),
                    const SizedBox(height: 16),
                    const Text('Tree Successfully Planted!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
                    const SizedBox(height: 8),
                    const Text('Here is the official Information Card and QR Code for your new tree.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 24),

                    // Unique DB Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text('UNIQUE TREE ID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(generatedTreeId, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B4332))),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          QrImageView(
                            data: qrCodeUrl,
                            version: QrVersions.auto,
                            size: 150.0,
                            backgroundColor: Colors.transparent,
                          ),
                          const SizedBox(height: 12),
                          const Text('Scan this QR in the app to view tree details',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share Info Card URL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B4332),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          SharePlus.instance.share(ShareParams(text: 'Check out this newly planted tree!\nTree ID: $generatedTreeId\nView here: $qrCodeUrl'));
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to add tree: $e');
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Tree 🌳',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B4332),
                    fontFamily: 'Nunito')),
            const SizedBox(height: 4),
            const Text('Log a newly planted tree with geotagging',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),

            // Tree name
            _buildLabel('Tree Name *'),
            TextFormField(
              controller: _treeNameController,
              decoration: _inputDecoration('e.g. Banyan Tree'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Tree species
            _buildLabel('Tree Species *'),
            TextFormField(
              controller: _speciesController,
              decoration: _inputDecoration('e.g. Ficus benghalensis'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Planted for (dropdown)
            _buildLabel('Planted For (Request)'),
            _loadingRequests
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<RequestModel>(
                    initialValue: _selectedRequest,
                    isExpanded: true,
                    decoration: _inputDecoration('Select a pending request'),
                    items: [
                      const DropdownMenuItem<RequestModel>(
                        value: null,
                        child: Text('None (general planting)',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      ..._pendingRequests.map((req) =>
                          DropdownMenuItem<RequestModel>(
                            value: req,
                            child: Text(
                                '${req.treeType} — ${req.userName ?? 'Unknown'}',
                                overflow: TextOverflow.ellipsis),
                          )),
                    ],
                    onChanged: (v) => setState(() => _selectedRequest = v),
                  ),
            const SizedBox(height: 16),

            // Planting date
            _buildLabel('Planting Date'),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: _inputDecoration(''),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                    const Icon(Icons.calendar_today,
                        size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            _buildLabel('Notes'),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: _inputDecoration('Any additional notes...'),
            ),
            const SizedBox(height: 24),

            // Geotagged photo section
            _buildLabel('Geotagged Photo *'),
            const SizedBox(height: 8),

            // Photo preview
            if (_capturedPhoto != null)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(
                    image: FileImage(_capturedPhoto!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // GPS Coordinates chip + source indicator
            if (_latitude != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _gpsSource == 'exif'
                      ? Colors.blue.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _gpsSource == 'exif'
                        ? Colors.blue.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _gpsSource == 'exif'
                          ? Icons.camera_alt
                          : Icons.gps_fixed,
                      size: 16,
                      color: _gpsSource == 'exif'
                          ? Colors.blue.shade700
                          : Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _gpsSource == 'exif'
                                ? 'GPS from photo EXIF'
                                : 'GPS from device',
                            style: TextStyle(
                              fontSize: 11,
                              color: _gpsSource == 'exif'
                                  ? Colors.blue.shade700
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _gpsSource == 'exif'
                                  ? Colors.blue.shade700
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                   Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isCapturing ? null : () => _pickGeotaggedPhoto(ImageSource.camera),
                      icon: _isCapturing
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1B4332),
                        side: const BorderSide(color: Color(0xFF1B4332)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isCapturing ? null : () => _pickGeotaggedPhoto(ImageSource.gallery),
                      icon: _isCapturing
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.photo_library),
                      label: const Text('Gallery (EXIF)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1B4332),
                        side: const BorderSide(color: Color(0xFF1B4332)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Coordinates (read-only)
            _buildLabel('Coordinates'),
            TextFormField(
              controller: _coordsController,
              readOnly: true,
              decoration: _inputDecoration('Auto-filled after photo'),
            ),
            const SizedBox(height: 16),

            // Exact location (read-only)
            _buildLabel('Exact Location'),
            TextFormField(
              controller: _locationController,
              readOnly: true,
              decoration: _inputDecoration('Auto-filled via reverse geocoding'),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('🌱 Plant Tree',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(text,
          style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 13)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: Colors.grey.withValues(alpha: 0.6), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1B4332))),
    );
  }
}
