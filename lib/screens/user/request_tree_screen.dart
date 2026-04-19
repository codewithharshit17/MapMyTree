import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/session_helper.dart';
import '../../models/request_model.dart';
import '../../services/request_service.dart';

// ── Maharashtra NGO plantation trees with exact costs ─────────────────────
class _PlantOption {
  final String name;
  final String localName;
  final int costRs;
  final String emoji;

  const _PlantOption({
    required this.name,
    required this.localName,
    required this.costRs,
    required this.emoji,
  });

  String get costLabel => '₹$costRs (sapling + planting)';
}

const List<_PlantOption> _plantOptions = [
  _PlantOption(name: 'Neem',          localName: 'Nimb',      costRs: 35,  emoji: '🌿'),
  _PlantOption(name: 'Banyan',        localName: 'Vad',       costRs: 90,  emoji: '🌳'),
  _PlantOption(name: 'Peepal',        localName: 'Pimpal',    costRs: 65,  emoji: '🍃'),
  _PlantOption(name: 'Mango',         localName: 'Amba',      costRs: 55,  emoji: '🥭'),
  _PlantOption(name: 'Tamarind',      localName: 'Chincha',   costRs: 50,  emoji: '🌱'),
  _PlantOption(name: 'Amla',          localName: 'Avla',      costRs: 45,  emoji: '🫐'),
  _PlantOption(name: 'Teak',          localName: 'Sag',       costRs: 75,  emoji: '🪵'),
  _PlantOption(name: 'Bamboo',        localName: 'Baans',     costRs: 30,  emoji: '🎋'),
  _PlantOption(name: 'Jackfruit',     localName: 'Phanas',    costRs: 60,  emoji: '🍈'),
  _PlantOption(name: 'Kadamba',       localName: 'Kadamba',   costRs: 40,  emoji: '🌸'),
  _PlantOption(name: 'Arjun',         localName: 'Arjun',     costRs: 45,  emoji: '🌲'),
  _PlantOption(name: 'Karanj',        localName: 'Karanj',    costRs: 35,  emoji: '🌾'),
  _PlantOption(name: 'Subabul',       localName: 'Subabul',   costRs: 25,  emoji: '🌿'),
  _PlantOption(name: 'Drumstick',     localName: 'Shevaga',   costRs: 40,  emoji: '🥦'),
  _PlantOption(name: 'Custard Apple', localName: 'Sitaphal',  costRs: 50,  emoji: '🍏'),
];
// ──────────────────────────────────────────────────────────────────────────

class RequestTreeScreen extends StatefulWidget {
  const RequestTreeScreen({super.key});
  @override
  State<RequestTreeScreen> createState() => _RequestTreeScreenState();
}

class _RequestTreeScreenState extends State<RequestTreeScreen> {
  final _formKey = GlobalKey<FormState>();
  _PlantOption? _selectedPlant;
  final _treeNameCtrl = TextEditingController();
  final _requestService = RequestService();
  bool _isSubmitting = false;
  File? _paymentScreenshot;
  bool _showQr = false;

  String? _selectedOccasion;
  DateTime? _occasionDate;
  final List<String> _occasions = ['Birthday', 'Anniversary', 'In Memory', 'Other'];
  final _customOccasionCtrl = TextEditingController();

  @override
  void dispose() {
    _treeNameCtrl.dispose();
    _customOccasionCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _occasionDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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
    if (picked != null && picked != _occasionDate) {
      setState(() {
        _occasionDate = picked;
      });
    }
  }

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _paymentScreenshot = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      String? screenshotUrl;
      if (_paymentScreenshot != null) {
        screenshotUrl = await _requestService.uploadPaymentScreenshot(
          _paymentScreenshot!,
          SessionHelper.userId,
        );
      }

      final occasionValue = _selectedOccasion == 'Other' 
            ? (_customOccasionCtrl.text.trim().isNotEmpty ? _customOccasionCtrl.text.trim() : 'Other')
            : _selectedOccasion;

