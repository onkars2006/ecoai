import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LearnScreen extends StatelessWidget {
  final List<Map<String, dynamic>> videoTutorials = [
    {
      'title': 'E-Waste Recycling Process',
      'description': 'Complete guide to proper e-waste recycling',
      'videoId': 'HgEo7YnvJs0',
    },
    {
      'title': 'Danger of Improper Disposal',
      'description': 'Understanding environmental impacts',
      'videoId': 'MykdIfMRROE',
    },
    {
      'title': 'Creative E-Waste Reuse',
      'description': 'Innovative ways to repurpose old devices',
      'videoId': 'K6ppCC3lboU',
    },
    {
      'title': 'Battery Recycling Guide',
      'description': 'Safe handling of old batteries',
      'videoId': 'Pe5fSaOTtDo',
    },
  ];

  final List<Map<String, dynamic>> learningMaterials = [
    {
      'title': 'Repurpose Old Phones',
      'content': 'Transform old smartphones into security cameras or media players',
    },
    {
      'title': 'Battery Safety',
      'content': 'Proper handling and disposal of lithium-ion batteries',
    },
    {
      'title': 'Cable Organization',
      'content': 'Creative ways to reuse and organize old cables',
    },
  ];

  LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Video Tutorials'),
          const SizedBox(height: 16),
          _buildVideoList(),
          const SizedBox(height: 24),
          _buildSectionTitle('Learning Guides'),
          const SizedBox(height: 16),
          ..._buildLearningGuides(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.green.shade800,
      ),
    );
  }

  Widget _buildVideoList() {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: videoTutorials.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final video = videoTutorials[index];
          return _buildVideoCard(video);
        },
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _launchYouTube(video['videoId']),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: 'https://img.youtube.com/vi/${video['videoId']}/0.jpg',
                  height: 140,
                  width: 280,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video['description'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLearningGuides() {
    return learningMaterials.map((material) => Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              material['title'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              material['content'],
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    )).toList();
  }

  Future<void> _launchYouTube(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch YouTube');
    }
  }
}