import 'package:flutter/foundation.dart';
import '../models/admin_user.dart';
import '../models/admin_dashboard.dart';
import '../models/system_user.dart';
import '../models/admin_student.dart';
import '../models/admin_teacher.dart';
import '../models/admin_parent.dart';
import '../models/course.dart';
import '../services/admin_api_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();

  // Dashboard data
  AdminDashboard? _dashboard;
  AdminDashboard? get dashboard => _dashboard;

  AdminUser? get adminUser => _dashboard?.adminUser;
  AdminStatistics? get statistics => _dashboard?.statistics;
  FinancialSummary? get financialSummary => _dashboard?.financialSummary;

  // Users data
  List<SystemUser> _users = [];
  List<SystemUser> get users => _users;

  // Students data
  List<AdminStudent> _students = [];
  List<AdminStudent> get students => _students;

  // Teachers data
  List<AdminTeacher> _teachers = [];
  List<AdminTeacher> get teachers => _teachers;

  // Parents data
  List<AdminParent> _parents = [];
  List<AdminParent> get parents => _parents;

  // Courses data
  List<Course> _courses = [];
  List<Course> get courses => _courses;

  // Loading states
  bool _isLoadingDashboard = false;
  bool get isLoadingDashboard => _isLoadingDashboard;

  bool _isLoadingUsers = false;
  bool get isLoadingUsers => _isLoadingUsers;

  bool _isLoadingStudents = false;
  bool get isLoadingStudents => _isLoadingStudents;

  bool _isLoadingTeachers = false;
  bool get isLoadingTeachers => _isLoadingTeachers;

  bool _isLoadingParents = false;
  bool get isLoadingParents => _isLoadingParents;

  bool _isLoadingCourses = false;
  bool get isLoadingCourses => _isLoadingCourses;

  // Error states
  String? _error;
  String? get error => _error;

  // Load dashboard
  Future<void> loadDashboard() async {
    _isLoadingDashboard = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _apiService.fetchDashboard();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading dashboard: $e');
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  // Load users
  Future<void> loadUsers({
    String? userType,
    String? search,
    bool? isActive,
  }) async {
    _isLoadingUsers = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _apiService.fetchUsers(
        userType: userType,
        search: search,
        isActive: isActive,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading users: $e');
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  // Load students
  Future<void> loadStudents({String? search}) async {
    _isLoadingStudents = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _apiService.fetchStudents(search: search);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading students: $e');
    } finally {
      _isLoadingStudents = false;
      notifyListeners();
    }
  }

  // Load teachers
  Future<void> loadTeachers({String? search}) async {
    _isLoadingTeachers = true;
    _error = null;
    notifyListeners();

    try {
      _teachers = await _apiService.fetchTeachers(search: search);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading teachers: $e');
    } finally {
      _isLoadingTeachers = false;
      notifyListeners();
    }
  }

  // Load parents
  Future<void> loadParents({String? search}) async {
    _isLoadingParents = true;
    _error = null;
    notifyListeners();

    try {
      _parents = await _apiService.fetchParents(search: search);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading parents: $e');
    } finally {
      _isLoadingParents = false;
      notifyListeners();
    }
  }

  // Load courses
  Future<void> loadCourses({String? search}) async {
    _isLoadingCourses = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _apiService.fetchCourses(search: search);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading courses: $e');
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  // Delete user
  Future<bool> deleteUser(int userId) async {
    try {
      final success = await _apiService.deleteUser(userId);
      
      if (success) {
        // Reload users and dashboard
        await Future.wait([
          loadDashboard(),
          loadUsers(),
        ]);
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting user: $e');
      notifyListeners();
      return false;
    }
  }

  // Toggle user status
  Future<bool> toggleUserStatus(int userId, bool isActive) async {
    try {
      final success = await _apiService.toggleUserStatus(userId, isActive);
      
      if (success) {
        // Update user in list
        final userIndex = _users.indexWhere((u) => u.id == userId);
        if (userIndex != -1) {
          // Reload users to get updated data
          await loadUsers();
        }
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error toggling user status: $e');
      notifyListeners();
      return false;
    }
  }

  // Clear all data
  void clearData() {
    _dashboard = null;
    _users = [];
    _students = [];
    _teachers = [];
    _parents = [];
    _courses = [];
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboard(),
      loadUsers(),
      loadStudents(),
      loadTeachers(),
      loadParents(),
      loadCourses(),
    ]);
  }
}
