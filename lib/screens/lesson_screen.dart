import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../providers/language_provider.dart';
import '../services/content_service.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;
  
  const LessonScreen({super.key, required this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final ContentService _contentService = ContentService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _vocabulary = [];
  
  @override
  void initState() {
    super.initState();
    _loadLessonVocabulary();
  }
  
  Future<void> _loadLessonVocabulary() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final lessonVocab = await _contentService.getLessonVocabulary(widget.lessonId);
      setState(() {
        _vocabulary = lessonVocab;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading lesson vocabulary: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final lesson = languageProvider.getLessonById(widget.lessonId);
        
        if (lesson == null) {
          return const Scaffold(
            body: Center(
              child: Text('Lesson not found'),
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text(lesson.title),
          ),
          body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      lesson.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (_vocabulary.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('No vocabulary found for this lesson.'),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _vocabulary.length,
                        itemBuilder: (context, index) {
                          final word = _vocabulary[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: ListTile(
                              title: Text(
                                word['finnish'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(word['english'] ?? ''),
                                  if (word['example'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Example: ${word['example']}',
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: const Text('Take Quiz'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(lessonId: lesson.id),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}