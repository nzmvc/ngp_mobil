import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../models/assignment.dart';
import '../models/dashboard.dart';
import '../services/api_service.dart';

class StudentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _user;
  Dashboard? _dashboard;
  List<Course> _courses = [];
  List<Assignment> _assignments = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  Dashboard? get dashboard => _dashboard;
  List<Course> get courses => _courses;
  List<Assignment> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed getters
  List<Assignment> get pendingAssignments =>
      _assignments.where((a) => a.status == 'pending').toList();
  
  List<Assignment> get completedAssignments =>
      _assignments.where((a) => a.status == 'graded' || a.status == 'submitted').toList();
  
  List<Assignment> get overdueAssignments =>
      _assignments.where((a) => a.isOverdue).toList();
  
  List<Assignment> get upcomingAssignments =>
      _assignments.where((a) => a.isDueSoon).toList();

  int get activeCourses => _dashboard?.stats.totalCourses ?? _courses.length;
  int get totalAssignments => _dashboard?.stats.totalAssignments ?? _assignments.length;

  // Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.login(username, password);
      
      if (result['success']) {
        // After successful login, fetch dashboard data
        await fetchDashboard();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Giriş yapılamadı: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    _dashboard = null;
    _courses = [];
    _assignments = [];
    notifyListeners();
  }

  // Fetch dashboard data
  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchDashboard();
      _dashboard = Dashboard.fromJson(data);
      _user = User.fromJson(data['student']);
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (_error!.contains('Unauthorized')) {
        await logout();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all student data
  Future<void> fetchStudentData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch courses and assignments in parallel
      final results = await Future.wait([
        _apiService.fetchCourses(),
        _apiService.fetchAssignments(),
      ]);

      _courses = results[0] as List<Course>;
      _assignments = results[1] as List<Assignment>;
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (_error!.contains('Unauthorized')) {
        // Token expired, need to re-login
        await logout();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await Future.wait([
      fetchDashboard(),
      fetchStudentData(),
    ]);
  }

  // Mark assignment as complete
  Future<bool> markAssignmentComplete(int assignmentId) async {
    try {
      final success = await _apiService.markAssignmentComplete(assignmentId);
      if (success) {
        // Refresh data to get updated status
        await fetchStudentData();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> checkAuth() async {
    final token = await _apiService.getToken();
    if (token != null) {
      // Try to fetch data to verify token is valid
      try {
        await fetchDashboard();
        return true;
      } catch (e) {
        await logout();
        return false;
      }
    }
    return false;
  }
}
