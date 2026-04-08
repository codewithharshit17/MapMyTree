import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/auth_service.dart';
import '../../services/new_tree_service.dart';
import '../../models/new_tree_model.dart';
import 'package:intl/intl.dart';
import '../../widgets/tree_detail_bottom_sheet.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  final NewTreeService _treeService = NewTreeService();

  ProfileModel? _profile;
  List<NewTreeModel> _trees = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getProfileModel(widget.userId);
      if (profile == null) {
        setState(() {
          _error = 'User not found in the database.';
          _isLoading = false;
        });
        return;
      }

      final List<NewTreeModel> trees;
      if (profile.role == 'ngo') {
        trees = await _treeService.getTreesForNgo(widget.userId);
      } else {
        trees = await _treeService.getTreesForUser(widget.userId);
      }

      setState(() {
        _profile = profile;
        _trees = trees;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() {
        _error = 'Failed to load user profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        title: Text(_profile?.role == 'ngo' ? 'NGO Profile' : 'User Profile', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final joinedDate = DateFormat('MMMM d, yyyy').format(_profile!.createdAt);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            color: const Color(0xFF1B4332),
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40, top: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: _profile!.avatarUrl != null ? NetworkImage(_profile!.avatarUrl!) : null,
                  child: _profile!.avatarUrl == null
                      ? Text(
                          _profile!.initials,
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _profile!.displayName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _profile!.email ?? 'No email provided',
                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Joined $joinedDate',
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Total Impact Stats
          Transform.translate(
            offset: const Offset(0, -20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Total Trees', _trees.length.toString(), Icons.eco, Colors.green),
                      Container(height: 40, width: 1, color: Colors.grey.shade300),
                      _buildStatColumn('Requests', '-', Icons.inbox, Colors.orange), // Future expansion
                      Container(height: 40, width: 1, color: Colors.grey.shade300),
                      _buildStatColumn('Updates', '-', Icons.history, Colors.blue), // Future expansion
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Trees Planted for this user
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile!.role == 'ngo' ? 'Trees Planted by NGO' : 'Trees Planted for User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                ),
                const SizedBox(height: 16),
                if (_trees.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.nature, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text('No trees planted yet.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _trees.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tree = _trees[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B4332).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.park, color: Color(0xFF1B4332)),
                          ),
                          title: Text(tree.treeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Planted: ${DateFormat('MMM d, yyyy').format(tree.plantingDate)}\nID: ${tree.treeId}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                          isThreeLine: true,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => TreeDetailBottomSheet(tree: tree, isNgo: true),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
