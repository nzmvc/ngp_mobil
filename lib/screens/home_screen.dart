import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/student_provider.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch dashboard data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchDashboard();
      context.read<StudentProvider>().fetchStudentData();
    });
  }

  Future<void> _handleRefresh() async {
    await context.read<StudentProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGP Mobil'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/student-profile');
              } else if (value == 'logout') {
                final navigator = Navigator.of(context);
                await context.read<StudentProvider>().logout();
                if (mounted) {
                  navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('Profilim'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Çıkış Yap'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final dashboard = provider.dashboard;
          final user = provider.user;

          if (dashboard == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Veriler yüklenemedi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _handleRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yeniden Dene'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Text(
                    'Merhaba, ${user?.displayName ?? dashboard.student.fullName} 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Öğrenme yolculuğuna devam et!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Section
                  Text(
                    'İstatistikler',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Toplam Kurslar',
                          value: dashboard.stats.totalCourses.toString(),
                          icon: Icons.book,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Toplam Dersler',
                          value: dashboard.stats.totalLessons.toString(),
                          icon: Icons.school,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Bekleyen Ödevler',
                          value: dashboard.stats.pendingAssignments.toString(),
                          icon: Icons.assignment,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Tamamlanan',
                          value: dashboard.stats.completedAssignments.toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Gecikmiş Ödevler',
                          value: dashboard.stats.overdueAssignments.toString(),
                          icon: Icons.warning,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Toplam Ödevler',
                          value: dashboard.stats.totalAssignments.toString(),
                          icon: Icons.assignment_turned_in,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Hızlı Erişim',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          title: 'Puanlarım',
                          icon: Icons.stars,
                          color: Colors.amber,
                          onTap: () {
                            Navigator.pushNamed(context, '/student-scores');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          title: 'Profilim',
                          icon: Icons.person,
                          color: Colors.blue,
                          onTap: () {
                            Navigator.pushNamed(context, '/student-profile');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Assignments
                  if (dashboard.recentAssignments.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Son Ödevler',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/tasks');
                          },
                          child: const Text('Tümünü Gör'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...dashboard.recentAssignments.map((assignment) {
                      return _RecentAssignmentCard(
                        title: assignment.title,
                        status: assignment.status,
                        dueDate: assignment.dueDate,
                        isOverdue: assignment.isOverdue,
                        onTap: () {
                          Navigator.of(context).pushNamed('/tasks');
                        },
                      );
                    }),
                    const SizedBox(height: 24),
                  ],

                  // Recent Courses
                  if (dashboard.recentCourses.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kurslarım',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/courses');
                          },
                          child: const Text('Tümünü Gör'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...dashboard.recentCourses.map((course) {
                      return _RecentCourseCard(
                        title: course.title,
                        lessonCount: course.lessonCount,
                        onTap: () {
                          Navigator.of(context).pushNamed('/courses');
                        },
                      );
                    }),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentAssignmentCard extends StatelessWidget {
  final String title;
  final String status;
  final String? dueDate;
  final bool isOverdue;
  final VoidCallback onTap;

  const _RecentAssignmentCard({
    required this.title,
    required this.status,
    this.dueDate,
    required this.isOverdue,
    required this.onTap,
  });

  Color _getStatusColor() {
    if (isOverdue) return Colors.red;
    switch (status) {
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

  String _getStatusText() {
    if (isOverdue) return 'Gecikmiş';
    switch (status) {
      case 'pending':
        return 'Bekliyor';
      case 'submitted':
        return 'Teslim Edildi';
      case 'graded':
        return 'Notlandırıldı';
      case 'late':
        return 'Geç Teslim';
      case 'missing':
        return 'Eksik';
      default:
        return 'Bilinmiyor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withOpacity(0.1),
          child: Icon(
            isOverdue ? Icons.warning : Icons.assignment,
            color: _getStatusColor(),
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: dueDate != null
            ? Text('Son Tarih: ${DateFormat('dd.MM.yyyy').format(DateTime.parse(dueDate!))}')
            : null,
        trailing: Chip(
          label: Text(
            _getStatusText(),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getStatusColor().withOpacity(0.1),
          labelStyle: TextStyle(color: _getStatusColor()),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _RecentCourseCard extends StatelessWidget {
  final String title;
  final int lessonCount;
  final VoidCallback onTap;

  const _RecentCourseCard({
    required this.title,
    required this.lessonCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(
            Icons.book,
            color: Colors.blue,
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('$lessonCount ders'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