      await _requestService.createRequest(
        userId: SessionHelper.userId,
        treeType: _selectedPlant!.name,
        treeName: _treeNameCtrl.text.trim().isNotEmpty ? _treeNameCtrl.text.trim() : null,
        occasion: occasionValue,
        occasionDate: _selectedOccasion == 'Other' ? null : _occasionDate?.toIso8601String(),
        description: null,
        plantCost: _selectedPlant!.costRs,
        paymentScreenshotUrl: screenshotUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(screenshotUrl != null
              ? '🌱 Request submitted! Payment under verification.'
              : '🌱 Request submitted! Please complete payment.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        _formKey.currentState!.reset();
        setState(() {
          _selectedPlant = null;
          _selectedOccasion = null;
          _occasionDate = null;
          _paymentScreenshot = null;
          _showQr = false;
          _isSubmitting = false;
        });
        _treeNameCtrl.clear();
        _customOccasionCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        const Text(
          'Request a Tree 🌱',
          style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800,
            color: Color(0xFF1B4332), fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Choose a plant and complete payment to confirm your request',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 24),

        Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Plant Dropdown ──────────────────────────────────────────────
            _label('Select Plant *'),
            DropdownButtonFormField<_PlantOption>(
              value: _selectedPlant,
              isExpanded: true,
              itemHeight: 60,
              decoration: _dec('Choose a plant...'),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1B4332)),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(14),
              items: _plantOptions.map((plant) {
                return DropdownMenuItem<_PlantOption>(
                  value: plant,
                  child: Row(children: [
                    Text(plant.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${plant.name} (${plant.localName})',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '₹${plant.costRs}',
                            style: const TextStyle(color: Color(0xFF2D6A4F), fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ]),
                );
              }).toList(),
              onChanged: (val) => setState(() {
                _selectedPlant = val;
                _showQr = val != null;
              }),
              validator: (val) => val == null ? 'Please select a plant' : null,
            ),

            // ── Cost Info Card ─────────────────────────────────────────────
            if (_selectedPlant != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8F3DC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF95D5B2)),
                ),
                child: Row(children: [
                  const Icon(Icons.payments_rounded, color: Color(0xFF1B4332), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Color(0xFF1B4332), fontSize: 13),
                        children: [
                          const TextSpan(
                            text: 'Total amount: ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: '₹${_selectedPlant!.costRs}',
                            style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(text: '  (includes sapling + planting)'),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ],

            const SizedBox(height: 16),
            _label("Tree's Name (Optional)"),
            TextFormField(
              controller: _treeNameCtrl,
              decoration: _dec('e.g., Arjun\'s Neem'),
            ),

            const SizedBox(height: 16),
            _label('Occasion (Optional)'),
            DropdownButtonFormField<String>(
              value: _selectedOccasion,
              decoration: _dec('Select Occasion'),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1B4332)),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(14),
              items: _occasions.map((occ) {
                return DropdownMenuItem(value: occ, child: Text(occ));
              }).toList(),
              onChanged: (val) => setState(() => _selectedOccasion = val),
            ),

            if (_selectedOccasion == 'Other') ...[
              const SizedBox(height: 16),
              _label('Please specify the occasion'),
              TextFormField(
                controller: _customOccasionCtrl,
                decoration: _dec('e.g., Graduation, New Job'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter an occasion' : null,
              ),
            ] else if (_selectedOccasion != null) ...[
              const SizedBox(height: 16),
              _label('Occasion Date'),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _occasionDate == null 
                            ? 'Select Date' 
                            : DateFormat('MMM dd, yyyy').format(_occasionDate!),
                        style: TextStyle(color: _occasionDate == null ? Colors.grey.shade600 : Colors.black87, fontSize: 15),
                      ),
                      const Icon(Icons.calendar_today_rounded, color: Color(0xFF1B4332), size: 20),
                    ],
                  ),
                ),
              ),
            ],

            // ── GPay QR Section ────────────────────────────────────────────
            if (_showQr && _selectedPlant != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(children: [
                  // Header bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B4332),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Scan & Pay via Google Pay',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // QR Image
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/gpay_qr.png',
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'UPI ID: mapmytree@oksbi',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount: ₹${_selectedPlant!.costRs}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1B4332),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ]),
                  ),
                  // Instructions
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFD166)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFF4A261), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'After paying, take a screenshot of the payment confirmation and upload it below. The NGO will verify and confirm your request.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF7D5A00)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),

              // ── Payment Screenshot Upload ──────────────────────────────
              const SizedBox(height: 20),
              _label('Upload Payment Screenshot *'),
              GestureDetector(
                onTap: _pickScreenshot,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 120),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _paymentScreenshot != null
                          ? const Color(0xFF2D6A4F)
                          : const Color(0xFFE0E0E0),
                      width: _paymentScreenshot != null ? 2 : 1,
                    ),
                  ),
                  child: _paymentScreenshot == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            Icon(Icons.upload_file_rounded, size: 40, color: Color(0xFF1B4332)),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload payment screenshot',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'JPG, PNG supported',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                            SizedBox(height: 20),
                          ],
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.file(
                                _paymentScreenshot!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8, right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _paymentScreenshot = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8, left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D6A4F),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(children: [
                                  Icon(Icons.check_circle, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Screenshot selected',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ]),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '* Payment verification is required before tree planting begins',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'My Requests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B4332)),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<RequestModel>>(
          stream: _requestService.streamUserRequests(SessionHelper.userId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final reqs = snap.data ?? [];
            if (reqs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No requests yet', style: TextStyle(color: Colors.grey)),
                ),
              );
            }
            return Column(children: reqs.map((r) => _RequestHistoryCard(request: r)).toList());
          },
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 4),
    child: Text(t, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13)),
  );

  InputDecoration _dec(String h) => InputDecoration(
    hintText: h,
    filled: true,
    fillColor: const Color(0xFFF9F9F9),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1B4332))),
  );
}

class _RequestHistoryCard extends StatelessWidget {
  final RequestModel request;
  const _RequestHistoryCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(request.statusEmoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(request.treeType, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            Text(
              DateFormat('dd MMM yyyy').format(request.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: request.isPending
                  ? Colors.orange.withValues(alpha: 0.15)
                  : request.isCompleted
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              request.statusLabel,
              style: TextStyle(
                color: request.isPending
                    ? Colors.orange
                    : request.isCompleted
                        ? Colors.green
                        : Colors.blue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ]),

        // Payment status badge
        if (request.plantCost != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const SizedBox(width: 34),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: request.isPaymentVerified
                    ? Colors.green.withValues(alpha: 0.1)
                    : request.isPaymentPendingVerification
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${request.paymentStatusLabel}  •  ₹${request.plantCost}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: request.isPaymentVerified
                      ? Colors.green.shade700
                      : request.isPaymentPendingVerification
                          ? Colors.blue.shade700
                          : Colors.red.shade700,
                ),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}
