import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/teacher_dashboard.dart';
import '../models/teacher_student.dart';
import '../models/course.dart';
import '../models/attendance.dart';
import '../models/assignment.dart';

class TeacherApiService {
  static const String baseUrl = 'http://192.168.1.4:8000/api';
  
  final storage = const FlutterSecureStorage();

  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get teacher dashboard
  Future<TeacherDashboard> fetchDashboard() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/teacher/dashboard/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TeacherDashboard.fromJson(data);
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
  Future<List<TeacherStudent>> fetchStudents({String? search, int? courseId}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (courseId != null) queryParams['course_id'] = courseId.toString();
      
      final uri = Uri.parse('$baseUrl/teacher/students/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> students = data['students'] ?? [];
        return students.map((json) => TeacherStudent.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      throw Exception('Error fetching students: ${e.toString()}');
    }
  }

  // Get student detail
  Future<TeacherStudent> fetchStudentDetail(int studentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/teacher/students/$studentId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TeacherStudent.fromJson(data);
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

  // Get courses
  Future<List<Course>> fetchCourses() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/teacher/courses/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> courses = data['courses'] ?? [];
        return courses.map((json) => Course.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      throw Exception('Error fetching courses: ${e.toString()}');
    }
  }

  // Get rollcalls (attendance records)
  Future<List<Attendance>> fetchRollcalls({
    String? date,
    int? courseId,
    int? limit,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (date != null) queryParams['date'] = date;
      if (courseId != null) queryParams['course_id'] = courseId.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
      final uri = Uri.parse('$baseUrl/teacher/rollcalls/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> rollcalls = data['rollcalls'] ?? [];
        return rollcalls.map((json) => Attendance.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load rollcalls');
      }
    } catch (e) {
      throw Exception('Error fetching rollcalls: ${e.toString()}');
    }
  }

  // Get homeworks (assignments)
  Future<List<Assignment>> fetchHomeworks({
    String? status,
    int? courseId,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (status != null) queryParams['status'] = status;
      if (courseId != null) queryParams['course_id'] = courseId.toString();
      
      final uri = Uri.parse('$baseUrl/teacher/homeworks/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> homeworks = data['homeworks'] ?? [];
        return homeworks.map((json) => Assignment.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load homeworks');
      }
    } catch (e) {
      throw Exception('Error fetching homeworks: ${e.toString()}');
    }
  }

  // Get pending grading homeworks
  Future<List<Assignment>> fetchPendingGrading() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/teacher/pending-grading/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> homeworks = data['homeworks'] ?? [];
        return homeworks.map((json) => Assignment.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load pending grading');
      }
    } catch (e) {
      throw Exception('Error fetching pending grading: ${e.toString()}');
    }
  }

  // Create rollcall
  Future<bool> createRollcall({
    required int studentId,
    required int courseSessionId,
    required bool rollcall,
    String? descToStudent,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/teacher/rollcalls/create/'),
        headers: headers,
        body: json.encode({
          'student_id': studentId,
          'course_session_id': courseSessionId,
          'rollcall': rollcall,
          if (descToStudent != null) 'desc_to_student': descToStudent,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to create rollcall');
      }
    } catch (e) {
      throw Exception('Error creating rollcall: ${e.toString()}');
    }
  }

  // Grade homework
  Future<bool> gradeHomework({
    required int assignmentId,
    required int score,
    int? maxScore,
    String? feedback,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/teacher/homeworks/$assignmentId/grade/'),
        headers: headers,
        body: json.encode({
          'score': score,
          if (maxScore != null) 'max_score': maxScore,
          if (feedback != null) 'feedback': feedback,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to grade homework');
      }
    } catch (e) {
      throw Exception('Error grading homework: ${e.toString()}');
    }
  }
}
