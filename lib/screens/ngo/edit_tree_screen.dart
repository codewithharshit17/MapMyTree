import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/session_helper.dart';
import '../../models/new_tree_model.dart';
import '../../models/tree_update_model.dart';
import '../../services/new_tree_service.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';

class EditTreeScreen extends StatefulWidget {
  final NewTreeModel tree;
  const EditTreeScreen({super.key, required this.tree});
  @override
  State<EditTreeScreen> createState() => _EditTreeScreenState();
}

class _EditTreeScreenState extends State<EditTreeScreen> {
  final _treeService = NewTreeService();
  final _storageService = StorageService();
  final _notificationService = NotificationService();
  late TextEditingController _notesCtrl;
  late TextEditingController _speciesCtrl;
  late String _healthStatus;
  bool _isSaving = false;
  // Update form
  final _updateNoteCtrl = TextEditingController();
  File? _updatePhoto;
  bool _isPostingUpdate = false;
  List<TreeUpdateModel> _updates = [];
  bool _loadingUpdates = true;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.tree.notes ?? '');
    _speciesCtrl = TextEditingController(text: widget.tree.treeSpecies ?? '');
    _healthStatus = widget.tree.healthStatus;
    _loadUpdates();
  }

  Future<void> _loadUpdates() async {
    final updates = await _treeService.getTreeUpdates(widget.tree.id);
    if (mounted) setState(() { _updates = updates; _loadingUpdates = false; });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _speciesCtrl.dispose();
    _updateNoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveTree() async {
    setState(() => _isSaving = true);
    try {
      await _treeService.updateTree(widget.tree.id, {
        'notes': _notesCtrl.text.trim(),
        'tree_species': _speciesCtrl.text.trim(),
        'health_status': _healthStatus,
      });

      if (widget.tree.plantedForUserId != null && widget.tree.plantedForUserId!.isNotEmpty) {
        await _notificationService.createNotification(
          userId: widget.tree.plantedForUserId!,
          title: 'Tree Details Updated',
          message: 'An NGO just updated the details for your tree: ${widget.tree.treeName}',
          type: 'tree_update',
          relatedTreeId: widget.tree.id,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Tree updated!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _postUpdate() async {
    if (_updateNoteCtrl.text.trim().isEmpty) return;
    setState(() => _isPostingUpdate = true);
    try {
      List<String> photoUrls = [];
      if (_updatePhoto != null) {
        final url = await _storageService.uploadUpdatePhoto(_updatePhoto!, widget.tree.id);
        if (url != null) photoUrls.add(url);
      }
      await _treeService.insertTreeUpdate({
        'tree_id': widget.tree.id,
        'ngo_id': SessionHelper.userId,
        'update_note': _updateNoteCtrl.text.trim(),
        'photo_urls': photoUrls,
        'health_status': _healthStatus,
      });

      if (widget.tree.plantedForUserId != null && widget.tree.plantedForUserId!.isNotEmpty) {
        await _notificationService.createNotification(
          userId: widget.tree.plantedForUserId!,
          title: 'New Tree Progress!',
          message: 'An NGO posted a new update and photo for your tree: ${widget.tree.treeName}',
          type: 'tree_update',
          relatedTreeId: widget.tree.id,
          imageUrl: photoUrls.isNotEmpty ? photoUrls.first : null,
        );
      }

      _updateNoteCtrl.clear();
      setState(() { _updatePhoto = null; });
      await _loadUpdates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update posted!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _isPostingUpdate = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Tree'), backgroundColor: const Color(0xFF1B4332), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.tree.treeName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1B4332), fontFamily: 'Nunito')),
          const SizedBox(height: 24),
          _label('Tree Species'),
          TextField(controller: _speciesCtrl, decoration: _dec('Species')),
          const SizedBox(height: 16),
          _label('Notes'),
          TextField(controller: _notesCtrl, maxLines: 3, decoration: _dec('Notes')),
          const SizedBox(height: 16),
          _label('Health Status'),
          DropdownButtonFormField<String>(
            initialValue: _healthStatus,
            decoration: _dec(''),
            items: const [
              DropdownMenuItem(value: 'healthy', child: Text('💚 Healthy')),
              DropdownMenuItem(value: 'needs_attention', child: Text('🟡 Needs Attention')),
              DropdownMenuItem(value: 'dead', child: Text('🔴 Dead')),
            ],
            onChanged: (v) { if (v != null) { setState(() => _healthStatus = v); } },
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _isSaving ? null : _saveTree,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4332), foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
          )),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Add Progress Update', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B4332))),
          const SizedBox(height: 12),
          TextField(controller: _updateNoteCtrl, maxLines: 2, decoration: _dec('What changed?')),
          const SizedBox(height: 12),
          if (_updatePhoto != null)
            Container(height: 120, width: double.infinity, margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: FileImage(_updatePhoto!), fit: BoxFit.cover))),
          Row(children: [
            OutlinedButton.icon(
              onPressed: () async {
                final p = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
                if (p != null) setState(() => _updatePhoto = File(p.path));
              },
              icon: const Icon(Icons.camera_alt, size: 16), label: const Text('Photo'),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1B4332), side: const BorderSide(color: Color(0xFF1B4332))),
            ),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: _isPostingUpdate ? null : _postUpdate,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D6A4F), foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: _isPostingUpdate ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Post Update'),
            )),
          ]),
          const SizedBox(height: 28),
          const Text('Update History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1B4332))),
          const SizedBox(height: 12),
          if (_loadingUpdates) const Center(child: CircularProgressIndicator())
          else if (_updates.isEmpty) const Text('No updates yet', style: TextStyle(color: Colors.grey))
          else ..._updates.map((u) => _UpdateTile(update: u)),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6, left: 4),
    child: Text(t, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13)));
  InputDecoration _dec(String h) => InputDecoration(hintText: h, filled: true, fillColor: const Color(0xFFF9F9F9),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1B4332))));
}

class _UpdateTile extends StatelessWidget {
  final TreeUpdateModel update;
  const _UpdateTile({required this.update});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.update, size: 16, color: Color(0xFF2D6A4F)),
          const SizedBox(width: 8),
          Text(DateFormat('dd MMM yyyy, hh:mm a').format(update.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          if (update.healthStatus != null) ...[
            const Spacer(),
            Text(update.healthStatus == 'healthy' ? '💚' : update.healthStatus == 'needs_attention' ? '🟡' : '🔴', style: const TextStyle(fontSize: 14)),
          ],
        ]),
        if (update.updateNote != null) ...[const SizedBox(height: 8), Text(update.updateNote!, style: const TextStyle(fontSize: 14))],
        if (update.photoUrls.isNotEmpty) ...[const SizedBox(height: 8),
          SizedBox(height: 80, child: ListView(scrollDirection: Axis.horizontal, children: update.photoUrls.map((url) =>
            Container(width: 80, height: 80, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)))).toList()))],
      ]),
    );
  }
}
