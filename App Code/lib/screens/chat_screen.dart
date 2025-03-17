import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  final bool isPublic;

  const ChatScreen({super.key, this.isPublic = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
Map<String, dynamic>? _lastImageAnalysis;
  final _toxicComponentsRegex = RegExp(
    r'(toxic|hazardous|dangerous|harmful|components|materials|elements)',
    caseSensitive: false
  );


class _ChatScreenState extends State<ChatScreen> {
  final bool isPublic = false;

  String? _userName;
  final _userNameRegex = RegExp(r'(my name is|i am|call me)\s+(\w+)', caseSensitive: false);

  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final GeminiService _geminiService = GeminiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  

  Future<void> _loadUserName() async {
    final user = _auth.currentUser;
    if(user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _userName = doc.data()?['name'];
      });
    }
  }
  

  void _handleTextInput() async {
  if (_controller.text.isEmpty) return;
  
  final text = _controller.text.trim();
  _controller.clear();
  _addMessage(text: text, isUser: true);
  
  if (_toxicComponentsRegex.hasMatch(text) && _lastImageAnalysis == null) {
    _addMessage(
      text: 'Please upload an image first to analyze toxic components',
      isUser: false
    );
    return;
  }
  // Check for name input
  final nameMatch = _userNameRegex.firstMatch(text);

  
  if (nameMatch != null) {
    final newName = nameMatch.group(2);
    await _updateUserName(newName!);
    _addMessage(
      text: 'Nice to meet you, $newName! How can I help with e-waste solutions?',
      isUser: false
    );
    return;
  }

  // Handle normal messages
  setState(() => _isLoading = true);
  
  try {
    String response;
    if (_toxicComponentsRegex.hasMatch(text) && _lastImageAnalysis != null) {
      // Handle toxic components follow-up
      response = await _geminiService.handleToxicComponentsQuery(
        text,
        _lastImageAnalysis!,
        userName: _userName
      );
    } else {
      // Normal message handling
      response = await _geminiService.handleMessage(
        text,
        imageContext: _lastImageAnalysis,
        userName: _userName
      );
    }
    
    _addMessage(text: response, isUser: false);
  } catch (e) {
    _showError('Error processing request');
  } finally {
    setState(() => _isLoading = false);
  }
}

  Future<void> _updateUserName(String name) async {
    final user = _auth.currentUser;
    if(user != null) {
      await _firestore.collection('users').doc(user.uid).update({'name': name});
      setState(() => _userName = name);
    }
  }


Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.recycling, size: 80, color: Colors.green.shade300),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _userName != null 
              ? 'Welcome back, $_userName!\nHow can I help with e-waste today?'
              : 'How can I help you with\ne-waste solutions?', // Fixed newline syntax
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              height: 1.3, // Adjust line height
            ),
          ),
        ),
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages.reversed.toList()[index];
                      return _buildChatBubble(message);
                    },
                  ),
                ),
              ),
              _buildInputArea(),
              if (_isLoading) const LinearProgressIndicator(),
            ],
          ),
          if (_messages.isEmpty) _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.green.shade50 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.image != null) _buildImagePreview(message.image!),
            if (message.text != null)
              Text(
                _addEmojis(message.text!),
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _addEmojis(String text) {
    final emojiMapping = {
      'recyclable': '♻️',
      'not recyclable': '🚫',
      'partially': '🟡',
      'plastic': '🥤',
      'paper': '📄',
      'glass': '🍶',
      'metal': '🔩',
      'electronic': '📱',
      'hazardous': '⚠️',
      'compost': '🌱',
      'step': '👉',
      'tip': '💡',
      'warning': '❗',
      'benefit': '✅',
    };

    emojiMapping.forEach((key, value) {
      text = text.replaceAll(RegExp(key, caseSensitive: false), value);
    });

    return text.replaceAll('**', '').replaceAll('*', '•');
  }

  Widget _buildImagePreview(File image) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          image,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInputArea() {
  return Container(
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 8,
        )
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16),
              // Enable suggestions and autocorrect
              enableSuggestions: true,  // Changed from false
              autocorrect: true,         // Changed from false
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.send, color: Colors.green),
              onPressed: _handleTextInput,
            ),
            if (!isPublic)
              IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.green),
                onPressed: _handleImageUpload,
              ),
          ],
        ),
      ],
    ),
  );
}



  void _handleImageUpload() async {
  final user = _auth.currentUser;
  if (user == null) {
    _showError('🔒 Please sign in to analyze items');
    return;
  }

  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.green),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.green),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );

    if (source == null) return;

  setState(() => _isLoading = true);
  
  try {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    final file = File(image.path);
    _addMessage(image: file, isUser: true);
    
    final analysis = await _geminiService.analyzeImage(file);
    _lastImageAnalysis = _parseAnalysis(analysis); // Store analysis
    _addMessage(text: analysis, isUser: false);

      // Update analysis count and check for points
      await _firestore.collection('users').doc(user.uid).update({
        'imageAnalysisCount': FieldValue.increment(1),
      });

      // Get updated count
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final count = (doc.data()?['imageAnalysisCount'] as num?)?.toInt() ?? 0;

      // Award points every 2 analyses
      if (count > 0 && count % 2 == 0) {
        await _firestore.collection('users').doc(user.uid).update({
          'points': FieldValue.increment(100),
        });

        // Get updated points
        final updatedDoc = await _firestore.collection('users').doc(user.uid).get();
        final points = (updatedDoc.data()?['points'] as num?)?.toInt() ?? 0;

        _addMessage(
          text: '🎉 Earned 100 points for 2 analyses! Total points: $points',
          isUser: false,
        );
      }
    } catch (e) {
      _showError('🔍 Could not analyze this item. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

Map<String, dynamic> _parseAnalysis(String analysis) {
  final components = <String>[];
  final lines = analysis.split('\n');
  
  for (final line in lines) {
    if (line.contains('⚠️') || line.contains('Hazardous')) {
      components.add(line.replaceAll('•', '').trim());
    }
  }
  
  return {
    'full_analysis': analysis,
    'toxic_components': components,
    'timestamp': DateTime.now().toString(),
  };
}

  void _addMessage({String? text, File? image, required bool isUser}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        image: image,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange.shade200,
      ),
    );
  }
}

class ChatMessage {
  final String? text;
  final File? image;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    this.text,
    this.image,
    required this.isUser,
    required this.timestamp,
  });
}