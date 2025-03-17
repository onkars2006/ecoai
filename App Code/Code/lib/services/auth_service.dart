// services/auth_service.dart
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle({String? referralCode}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      if (isNewUser) {
        await _createNewUser(userCredential.user!, referralCode);
        
        if (referralCode != null && referralCode.isNotEmpty) {
          await _processReferral(
            referralCode.trim().toUpperCase(), 
            userCredential.user!.uid
          );
        }
      }

      return userCredential.user;
    } catch (e) {
      print('SignIn Error: $e');
      rethrow;
    }
  }

Future<void> _createNewUser(User user, String? referralCode) async {
  await _firestore.collection('users').doc(user.uid).set({
    'uid': user.uid,
    'email': user.email ?? '',
    'displayName': user.displayName ?? 'Eco User',
    'photoURL': user.photoURL ?? '',
    'points': 100,
    'coins': 100,
    'referralCode': _generateReferralCode(),
    'referredBy': referralCode,
    'referrals': 0,
    'imageAnalysisCount': 0, // Add this field
    'createdAt': FieldValue.serverTimestamp(),
    'redeemed': [],
  });
}

  Future<void> _processReferral(String referralCode, String newUserId) async {
    try {
      final referrerQuery = await _firestore.collection('users')
          .where('referralCode', isEqualTo: referralCode.toUpperCase())
          .limit(1)
          .get();

      if (referrerQuery.docs.isEmpty) return;
      final referrerDoc = referrerQuery.docs.first;
      if (referrerDoc.id == newUserId) return;

      final batch = _firestore.batch();
      
      // Update referrer's points and referrals
      final referrerRef = _firestore.collection('users').doc(referrerDoc.id);
      batch.update(referrerRef, {
        'points': FieldValue.increment(100),
        'referrals': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update new user's data
      final newUserRef = _firestore.collection('users').doc(newUserId);
      batch.update(newUserRef, {
        'coins': FieldValue.increment(100),
      });

      await batch.commit();
    } catch (e) {
      print('Referral error: $e');
      rethrow;
    }
  }


  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}