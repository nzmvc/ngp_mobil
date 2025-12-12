import 'package:flutter/foundation.dart';
import '../models/parent_dashboard.dart';
import '../models/child.dart';
import '../models/assignment.dart';
import '../models/attendance.dart';
import '../models/payment.dart';
import '../models/teacher_comment.dart';
import '../services/parent_api_service.dart';

class ParentProvider with ChangeNotifier {
  final ParentApiService _apiService = ParentApiService();
  
  ParentDashboard? _dashboard;
  List<Child> _children = [];
  Child? _selectedChild;
  List<Assignment> _childAssignments = [];
  List<Attendance> _childAttendance = [];
  List<Payment> _payments = [];
  List<TeacherComment> _comments = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  ParentDashboard? get dashboard => _dashboard;
  List<Child> get children => _children;
  Child? get selectedChild => _selectedChild;
  List<Assignment> get childAssignments => _childAssignments;
  List<Attendance> get childAttendance => _childAttendance;
  List<Payment> get payments => _payments;
  List<TeacherComment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed getters
  int get totalChildren => _dashboard?.statistics.totalChildren ?? _children.length;
  double get totalPayments => _dashboard?.statistics.totalPayments ?? 0.0;
  int get totalPendingAssignments => _dashboard?.statistics.totalPendingAssignments ?? 0;

  // Logout
  Future<void> logout() async {
    await _apiService.logout();
    _dashboard = null;
    _children = [];
    _selectedChild = null;
    _childAssignments = [];
    _childAttendance = [];
    _payments = [];
    _comments = [];
    notifyListeners();
  }

  // Fetch dashboard
  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _apiService.fetchDashboard();
      _children = _dashboard!.children;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch children
  Future<void> fetchChildren() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _children = await _apiService.fetchChildren();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select child and fetch their details
  Future<void> selectChild(int childId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedChild = await _apiService.fetchChildDetail(childId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _selectedChild = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch child assignments
  Future<void> fetchChildAssignments(int childId, {String? status, bool? isOverdue}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _childAssignments = await _apiService.fetchChildAssignments(
        childId,
        status: status,
        isOverdue: isOverdue,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _childAssignments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch child attendance
  Future<void> fetchChildAttendance(int childId, {int? limit, String? month}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _childAttendance = await _apiService.fetchChildAttendance(
        childId,
        limit: limit,
        month: month,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _childAttendance = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch payments
  Future<void> fetchPayments({int? limit}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _payments = await _apiService.fetchPayments(limit: limit);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _payments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch teacher comments
  Future<void> fetchTeacherComments({int? childId, int? limit}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _comments = await _apiService.fetchTeacherComments(
        childId: childId,
        limit: limit,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _comments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await fetchDashboard();
    if (_selectedChild != null) {
      await selectChild(_selectedChild!.id);
    }
  }

  // Clear all data
  void clear() {
    _dashboard = null;
    _children = [];
    _selectedChild = null;
    _childAssignments = [];
    _childAttendance = [];
    _payments = [];
    _comments = [];
    _error = null;
    notifyListeners();
  }
}
