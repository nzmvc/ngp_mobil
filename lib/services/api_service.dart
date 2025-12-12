import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/course.dart';
import '../models/assignment.dart';
import '../models/lesson.dart';


class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
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
      print('DEBUG API fetchCourses: Requesting $uri');
      print('DEBUG API fetchCourses: Headers: $headers');
      final response = await http.get(uri, headers: headers);
      print('DEBUG API fetchCourses: Status code: ${response.statusCode}');
      print('DEBUG API fetchCourses: Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG API fetchCourses: Response keys: ${data.keys}');
        final List<dynamic> courses = data['courses'] ?? data;
        print('DEBUG API fetchCourses: Found ${courses.length} courses');
        return courses.map((json) => Course.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        print('DEBUG API fetchCourses: Unauthorized (401)');
        throw Exception('Unauthorized - Please login again');
      } else {
        print('DEBUG API fetchCourses: Failed with status ${response.statusCode}');
        print('DEBUG API fetchCourses: Response body: ${response.body}');
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG API fetchCourses: Exception: $e');
      throw Exception('Error fetching courses: ${e.toString()}');
    }
  }

  // Fetch lessons for a specific course
  Future<Map<String, dynamic>> fetchLessons(int courseId) async {
    try {
      final headers = await _getHeaders();
      print('API: Fetching lessons for course $courseId from $baseUrl/courses/$courseId/lessons/');
      final response = await http.get(
        Uri.parse('$baseUrl/courses/$courseId/lessons/'),
        headers: headers,
      );

      print('API: Lessons response status: ${response.statusCode}');
      print('API: Lessons response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('You are not enrolled in this course');
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('API: Error fetching lessons: $e');
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

  // Fetch assignment detail
  Future<Map<String, dynamic>> fetchAssignmentDetail(int assignmentId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/student/assignments/$assignmentId/');
      print('DEBUG API fetchAssignmentDetail: Requesting $uri');
      final response = await http.get(uri, headers: headers);
      print('DEBUG API fetchAssignmentDetail: Status code: ${response.statusCode}');
      print('DEBUG API fetchAssignmentDetail: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG API fetchAssignmentDetail: Response keys: ${data.keys}');
        return data;
      } else if (response.statusCode == 401) {
        print('DEBUG API fetchAssignmentDetail: Unauthorized (401)');
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        print('DEBUG API fetchAssignmentDetail: Not found (404)');
        throw Exception('Assignment not found');
      } else {
        print('DEBUG API fetchAssignmentDetail: Failed with status ${response.statusCode}');
        throw Exception('Failed to load assignment detail: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG API fetchAssignmentDetail: Exception: $e');
      throw Exception('Error fetching assignment detail: ${e.toString()}');
    }
  }

  // Submit assignment
  Future<Map<String, dynamic>> submitAssignment({
    required int assignmentId,
    required String submissionText,
    List<String>? filePaths,
  }) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type'); // multipart/form-data will set its own content type
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/student/assignments/$assignmentId/submit/'),
      );
      
      request.headers.addAll(headers);
      request.fields['text'] = submissionText;
      
      // Add files if provided
      if (filePaths != null && filePaths.isNotEmpty) {
        for (int i = 0; i < filePaths.length && i < 3; i++) {
          final file = await http.MultipartFile.fromPath(
            'file${i + 1}',
            filePaths[i],
          );
          request.files.add(file);
        }
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Invalid submission');
      } else {
        throw Exception('Failed to submit assignment');
      }
    } catch (e) {
      throw Exception('Error submitting assignment: ${e.toString()}');
    }
  }

  // Fetch student profile
  Future<Map<String, dynamic>> fetchStudentProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/student/profile/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      throw Exception('Error fetching profile: ${e.toString()}');
    }
  }

  // Update student profile
  Future<Map<String, dynamic>> updateStudentProfile({
    String? bio,
    String? school,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};
      
      if (bio != null) body['bio'] = bio;
      if (school != null) body['school'] = school;
      
      final response = await http.patch(
        Uri.parse('$baseUrl/student/profile/'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Invalid data');
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Error updating profile: ${e.toString()}');
    }
  }

  // Fetch student attendance
  Future<Map<String, dynamic>> fetchStudentAttendance({
    String? startDate,
    String? endDate,
    int? lessonId,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (lessonId != null) queryParams['lesson_id'] = lessonId.toString();
      
      final uri = Uri.parse('$baseUrl/student/attendance/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load attendance');
      }
    } catch (e) {
      throw Exception('Error fetching attendance: ${e.toString()}');
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
