import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseService _firebaseService = FirebaseService();
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      return await _firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign up with email and password
  Future<UserCredential> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential credential = await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      await _firebaseService.users.doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'progress': {},
      });
      
      return credential;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _firebaseService.auth.signOut();
  }
  
  // Get current user data from Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      if (_firebaseService.currentUser != null) {
        final doc = await _firebaseService.users.doc(_firebaseService.currentUser!.uid).get();
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  // Update user progress
  Future<void> updateUserProgress(String lessonId, double completionRate) async {
    try {
      if (_firebaseService.currentUser != null) {
        await _firebaseService.users.doc(_firebaseService.currentUser!.uid).update({
          'progress.$lessonId': completionRate,
        });
      }
    } catch (e) {
      rethrow;
    }
  }
  Future<void> ensureUserDocumentExists(String userId) async {
    try {
      final docRef = _firebaseService.users.doc(userId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        await docRef.set({
          'name': 'User',
          'email': _firebaseService.currentUser?.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'progress': {},
        });
      }
    } catch (e) {
      print('Error ensuring user document exists: $e');
      rethrow;
    }
  }
}