// lib/screens/public_home_screen.dart
import 'package:flutter/material.dart';
import 'package:mainapp/screens/chat_screen.dart';
import 'package:mainapp/screens/custom_app_bar.dart';

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Eco-Waste Assistant',
        context: context,
        showLogin: true,
      ),
      body: const ChatScreen(isPublic: true),
    );
  }
}