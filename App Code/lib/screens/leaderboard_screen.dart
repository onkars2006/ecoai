import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Community Leaderboard')),
      body: _buildLeaderboardList(),
    );
  }

  Widget _buildLeaderboardList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('points', isGreaterThan: 0)
          .orderBy('points', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No active users yet!'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final user = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildLeaderboardItem(index + 1, user);
          },
        );
      },
    );
  }

  Widget _buildLeaderboardItem(int rank, Map<String, dynamic> user) {
    final points = (user['points'] as num?)?.toInt() ?? 0;
    final displayName = user['displayName']?.toString() ?? 'Eco User';
    final photoUrl = user['photoURL']?.toString() ?? '';

    return ListTile(
      leading: _buildUserAvatar(photoUrl, rank),
      title: Text(displayName),
      subtitle: Text('$points points'),
      trailing: _buildRankBadge(rank),
    );
  }

  Widget _buildUserAvatar(String photoUrl, int rank) {
    return CircleAvatar(
      backgroundColor: Colors.green.shade100,
      foregroundImage: photoUrl.isNotEmpty
          ? CachedNetworkImageProvider(photoUrl)
          : null,
      child: photoUrl.isEmpty
          ? Text(rank.toString())
          : null,
    );
  }

  Widget _buildRankBadge(int rank) {
    final color = rank <= 3 ? _rankColors[rank] ?? Colors.green : Colors.grey;
    return CircleAvatar(
      backgroundColor: color,
      child: Text(
        rank.toString(),
        style: TextStyle(
          color: rank <= 3 ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  static const Map<int, Color> _rankColors = {
    1: Colors.amber,
    2: Colors.blueGrey,
    3: Colors.brown,
  };
}