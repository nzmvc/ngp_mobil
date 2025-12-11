class Lesson {
  final int id;
  final String title;
  final String? description;
  final int order;
  final String? videoUrl;
  final String? fileUrl;
  final int courseId;

  Lesson({
    required this.id,
    required this.title,
    this.description,
    required this.order,
    this.videoUrl,
    this.fileUrl,
    required this.courseId,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      order: json['order'] ?? 0,
      videoUrl: json['video_url'],
      fileUrl: json['file_url'],
      courseId: json['course_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'video_url': videoUrl,
      'file_url': fileUrl,
      'course_id': courseId,
    };
  }
}
