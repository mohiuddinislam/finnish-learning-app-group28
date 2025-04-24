import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/content_service.dart';
import 'quiz_screen.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  bool _isLoading = true;
  final ContentService _contentService = ContentService();
  List<Map<String, dynamic>> _dailyQuizzes = [];
  
  @override
  void initState() {
    super.initState();
    _loadDailyQuizzes();
  }
  
  Future<void> _loadDailyQuizzes() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // This would typically come from a service that generates daily quizzes
      // For now, we'll just use a placeholder
      _dailyQuizzes = [
        {
          'id': 'daily_quiz_1',
          'title': 'Daily Vocabulary Quiz',
          'description': 'Test your knowledge of Finnish vocabulary',
          'icon': Icons.auto_stories,
          'color': Colors.blue.shade100,
        },
        {
          'id': 'daily_quiz_2',
          'title': 'Grammar Challenge',
          'description': 'Practice Finnish grammar rules',
          'icon': Icons.rule,
          'color': Colors.green.shade100,
        },
      ];
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Consumer<LanguageProvider>(
            builder: (context, provider, child) {
              final availableLessons = provider.getAvailableLessons();
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily quizzes section
                    const Text(
                      'Daily Quizzes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _dailyQuizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = _dailyQuizzes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: quiz['color'],
                              child: Icon(quiz['icon'] as IconData),
                            ),
                            title: Text(quiz['title']),
                            subtitle: Text(quiz['description']),
                            trailing: ElevatedButton(
                              onPressed: () {
                                if (availableLessons.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizScreen(
                                        lessonId: availableLessons.first.id,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Start'),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Lesson quizzes
                    const Text(
                      'Lesson Quizzes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (availableLessons.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text('No lesson quizzes available'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: availableLessons.length,
                        itemBuilder: (context, index) {
                          final lesson = availableLessons[index];
                          final progress = provider.getLessonProgress(lesson.id);
                          final isLocked = provider.isLessonLocked(lesson.id);
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: isLocked 
                                  ? Colors.grey.shade300
                                  : Colors.orange.shade100,
                                child: Icon(
                                  isLocked ? Icons.lock : Icons.quiz,
                                  color: isLocked ? Colors.grey : Colors.orange.shade800,
                                ),
                              ),
                              title: Text(
                                lesson.title,
                                style: TextStyle(
                                  color: isLocked ? Colors.grey : Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isLocked
                                      ? 'Complete previous lessons to unlock'
                                      : 'Test your knowledge from this lesson',
                                    style: TextStyle(
                                      color: isLocked ? Colors.grey : null,
                                    ),
                                  ),
                                  if (!isLocked && progress > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey.shade200,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: isLocked
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => QuizScreen(
                                            lessonId: lesson.id,
                                          ),
                                        ),
                                      );
                                    },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLocked
                                    ? Colors.grey.shade300
                                    : null,
                                ),
                                child: const Text('Start'),
                              ),
                            ),
                          );
                        },
                      ),
                      
                    // Recently completed quizzes section
                    const SizedBox(height: 24),
                    const Text(
                      'Recently Completed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 1,
                      color: Colors.grey.shade100,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('Complete quizzes to see your history here'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}