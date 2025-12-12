import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/pdr_dashboard.dart';
import '../models/pdr_student.dart';
import '../models/pdr_question.dart';
import '../models/pdr_answer.dart';
import '../models/emotional_analysis.dart';

class PdrApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  final storage = const FlutterSecureStorage();

  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Logout
  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'user_type');
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'username');
    await storage.delete(key: 'full_name');
    await storage.delete(key: 'profile');
  }

  // Get PDR dashboard
  Future<PdrDashboard> fetchDashboard() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pdr/dashboard/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PdrDashboard.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load dashboard');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard: ${e.toString()}');
    }
  }

  // Get all students
  Future<List<PdrStudent>> fetchStudents({
    String? search,
    String? riskLevel,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (riskLevel != null) queryParams['risk_level'] = riskLevel;
      
      final uri = Uri.parse('$baseUrl/pdr/students/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> students = data['students'] ?? [];
        return students.map((json) => PdrStudent.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      throw Exception('Error fetching students: ${e.toString()}');
    }
  }

  // Get student detail with emotional analysis
  Future<Map<String, dynamic>> fetchStudentDetail(int studentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pdr/students/$studentId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'student': PdrStudent.fromJson(data['student']),
          'statistics': data['statistics'],
          'recent_analyses': (data['recent_analyses'] as List)
              .map((e) => EmotionalAnalysis.fromJson(e))
              .toList(),
          'risk_history': data['risk_history'],
          'recent_answers': (data['recent_answers'] as List)
              .map((e) => PdrAnswer.fromJson(e))
              .toList(),
        };
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Student not found');
      } else {
        throw Exception('Failed to load student details');
      }
    } catch (e) {
      throw Exception('Error fetching student details: ${e.toString()}');
    }
  }

  // Get questions
  Future<List<PdrQuestion>> fetchQuestions({
    String? ageRange,
    String? category,
    bool? isActive,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (ageRange != null) queryParams['age_range'] = ageRange;
      if (category != null) queryParams['category'] = category;
      if (isActive != null) queryParams['is_active'] = isActive.toString();
      
      final uri = Uri.parse('$baseUrl/pdr/questions/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> questions = data['questions'] ?? [];
        return questions.map((json) => PdrQuestion.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      throw Exception('Error fetching questions: ${e.toString()}');
    }
  }

  // Get answers
  Future<List<PdrAnswer>> fetchAnswers({
    int? studentId,
    int? questionId,
    String? riskLevel,
    bool? isReviewed,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (studentId != null) queryParams['student_id'] = studentId.toString();
      if (questionId != null) queryParams['question_id'] = questionId.toString();
      if (riskLevel != null) queryParams['risk_level'] = riskLevel;
      if (isReviewed != null) queryParams['is_reviewed'] = isReviewed.toString();
      
      final uri = Uri.parse('$baseUrl/pdr/answers/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> answers = data['answers'] ?? [];
        return answers.map((json) => PdrAnswer.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load answers');
      }
    } catch (e) {
      throw Exception('Error fetching answers: ${e.toString()}');
    }
  }

  // Get emotional analyses
  Future<List<EmotionalAnalysis>> fetchAnalyses({
    int? studentId,
    String? riskLevel,
    bool? expertReviewed,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (studentId != null) queryParams['student_id'] = studentId.toString();
      if (riskLevel != null) queryParams['risk_level'] = riskLevel;
      if (expertReviewed != null) queryParams['expert_reviewed'] = expertReviewed.toString();
      
      final uri = Uri.parse('$baseUrl/pdr/analyses/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> analyses = data['analyses'] ?? [];
        return analyses.map((json) => EmotionalAnalysis.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load analyses');
      }
    } catch (e) {
      throw Exception('Error fetching analyses: ${e.toString()}');
    }
  }

  // Review answer
  Future<bool> reviewAnswer({
    required int answerId,
    required String expertNotes,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pdr/answers/$answerId/review/'),
        headers: headers,
        body: json.encode({
          'expert_notes': expertNotes,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to review answer');
      }
    } catch (e) {
      throw Exception('Error reviewing answer: ${e.toString()}');
    }
  }

  // Review analysis
  Future<bool> reviewAnalysis({
    required int analysisId,
    required String expertNotes,
    String? expertActionTaken,
    bool? parentNotified,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/pdr/analyses/$analysisId/review/'),
        headers: headers,
        body: json.encode({
          'expert_notes': expertNotes,
          if (expertActionTaken != null) 'expert_action_taken': expertActionTaken,
          if (parentNotified != null) 'parent_notified': parentNotified,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to review analysis');
      }
    } catch (e) {
      throw Exception('Error reviewing analysis: ${e.toString()}');
    }
  }
}
