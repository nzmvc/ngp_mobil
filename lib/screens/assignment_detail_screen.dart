import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final int assignmentId;

  const AssignmentDetailScreen({Key? key, required this.assignmentId}) : super(key: key);

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _assignmentData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssignmentDetail();
  }

  Future<void> _loadAssignmentDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('DEBUG AssignmentDetail: Fetching assignment ${widget.assignmentId}');
      final data = await _apiService.fetchAssignmentDetail(widget.assignmentId);
      print('DEBUG AssignmentDetail: API Response keys: ${data.keys}');
      print('DEBUG AssignmentDetail: Assignment title: ${data['title']}');
      setState(() {
        _assignmentData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG AssignmentDetail: Error fetching assignment: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dosya açılamadı')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'submitted':
        return Colors.blue;
      case 'graded':
        return Colors.green;
      case 'late':
      case 'missing':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'submitted':
        return Icons.upload_file;
      case 'graded':
        return Icons.check_circle;
      case 'late':
        return Icons.warning;
      case 'missing':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödev Detayı'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Hata',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'DEBUG: Hata Detayı',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Assignment ID: ${widget.assignmentId}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _error!,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadAssignmentDetail,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(),
      floatingActionButton: _assignmentData != null &&
              _assignmentData!['status'] == 'pending'
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/assignment-submit',
                  arguments: widget.assignmentId,
                ).then((_) => _loadAssignmentDetail());
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Teslim Et'),
            )
          : null,
    );
  }

  Widget _buildContent() {
    final assignment = _assignmentData!;
    final homework = assignment['homework'];
    final submission = assignment['submission'];
    final grade = assignment['grade'];
    final status = assignment['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status
          Row(
            children: [
              Expanded(
                child: Text(
                  assignment['title'] ?? '',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Chip(
                avatar: Icon(_getStatusIcon(status), size: 18, color: statusColor),
                label: Text(
                  assignment['status_display'] ?? status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
                backgroundColor: statusColor.withOpacity(0.1),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Metadata chips
          if (homework != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (homework['homework_type'] != null)
                  Chip(
                    label: Text(_getHomeworkTypeDisplay(homework['homework_type'])),
                    avatar: const Icon(Icons.category, size: 18),
                  ),
                if (homework['difficulty'] != null)
                  Chip(
                    label: Text(_getDifficultyDisplay(homework['difficulty'])),
                    avatar: const Icon(Icons.signal_cellular_alt, size: 18),
                    backgroundColor: _getDifficultyColor(homework['difficulty']).withOpacity(0.1),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Due date
          if (assignment['due_date'] != null) ...[
            Card(
              child: ListTile(
                leading: Icon(Icons.event, color: Theme.of(context).primaryColor),
                title: const Text('Son Teslim Tarihi'),
                subtitle: Text(_formatDateTime(assignment['due_date'] as String?)),
                trailing: assignment['is_overdue'] == true
                    ? const Chip(
                        label: Text('Süre Doldu', style: TextStyle(fontSize: 11)),
                        backgroundColor: Colors.red,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Description (Markdown)
          if (assignment['description'] != null && assignment['description'].isNotEmpty) ...[
            Text(
              'Açıklama',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: MarkdownBody(
                data: assignment['description'],
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Attachment
          if (homework != null && homework['attachment_url'] != null) ...[
            Text(
              'Ek Dosya',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.attach_file, color: Colors.blue),
                title: const Text('Ödev Dosyası'),
                subtitle: const Text('İndirmek için tıklayın'),
                trailing: const Icon(Icons.download),
                onTap: () => _downloadFile(homework['attachment_url']),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Teacher notes
          if (assignment['teacher_notes'] != null && assignment['teacher_notes'].isNotEmpty) ...[
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Öğretmen Notları',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text((assignment['teacher_notes'] ?? '') as String),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Submission info
          if (submission != null) ...[
            Text(
              'Teslim Bilgisi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Teslim Edildi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Tarih: ${_formatDateTime(submission['submitted_at'] as String?)}'),
                    if (submission['is_late'] == true)
                      const Text(
                        'Geç teslim edildi',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Grade info
          if (grade != null) ...[
            Text(
              'Değerlendirme',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.green, size: 32),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${grade['score']} / ${grade['max_score']}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '%${grade['percentage'].toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (grade['graded_date'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Değerlendirme Tarihi: ${_formatDateTime(grade['graded_date'] as String?)}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Feedback
          if (assignment['feedback'] != null && assignment['feedback'].isNotEmpty) ...[
            Text(
              'Geri Bildirim',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.purple[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.comment, color: Colors.purple[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Öğretmen Yorumu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (assignment['feedback'] ?? '') as String,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  String _getHomeworkTypeDisplay(String type) {
    switch (type) {
      case 'assignment':
        return 'Ödev';
      case 'project':
        return 'Proje';
      case 'research':
        return 'Araştırma';
      case 'practice':
        return 'Alıştırma';
      case 'quiz':
        return 'Quiz';
      case 'reading':
        return 'Okuma';
      case 'presentation':
        return 'Sunum';
      default:
        return type;
    }
  }

  String _getDifficultyDisplay(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'Kolay';
      case 'medium':
        return 'Orta';
      case 'hard':
        return 'Zor';
      default:
        return difficulty;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Bilinmiyor';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}
