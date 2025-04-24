import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class ContentService {
  final FirebaseService _firebaseService = FirebaseService();

  // Get all lessons
  Future<List<Map<String, dynamic>>> getLessons() async {
    try {
      final QuerySnapshot snapshot = await _firebaseService.lessons
          .orderBy('order', descending: false) // Order by lesson number
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Add the document ID to the data
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'order': data['order'] ?? 0,
          'topics': (data['topics'] as List<dynamic>?)?.cast<String>() ?? [],
        };
      }).toList();
    } catch (e) {
      print('Error loading lessons: $e');
      return []; // Return empty list on error
    }
  }

  // Get lesson vocabulary words
  Future<List<Map<String, dynamic>>> getLessonVocabulary(String lessonId) async {
    try {
      final QuerySnapshot snapshot = await _firebaseService.lessons
          .doc(lessonId)
          .collection('vocabulary')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Add the document ID to the data
        return {
          'id': doc.id,
          'finnish': data['finnish'] ?? '',
          'english': data['english'] ?? '',
          'example': data['example'],
          'audioPath': data['audioPath'],
          'isUserAdded': false, // System vocabulary
        };
      }).toList();
    } catch (e) {
      print('Error loading lesson vocabulary: $e');
      return []; // Return empty list on error
    }
  }

  // Get quizzes by lesson
  Future<List<Map<String, dynamic>>> getQuizzesByLesson(String lessonId) async {
    try {
      final QuerySnapshot snapshot = await _firebaseService.quizzes
          .where('lessonId', isEqualTo: lessonId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'question': data['question'] ?? '',
          'options': (data['options'] as List<dynamic>?)?.cast<String>() ?? [],
          'correctOptionIndex': data['correctOptionIndex'] ?? 0,
          'explanation': data['explanation'],
        };
      }).toList();
    } catch (e) {
      print('Error loading quizzes: $e');
      return []; // Return empty list on error
    }
  }
}