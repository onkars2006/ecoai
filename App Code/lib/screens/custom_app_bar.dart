import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mainapp/screens/auth_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/profile_screen.dart';
import '../screens/about_us_screen.dart';
import '../screens/faqs_screen.dart';
import '../screens/public_home_screen.dart'; // Make sure to import your home screen

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final BuildContext context;
  final bool showLogin;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.context,
    this.showLogin = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AppBar(
      title: Text(title),
      actions: [
        if (showLogin && user == null)
          IconButton(
            icon: const Icon(Icons.login, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            ),
          )
        else if (user != null)
          _buildProfileIcon(user),
        _buildMenuButton(context,user),
      ],
    );
  }

  Widget _buildProfileIcon(User? user) {
    return IconButton(
      icon: user?.photoURL != null
          ? CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user!.photoURL!),
              radius: 16,
            )
          : const Icon(Icons.person_outline, color: Colors.white),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, User? user) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) async => await _handleMenuSelection(value, context),
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'about',
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About Us'),
          ),
        ),
        const PopupMenuItem(
          value: 'faq',
          child: ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('FAQs'),
          ),
        ),
        if (user != null)
          const PopupMenuItem(
            value: 'logout',
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ),
      ],
    );
  }

  Future<void> _handleMenuSelection(String value, BuildContext context) async {
    switch (value) {
      case 'about':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutUsScreen()),
        );
        break;
      case 'faq':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FAQsScreen()),
        );
        break;
      case 'logout':
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PublicHomeScreen()),
          (route) => false,
        );
        break;
    }
  }
}