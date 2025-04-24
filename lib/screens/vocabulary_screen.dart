
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';
import '../models/vocabulary.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final _finnishController = TextEditingController();
  final _englishController = TextEditingController();
  final _exampleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _userId; 
  
  @override
  void initState() {
  super.initState();
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    _userId = user.uid;
    Provider.of<VocabularyProvider>(context, listen: false)
        .loadUserVocabulary(user.uid);
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vocabulary'),
      ),
      body: Consumer<VocabularyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.userWords.isEmpty) {
            return Center(
              child: Text(
                'No words added yet.\nAdd your first Finnish word!',
                textAlign: TextAlign.center,
              ),
            );
          }
          
          return ListView.builder(
            itemCount: provider.userWords.length,
            itemBuilder: (context, index) {
              final word = provider.userWords[index];
              return ListTile(
                title: Text(word.finnish),
                subtitle: Text(word.english),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Replace with actual user ID
                    provider.deleteWord(_userId!, word.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddWordDialog(context),
      ),
    );
  }
  
  void _showAddWordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Word'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _finnishController,
                decoration: const InputDecoration(labelText: 'Finnish'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Finnish word';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _englishController,
                decoration: const InputDecoration(labelText: 'English'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the English translation';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _exampleController,
                decoration: const InputDecoration(
                  labelText: 'Example (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final provider = Provider.of<VocabularyProvider>(
                  context, 
                  listen: false
                );
                
                if(_userId != null) {
                  provider.addWord(
                    _userId!,
                    _finnishController.text,
                    _englishController.text,
                    example: _exampleController.text.isNotEmpty ? _exampleController.text : null,
                  );
                }
                
                _finnishController.clear();
                _englishController.clear();
                _exampleController.clear();
                
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}