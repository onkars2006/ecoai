import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:mainapp/screens/public_home_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: user == null 
          ? _buildAuthPrompt(context, authService)
          : _buildProfileContent(context, user),
    );
  }

  Widget _buildAuthPrompt(BuildContext context, AuthService authService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Please sign in to view profile'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async => await authService.signInWithGoogle(),
            child: const Text('Sign In with Google'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User data not found'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final photoURL = userData['photoURL'] as String? ?? '';
        final points = (userData['points'] as num?)?.toInt() ?? 0;
        final referrals = (userData['referrals'] as num?)?.toInt() ?? 0;
        final joinedDate = (userData['createdAt'] as Timestamp?)?.toDate();
        final redemptions = _parseRedemptions(userData['redeemed'] ?? []);
        final authService = Provider.of<AuthService>(context, listen: false);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserHeader(photoURL, userData),
              const SizedBox(height: 24),
              _buildStatsCard(points, referrals, joinedDate),
              const SizedBox(height: 24),
              _buildReferralCard(userData),
              const SizedBox(height: 24),
              _buildRedemptionHistory(redemptions),
              const SizedBox(height: 24),
              _buildSignOutButton(context, authService),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserHeader(String photoURL, Map<String, dynamic> userData) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: photoURL.isNotEmpty
              ? CachedNetworkImageProvider(photoURL)
              : null,
          child: photoURL.isEmpty
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          userData['displayName'] as String? ?? 'Eco User',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userData['email'] as String? ?? '',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(int points, int referrals, DateTime? joinedDate) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Total Points', points.toString()),
            const Divider(height: 24),
            _buildStatRow('Total Referrals', referrals.toString()),
            const Divider(height: 24),
            _buildStatRow(
              'Member Since',
              joinedDate != null 
                  ? DateFormat('MMM dd, yyyy').format(joinedDate)
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildReferralCard(Map<String, dynamic> userData) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Your Referral Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              userData['referralCode']?.toString() ?? 'N/A',
              style: TextStyle(
                fontSize: 28,
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Share this code with friends to earn bonus points!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            if (userData['referredBy'] != null && userData['referredBy'].isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Referred by: ${userData['referredBy']}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _parseRedemptions(dynamic redeemedData) {
    if (redeemedData is! List) return [];
    return redeemedData.whereType<Map<String, dynamic>>().toList();
  }

  Widget _buildRedemptionHistory(List<Map<String, dynamic>> redemptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Redemption History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: redemptions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No redemption history available',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: redemptions.length,
                  separatorBuilder: (context, index) => const Divider(height: 8),
                  itemBuilder: (context, index) {
                    final redemption = redemptions[index];
                    return _buildRedemptionItem(redemption);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRedemptionItem(Map<String, dynamic> redemption) {
    final date = (redemption['timestamp'] as Timestamp).toDate();
    final formatter = DateFormat('MMM dd, yyyy - hh:mm a');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.redeem, color: Colors.green),
      ),
      title: Text(
        redemption['title']?.toString() ?? 'Unknown Reward',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(formatter.format(date)),
      trailing: Chip(
        label: Text(
          '-${redemption['points']?.toString() ?? '0'} pts',
          style: const TextStyle(color: Colors.red),
        
      ),
    ));
  }

  Widget _buildSignOutButton(BuildContext context, AuthService authService) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () async {
        await authService.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PublicHomeScreen()),
          (route) => false,
        );
      },
      child: const Text('Sign Out', style: TextStyle(fontSize: 16)),
    ),
  );
}
}