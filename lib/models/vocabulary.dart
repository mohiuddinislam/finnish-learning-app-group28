import 'package:cloud_firestore/cloud_firestore.dart';

class Vocabulary {
  final String id;
  final String finnish;
  final String english;
  final String? audioPath;
  final String? example;
  final String? imageUrl;
  final bool isUserAdded; // Flag to identify user-added words
  final DateTime dateAdded;
  final int? practiceCount; // Track practice frequency

  Vocabulary({
    required this.id,
    required this.finnish,
    required this.english,
    this.audioPath,
    this.example,
    this.imageUrl,
    this.isUserAdded = false,
    DateTime? dateAdded,
    this.practiceCount = 0,
  }) : dateAdded = dateAdded ?? DateTime.now();

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    return Vocabulary(
      id: map['id'] ?? '',
      finnish: map['finnish'] ?? '',
      english: map['english'] ?? '',
      audioPath: map['audioPath'],
      example: map['example'],
      imageUrl: map['imageUrl'],
      isUserAdded: map['isUserAdded'] ?? false,
      dateAdded: map['dateAdded'] != null 
          ? (map['dateAdded'] as Timestamp).toDate() 
          : DateTime.now(),
      practiceCount: map['practiceCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'finnish': finnish,
      'english': english,
      'audioPath': audioPath,
      'example': example,
      'imageUrl': imageUrl,
      'isUserAdded': isUserAdded,
      'dateAdded': dateAdded,
      'practiceCount': practiceCount,
    };
  }

  Vocabulary copyWith({
    String? id,
    String? finnish,
    String? english,
    String? audioPath,
    String? example,
    String? imageUrl,
    bool? isUserAdded,
    DateTime? dateAdded,
    int? practiceCount,
  }) {
    return Vocabulary(
      id: id ?? this.id,
      finnish: finnish ?? this.finnish,
      english: english ?? this.english,
      audioPath: audioPath ?? this.audioPath,
      example: example ?? this.example,
      imageUrl: imageUrl ?? this.imageUrl,
      isUserAdded: isUserAdded ?? this.isUserAdded,
      dateAdded: dateAdded ?? this.dateAdded,
      practiceCount: practiceCount ?? this.practiceCount,
    );
  }
}