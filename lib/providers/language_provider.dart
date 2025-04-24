import 'package:flutter/foundation.dart';
import '../models/lesson.dart';
import '../models/quiz.dart';
import '../services/content_service.dart';
import '../services/auth_service.dart';

class LanguageProvider with ChangeNotifier {
  final ContentService _contentService = ContentService();
  final AuthService _authService = AuthService();
  
  List<Lesson> _lessons = [];
  Map<String, List<Quiz>> _quizzes = {};
  Map<String, double> _progress = {};
  bool _isLoading = false;
  String? _currentLessonId;
  
  // Getters
  List<Lesson> get lessons => _lessons;
  Map<String, List<Quiz>> get quizzes => _quizzes;
  Map<String, double> get progress => _progress;
  bool get isLoading => _isLoading;
  String? get currentLessonId => _currentLessonId;
  
  // Set current lesson
  void setCurrentLesson(String lessonId) {
    _currentLessonId = lessonId;
    notifyListeners();
  }
  
  // Load initial data
  Future<void> loadInitialData(String userId) async {
    _setLoading(true);
    try {
      await _loadLessons();
      await _loadUserProgress(userId);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load lessons
  Future<void> _loadLessons() async {
    try {
      print('Loading lessons from Firebase...');
      final lessonData = await _contentService.getLessons();
      print('Loaded ${lessonData.length} lessons');
      _lessons = lessonData.map((map) => Lesson.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading lessons: $e');
    }
  }
  
  // Get lesson by ID
  Lesson? getLessonById(String lessonId) {
    try {
      return _lessons.firstWhere((lesson) => lesson.id == lessonId);
    } catch (e) {
      return null;
    }
  }
  
  // Load quizzes for a lesson
  Future<List<Quiz>> loadQuizzesForLesson(String lessonId) async {
    try {
      if (!_quizzes.containsKey(lessonId)) {
        _setLoading(true);
        final quizData = await _contentService.getQuizzesByLesson(lessonId);
        _quizzes[lessonId] = quizData.map((map) => Quiz.fromMap(map)).toList();
        notifyListeners();
        _setLoading(false);
      }
      return _quizzes[lessonId] ?? [];
    } catch (e) {
      print('Error loading quizzes: $e');
      _setLoading(false);
      return [];
    }
  }
  
  // Load user progress
  Future<void> _loadUserProgress(String userId) async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData != null && userData.containsKey('progress')) {
        final Map<String, dynamic> userProgress = userData['progress'];
        _progress = Map.from(userProgress.map(
          (key, value) => MapEntry(key, value.toDouble())
        ));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user progress: $e');
    }
  }
  
  // Update lesson progress
  Future<void> updateLessonProgress(String userId, String lessonId, double completionRate) async {
    try {
      await _authService.updateUserProgress(lessonId, completionRate);
      _progress[lessonId] = completionRate;
      notifyListeners();
    } catch (e) {
      print('Error updating progress: $e');
    }
  }
  
  // Get lesson progress
  double getLessonProgress(String lessonId) {
    return _progress[lessonId] ?? 0.0;
  }
  
  // Get available lessons (based on progress)
  List<Lesson> getAvailableLessons() {
    // First lesson is always available
    if (_lessons.isEmpty) return [];
    
    final List<Lesson> available = [];
    bool foundLocked = false;
    
    for (var lesson in _lessons) {
      if (!foundLocked) {
        available.add(lesson);
        
        // Check if user has completed at least 70% of this lesson
        final progress = getLessonProgress(lesson.id);
        if (progress < 0.7) {
          foundLocked = true; // Lock subsequent lessons
        }
      }
    }
    
    return available;
  }
  
  // Check if a lesson is locked
  bool isLessonLocked(String lessonId) {
    final availableLessons = getAvailableLessons();
    return !availableLessons.any((lesson) => lesson.id == lessonId);
  }
  
  // Helper method to update loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}