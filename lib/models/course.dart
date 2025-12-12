class Course {
  final int id;
  final String title;
  final String? shortNot;
  final String? description;
  final String? lessonCategory;
  final String? categoryDisplay;
  final int lessonCount;
  final String? imageUrl;
  final double? price;
  final DateTime? enrollmentDate;

  Course({
    required this.id,
    required this.title,
    this.shortNot,
    this.description,
    this.lessonCategory,
    this.categoryDisplay,
    required this.lessonCount,
    this.imageUrl,
    this.price,
    this.enrollmentDate,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Handle lessonCategory which might be int or string
    String? lessonCat;
    if (json['lessonCategory'] != null) {
      lessonCat = json['lessonCategory'].toString();
    }
    
    // Handle category_display which might be int or string
    String? catDisplay;
    if (json['category_display'] != null) {
      catDisplay = json['category_display'].toString();
    }
    
    return Course(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      shortNot: json['shortNot'],
      description: json['description'],
      lessonCategory: lessonCat,
      categoryDisplay: catDisplay,
      lessonCount: json['lesson_count'] ?? 0,
      imageUrl: json['image_url'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      enrollmentDate: json['enrollment_date'] != null
          ? DateTime.parse(json['enrollment_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'shortNot': shortNot,
      'description': description,
      'lessonCategory': lessonCategory,
      'category_display': categoryDisplay,
      'lesson_count': lessonCount,
      'image_url': imageUrl,
      'price': price,
      'enrollment_date': enrollmentDate?.toIso8601String(),
    };
  }

  String get categoryName {
    switch (lessonCategory) {
      case 'coding':
        return 'Kodlama';
      case 'math':
        return 'Matematik';
      case 'robotics':
        return 'Robotik';
      case 'design':
        return 'Tasarım';
      case 'electronics':
        return 'Elektronik';
      case 'other':
        return 'Diğer';
      default:
        return categoryDisplay ?? 'Diğer';
    }
  }
}
