// lib/services/gemini_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiService {
  final _apiKey = 'AIzaSyD-BFv4lgb7M_eDF62-k_6dSjTNVwW8ltI';
  final _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  

  Future<String> analyzeImage(File image) async {
    const prompt = """
    Analyze this image for e-waste impact:
    1. ♻️ Recyclability of components
    2. ⚠️ Presence of toxic substances (Lead, Mercury, etc.)
    3. 🔄 Safe disposal & recycling methods
    4. 📊 Environmental impact assessment
    5. 🌍 Sustainable alternatives
    
    Provide structured results:
    📱 Device Type: [Identification]
    🔋 Key Components: [List]
    ☠️ Hazardous Materials: [Details]
    ✅ Safe Disposal: [Steps]
    🔄 Recycling Methods: [Suggestions]
    🌱 Eco-friendly Alternatives: [If applicable]
    """;

    return _processInput(image, prompt);
  }

  Future<String> handleMessage(
    String message, {
    Map<String, dynamic>? imageContext,
    String? userName
  }) async {
    final prompt = """
    ${imageContext != null ? 'Recent image analysis context:\n${imageContext['full_analysis']}\n\n' : ''}
    User Query: "$message"
    
    Respond **only** with e-waste crisis-related information:
    - Stay factual and technical
    - Concise for casual queries (max 3 lines)
    - Detailed for in-depth questions
    - Always suggest eco-friendly actions
    
    🏭 E-waste Effects: [Pollution, health risks]
    ⚠️ Toxic Elements: [Lead, Mercury, Cadmium]
    ♻️ Best Recycling Methods: [Step-by-step guide]
    🌍 Sustainable Tech Choices: [Alternatives]
    
    If the message is a greeting ("hi", "hello", "how are you"), respond with:
    - A friendly greeting
    - Example: "👋 Hello! 🌱 How can I help you with e-waste solutions today? ♻️"
    
    If the message is an e-waste question, provide:
    - Technical accuracy but concise answers
    - Bullet points for clarity
    - Safety first recommendations

    If the message is about the owner/creator of this app, provide:
    - App developed/created by Deccan Innovators
    - Developed By Vit Bhopal Students for educational purpose only
    
    
    """;

    return _processInput(message, prompt);
  }

  Future<String> handleToxicComponentsQuery(
    String query, 
    Map<String, dynamic> analysis,
    {String? userName}
  ) async {
    final prompt = """
    Based on the recent e-waste analysis:
    ${analysis['full_analysis']}
    
    Query: "$query"
    
    Respond with:
    - List of hazardous components ⚠️
    - Environmental & health risks
    - Safe handling and disposal methods
    - Best recycling practices ♻️

    Response Structure Examples:
    ----------------------------
    
    User: "What is e-waste?"
    Response: "📱 E-waste = Discarded electronics\n⚠️ Contains toxic materials (Lead, Mercury)\n🌍 53M+ tons generated yearly\n♻️ Proper recycling recovers valuable materials"
    
    User: "How to recycle old devices?"
    Response: 
    "♻️ Device Recycling Guide:
    1️⃣ Backup & wipe data
    2️⃣ Find certified e-waste center (Use Earth911.com)
    3️⃣ Remove batteries if possible
    4️⃣ Get recycling receipt for tracking
    🌱 Earn 100 eco-points per 2 recycled item!"
    """;

    return _processInput(query, prompt);
  }
  
  Future<String> _processInput(dynamic input, String prompt) async {
    final uri = Uri.parse('$_baseUrl?key=$_apiKey');
    final parts = [];

    if (input is File) {
      parts.add({
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Encode(await input.readAsBytes())
        }
      });
    } else {
      parts.add({'text': input});
    }

    parts.add({'text': prompt});

    final request = {
    "contents": [{"parts": parts}],
    "generationConfig": {
      "temperature": 0.3,  // Reduced for more deterministic responses
      "topP": 0.95,
      "topK": 20,
      "maxOutputTokens": 800
    }
  };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );

    if (response.statusCode == 200) {
      return _formatResponse(jsonDecode(response.body)['candidates'][0]['content']['parts'][0]['text']);
    }
    throw Exception('API Error: ${response.body}');
  }

  String _formatResponse(String response) {
    return response
        .replaceAll('**', '')
        .replaceAll('*', '•')
        .replaceAllMapped(RegExp(r'\d+\.'), (match) => '${_numberToEmoji(match.group(0)!)} ')
        .replaceAll('- ', '• ');
  }

  String _numberToEmoji(String number) {
    const emojiMap = {
      '1': '1️⃣', '2': '2️⃣', '3': '3️⃣', '4': '4️⃣', '5': '5️⃣',
      '6': '6️⃣', '7': '7️⃣', '8': '8️⃣', '9': '9️⃣', '10': '🔟'
    };
    return emojiMap[number.replaceAll('.', '')] ?? number;
  }
}