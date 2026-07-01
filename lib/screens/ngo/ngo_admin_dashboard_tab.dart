import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/master_data_service.dart';
import '../../services/volunteer_service.dart';
import '../../services/new_tree_service.dart';
import '../../models/profile_model.dart';
import '../../models/new_tree_model.dart';

class NgoAdminDashboardTab extends StatefulWidget {
  const NgoAdminDashboardTab({super.key});

  @override
  State<NgoAdminDashboardTab> createState() => _NgoAdminDashboardTabState();
}

class _NgoAdminDashboardTabState extends State<NgoAdminDashboardTab> {
  final _masterService = MasterDataService();
  final _volunteerService = VolunteerService();
  final _treeService = NewTreeService();

  int _selectedPanelIndex = 0; // 0: Volunteers, 1: Species, 2: Locations, 3: Categories
  bool _isLoading = false;

  // Cached lists
  List<ProfileModel> _volunteers = [];
  List<TreeSpecies> _species = [];
  List<PlantationLocation> _locations = [];
  List<TreeCategory> _categories = [];
  List<NewTreeModel> _allTrees = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _volunteerService.getVolunteers(),
        _masterService.getTreeSpecies(),
        _masterService.getPlantationLocations(),
        _masterService.getCategories(),
        _treeService.getTreesForNgo(''), // ngoId empty fetches all or matches cached
      ]);

      setState(() {
        _volunteers = results[0] as List<ProfileModel>;
        _species = results[1] as List<TreeSpecies>;
        _locations = results[2] as List<PlantationLocation>;
        _categories = results[3] as List<TreeCategory>;
        _allTrees = results[4] as List<NewTreeModel>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading admin data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF1B4332),
      onRefresh: _loadAllData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Text(
                      'NGO Control Center ⚙️',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B4332),
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Manage master data, volunteers, and analyze logs',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Segmented horizontal pills selector
                  _buildPanelSelector(),

                  // Selected panel body
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildSelectedPanel(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPanelSelector() {
    final icons = [
      Icons.people_alt_outlined,
      Icons.eco_outlined,
      Icons.location_on_outlined,
      Icons.category_outlined,
    ];
    final labels = ['Volunteers', 'Species', 'Locations', 'Categories'];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final isSelected = _selectedPanelIndex == idx;
          return GestureDetector(
            onTap: () => setState(() => _selectedPanelIndex = idx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1B4332) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? const Color(0xFF1B4332) : Colors.grey.shade200,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: const Color(0xFF1B4332).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    icons[idx],
                    size: 18,
                    color: isSelected ? Colors.white : const Color(0xFF1B4332),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    labels[idx],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedPanel() {
    switch (_selectedPanelIndex) {
      case 0:
        return _buildVolunteersPanel();
      case 1:
        return _buildSpeciesPanel();
      case 2:
        return _buildLocationsPanel();
      case 3:
        return _buildCategoriesPanel();
      default:
        return const SizedBox.shrink();
    }
  }




  Widget _buildMetricCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. VOLUNTEERS PANEL ───────────────────────────────────────────────────

  Widget _buildVolunteersPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Volunteers (${_volunteers.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
            ),
            ElevatedButton.icon(
              onPressed: _showAddVolunteerDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Volunteer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4332),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _volunteers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, idx) {
            final vol = _volunteers[idx];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
                    child: Text(
                      vol.initials,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vol.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(vol.email ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(vol.phoneNumber ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Switch.adaptive(
                        activeTrackColor: const Color(0xFF1B4332),
                        value: vol.isActive,
                        onChanged: (val) async {
                          final updated = ProfileModel(
                            id: vol.id,
                            fullName: vol.fullName,
                            email: vol.email,
                            phoneNumber: vol.phoneNumber,
                            isVerified: vol.isVerified,
                            role: vol.role,
                            createdAt: vol.createdAt,
                            avatarUrl: vol.avatarUrl,
                            isActive: val,
                          );
                          await _volunteerService.updateVolunteer(updated);
                          _loadAllData();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        onPressed: () => _confirmDeleteVolunteer(vol),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddVolunteerDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Volunteer Account', style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name *'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email Address *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone Number *'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: 'Password *'),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4332), foregroundColor: Colors.white),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                await _volunteerService.createVolunteer(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  password: passCtrl.text,
                );
                _loadAllData();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVolunteer(ProfileModel vol) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Volunteer'),
        content: Text('Are you sure you want to delete ${vol.displayName}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              await _volunteerService.deleteVolunteer(vol.id);
              _loadAllData();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ─── 3. SPECIES PANEL ──────────────────────────────────────────────────────

  Widget _buildSpeciesPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tree Species (${_species.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddEditSpeciesDialog(null),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Species'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4332),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _species.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, idx) {
            final sp = _species[idx];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B4332).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(sp.emoji, style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${sp.commonName} (${sp.name})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Category: ${sp.category} • Cost: ₹${sp.cost.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                        onPressed: () => _showAddEditSpeciesDialog(sp),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _confirmDeleteSpecies(sp),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddEditSpeciesDialog(TreeSpecies? existing) {
    final formKey = GlobalKey<FormState>();
    final sciNameCtrl = TextEditingController(text: existing?.name ?? '');
    final comNameCtrl = TextEditingController(text: existing?.commonName ?? '');
    final costCtrl = TextEditingController(text: existing != null ? existing.cost.toStringAsFixed(0) : '50');
    final emojiCtrl = TextEditingController(text: existing?.emoji ?? '🌳');
    String? selectedCategory = existing?.category;

    // Fallback if selected category is not in list
    if (selectedCategory != null && !_categories.any((c) => c.name == selectedCategory)) {
      selectedCategory = null;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Tree Species' : 'Edit Tree Species', style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: sciNameCtrl,
                  decoration: const InputDecoration(labelText: 'Scientific Name *', hintText: 'e.g. Ficus religiosa'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: comNameCtrl,
                  decoration: const InputDecoration(labelText: 'Common Name *', hintText: 'e.g. Peepal'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category *'),
                  items: _categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                  onChanged: (v) => selectedCategory = v,
                  validator: (v) => v == null ? 'Required' : null,
                ),
                TextFormField(
                  controller: costCtrl,
                  decoration: const InputDecoration(labelText: 'Sapling Cost (INR) *'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || double.tryParse(v) == null ? 'Must be a valid number' : null,
                ),
                TextFormField(
                  controller: emojiCtrl,
                  decoration: const InputDecoration(labelText: 'Emoji Icon'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4332), foregroundColor: Colors.white),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                final updated = TreeSpecies(
                  id: existing?.id ?? 'sp-${DateTime.now().millisecondsSinceEpoch}',
                  name: sciNameCtrl.text.trim(),
                  commonName: comNameCtrl.text.trim(),
                  category: selectedCategory ?? 'General',
                  cost: double.parse(costCtrl.text.trim()),
                  emoji: emojiCtrl.text.trim(),
                );
                await _masterService.saveTreeSpecies(updated);
                _loadAllData();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSpecies(TreeSpecies sp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Species'),
        content: Text('Are you sure you want to delete ${sp.commonName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              await _masterService.deleteTreeSpecies(sp.id);
              _loadAllData();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ─── 4. LOCATIONS PANEL ────────────────────────────────────────────────────

  Widget _buildLocationsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Plantation Locations (${_locations.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddEditLocationDialog(null),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Site'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4332),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _locations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, idx) {
            final loc = _locations[idx];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0077B6).withValues(alpha: 0.1),
                    child: const Icon(Icons.place, color: Color(0xFF0077B6)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(loc.city, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Switch.adaptive(
                        activeTrackColor: const Color(0xFF1B4332),
                        value: loc.isActive,
                        onChanged: (val) async {
                          final updated = PlantationLocation(
                            id: loc.id,
                            name: loc.name,
                            city: loc.city,
                            isActive: val,
                          );
                          await _masterService.savePlantationLocation(updated);
                          _loadAllData();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        onPressed: () => _confirmDeleteLocation(loc),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddEditLocationDialog(PlantationLocation? existing) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Plantation Site' : 'Edit Site', style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Location / Site Name *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: 'City *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4332), foregroundColor: Colors.white),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                final updated = PlantationLocation(
                  id: existing?.id ?? 'loc-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  city: cityCtrl.text.trim(),
                  isActive: existing?.isActive ?? true,
                );
                await _masterService.savePlantationLocation(updated);
                _loadAllData();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteLocation(PlantationLocation loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text('Are you sure you want to delete ${loc.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              await _masterService.deletePlantationLocation(loc.id);
              _loadAllData();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ─── 5. CATEGORIES PANEL ───────────────────────────────────────────────────

  Widget _buildCategoriesPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tree Categories (${_categories.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddEditCategoryDialog(null),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4332),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, idx) {
            final cat = _categories[idx];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF8338EC).withValues(alpha: 0.1),
                    child: const Icon(Icons.style, color: Color(0xFF8338EC)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(cat.description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                        onPressed: () => _showAddEditCategoryDialog(cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _confirmDeleteCategory(cat),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddEditCategoryDialog(TreeCategory? existing) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Category' : 'Edit Category', style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Category Name *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4332), foregroundColor: Colors.white),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                final updated = TreeCategory(
                  id: existing?.id ?? 'cat-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                );
                await _masterService.saveCategory(updated);
                _loadAllData();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(TreeCategory cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete ${cat.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              await _masterService.deleteCategory(cat.id);
              _loadAllData();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
