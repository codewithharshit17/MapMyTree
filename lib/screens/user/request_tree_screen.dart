import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/session_helper.dart';
import '../../models/request_model.dart';
import '../../services/request_service.dart';

class RequestTreeScreen extends StatefulWidget {
  const RequestTreeScreen({super.key});
  @override
  State<RequestTreeScreen> createState() => _RequestTreeScreenState();
}

class _RequestTreeScreenState extends State<RequestTreeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _treeTypeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _requestService = RequestService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _treeTypeCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await _requestService.createRequest(
        userId: SessionHelper.userId,
        treeType: _treeTypeCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isNotEmpty ? _descriptionCtrl.text.trim() : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('🌱 Request submitted!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
        _formKey.currentState!.reset();
        _treeTypeCtrl.clear(); _descriptionCtrl.clear();
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Request a Tree 🌱', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1B4332), fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        const Text('Tell us what tree you want planted', style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 24),
        Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Tree Type *'),
          TextFormField(controller: _treeTypeCtrl, decoration: _dec('e.g. Neem, Banyan, Mango'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 16),
          _label('Reason / Description'),
          TextFormField(controller: _descriptionCtrl, maxLines: 3, decoration: _dec('Why you want this tree')),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4332), foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
        ])),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        const Text('My Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B4332))),
        const SizedBox(height: 12),
        StreamBuilder<List<RequestModel>>(
          stream: _requestService.streamUserRequests(SessionHelper.userId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final reqs = snap.data ?? [];
            if (reqs.isEmpty) {
              return const Center(child: Padding(padding: EdgeInsets.all(24),
                child: Text('No requests yet', style: TextStyle(color: Colors.grey))));
            }
            return Column(children: reqs.map((r) => _RequestHistoryCard(request: r)).toList());
          },
        ),
        const SizedBox(height: 32),
      ]),
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

class _RequestHistoryCard extends StatelessWidget {
  final RequestModel request;
  const _RequestHistoryCard({required this.request});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Row(children: [
        Text(request.statusEmoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(request.treeType, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          Text(DateFormat('dd MMM yyyy').format(request.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          if (request.preferredLocation != null) Text(request.preferredLocation!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: request.isPending ? Colors.orange.withValues(alpha: 0.15)
                : request.isCompleted ? Colors.green.withValues(alpha: 0.15)
                : Colors.blue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20)),
          child: Text(request.statusLabel, style: TextStyle(
            color: request.isPending ? Colors.orange : request.isCompleted ? Colors.green : Colors.blue,
            fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}
