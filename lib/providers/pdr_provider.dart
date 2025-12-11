import 'package:flutter/foundation.dart';
import '../models/pdr_expert.dart';
import '../models/pdr_dashboard.dart';
import '../models/pdr_student.dart';
import '../models/pdr_question.dart';
import '../models/pdr_answer.dart';
import '../models/emotional_analysis.dart';
import '../services/pdr_api_service.dart';

class PdrProvider with ChangeNotifier {
  final PdrApiService _apiService = PdrApiService();

  // Dashboard data
  PdrDashboard? _dashboard;
  PdrDashboard? get dashboard => _dashboard;

  PdrExpert? get pdrExpert => _dashboard?.pdrExpert;
  PdrStatistics? get statistics => _dashboard?.statistics;

  // Students data
  List<PdrStudent> _students = [];
  List<PdrStudent> get students => _students;

  PdrStudent? _selectedStudent;
  PdrStudent? get selectedStudent => _selectedStudent;

  Map<String, dynamic>? _studentDetail;
  Map<String, dynamic>? get studentDetail => _studentDetail;

  // Questions data
  List<PdrQuestion> _questions = [];
  List<PdrQuestion> get questions => _questions;

  // Answers data
  List<PdrAnswer> _answers = [];
  List<PdrAnswer> get answers => _answers;

  // Analyses data
  List<EmotionalAnalysis> _analyses = [];
  List<EmotionalAnalysis> get analyses => _analyses;

  // Loading states
  bool _isLoadingDashboard = false;
  bool get isLoadingDashboard => _isLoadingDashboard;

  bool _isLoadingStudents = false;
  bool get isLoadingStudents => _isLoadingStudents;

  bool _isLoadingQuestions = false;
  bool get isLoadingQuestions => _isLoadingQuestions;

  bool _isLoadingAnswers = false;
  bool get isLoadingAnswers => _isLoadingAnswers;

  bool _isLoadingAnalyses = false;
  bool get isLoadingAnalyses => _isLoadingAnalyses;

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
  Future<void> loadStudents({String? search, String? riskLevel}) async {
    _isLoadingStudents = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _apiService.fetchStudents(
        search: search,
        riskLevel: riskLevel,
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
      _studentDetail = await _apiService.fetchStudentDetail(studentId);
      _selectedStudent = _studentDetail!['student'] as PdrStudent;
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
    _studentDetail = null;
    notifyListeners();
  }

  // Load questions
  Future<void> loadQuestions({
    String? ageRange,
    String? category,
    bool? isActive,
  }) async {
    _isLoadingQuestions = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _apiService.fetchQuestions(
        ageRange: ageRange,
        category: category,
        isActive: isActive,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading questions: $e');
    } finally {
      _isLoadingQuestions = false;
      notifyListeners();
    }
  }

  // Load answers
  Future<void> loadAnswers({
    int? studentId,
    int? questionId,
    String? riskLevel,
    bool? isReviewed,
  }) async {
    _isLoadingAnswers = true;
    _error = null;
    notifyListeners();

    try {
      _answers = await _apiService.fetchAnswers(
        studentId: studentId,
        questionId: questionId,
        riskLevel: riskLevel,
        isReviewed: isReviewed,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading answers: $e');
    } finally {
      _isLoadingAnswers = false;
      notifyListeners();
    }
  }

  // Load analyses
  Future<void> loadAnalyses({
    int? studentId,
    String? riskLevel,
    bool? expertReviewed,
  }) async {
    _isLoadingAnalyses = true;
    _error = null;
    notifyListeners();

    try {
      _analyses = await _apiService.fetchAnalyses(
        studentId: studentId,
        riskLevel: riskLevel,
        expertReviewed: expertReviewed,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading analyses: $e');
    } finally {
      _isLoadingAnalyses = false;
      notifyListeners();
    }
  }

  // Review answer
  Future<bool> reviewAnswer({
    required int answerId,
    required String expertNotes,
  }) async {
    try {
      final success = await _apiService.reviewAnswer(
        answerId: answerId,
        expertNotes: expertNotes,
      );
      
      if (success) {
        // Reload dashboard and answers
        await Future.wait([
          loadDashboard(),
          loadAnswers(),
        ]);
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error reviewing answer: $e');
      notifyListeners();
      return false;
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
      final success = await _apiService.reviewAnalysis(
        analysisId: analysisId,
        expertNotes: expertNotes,
        expertActionTaken: expertActionTaken,
        parentNotified: parentNotified,
      );
      
      if (success) {
        // Reload dashboard and analyses
        await Future.wait([
          loadDashboard(),
          loadAnalyses(),
        ]);
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error reviewing analysis: $e');
      notifyListeners();
      return false;
    }
  }

  // Clear all data
  void clearData() {
    _dashboard = null;
    _students = [];
    _selectedStudent = null;
    _studentDetail = null;
    _questions = [];
    _answers = [];
    _analyses = [];
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboard(),
      loadStudents(),
    ]);
  }
}
