class Lesson {
  final String id;
  final String title;
  final String description;
  final int order;
  final String imageUrl;
  final List<String> topics;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.imageUrl,
    required this.topics,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      order: map['order'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      topics: List<String>.from(map['topics'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'order': order,
      'imageUrl': imageUrl,
      'topics': topics,
    };
  }
}