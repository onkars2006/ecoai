import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mainapp/screens/public_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBPzKQ1ax4gbemIANN4r-YN9zyVwRlkAaQ",
        appId: "1:455109181238:android:d1c36eaf7fda1121cc7d97",
        messagingSenderId: "455109181238",
        projectId: "ecoscan-3935e",
        storageBucket: "ecoscan-3935e.appspot.com",
        authDomain: "ecoscan-3935e.firebaseapp.com",
        databaseURL: "https://ecoscan-3935e.firebaseio.com",
      ),
    );
    runApp(
      MultiProvider(
        providers: [
          Provider<AuthService>(create: (_) => AuthService()),
          StreamProvider<User?>.value(
            value: FirebaseAuth.instance.authStateChanges(),
            initialData: null,
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print("Firebase initialization error: $e");
    runApp(const FirebaseErrorScreen());
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animationComplete = false;

  void _navigateToNextScreen() {
    if (_animationComplete) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade900,
              Colors.green.shade600,
              Colors.green.shade400,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.recycling,
                size: 100,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(height: 30),
              _buildTypingAnimation(),
              const SizedBox(height: 40),
              SpinKitFadingCircle(
                color: Colors.white.withOpacity(0.8),
                size: 40.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingAnimation() {
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            'Eco-Waste AI',
            speed: const Duration(milliseconds: 100),
            textStyle: const TextStyle(
              fontSize: 42.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          TypewriterAnimatedText(
            'Sustainable E-Waste Solutions',
            speed: const Duration(milliseconds: 80),
            textStyle: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        totalRepeatCount: 1,
        pause: const Duration(milliseconds: 500),
        displayFullTextOnTap: true,
        stopPauseOnTap: true,
        onFinished: () {
          setState(() => _animationComplete = true);
          _navigateToNextScreen();
        },
      ),
    );
  }
}

class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Firebase initialization failed. Check your configuration.'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'Eco-Waste',
  theme: ThemeData(
    primarySwatch: Colors.green,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green.shade800,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  home: const SplashScreen(),
  debugShowCheckedModeBanner: false,
  routes: {
    '/public': (context) => const PublicHomeScreen(),
    '/home': (context) => const HomeScreen(),
    '/auth': (context) => const AuthScreen(),
  },
);
}}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = Provider.of<User?>(context);

    if (user != null && user.isAnonymous) {
      authService.signOut();
    }

    return user == null ? const PublicHomeScreen() : const HomeScreen();
  }
}