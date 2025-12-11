class PdrQuestion {
  final int id;
  final String text;
  final String ageRange;
  final String ageRangeDisplay;
  final String category;
  final String categoryDisplay;
  final String questionType;
  final String questionTypeDisplay;
  final List<String>? options;
  final List<EmojiOption>? emojiOptions;
  final int order;
  final bool isActive;
  final int? answersCount;

  PdrQuestion({
    required this.id,
    required this.text,
    required this.ageRange,
    required this.ageRangeDisplay,
    required this.category,
    required this.categoryDisplay,
    required this.questionType,
    required this.questionTypeDisplay,
    this.options,
    this.emojiOptions,
    required this.order,
    required this.isActive,
    this.answersCount,
  });

  factory PdrQuestion.fromJson(Map<String, dynamic> json) {
    List<EmojiOption>? emojiOpts;
    if (json['emoji_options'] != null) {
      emojiOpts = (json['emoji_options'] as List)
          .map((e) => EmojiOption.fromJson(e))
          .toList();
    }

    return PdrQuestion(
      id: json['id'],
      text: json['text'],
      ageRange: json['age_range'],
      ageRangeDisplay: json['age_range_display'],
      category: json['category'],
      categoryDisplay: json['category_display'],
      questionType: json['question_type'],
      questionTypeDisplay: json['question_type_display'],
      options: json['options'] != null 
          ? List<String>.from(json['options']) 
          : null,
      emojiOptions: emojiOpts,
      order: json['order'],
      isActive: json['is_active'],
      answersCount: json['answers_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'age_range': ageRange,
      'age_range_display': ageRangeDisplay,
      'category': category,
      'category_display': categoryDisplay,
      'question_type': questionType,
      'question_type_display': questionTypeDisplay,
      'options': options,
      'emoji_options': emojiOptions?.map((e) => e.toJson()).toList(),
      'order': order,
      'is_active': isActive,
      'answers_count': answersCount,
    };
  }
}

class EmojiOption {
  final String emoji;
  final String label;

  EmojiOption({
    required this.emoji,
    required this.label,
  });

  factory EmojiOption.fromJson(Map<String, dynamic> json) {
    return EmojiOption(
      emoji: json['emoji'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'label': label,
    };
  }
}
