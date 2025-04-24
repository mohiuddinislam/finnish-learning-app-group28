import 'package:flutter/foundation.dart';
import '../models/vocabulary.dart';
import '../services/user_vocabulary_service.dart';
import '../services/practice_service.dart';

class VocabularyProvider with ChangeNotifier {
  final UserVocabularyService _userVocabularyService = UserVocabularyService();
  final PracticeService _practiceService = PracticeService();
  
  List<Vocabulary> _userWords = [];
  List<Vocabulary> _practiceWords = [];
  List<Map<String, dynamic>> _quizQuestions = [];
  bool _isLoading = false;
  
  // Getters
  List<Vocabulary> get userWords => _userWords;
  List<Vocabulary> get practiceWords => _practiceWords;
  List<Map<String, dynamic>> get quizQuestions => _quizQuestions;
  bool get isLoading => _isLoading;
  
  // Load user's vocabulary
  Future<void> loadUserVocabulary(String userId) async {
    _setLoading(true);
    try {
      _userWords = await _userVocabularyService.getUserWords(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading user vocabulary: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Add a new word
  Future<void> addWord(String userId, String finnish, String english, {String? example}) async {
    _setLoading(true);
    try {
      final Vocabulary newWord = Vocabulary(
        id: '', // Will be set by Firestore
        finnish: finnish,
        english: english,
        example: example,
        isUserAdded: true,
        dateAdded: DateTime.now(),
      );
      
      await _userVocabularyService.addWord(userId, newWord);
      await loadUserVocabulary(userId); // Reload words
    } catch (e) {
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete a word
  Future<void> deleteWord(String userId, String wordId) async {
    _setLoading(true);
    try {
      await _userVocabularyService.deleteWord(userId, wordId);
      await loadUserVocabulary(userId); // Reload words
    } catch (e) {
    } finally {
      _setLoading(false);
    }
  }
  
  // Update a word
  Future<void> updateWord(String userId, Vocabulary vocabulary) async {
    _setLoading(true);
    try {
      await _userVocabularyService.updateWord(userId, vocabulary);
      await loadUserVocabulary(userId); // Reload words
    } catch (e) {
    } finally {
      _setLoading(false);
    }
  }
  
  // Load practice words
  Future<void> loadPracticeWords(String userId, {int count = 10, bool useSpacedRepetition = true}) async {
    _setLoading(true);
    try {
      if (useSpacedRepetition) {
        _practiceWords = await _practiceService.getSpacedRepetitionWords(userId, count: count);
      } else {
        _practiceWords = await _practiceService.getPracticeWords(userId, count: count);
      }
      notifyListeners();
    } catch (e) {
    } finally {
      _setLoading(false);
    }
  }
  
  // Generate quiz from user vocabulary
  Future<void> generateQuiz(String userId, {int questionCount = 5}) async {
    _setLoading(true);
    try {
      _quizQuestions = await _practiceService.generateVocabularyQuiz(
        userId, 
        questionCount: questionCount
      );
      notifyListeners();
    } catch (e) {
    } finally {
      _setLoading(false);
    }
  }
  
  // Record completion of practice session
  Future<void> recordPracticeCompletion(String userId, List<String> wordIds) async {
    try {
      await _practiceService.recordPracticeCompletion(userId, wordIds);
    } catch (e) {
    }
  }
  
  // Helper method to update loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}