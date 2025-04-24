class Quiz {
  final String id;
  final String lessonId;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;

  Quiz({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] ?? '',
      lessonId: map['lessonId'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
      explanation: map['explanation'],
    );
  }
}