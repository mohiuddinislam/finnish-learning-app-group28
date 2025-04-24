import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'home_screen.dart';
import '../services/content_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizScreen extends StatefulWidget {
  final String lessonId;
  
  const QuizScreen({super.key, required this.lessonId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ContentService _contentService = ContentService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  bool _questionAnswered = false;
  int? _selectedOptionIndex;
  bool _quizCompleted = false;
  
  @override
  void initState() {
    super.initState();
    _loadQuizQuestions();
  }
  
  Future<void> _loadQuizQuestions() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final questions = await _contentService.getQuizzesByLesson(widget.lessonId);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading quiz questions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _selectAnswer(int index) {
    if (_questionAnswered) return;
    
    setState(() {
      _questionAnswered = true;
      _selectedOptionIndex = index;
      
      // Check if answer is correct
      if (index == _questions[_currentQuestionIndex]['correctOptionIndex']) {
        _correctAnswers++;
      }
    });
    
    // Wait a bit before moving to next question
    Future.delayed(const Duration(seconds: 1), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _questionAnswered = false;
          _selectedOptionIndex = null;
        });
      } else {
        // Quiz completed
        setState(() {
          _quizCompleted = true;
        });
        
        // Update lesson progress
        final score = _correctAnswers / _questions.length;
        _updateProgress(score);
      }
    });
  }
  
  Future<void> _updateProgress(double score) async {
    final provider = Provider.of<LanguageProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      await provider.updateLessonProgress(user.uid, widget.lessonId, score);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _questions.isEmpty 
          ? const Center(child: Text('No questions available for this lesson.'))
          : _quizCompleted
            ? _buildResultScreen()
            : _buildQuizScreen(),
    );
  }
  
  Widget _buildQuizScreen() {
    final question = _questions[_currentQuestionIndex];
    final options = question['options'] as List<String>;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${_currentQuestionIndex + 1}/${_questions.length}',
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                question['question'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            options.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getOptionColor(index),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: _questionAnswered ? null : () => _selectAnswer(index),
                child: Text(
                  options[index],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_questionAnswered && question['explanation'] != null) 
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  question['explanation'],
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildResultScreen() {
    final score = (_correctAnswers / _questions.length) * 100;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            'Quiz Complete!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your score: ${score.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            '$_correctAnswers out of ${_questions.length} correct',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Return to Lesson'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }
  
  Color _getOptionColor(int index) {
    if (!_questionAnswered) return Colors.blue.shade50;
    
    if (index == _questions[_currentQuestionIndex]['correctOptionIndex']) {
      return Colors.green.shade100;
    }
    
    if (index == _selectedOptionIndex) {
      return Colors.red.shade100;
    }
    
    return Colors.blue.shade50;
  }
}