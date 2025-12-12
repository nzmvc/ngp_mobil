import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/parent_dashboard.dart';
import '../models/child.dart';
import '../models/assignment.dart';
import '../models/attendance.dart';
import '../models/payment.dart';
import '../models/teacher_comment.dart';

class ParentApiService {
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

  // Get parent dashboard
  Future<ParentDashboard> fetchDashboard() async {
    try {
      final headers = await _getHeaders();
      print('===== PARENT DASHBOARD DEBUG =====');
      print('Request URL: $baseUrl/parent/dashboard/');
      print('Headers: $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl/parent/dashboard/'),
        headers: headers,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body Length: ${response.body.length} bytes');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed JSON keys: ${data.keys.toList()}');
        print('Children in JSON: ${data['children']}');
        print('Children count: ${data['children']?.length ?? 0}');
        
        final dashboard = ParentDashboard.fromJson(data);
        print('Dashboard children count: ${dashboard.children.length}');
        if (dashboard.children.isNotEmpty) {
          print('First child: ${dashboard.children.first.fullName}');
        }
        print('==================================');
        
        return dashboard;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading dashboard');
    }
  }

  // Get all children
  Future<List<Child>> fetchChildren() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/parent/children/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> children = data['children'] ?? [];
        return children.map((json) => Child.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load children');
      }
    } catch (e) {
      throw Exception('Error fetching children: ${e.toString()}');
    }
  }

  // Get child detail
  Future<Child> fetchChildDetail(int childId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/parent/children/$childId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Child.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        throw Exception('Child not found or access denied');
      } else {
        throw Exception('Failed to load child details');
      }
    } catch (e) {
      throw Exception('Error fetching child details: ${e.toString()}');
    }
  }

  // Get child assignments
  Future<List<Assignment>> fetchChildAssignments(
    int childId, {
    String? status,
    bool? isOverdue,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (status != null) queryParams['status'] = status;
      if (isOverdue != null) queryParams['is_overdue'] = isOverdue.toString();
      
      final uri = Uri.parse('$baseUrl/parent/children/$childId/assignments/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> assignments = data['assignments'] ?? [];
        return assignments.map((json) => Assignment.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        throw Exception('Child not found or access denied');
      } else {
        throw Exception('Failed to load assignments');
      }
    } catch (e) {
      throw Exception('Error fetching assignments: ${e.toString()}');
    }
  }

  // Get child attendance/rollcall
  Future<List<Attendance>> fetchChildAttendance(
    int childId, {
    int? limit,
    String? month,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (limit != null) queryParams['limit'] = limit.toString();
      if (month != null) queryParams['month'] = month;
      
      final uri = Uri.parse('$baseUrl/parent/children/$childId/rollcall/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> rollcalls = data['rollcalls'] ?? [];
        return rollcalls.map((json) => Attendance.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        throw Exception('Child not found or access denied');
      } else {
        throw Exception('Failed to load attendance');
      }
    } catch (e) {
      throw Exception('Error fetching attendance: ${e.toString()}');
    }
  }

  // Get all payments
  Future<List<Payment>> fetchPayments({int? limit}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (limit != null) queryParams['limit'] = limit.toString();
      
      final uri = Uri.parse('$baseUrl/parent/payments/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> payments = data['payments'] ?? [];
        return payments.map((json) => Payment.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load payments');
      }
    } catch (e) {
      throw Exception('Error fetching payments: ${e.toString()}');
    }
  }

  // Get teacher comments
  Future<List<TeacherComment>> fetchTeacherComments({
    int? childId,
    int? limit,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (childId != null) queryParams['child_id'] = childId.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
      final uri = Uri.parse('$baseUrl/parent/comments/')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> comments = data['comments'] ?? [];
        return comments.map((json) => TeacherComment.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('Error fetching comments: ${e.toString()}');
    }
  }
}
