import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.green.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('The E-Waste Crisis'),
            const SizedBox(height: 10),
            Text(
              'The rapid technological advancement and shorter device lifespans have led to a dramatic rise in electronic waste. According to the Global E-waste Monitor 2020:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 15),
            _buildStatCard('74M', 'Metric tons of e-waste projected by 2030'),
            const SizedBox(height: 10),
            Text(
              'E-waste contains hazardous materials like lead, mercury, and cadmium, '
              'contributing to toxic landfills and serious environmental health risks. '
              'With AI advancements and increasing demand for advanced hardware, '
              'this crisis is accelerating exponentially.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 25),

            _buildSectionTitle('Our Mission'),
            const SizedBox(height: 10),
            Text(
              'Aligning with UN SDG 12: Responsible Consumption and Production, '
              'we develop innovative solutions to address the e-waste crisis through:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 15),
            _buildSDGPillars(),
            const SizedBox(height: 25),

            _buildSectionTitle('Our Solutions'),
            _buildFeatureTile(
              icon: Icons.warning_amber_rounded,
              title: 'Prevention',
              subtitle: 'Device repair tutorials\nLifespan extension guides\nUpcycling ideas',
            ),
            _buildFeatureTile(
              icon: Icons.trending_down_rounded,
              title: 'Reduction',
              subtitle: 'Eco-points incentive system\nSustainable practice education\nCorporate accountability tools',
            ),
            _buildFeatureTile(
              icon: Icons.recycling_rounded,
              title: 'Recycling',
              subtitle: 'AI-powered material analysis\nCertified center localization\nHazardous disposal protocols',
            ),
            _buildFeatureTile(
              icon: Icons.loop_rounded,
              title: 'Reuse',
              subtitle: 'Second-life marketplace\nDevice refurbishment network\nComponent recovery system',
            ),
            const SizedBox(height: 25),

            _buildSectionTitle('SDG 12 Alignment'),
            _buildSDGTarget('Target 12.4', 'Safe management of chemicals and waste'),
            _buildSDGTarget('Target 12.5', 'Substantial reduction of waste generation'),
            _buildSDGTarget('Target 12.8', 'Promotion of sustainable lifestyles'),
            _buildSectionTitle('The App is created by Deccan Innovators for Google AI Solution Hackathon'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Card(
      elevation: 3,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSDGPillars() {
    return const Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        Chip(
          label: Text('♻️ Prevention'),
          backgroundColor: Colors.greenAccent,
        ),
        Chip(
          label: Text('🌱 Reduction'),
          backgroundColor: Colors.lightGreenAccent,
        ),
        Chip(
          label: Text('⚠️ Recycling'),
          backgroundColor: Colors.amberAccent,
        ),
        Chip(
          label: Text('🔄 Reuse'),
          backgroundColor: Colors.tealAccent,
        ),
      ],
    );
  }

  Widget _buildFeatureTile({required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade800),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          height: 1.4,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  Widget _buildSDGTarget(String code, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              code,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}