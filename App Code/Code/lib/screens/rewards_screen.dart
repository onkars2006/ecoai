import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _ecoPoints = 0;
  late Key _streamKey;

  @override
  void initState() {
    super.initState();
    _streamKey = UniqueKey();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await _createNewUserDocument(user.uid);
        }
        setState(() {
          _ecoPoints = (doc.data()?['points'] ?? 0) as int;
        });
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _createNewUserDocument(String uid) async {
    await _firestore.collection('users').doc(uid).set({
      'points': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'redeemed': [],
    });
  }

  void _handleRefresh() {
    setState(() {
      _streamKey = UniqueKey(); // Change key to force stream refresh
    });
    _loadUserData();
  }

  IconData _getIconData(String iconName) {
    const icons = {
      'park': Icons.park,
      'school': Icons.school,
      'people': Icons.people,
      'clean_hands': Icons.clean_hands,
      'electrical_services': Icons.electrical_services,
      'eco': Icons.eco,
    };
    return icons[iconName] ?? Icons.error;
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 40), // Add top padding for status bar
                child: _buildImpactDashboard(),
              ),
            ),
            
            SliverToBoxAdapter(
              child: _buildRewardsHeader(),
            ),
            _buildRewardsList(),
          ],
        ),
        Positioned(
          top: 30, // Adjust based on your status bar height
          right: 16,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
            )],
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.green.shade800),
              onPressed: _handleRefresh,
              tooltip: 'Refresh data',
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildImpactDashboard() {
    final co2Reduced = _ecoPoints / 10;
    final treesPlanted = _ecoPoints ~/ 500;
    final eWasteRecycled = _ecoPoints / 100;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Your Environmental Impact',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildImpactStat('CO₂ Reduced', '${co2Reduced.toStringAsFixed(1)}kg'),
                _buildImpactStat('Trees Planted', treesPlanted.toString()),
                _buildImpactStat('E-Waste Recycled', '${eWasteRecycled.toStringAsFixed(1)}kg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  

  Widget _buildChallengeCard(String title, int goal, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(right: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.green.shade800),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Goal: ${goal.toString()}pts'),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsHeader() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Available Rewards',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRewardsList() {
    return StreamBuilder<QuerySnapshot>(
      key: _streamKey, 
      stream: _firestore.collection('rewards').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Failed to load rewards: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final rewards = snapshot.data!.docs;

        if (rewards.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No rewards available yet!')),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildRewardCard(
              rewards[index].data() as Map<String, dynamic>,
              rewards[index].id,
            ),
            childCount: rewards.length,
          ),
        );
      },
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward, String rewardId) {
    final points = (reward['points'] as num).toInt();
    final canRedeem = _ecoPoints >= points;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          _getIconData(reward['icon']),
          color: Colors.green.shade800,
        ),
        title: Text(reward['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reward['impact']),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: _ecoPoints / points,
              minHeight: 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                canRedeem ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text('$points pts'),
          backgroundColor: canRedeem ? Colors.green.shade100 : Colors.grey.shade200,
        ),
        onTap: canRedeem ? () => _redeemReward(reward, rewardId) : null,
      ),
    );
  }

  void _redeemReward(Map<String, dynamic> reward, String rewardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${reward['title']}'),
        content: Text(reward['impact']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _confirmRedemption(reward, rewardId),
            child: const Text('Redeem', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRedemption(Map<String, dynamic> reward, String rewardId) async {
  final points = (reward['points'] as num).toInt();
  final user = _auth.currentUser;
  
  if (user != null) {
    try {
      if (_ecoPoints < points) {
        throw Exception('Insufficient EcoPoints');
      }

      final redemptionData = {
        'title': reward['title'],
        'points': points,
        'rewardId': rewardId,
        'timestamp': FieldValue.serverTimestamp(), // Remove this line
        'timestamp': DateTime.now().toUtc(), // Add this instead
      };

      await _firestore.collection('users').doc(user.uid).update({
        'points': FieldValue.increment(-points),
        'redeemed': FieldValue.arrayUnion([redemptionData]),
        'lastUpdated': FieldValue.serverTimestamp(), // Add server timestamp here if needed
      });

      setState(() => _ecoPoints -= points);
      
      if (!mounted) return;
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Success! ${reward['title']}'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redemption failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
}