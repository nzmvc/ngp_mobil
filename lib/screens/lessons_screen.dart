import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../services/api_service.dart';

class LessonsScreen extends StatefulWidget {
  final Course course;

  const LessonsScreen({super.key, required this.course});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final ApiService _apiService = ApiService();
  List<Lesson> _lessons = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('LessonsScreen initState - Course: ${widget.course.title} (ID: ${widget.course.id})');
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('DEBUG LessonsScreen: Fetching lessons for course ${widget.course.id}');
      final response = await _apiService.fetchLessons(widget.course.id);
      print('DEBUG LessonsScreen: API Response: $response');
      final lessonsList = response['lessons'] as List<dynamic>;
      print('DEBUG LessonsScreen: Found ${lessonsList.length} lessons');
      final lessons = lessonsList.map((json) {
        final lesson = Lesson.fromJson(json);
        // Set courseId from widget since API doesn't return it
        return Lesson(
          id: lesson.id,
          title: lesson.title,
          description: lesson.description,
          order: lesson.order,
          videoUrl: lesson.videoUrl,
          fileUrl: lesson.fileUrl,
          courseId: widget.course.id,
        );
      }).toList();
      setState(() {
        _lessons = lessons;
        _isLoading = false;
      });
      print('DEBUG LessonsScreen: Successfully loaded ${lessons.length} lessons');
    } catch (e) {
      print('DEBUG LessonsScreen: Error fetching lessons: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
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
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Dersler yüklenemedi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
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
                                _error!,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchLessons,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : _lessons.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bu kursta henüz ders yok',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchLessons,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = _lessons[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  '${lesson.order}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                lesson.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: lesson.description != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        lesson.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    )
                                  : null,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  '/lesson-detail',
                                  arguments: lesson,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
