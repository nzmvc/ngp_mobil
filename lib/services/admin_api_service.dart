import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/admin_dashboard.dart';
import '../models/system_user.dart';
import '../models/admin_student.dart';
import '../models/admin_teacher.dart';
import '../models/admin_parent.dart';
import '../models/course.dart';

class AdminApiService {
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

  // Get admin dashboard
  Future<AdminDashboard> fetchDashboard() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AdminDashboard.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to load dashboard');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard: ${e.toString()}');
    }
  }

  // Get all users
  Future<List<SystemUser>> fetchUsers({
    String? userType,
    String? search,
    bool? isActive,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (userType != null) queryParams['user_type'] = userType;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isActive != null) queryParams['is_active'] = isActive.toString();
      
      final uri = Uri.parse('$baseUrl/admin/users/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> users = data['users'] ?? [];
        return users.map((json) => SystemUser.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: ${e.toString()}');
    }
  }

  // Get all students
  Future<List<AdminStudent>> fetchStudents({String? search}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final uri = Uri.parse('$baseUrl/admin/students/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> students = data['students'] ?? [];
        return students.map((json) => AdminStudent.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      throw Exception('Error fetching students: ${e.toString()}');
    }
  }

  // Get all teachers
  Future<List<AdminTeacher>> fetchTeachers({String? search}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final uri = Uri.parse('$baseUrl/admin/teachers/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> teachers = data['teachers'] ?? [];
        return teachers.map((json) => AdminTeacher.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to load teachers');
      }
    } catch (e) {
      throw Exception('Error fetching teachers: ${e.toString()}');
    }
  }

  // Get all parents
  Future<List<AdminParent>> fetchParents({String? search}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final uri = Uri.parse('$baseUrl/admin/parents/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> parents = data['parents'] ?? [];
        return parents.map((json) => AdminParent.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to load parents');
      }
    } catch (e) {
      throw Exception('Error fetching parents: ${e.toString()}');
    }
  }

  // Get all courses
  Future<List<Course>> fetchCourses({String? search}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final uri = Uri.parse('$baseUrl/admin/courses/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> courses = data['courses'] ?? [];
        return courses.map((json) => Course.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      throw Exception('Error fetching courses: ${e.toString()}');
    }
  }

  // Delete user
  Future<bool> deleteUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId/delete/'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      throw Exception('Error deleting user: ${e.toString()}');
    }
  }

  // Toggle user active status
  Future<bool> toggleUserStatus(int userId, bool isActive) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$userId/toggle-status/'),
        headers: headers,
        body: json.encode({
          'is_active': isActive,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to update user status');
      }
    } catch (e) {
      throw Exception('Error updating user status: ${e.toString()}');
    }
  }
}
