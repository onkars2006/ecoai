// auth_screen.dart
import 'package:flutter/material.dart';
import 'package:mainapp/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _referralController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Eco-Waste AI',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Text(
                'Please sign in to continue',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _referralController,
                decoration: const InputDecoration(
                  labelText: 'Referral Code (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.card_giftcard),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading 
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: Image.asset('assets/images/google_logo.png', height: 24),
                      label: const Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      ),
                      onPressed: _handleSignIn,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
  if (_isLoading) return;
  setState(() => _isLoading = true);

  final authService = Provider.of<AuthService>(context, listen: false);
  try {
    await authService.signInWithGoogle(
      referralCode: _referralController.text.trim(),
    );
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sign in failed: ${e.toString()}')),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
}