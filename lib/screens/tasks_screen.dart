import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../models/assignment.dart';
import '../widgets/assignment_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStudentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödevlerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StudentProvider>().fetchStudentData();
            },
          ),
        ],
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.assignments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz ödev yok 🎉',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yeni ödevler eklendiğinde burada görünecek',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculate counts for all categories
          final allAssignments = provider.assignments;
          final pendingCount = allAssignments.where((a) => a.status == 'pending').length;
          final submittedCount = allAssignments.where((a) => a.status == 'submitted').length;
          final gradedCount = allAssignments.where((a) => a.status == 'graded').length;
          final overdueCount = allAssignments.where((a) => a.isOverdue).length;
          final lateCount = allAssignments.where((a) => a.status == 'late').length;

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: DefaultTabController(
              length: 5,
              child: Column(
                children: [
                  Material(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 1,
                    child: TabBar(
                      isScrollable: true,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).primaryColor,
                      tabs: [
                        Tab(text: 'Tümü (${allAssignments.length})'),
                        Tab(text: 'Bekleyen ($pendingCount)'),
                        Tab(text: 'Teslim Edildi ($submittedCount)'),
                        Tab(text: 'Notlandı ($gradedCount)'),
                        Tab(text: 'Gecikmiş ($overdueCount)'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // All assignments
                        _buildAssignmentsList(
                          allAssignments,
                          'Henüz ödev yok',
                        ),
                        // Pending tasks
                        _buildAssignmentsList(
                          allAssignments.where((a) => a.status == 'pending').toList(),
                          'Bekleyen ödev yok',
                        ),
                        // Submitted tasks
                        _buildAssignmentsList(
                          allAssignments.where((a) => a.status == 'submitted').toList(),
                          'Teslim edilmiş ödev yok',
                        ),
                        // Graded tasks
                        _buildAssignmentsList(
                          allAssignments.where((a) => a.status == 'graded').toList(),
                          'Notlandırılmış ödev yok',
                        ),
                        // Overdue tasks
                        _buildAssignmentsList(
                          allAssignments.where((a) => a.isOverdue).toList(),
                          'Gecikmiş ödev yok',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssignmentsList(List<Assignment> assignments, String emptyMessage) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Sort assignments: overdue first, then by due date
    final sortedAssignments = List<Assignment>.from(assignments)
      ..sort((a, b) {
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedAssignments.length,
      itemBuilder: (context, index) {
        final assignment = sortedAssignments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AssignmentCard(
            assignment: assignment,
            onTap: () {
              _showAssignmentDetails(context, assignment);
            },
          ),
        );
      },
    );
  }

  void _showAssignmentDetails(BuildContext context, Assignment assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Status and info
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (assignment.statusDisplay != null)
                      Chip(
                        label: Text(assignment.statusDisplay!),
                        backgroundColor: _getStatusColor(assignment).withOpacity(0.1),
                        labelStyle: TextStyle(color: _getStatusColor(assignment)),
                      ),
                    if (assignment.homeworkType != null)
                      Chip(
                        label: Text(assignment.homeworkTypeDisplay),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    if (assignment.difficulty != null)
                      Chip(
                        label: Text(assignment.difficultyDisplay),
                        backgroundColor: Colors.purple.withOpacity(0.1),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Course and Lesson
                if (assignment.courseName != null) ...[
                  _DetailRow(
                    icon: Icons.book,
                    label: 'Kurs',
                    value: assignment.courseName!,
                  ),
                  const SizedBox(height: 8),
                ],
                if (assignment.lessonName != null) ...[
                  _DetailRow(
                    icon: Icons.school,
                    label: 'Ders',
                    value: assignment.lessonName!,
                  ),
                  const SizedBox(height: 8),
                ],
                // Dates
                if (assignment.assignedDate != null) ...[
                  _DetailRow(
                    icon: Icons.event,
                    label: 'Veriliş Tarihi',
                    value: _formatDateTime(assignment.assignedDate!),
                  ),
                  const SizedBox(height: 8),
                ],
                if (assignment.dueDate != null) ...[
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Son Tarih',
                    value: _formatDateTime(assignment.dueDate!),
                    valueColor: assignment.isOverdue ? Colors.red : null,
                  ),
                  const SizedBox(height: 8),
                ],
                if (assignment.submissionDate != null) ...[
                  _DetailRow(
                    icon: Icons.upload_file,
                    label: 'Teslim Tarihi',
                    value: _formatDateTime(assignment.submissionDate!),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 16),
                // Description
                if (assignment.description != null && assignment.description!.isNotEmpty) ...[
                  const Text(
                    'Açıklama',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assignment.description!,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                ],
                // Grade
                if (assignment.grade != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            const Text(
                              'Not Bilgisi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${assignment.grade!.score} / ${assignment.grade!.maxScore} (${assignment.grade!.percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        if (assignment.grade!.gradedDate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Notlandırma: ${_formatDateTime(assignment.grade!.gradedDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Feedback
                if (assignment.feedback != null && assignment.feedback!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.comment, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            const Text(
                              'Geri Bildirim',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          assignment.feedback!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(Assignment assignment) {
    if (assignment.isOverdue) return Colors.red;
    switch (assignment.status) {
      case 'pending':
        return Colors.orange;
      case 'submitted':
        return Colors.blue;
      case 'graded':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}