import 'dart:math';
import '../models/vocabulary.dart';
import 'user_vocabulary_service.dart';

class PracticeService {
  final UserVocabularyService _userVocabularyService = UserVocabularyService();
  
  // Get practice words in shuffle mode
  Future<List<Vocabulary>> getPracticeWords(String userId, {int count = 10}) async {
    return _userVocabularyService.getRandomWordsForPractice(userId, limit: count);
  }
  
  // Get practice words in spaced repetition mode
  Future<List<Vocabulary>> getSpacedRepetitionWords(String userId, {int count = 10}) async {
    return _userVocabularyService.getWordsDueForPractice(userId, limit: count);
  }
  
  // Generate a quiz from user's vocabulary
  Future<List<Map<String, dynamic>>> generateVocabularyQuiz(String userId, {int questionCount = 5}) async {
    final List<Vocabulary> words = await _userVocabularyService.getUserWords(userId);
    
    if (words.length < questionCount) {
      return [];
    }
    
    // Shuffle and take first questionCount items
    words.shuffle();
    final quizWords = words.take(questionCount).toList();
    
    // Generate quiz questions
    final List<Map<String, dynamic>> questions = [];
    
    for (var word in quizWords) {
      // Random choice: translate Finnish to English or English to Finnish
      final bool finnishToEnglish = Random().nextBool();
      
      // Create options (1 correct + 3 incorrect)
      List<String> options = [];
      
      if (finnishToEnglish) {
        // Question: Finnish word, Options: English translations
        options.add(word.english); // Correct answer
        
        // Add incorrect options (random English translations from other words)
        final shuffledWords = List<Vocabulary>.from(words)..shuffle();
        for (var otherWord in shuffledWords) {
          if (otherWord.id != word.id && !options.contains(otherWord.english) && options.length < 4) {
            options.add(otherWord.english);
          }
        }
      } else {
        // Question: English word, Options: Finnish translations
        options.add(word.finnish); // Correct answer
        
        // Add incorrect options (random Finnish words)
        final shuffledWords = List<Vocabulary>.from(words)..shuffle();
        for (var otherWord in shuffledWords) {
          if (otherWord.id != word.id && !options.contains(otherWord.finnish) && options.length < 4) {
            options.add(otherWord.finnish);
          }
        }
      }
      
      // Shuffle options
      options.shuffle();
      
      // Find index of correct answer
      final correctIndex = options.indexOf(finnishToEnglish ? word.english : word.finnish);
      
      // Create question
      questions.add({
        'wordId': word.id,
        'question': finnishToEnglish ? word.finnish : word.english,
        'options': options,
        'correctIndex': correctIndex,
        'isFinishToEnglish': finnishToEnglish,
      });
    }
    
    return questions;
  }
  
  // Record practice completion
  Future<void> recordPracticeCompletion(String userId, List<String> wordIds) async {
    try {
      // Check if we have valid IDs before proceeding
      if (wordIds.isEmpty) {
        print('No word IDs to update');
        return;
      }
      
      for (var id in wordIds) {
        if (id.isNotEmpty) {
          await _userVocabularyService.updateWordPracticeCount(userId, id);
        }
      }
    } catch (e) {
      print('Error recording practice completion: $e');
      rethrow;
    }
  }
}