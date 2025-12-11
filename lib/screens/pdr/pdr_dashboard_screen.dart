import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pdr_provider.dart';

class PdrDashboardScreen extends StatefulWidget {
  const PdrDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PdrDashboardScreen> createState() => _PdrDashboardScreenState();
}

class _PdrDashboardScreenState extends State<PdrDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PdrProvider>(context, listen: false).loadDashboard();
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
          'PDR Uzmanı Paneli',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2C3E50)),
            onPressed: () {
              Provider.of<PdrProvider>(context, listen: false).loadDashboard();
            },
          ),
        ],
      ),
      body: Consumer<PdrProvider>(
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
          final expert = dashboard.pdrExpert;
          final stats = dashboard.statistics;

          return RefreshIndicator(
            onRefresh: () => provider.loadDashboard(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expert Info Card
                  _buildExpertCard(expert),
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

                  // High Risk Students
                  if (dashboard.highRiskStudents.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Yüksek Riskli Öğrenciler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${dashboard.highRiskStudents.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...dashboard.highRiskStudents.map(
                      (student) => _buildStudentCard(student),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Recent Analyses
                  if (dashboard.recentAnalyses.isNotEmpty) ...[
                    const Text(
                      'Son Duygusal Analizler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...dashboard.recentAnalyses.take(5).map(
                      (analysis) => _buildAnalysisCard(analysis),
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

  Widget _buildExpertCard(dynamic expert) {
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
            backgroundColor: const Color(0xFF9B59B6),
            backgroundImage: expert.profilePicUrl != null
                ? NetworkImage(expert.profilePicUrl!)
                : null,
            child: expert.profilePicUrl == null
                ? Text(
                    expert.initials,
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
                  expert.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expert.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (expert.specialization != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    expert.specialization!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9B59B6),
                      fontStyle: FontStyle.italic,
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

  Widget _buildStatisticsGrid(dynamic stats) {
    final statItems = [
      {
        'title': 'Öğrenciler',
        'value': stats.totalStudents.toString(),
        'icon': Icons.people,
        'color': const Color(0xFF3498DB),
      },
      {
        'title': 'Sorular',
        'value': stats.totalQuestions.toString(),
        'icon': Icons.quiz,
        'color': const Color(0xFF9B59B6),
      },
      {
        'title': 'Cevaplar',
        'value': stats.totalAnswers.toString(),
        'icon': Icons.question_answer,
        'color': const Color(0xFF1ABC9C),
      },
      {
        'title': 'Analizler',
        'value': stats.totalAnalyses.toString(),
        'icon': Icons.analytics,
        'color': const Color(0xFF2ECC71),
      },
      {
        'title': 'Yüksek Risk',
        'value': stats.highRiskCount.toString(),
        'icon': Icons.warning,
        'color': Colors.red,
      },
      {
        'title': 'İnceleme Bekleyen',
        'value': stats.pendingReview.toString(),
        'icon': Icons.pending_actions,
        'color': const Color(0xFFE67E22),
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

  Widget _buildStudentCard(dynamic student) {
    Color riskColor;
    switch (student.riskLevel) {
      case 'high':
      case 'critical':
        riskColor = Colors.red;
        break;
      case 'medium':
        riskColor = Colors.orange;
        break;
      default:
        riskColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withOpacity(0.3), width: 2),
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
            radius: 28,
            backgroundColor: riskColor.withOpacity(0.1),
            backgroundImage: student.profilePicUrl != null
                ? NetworkImage(student.profilePicUrl!)
                : null,
            child: student.profilePicUrl == null
                ? Text(
                    student.fullName[0].toUpperCase(),
                    style: TextStyle(
                      color: riskColor,
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
                  student.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                if (student.lastEmotion != null)
                  Text(
                    student.lastEmotion!.emotionDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      color: riskColor,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              student.riskLevelDisplay,
              style: TextStyle(
                fontSize: 12,
                color: riskColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(dynamic analysis) {
    Color riskColor;
    switch (analysis.riskLevel) {
      case 'high':
      case 'critical':
        riskColor = Colors.red;
        break;
      case 'medium':
        riskColor = Colors.orange;
        break;
      default:
        riskColor = Colors.green;
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  analysis.studentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  analysis.riskLevelDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    color: riskColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            analysis.weekDisplay,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          if (analysis.aiComment != null) ...[
            const SizedBox(height: 8),
            Text(
              analysis.aiComment!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (!analysis.expertReviewed) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pending, size: 14, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'İnceleme Bekliyor',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
