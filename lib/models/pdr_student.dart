class PdrStudent {
  final int id;
  final String fullName;
  final String username;
  final String? profilePicUrl;
  final int gender;
  final String? school;
  final String? birthday;
  final int age;
  final int totalAnswers;
  final LastEmotion? lastEmotion;
  final String riskLevel;

  PdrStudent({
    required this.id,
    required this.fullName,
    required this.username,
    this.profilePicUrl,
    required this.gender,
    this.school,
    this.birthday,
    required this.age,
    required this.totalAnswers,
    this.lastEmotion,
    required this.riskLevel,
  });

  factory PdrStudent.fromJson(Map<String, dynamic> json) {
    return PdrStudent(
      id: json['id'],
      fullName: json['full_name'],
      username: json['username'],
      profilePicUrl: json['profile_pic_url'],
      gender: json['gender'],
      school: json['school'],
      birthday: json['birthday'],
      age: json['age'],
      totalAnswers: json['total_answers'],
      lastEmotion: json['last_emotion'] != null 
          ? LastEmotion.fromJson(json['last_emotion']) 
          : null,
      riskLevel: json['risk_level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'profile_pic_url': profilePicUrl,
      'gender': gender,
      'school': school,
      'birthday': birthday,
      'age': age,
      'total_answers': totalAnswers,
      'last_emotion': lastEmotion?.toJson(),
      'risk_level': riskLevel,
    };
  }

  String get genderDisplay {
    switch (gender) {
      case 1:
        return 'Erkek';
      case 2:
        return 'Kadın';
      default:
        return 'Belirtilmemiş';
    }
  }

  String get riskLevelDisplay {
    switch (riskLevel) {
      case 'low':
        return 'Düşük';
      case 'medium':
        return 'Orta';
      case 'high':
        return 'Yüksek';
      case 'critical':
        return 'Kritik';
      default:
        return riskLevel;
    }
  }
}

class LastEmotion {
  final String emotion;
  final String emotionDisplay;
  final String week;

  LastEmotion({
    required this.emotion,
    required this.emotionDisplay,
    required this.week,
  });

  factory LastEmotion.fromJson(Map<String, dynamic> json) {
    return LastEmotion(
      emotion: json['emotion'],
      emotionDisplay: json['emotion_display'],
      week: json['week'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emotion': emotion,
      'emotion_display': emotionDisplay,
      'week': week,
    };
  }
}
