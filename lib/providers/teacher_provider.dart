import 'package:flutter/foundation.dart';
import '../models/teacher.dart';
import '../models/teacher_dashboard.dart';
import '../models/teacher_student.dart';
import '../models/course.dart';
import '../models/attendance.dart';
import '../models/assignment.dart';
import '../services/teacher_api_service.dart';

class TeacherProvider with ChangeNotifier {
  final TeacherApiService _apiService = TeacherApiService();

  // Dashboard data
  TeacherDashboard? _dashboard;
  TeacherDashboard? get dashboard => _dashboard;

  Teacher? get teacher => _dashboard?.teacher;
  TeacherStatistics? get statistics => _dashboard?.statistics;

  // Students data
  List<TeacherStudent> _students = [];
  List<TeacherStudent> get students => _students;

  TeacherStudent? _selectedStudent;
  TeacherStudent? get selectedStudent => _selectedStudent;

  // Courses data
  List<Course> _courses = [];
  List<Course> get courses => _courses;

  // Rollcalls data
  List<Attendance> _rollcalls = [];
  List<Attendance> get rollcalls => _rollcalls;

  // Homeworks data
  List<Assignment> _homeworks = [];
  List<Assignment> get homeworks => _homeworks;

  List<Assignment> _pendingGrading = [];
  List<Assignment> get pendingGrading => _pendingGrading;

  // Loading states
  bool _isLoadingDashboard = false;
  bool get isLoadingDashboard => _isLoadingDashboard;

  bool _isLoadingStudents = false;
  bool get isLoadingStudents => _isLoadingStudents;

  bool _isLoadingCourses = false;
  bool get isLoadingCourses => _isLoadingCourses;

  // Logout
  Future<void> logout() async {
    await _apiService.logout();
    _dashboard = null;
    _students = [];
    _selectedStudent = null;
    _courses = [];
    _rollcalls = [];
    _homeworks = [];
    _pendingGrading = [];
    notifyListeners();
  }

  bool _isLoadingRollcalls = false;
  bool get isLoadingRollcalls => _isLoadingRollcalls;

  bool _isLoadingHomeworks = false;
  bool get isLoadingHomeworks => _isLoadingHomeworks;

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

  // Load students
  Future<void> loadStudents({String? search, int? courseId}) async {
    _isLoadingStudents = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _apiService.fetchStudents(
        search: search,
        courseId: courseId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading students: $e');
    } finally {
      _isLoadingStudents = false;
      notifyListeners();
    }
  }

  // Load student detail
  Future<void> loadStudentDetail(int studentId) async {
    _isLoadingStudents = true;
    _error = null;
    notifyListeners();

    try {
      _selectedStudent = await _apiService.fetchStudentDetail(studentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading student detail: $e');
    } finally {
      _isLoadingStudents = false;
      notifyListeners();
    }
  }

  // Clear selected student
  void clearSelectedStudent() {
    _selectedStudent = null;
    notifyListeners();
  }

  // Load courses
  Future<void> loadCourses() async {
    _isLoadingCourses = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _apiService.fetchCourses();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading courses: $e');
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  // Load rollcalls
  Future<void> loadRollcalls({
    String? date,
    int? courseId,
    int? limit,
  }) async {
    _isLoadingRollcalls = true;
    _error = null;
    notifyListeners();

    try {
      _rollcalls = await _apiService.fetchRollcalls(
        date: date,
        courseId: courseId,
        limit: limit,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading rollcalls: $e');
    } finally {
      _isLoadingRollcalls = false;
      notifyListeners();
    }
  }

  // Load homeworks
  Future<void> loadHomeworks({String? status, int? courseId}) async {
    _isLoadingHomeworks = true;
    _error = null;
    notifyListeners();

    try {
      _homeworks = await _apiService.fetchHomeworks(
        status: status,
        courseId: courseId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading homeworks: $e');
    } finally {
      _isLoadingHomeworks = false;
      notifyListeners();
    }
  }

  // Load pending grading
  Future<void> loadPendingGrading() async {
    _isLoadingHomeworks = true;
    _error = null;
    notifyListeners();

    try {
      _pendingGrading = await _apiService.fetchPendingGrading();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading pending grading: $e');
    } finally {
      _isLoadingHomeworks = false;
      notifyListeners();
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
      final success = await _apiService.createRollcall(
        studentId: studentId,
        courseSessionId: courseSessionId,
        rollcall: rollcall,
        descToStudent: descToStudent,
      );
      
      if (success) {
        // Reload dashboard to refresh statistics
        await loadDashboard();
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating rollcall: $e');
      notifyListeners();
      return false;
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
      final success = await _apiService.gradeHomework(
        assignmentId: assignmentId,
        score: score,
        maxScore: maxScore,
        feedback: feedback,
      );
      
      if (success) {
        // Reload dashboard and pending grading to refresh data
        await Future.wait([
          loadDashboard(),
          loadPendingGrading(),
        ]);
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error grading homework: $e');
      notifyListeners();
      return false;
    }
  }

  // Clear all data
  void clearData() {
    _dashboard = null;
    _students = [];
    _selectedStudent = null;
    _courses = [];
    _rollcalls = [];
    _homeworks = [];
    _pendingGrading = [];
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboard(),
      loadStudents(),
      loadCourses(),
    ]);
  }
}
