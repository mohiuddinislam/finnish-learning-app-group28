
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';
import '../services/auth_service.dart';
import '../models/vocabulary.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  bool _showTranslation = false;
  int _currentWordIndex = 0;
  List<String> _practiceCompletedIds = [];
  
  @override
  void initState() {
    super.initState();
    _loadPracticeWords();
  }
  
  Future<void> _loadPracticeWords() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Ensure user document exists before trying to use it
    final authService = AuthService();
    await authService.ensureUserDocumentExists(user.uid);
    
    // Now load practice words
    await Provider.of<VocabularyProvider>(context, listen: false)
        .loadPracticeWords(user.uid, useSpacedRepetition: true);
  }
}
  
  void _nextWord() {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (_currentWordIndex < provider.practiceWords.length - 1) {
      setState(() {
        _showTranslation = false;
        _currentWordIndex++;
      });
    } else {
      // Practice completed
      if (user != null) {
        provider.recordPracticeCompletion(user.uid, _practiceCompletedIds);
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Practice Complete'),
          content: const Text('Great job! You have completed this practice session.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context); 
              },
            ),
            TextButton(
              child: const Text('Practice Again'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentWordIndex = 0;
                  _showTranslation = false;
                  _practiceCompletedIds = [];
                });
                _loadPracticeWords();
              },
            ),
          ],
        ),
      );
    }
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
      ),
      body: Consumer<VocabularyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.practiceWords.isEmpty) {
            return const Center(
              child: Text(
                'No words available for practice.\nAdd some words first!',
                textAlign: TextAlign.center,
              ),
            );
          }
          
          final word = provider.practiceWords[_currentWordIndex];
          
          // Add word ID to completed list
          if (!_practiceCompletedIds.contains(word.id)) {
            _practiceCompletedIds.add(word.id);
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Word ${_currentWordIndex + 1} of ${provider.practiceWords.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          word.finnish,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_showTranslation)
                          Text(
                            word.english,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                            ),
                          ),
                        if (!_showTranslation)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showTranslation = true;
                              });
                            },
                            child: const Text('Show Translation'),
                          ),
                        if (word.example != null && _showTranslation) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Example: ${word.example}',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_showTranslation)
                      ElevatedButton(
                        onPressed: _nextWord,
                        child: const Text('Next Word'),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}