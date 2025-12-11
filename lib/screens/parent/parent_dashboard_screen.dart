import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/parent_provider.dart';
import '../../models/child.dart';
import '../../models/parent_dashboard.dart';
import 'package:intl/intl.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParentProvider>(context, listen: false).fetchDashboard();
    });
  }

  Future<void> _refreshData() async {
    await Provider.of<ParentProvider>(context, listen: false).fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veli Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: Consumer<ParentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.dashboard == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Veriler yüklenemedi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final dashboard = provider.dashboard;
          if (dashboard == null) {
            return const Center(child: Text('Veri bulunamadı'));
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  _buildWelcomeCard(dashboard.parent.fullName),
                  const SizedBox(height: 20),

                  // Statistics Cards
                  _buildStatisticsSection(dashboard.statistics),
                  const SizedBox(height: 20),

                  // Children Cards
                  if (dashboard.children.isNotEmpty) ...[
                    _buildSectionTitle('Çocuklarım'),
                    const SizedBox(height: 12),
                    _buildChildrenSection(dashboard.children),
                    const SizedBox(height: 20),
                  ],

                  // Recent Payments
                  if (dashboard.recentPayments.isNotEmpty) ...[
                    _buildSectionTitle('Son Ödemeler'),
                    const SizedBox(height: 12),
                    _buildRecentPaymentsSection(dashboard.recentPayments),
                    const SizedBox(height: 20),
                  ],

                  // Recent Comments
                  if (dashboard.recentComments.isNotEmpty) ...[
                    _buildSectionTitle('Öğretmen Yorumları'),
                    const SizedBox(height: 12),
                    _buildRecentCommentsSection(dashboard.recentComments),
                    const SizedBox(height: 20),
                  ],

                  // Recent Rollcalls
                  if (dashboard.recentRollcalls.isNotEmpty) ...[
                    _buildSectionTitle('Son Yoklamalar'),
                    const SizedBox(height: 12),
                    _buildRecentRollcallsSection(dashboard.recentRollcalls),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş Geldiniz',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(DashboardStatistics stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Çocuklar',
            stats.totalChildren.toString(),
            Icons.child_care,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Bekleyen Ödevler',
            stats.totalPendingAssignments.toString(),
            Icons.assignment_late,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildChildrenSection(List<Child> children) {
    return Column(
      children: children.map((child) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: child.gender == 'male' ? Colors.blue : Colors.pink,
              child: Text(
                child.initials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(child.fullName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (child.school != null) Text(child.school!),
                if (child.age != null) Text('${child.age} yaş'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/parent/child-detail',
                arguments: child.id,
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentPaymentsSection(List payments) {
    return Column(
      children: payments.take(3).map((payment) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.payment, color: Colors.white),
            ),
            title: Text(payment.studentName),
            subtitle: Text(payment.description),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  payment.formattedAmount,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  DateFormat('dd.MM.yyyy').format(DateTime.parse(payment.date)),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentCommentsSection(List comments) {
    return Column(
      children: comments.take(3).map((comment) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.comment, color: Colors.white),
            ),
            title: Text(comment.studentName),
            subtitle: Text(
              comment.descToStudent ?? 'Yorum bulunmuyor',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              DateFormat('dd.MM').format(DateTime.parse(comment.date)),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentRollcallsSection(List rollcalls) {
    return Column(
      children: rollcalls.take(5).map((rollcall) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: rollcall.rollcall ? Colors.green : Colors.red,
              child: Icon(
                rollcall.rollcall ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            title: Text(rollcall.studentName),
            subtitle: Text(rollcall.lessonSubject),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rollcall.rollcallDisplay,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: rollcall.rollcall ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  DateFormat('dd.MM').format(DateTime.parse(rollcall.date)),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
