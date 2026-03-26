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

  // Request dropdown
  List<RequestModel> _pendingRequests = [];
  RequestModel? _selectedRequest;
  bool _loadingRequests = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
    if (widget.prefilledRequest != null) {
      _selectedRequest = widget.prefilledRequest;
    }
  }

  Future<void> _loadPendingRequests() async {
    try {
      final requests = await _requestService.getPendingRequests();
      if (mounted) {
        setState(() {
          _pendingRequests = requests;
          _loadingRequests = false;
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

  Future<void> _captureGeotaggedPhoto() async {
    setState(() => _isCapturing = true);
    try {
      // Request camera permission
      final camGranted = await _locationService.requestCameraPermission();
      if (!camGranted) {
        _showError('Camera permission is required');
        setState(() => _isCapturing = false);
        return;
      }

      // Open camera
      final picker = ImagePicker();
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (pickedFile == null) {
        setState(() => _isCapturing = false);
        return;
      }

      // Get GPS location
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        _showError('Could not get GPS location. Please enable location services.');
        setState(() => _isCapturing = false);
        return;
      }

      // Reverse geocode
      final address = await _locationService.getAddressFromCoordinates(
          position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _capturedPhoto = File(pickedFile.path);
          _latitude = position.latitude;
          _longitude = position.longitude;
          _coordsController.text =
              'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
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
      _showError('Please capture a geotagged photo first');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Upload photo
      String? photoUrl;
      if (_capturedPhoto != null) {
        photoUrl = await _storageService.uploadTreePhoto(
            _capturedPhoto!, 'new-tree');
      }

      // Insert tree
      await _treeService.insertTree({
        'ngo_id': SessionHelper.userId,
        'request_id': _selectedRequest?.id,
        'planted_for_user_id': _selectedRequest?.userId,
        'tree_name': _treeNameController.text.trim(),
        'tree_species': _speciesController.text.trim(),
        'planting_date': _selectedDate.toIso8601String().split('T')[0],
        'latitude': _latitude,
        'longitude': _longitude,
        'exact_location': _locationController.text,
        'photo_urls': photoUrl != null ? [photoUrl] : [],
        'notes': _notesController.text.trim(),
        'health_status': 'healthy',
      });

      // Update linked request status
      if (_selectedRequest != null) {
        await _requestService.updateRequestStatus(
            _selectedRequest!.id, 'completed');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('🌳 Tree planted successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));

        // Reset form
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
          _selectedRequest = null;
          _selectedDate = DateTime.now();
          _isSubmitting = false;
        });
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

            // Capture button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isCapturing ? null : _captureGeotaggedPhoto,
                icon: _isCapturing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.camera_alt),
                label: Text(_capturedPhoto != null
                    ? '📷 Retake Photo'
                    : '📷 Click Geotagged Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B4332),
                  side: const BorderSide(color: Color(0xFF1B4332)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
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
