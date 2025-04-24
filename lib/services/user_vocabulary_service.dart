import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vocabulary.dart';
import 'firebase_service.dart';

class UserVocabularyService {
  final FirebaseService _firebaseService = FirebaseService();
  
  // Get user's vocabulary collection reference
  CollectionReference _getUserVocabularyRef(String userId) {
    return _firebaseService.users.doc(userId).collection('vocabulary');
  }
  
  // Add a new word
  Future<String> addWord(String userId, Vocabulary vocabulary) async {
    try {
      final doc = await _getUserVocabularyRef(userId).add(vocabulary.toMap());
      return doc.id;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all user's words
  Future<List<Vocabulary>> getUserWords(String userId) async {
    try {
      final QuerySnapshot snapshot = await _getUserVocabularyRef(userId)
          .orderBy('dateAdded', descending: true)
          .get();
          
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Vocabulary.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get random words for practice
  Future<List<Vocabulary>> getRandomWordsForPractice(String userId, {int limit = 10}) async {
    try {
      // Getting all words first since Firestore doesn't support true random selection
      final QuerySnapshot snapshot = await _getUserVocabularyRef(userId).get();
      
      final List<Vocabulary> words = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Vocabulary.fromMap(data);
      }).toList();
      
      // Shuffle the list and take the first 'limit' items
      words.shuffle();
      
      return words.take(limit).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get words due for practice (based on spaced repetition algorithm)
  Future<List<Vocabulary>> getWordsDueForPractice(String userId, {int limit = 10}) async {
    try {
      final DateTime now = DateTime.now();
      
      // Get all words
      final List<Vocabulary> allWords = await getUserWords(userId);
      
      // Sort words by a spaced repetition priority algorithm
      // Lower practice count and older words get higher priority
      allWords.sort((a, b) {
        // Calculate days since added
        final int daysA = now.difference(a.dateAdded).inDays;
        final int daysB = now.difference(b.dateAdded).inDays;
        
        // Priority score: days since added divided by practice count (higher = more priority)
        final double scoreA = daysA / (a.practiceCount! + 1);
        final double scoreB = daysB / (b.practiceCount! + 1);
        
        // Sort by descending priority score (higher score first)
        return scoreB.compareTo(scoreA);
      });
      
      return allWords.take(limit).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Update word practice count
  Future<void> updateWordPracticeCount(String userId, String wordId) async {
    try {
      // First check if the word document exists
      final docRef = _getUserVocabularyRef(userId).doc(wordId);
      final doc = await docRef.get();
      
      if (doc.exists) {
        // If word exists, update the practice count
        final currentCount = (doc.data() as Map<String, dynamic>)['practiceCount'] ?? 0;
        
        await docRef.update({
          'practiceCount': currentCount + 1,
          'lastPracticed': FieldValue.serverTimestamp(),
        });
      } else {
        // The word doesn't exist - this is likely causing your error
        print('Warning: Trying to update practice count for non-existent word: $wordId');
        // Do nothing or handle appropriately
      }
    } catch (e) {
      print('Error updating practice count: $e');
      rethrow;
    }
}
  
  // Delete a word
  Future<void> deleteWord(String userId, String wordId) async {
    try {
      await _getUserVocabularyRef(userId).doc(wordId).delete();
    } catch (e) {
      rethrow;
    }
  }
  
  // Update a word
  Future<void> updateWord(String userId, Vocabulary vocabulary) async {
    try {
      await _getUserVocabularyRef(userId).doc(vocabulary.id).update(vocabulary.toMap());
    } catch (e) {
      rethrow;
    }
  }
}