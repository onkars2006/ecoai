import 'package:flutter/material.dart';
import 'package:mainapp/screens/chat_screen.dart';
import 'package:mainapp/screens/map_screen.dart';
import 'custom_app_bar.dart';
import 'leaderboard_screen.dart';
import 'rewards_screen.dart';
import 'learn_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _appBarTitles = const [
    'E-Waste Scanner',
    'Community Leaderboard',
    'Eco Impact Hub',
    'Learn Hub',
    'Recycling Map' // Added
  ];

  final List<Widget> _screens = [
    const ChatScreen(),
    const LeaderboardScreen(),
    const RewardsScreen(),
    LearnScreen(),
    const MapScreen() // Added
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _appBarTitles[_currentIndex],
        context: context,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green.shade800,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Rewards',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem( // Added
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}