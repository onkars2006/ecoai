import 'package:flutter/material.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
        backgroundColor: Colors.green.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFAQItem(
              question: 'How does the AI scanning work?',
              answer: 'Our advanced computer vision models analyze device images to identify components, assess recyclability potential (0-100%), and detect hazardous materials using spectral analysis and material recognition algorithms.',
            ),
            _buildFAQItem(
              question: 'Are my scanned images stored?',
              answer: 'No personal device images are permanently stored. We temporarily process images using secure memory buffers and only retain anonymized metadata for service improvement.',
            ),
            _buildFAQItem(
              question: 'How are EcoPoints calculated?',
              answer: 'Points are awarded based on:\n- Toxicity level of components\n- Proper recycling impact\n- Device lifespan extension\n- Hazardous material containment\nHigher points for more dangerous items disposed correctly.',
            ),
            _buildFAQItem(
              question: 'Is my account information secure?',
              answer: 'We use bank-grade encryption (AES-256) and comply with GDPR regulations. Personal data is never shared with third parties without explicit consent.',
            ),
            _buildFAQItem(
              question: 'How does this help the environment?',
              answer: 'For every 1000 users, we prevent:\n✅ 5 tons of e-waste landfills\n✅ 12k liters of water contamination\n✅ 800kg CO2 emissions\nAligned with UN SDG 12 targets for responsible consumption.',
            ),
            _buildFAQItem(
              question: 'What certifications do partners have?',
              answer: 'We only list R2/RIOS certified recyclers and e-Stewards initiatives compliant with Basel Convention regulations for safe e-waste management.',
            ),
            _buildFAQItem(
              question: 'Can I get repair guides for old devices?',
              answer: 'Yes! Our Learn Hub provides:\n🔧 50+ step-by-step repair tutorials\n🔋 Battery replacement guides\n💻 Component-level troubleshooting\n📈 Device lifespan extension tips',
            ),
            _buildFAQItem(
              question: 'How to handle hazardous materials?',
              answer: 'Our AI identifies:\n⚠️ Lead (batteries)\n⚠️ Mercury (displays)\n⚠️ Cadmium (chips)\n⚠️ BFRs (circuit boards)\nWith proper disposal instructions for each.',
            ),
            _buildFAQItem(
              question: 'What future features are planned?',
              answer: 'Roadmap includes:\n🌐 AR repair assistance\n📈 Blockchain recycling tracking\n🤝 OEM take-back programs\n♻️ AI-powered upcycling ideas',
            ),
            _buildFAQItem(
              question: 'How to report improper recycling?',
              answer: 'Use our Community Watch feature to anonymously report violations. Verified reports earn bonus EcoPoints and help improve our recycling network.',
            ),
            _buildFAQItem(
              question: 'Who created this app?',
              answer: 'The App is created by Deccan Innovators for Google AI Solution Hackathon',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}