import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'profile_screen.dart';
import 'lesson_screen.dart';
import 'practice_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await Provider.of<LanguageProvider>(context, listen: false)
            .loadInitialData(user.uid);
      } catch (e) {
        // Handle error
        debugPrint('Error loading lesson data: $e');
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removed the Scaffold and kept just the content
    return Material(
    color: Colors.white, // Or use Theme.of(context).scaffoldBackgroundColor
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learn Finnish',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Continue Learning',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildContinueSection(),
            const SizedBox(height: 16),
            const Text(
              'Lessons',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildLessonGrid(),
            ),
          ],
        ),
      ),
      )
    );  
  }

  Widget _buildContinueSection() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLessonId = languageProvider.currentLessonId;
    
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    
    // Show continue buttons if there's a current lesson
    if (currentLessonId != null) {
      final lesson = languageProvider.getLessonById(currentLessonId);
      
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson?.title ?? 'Continue Learning',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(languageProvider.getLessonProgress(currentLessonId) * 100).toInt()}% Complete',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonScreen(lessonId: currentLessonId),
                  ),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      // Show a message if no lesson is in progress
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Start a lesson below to begin learning Finnish!'),
      );
    }
  }

  Widget _buildLessonGrid() {
    final provider = Provider.of<LanguageProvider>(context);
    final availableLessons = provider.getAvailableLessons();
    
    if (availableLessons.isEmpty) {
      return const Center(child: Text('No lessons available.'));
    }
    
    // First show regular lessons from Firebase
    List<Widget> lessonCards = [];
    
    // Add the first two lessons or as many as available
    for (var i = 0; i < availableLessons.length && i < 2; i++) {
      final lesson = availableLessons[i];
      final progress = provider.getLessonProgress(lesson.id);
      
      lessonCards.add(
        _buildLessonCard(
          context,
          icon: i == 0 ? Icons.abc : Icons.tag,
          title: lesson.title,
          color: i == 0 ? Colors.blue.shade100 : Colors.green.shade100,
          progress: progress,
          locked: provider.isLessonLocked(lesson.id),
          onTap: () {
            if (!provider.isLessonLocked(lesson.id)) {
              provider.setCurrentLesson(lesson.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonScreen(lessonId: lesson.id),
                ),
              );
            }
          },
        ),
      );
    }
    
    // Add quiz of the day card
    lessonCards.add(
      _buildLessonCard(
        context,
        icon: Icons.question_answer,
        title: 'Quiz of\nthe Day',
        color: Colors.orange.shade100,
        onTap: () {
          if (availableLessons.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizScreen(lessonId: availableLessons.first.id),
              ),
            );
          }
        },
      ),
    );
    
    
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: lessonCards,
    );
  }

  Widget _buildLessonCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    double progress = 0.0,
    bool locked = false,
  }) {
    return InkWell(
      onTap: locked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: locked ? Colors.grey.shade200 : color,
          borderRadius: BorderRadius.circular(12),
          border: locked 
            ? Border.all(color: Colors.grey.shade400)
            : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            locked 
              ? const Icon(Icons.lock, size: 40, color: Colors.grey)
              : Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: locked ? Colors.grey : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            if (progress > 0 && progress < 1)
              SizedBox(
                width: double.infinity,
                height: 5,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade700,
                  ),
                ),
              ),
            if (!locked)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('Start'),
              ),
          ],
        ),
      ),
    );
  }
}