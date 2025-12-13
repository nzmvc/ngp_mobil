class ScoreType {
  final int id;
  final String name;

  ScoreType({
    required this.id,
    required this.name,
  });

  factory ScoreType.fromJson(Map<String, dynamic> json) {
    return ScoreType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Score {
  final int id;
  final int score;
  final String? description;
  final String createdDate;
  final ScoreType? scoreType;
  final Map<String, dynamic>? givenBy;
  final Map<String, dynamic>? receivedBy;

  Score({
    required this.id,
    required this.score,
    this.description,
    required this.createdDate,
    this.scoreType,
    this.givenBy,
    this.receivedBy,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id: json['id'] ?? 0,
      score: json['score'] ?? 0,
      description: json['description'],
      createdDate: json['created_date'] ?? '',
      scoreType: json['score_type'] != null 
          ? ScoreType.fromJson(json['score_type']) 
          : null,
      givenBy: json['given_by'],
      receivedBy: json['received_by'],
    );
  }

  String get givenByName {
    if (givenBy == null) return 'Bilinmiyor';
    return givenBy!['full_name'] ?? givenBy!['username'] ?? 'Bilinmiyor';
  }

  String get scoreTypeName => scoreType?.name ?? 'Genel';
}

class StudentScoreStats {
  final int totalScore;
  final int scoreCount;
  final double averageScore;
  final int highestScore;
  final int lowestScore;
  final Map<String, Map<String, dynamic>> scoreByType;
  final List<Map<String, dynamic>> monthlyTrend;
  final List<Score> recentScores;
  final List<Score> allScores;

  StudentScoreStats({
    required this.totalScore,
    required this.scoreCount,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.scoreByType,
    required this.monthlyTrend,
    required this.recentScores,
    required this.allScores,
  });

  factory StudentScoreStats.fromJson(Map<String, dynamic> json) {
    final statistics = json['statistics'] ?? {};
    final scoreByType = Map<String, Map<String, dynamic>>.from(
      (json['score_by_type'] ?? {}).map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
      ),
    );

    final recentScoresList = (json['recent_scores'] as List<dynamic>?)
        ?.map((e) => Score.fromJson(e))
        .toList() ?? [];

    final allScoresList = (json['all_scores'] as List<dynamic>?)
        ?.map((e) => Score.fromJson(e))
        .toList() ?? [];

    return StudentScoreStats(
      totalScore: statistics['total_score'] ?? 0,
      scoreCount: statistics['score_count'] ?? 0,
      averageScore: (statistics['average_score'] ?? 0.0).toDouble(),
      highestScore: statistics['highest_score'] ?? 0,
      lowestScore: statistics['lowest_score'] ?? 0,
      scoreByType: scoreByType,
      monthlyTrend: List<Map<String, dynamic>>.from(json['monthly_trend'] ?? []),
      recentScores: recentScoresList,
      allScores: allScoresList,
    );
  }
}
