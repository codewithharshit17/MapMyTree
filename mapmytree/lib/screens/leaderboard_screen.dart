import 'package:flutter/material.dart';
import '../app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<LeaderboardEntry> _leaders = [
    LeaderboardEntry('Arjun Mehta', '🌳', 142, 3.8, 'Mumbai', '#1'),
    LeaderboardEntry('Sunita Patel', '🌿', 128, 3.2, 'Bangalore', '#2'),
    LeaderboardEntry('Vikram Singh', '🍃', 115, 2.9, 'Delhi', '#3'),
    LeaderboardEntry('Priya Nair', '🌱', 98, 2.4, 'Chennai', '#4'),
    LeaderboardEntry('Rajesh Kumar', '🌲', 87, 2.1, 'Pune', '#5'),
    LeaderboardEntry('Deepa Sharma', '🍀', 74, 1.8, 'Hyderabad', '#6'),
    LeaderboardEntry('Ankit Gupta', '🌺', 68, 1.7, 'Jaipur', '#7'),
    LeaderboardEntry('Meera Iyer', '🌻', 62, 1.5, 'Kolkata', '#8'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildMyRankCard(),
            _buildTabBar(),
            Expanded(child: _buildLeaderboard()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      color: Colors.white,
      child: const Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rankings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.charcoal,
                ),
              ),
              Text(
                'Top tree planters worldwide',
                style: TextStyle(fontSize: 14, color: AppTheme.grey),
              ),
            ],
          ),
          Spacer(),
          Text('🏆', style: TextStyle(fontSize: 36)),
        ],
      ),
    );
  }

  Widget _buildMyRankCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Ranking',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'You • #23',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '24 trees',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '0.6 tons CO₂',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryGreen,
        unselectedLabelColor: AppTheme.grey,
        indicatorColor: AppTheme.primaryGreen,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Global'),
          Tab(text: 'Monthly'),
          Tab(text: 'Friends'),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildListView(),
        _buildListView(),
        _buildFriendsView(),
      ],
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _leaders.length,
      itemBuilder: (context, index) {
        return _buildLeaderCard(_leaders[index], index);
      },
    );
  }

  Widget _buildLeaderCard(LeaderboardEntry entry, int index) {
    final isTop3 = index < 3;
    final medalColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTop3
            ? medalColors[index].withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isTop3
            ? Border.all(color: medalColors[index].withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: Center(
              child: isTop3
                  ? Text(
                      ['🥇', '🥈', '🥉'][index],
                      style: const TextStyle(fontSize: 24),
                    )
                  : Text(
                      entry.rank,
                      style: const TextStyle(
                        color: AppTheme.grey,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isTop3
                  ? medalColors[index].withValues(alpha: 0.2)
                  : AppTheme.paleGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.charcoal,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppTheme.grey),
                    const SizedBox(width: 2),
                    Text(
                      entry.city,
                      style: const TextStyle(
                          color: AppTheme.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.trees} trees',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isTop3
                      ? medalColors[index]
                      : AppTheme.primaryGreen,
                ),
              ),
              Text(
                '${entry.co2}t CO₂',
                style: const TextStyle(
                    color: AppTheme.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('👥', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text(
            'Connect with Friends',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.charcoal,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Invite friends to see how\nyou compare!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class LeaderboardEntry {
  final String name;
  final String emoji;
  final int trees;
  final double co2;
  final String city;
  final String rank;

  LeaderboardEntry(
      this.name, this.emoji, this.trees, this.co2, this.city, this.rank);
}
