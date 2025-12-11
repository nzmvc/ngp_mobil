import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/course.dart';
import '../models/assignment.dart';
import '../models/lesson.dart';


class ApiService {
  static const String baseUrl = 'http://192.168.1.4:8000/api';
  
  final storage = const FlutterSecureStorage();

  // Authentication
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Store tokens
        await storage.write(key: 'access_token', value: data['access']);
        if (data['refresh'] != null) {
          await storage.write(key: 'refresh_token', value: data['refresh']);
        }
        
        // Store user type for routing
        if (data['user_type'] != null) {
          await storage.write(key: 'user_type', value: data['user_type']);
        }
        
        // Store user info
        if (data['user'] != null) {
          await storage.write(key: 'user_id', value: data['user']['id'].toString());
          await storage.write(key: 'username', value: data['user']['username']);
          if (data['user']['full_name'] != null) {
            await storage.write(key: 'full_name', value: data['user']['full_name']);
          }
        }
        
        // Store profile info as JSON string
        if (data['profile'] != null) {
          await storage.write(key: 'profile', value: json.encode(data['profile']));
        }
        
        return {'success': true, 'data': data, 'user_type': data['user_type']};
      } else {
        return {
          'success': false,
          'error': 'Kullanıcı adı veya şifre hatalı'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Bağlantı hatası: ${e.toString()}'
      };
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'user_type');
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'username');
    await storage.delete(key: 'full_name');
    await storage.delete(key: 'profile');
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<String?> getUserType() async {
    return await storage.read(key: 'user_type');
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'access_token');
    return token != null;
  }

  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Fetch student assignments
  Future<Map<String, dynamic>> fetchDashboard() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/student/dashboard/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load dashboard');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard: ${e.toString()}');
    }
  }

  // Fetch student assignments
  Future<List<Assignment>> fetchAssignments({String? status, int? courseId, bool? isOverdue}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (status != null) queryParams['status'] = status;
      if (courseId != null) queryParams['course_id'] = courseId.toString();
      if (isOverdue != null) queryParams['is_overdue'] = isOverdue.toString();
      
      final uri = Uri.parse('$baseUrl/student/assignments/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> assignments = data['assignments'] ?? data;
        return assignments.map((json) => Assignment.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load assignments');
      }
    } catch (e) {
      throw Exception('Error fetching assignments: ${e.toString()}');
    }
  }

  // Fetch student courses
  Future<List<Course>> fetchCourses({String? category}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (category != null) queryParams['category'] = category;
      
      final uri = Uri.parse('$baseUrl/student/courses/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> courses = data['courses'] ?? data;
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

  // Fetch lessons for a specific course
  Future<Map<String, dynamic>> fetchLessons(int courseId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/courses/$courseId/lessons/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('You are not enrolled in this course');
      } else {
        throw Exception('Failed to load lessons');
      }
    } catch (e) {
      throw Exception('Error fetching lessons: ${e.toString()}');
    }
  }

  // Fetch lesson detail
  Future<Map<String, dynamic>> fetchLessonDetail(int lessonId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/$lessonId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('You are not enrolled in the course for this lesson');
      } else {
        throw Exception('Failed to load lesson');
      }
    } catch (e) {
      throw Exception('Error fetching lesson: ${e.toString()}');
    }
  }

  // Mark assignment as completed (if supported by backend)
  Future<bool> markAssignmentComplete(int assignmentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/student/assignments/$assignmentId/complete/'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
