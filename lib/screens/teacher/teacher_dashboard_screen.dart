import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/teacher_provider.dart';
import '../../models/teacher_dashboard.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeacherProvider>(context, listen: false).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Öğretmen Paneli',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2C3E50)),
            onPressed: () {
              Provider.of<TeacherProvider>(context, listen: false).loadDashboard();
            },
          ),
        ],
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadDashboard();
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (provider.dashboard == null) {
            return const Center(child: Text('Veri bulunamadı'));
          }

          final dashboard = provider.dashboard!;
          final teacher = dashboard.teacher;
          final stats = dashboard.statistics;

          return RefreshIndicator(
            onRefresh: () => provider.loadDashboard(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teacher Info Card
                  _buildTeacherCard(teacher),
                  const SizedBox(height: 20),

                  // Statistics Cards
                  const Text(
                    'İstatistikler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatisticsGrid(stats),
                  const SizedBox(height: 20),

                  // Today's Sessions
                  if (dashboard.todaySessions.isNotEmpty) ...[
                    const Text(
                      'Bugünkü Oturumlar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...dashboard.todaySessions.map((session) => _buildSessionCard(session)),
                    const SizedBox(height: 20),
                  ],

                  // Recent Sessions
                  if (dashboard.recentSessions.isNotEmpty) ...[
                    const Text(
                      'Son Oturumlar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...dashboard.recentSessions.take(5).map((session) => _buildSessionCard(session)),
                    const SizedBox(height: 20),
                  ],

                  // Pending Homeworks
                  if (dashboard.pendingHomeworks.isNotEmpty) ...[
                    const Text(
                      'Bekleyen Ödevler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...dashboard.pendingHomeworks.take(5).map((homework) => _buildHomeworkCard(homework)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeacherCard(dynamic teacher) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFF3498DB),
            backgroundImage: teacher.profilePicUrl != null
                ? NetworkImage(teacher.profilePicUrl!)
                : null,
            child: teacher.profilePicUrl == null
                ? Text(
                    teacher.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  teacher.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (teacher.sube != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Şube: ${teacher.sube}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3498DB),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(TeacherStatistics stats) {
    final statItems = [
      {
        'title': 'Öğrenciler',
        'value': stats.totalStudents.toString(),
        'icon': Icons.people,
        'color': const Color(0xFF3498DB),
      },
      {
        'title': 'Dersler',
        'value': stats.totalCourses.toString(),
        'icon': Icons.book,
        'color': const Color(0xFF9B59B6),
      },
      {
        'title': 'Ödevler',
        'value': stats.totalHomeworks.toString(),
        'icon': Icons.assignment,
        'color': const Color(0xFF1ABC9C),
      },
      {
        'title': 'Notlandırma Bekleyen',
        'value': stats.pendingGrading.toString(),
        'icon': Icons.pending_actions,
        'color': const Color(0xFFE67E22),
      },
      {
        'title': 'Bugünkü Yoklama',
        'value': stats.todayRollcalls.toString(),
        'icon': Icons.how_to_reg,
        'color': const Color(0xFF2ECC71),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: statItems.length,
      itemBuilder: (context, index) {
        final item = statItems[index];
        return _buildStatCard(
          title: item['title'] as String,
          value: item['value'] as String,
          icon: item['icon'] as IconData,
          color: item['color'] as Color,
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(dynamic session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.courseName ?? 'Ders',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.sessionDate ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard(dynamic homework) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE67E22),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homework.title ?? 'Ödev',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  homework.courseName ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE67E22).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Bekliyor',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFE67E22),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
