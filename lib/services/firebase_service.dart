import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  FirebaseAuth get auth => _auth;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  //firestore getters
  FirebaseFirestore get firestore => _firestore;
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get lessons => _firestore.collection('lessons');
  CollectionReference get quizzes => _firestore.collection('quizzes');
  
  //storage getter
  FirebaseStorage get storage => _storage;
}