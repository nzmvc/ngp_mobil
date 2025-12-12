import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../widgets/course_card.dart';


class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Derslerim'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.courses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.courses.isEmpty) {
            print('DEBUG CoursesScreen: No courses found. Loading: ${provider.isLoading}, Error: ${provider.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz ders kaydınız yok',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (provider.error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'DEBUG: Hata',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.error!,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          print('DEBUG CoursesScreen: Showing ${provider.courses.length} courses');
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.blue[50],
                  child: Text(
                    'DEBUG: ${provider.courses.length} kurs bulundu',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: provider.courses.length,
                    itemBuilder: (context, index) {
                final course = provider.courses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: CourseCard(
                    course: course,
                    onTap: () {
                      print('CourseCard tapped: ${course.title} (ID: ${course.id})');
                      Navigator.of(context).pushNamed(
                        '/lessons',
                        arguments: course,
                      ).then((value) => print('Navigation to lessons completed'));
                    },
                  ),
                );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
