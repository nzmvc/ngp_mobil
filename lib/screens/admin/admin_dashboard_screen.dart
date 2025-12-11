import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadDashboard();
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
          'Admin Paneli',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2C3E50)),
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false).loadDashboard();
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
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
          final admin = dashboard.adminUser;
          final stats = dashboard.statistics;
          final financial = dashboard.financialSummary;

          return RefreshIndicator(
            onRefresh: () => provider.loadDashboard(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin Info Card
                  _buildAdminCard(admin),
                  const SizedBox(height: 20),

                  // System Statistics
                  const Text(
                    'Sistem İstatistikleri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatisticsGrid(stats),
                  const SizedBox(height: 20),

                  // Financial Summary
                  const Text(
                    'Finansal Özet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFinancialCard(financial),
                  const SizedBox(height: 20),

                  // System Health
                  const Text(
                    'Sistem Durumu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSystemHealthCard(dashboard.systemHealth),
                  const SizedBox(height: 20),

                  // Recent Activities
                  if (dashboard.recentActivities.isNotEmpty) ...[
                    const Text(
                      'Son Aktiviteler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...dashboard.recentActivities.take(10).map(
                      (activity) => _buildActivityCard(activity),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminCard(dynamic admin) {
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
            backgroundColor: const Color(0xFFE74C3C),
            child: Text(
              admin.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  admin.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Sistem Yöneticisi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE74C3C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(dynamic stats) {
    final statItems = [
      {
        'title': 'Öğrenciler',
        'value': stats.totalStudents.toString(),
        'icon': Icons.school,
        'color': const Color(0xFF3498DB),
      },
      {
        'title': 'Öğretmenler',
        'value': stats.totalTeachers.toString(),
        'icon': Icons.person,
        'color': const Color(0xFF9B59B6),
      },
      {
        'title': 'Veliler',
        'value': stats.totalParents.toString(),
        'icon': Icons.people,
        'color': const Color(0xFF1ABC9C),
      },
      {
        'title': 'PDR Uzmanları',
        'value': stats.totalPdr.toString(),
        'icon': Icons.psychology,
        'color': const Color(0xFFE67E22),
      },
      {
        'title': 'Kurslar',
        'value': stats.totalCourses.toString(),
        'icon': Icons.book,
        'color': const Color(0xFF2ECC71),
      },
      {
        'title': 'Ödevler',
        'value': stats.totalHomeworks.toString(),
        'icon': Icons.assignment,
        'color': const Color(0xFFF39C12),
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

  Widget _buildFinancialCard(dynamic financial) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toplam Gelir',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                '₺${financial.totalIncome.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toplam Gider',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                '₺${financial.totalExpense.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Net Kar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '₺${financial.netProfit.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            financial.period,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealthCard(dynamic health) {
    Color statusColor;
    IconData statusIcon;
    
    switch (health.databaseStatus) {
      case 'healthy':
        statusColor = const Color(0xFF2ECC71);
        statusIcon = Icons.check_circle;
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'critical':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

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
        children: [
          Row(
            children: [
              Icon(statusIcon, size: 32, color: statusColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Veritabanı Durumu',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      health.databaseStatusDisplay,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'Aktif Öğrenci',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    health.activeStudents.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3498DB),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Aktif Öğretmen',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    health.activeTeachers.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9B59B6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(dynamic activity) {
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
                  activity.operation,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.userName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.access_time,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
