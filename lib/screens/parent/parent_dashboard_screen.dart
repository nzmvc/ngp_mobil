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
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) async {
              if (value == 'logout') {
                final navigator = Navigator.of(context);
                await context.read<ParentProvider>().logout();
                if (mounted) {
                  navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                }
              }
            },
            itemBuilder: (BuildContext context) => [
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
      body: Consumer<ParentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.dashboard == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Veriler yüklenemedi',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sunucu hatası. Lütfen daha sonra tekrar deneyin.',
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

                  // Quick Access Buttons
                  _buildQuickAccessButtons(),
                  const SizedBox(height: 20),

                  // Children Cards
                  if (dashboard.children.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Çocuklarım'),
                        if (dashboard.children.length > 1)
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/parent/children');
                            },
                            child: const Text('Tümünü Gör'),
                          ),
                      ],
                    ),
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

                  // Recent Activity Timeline
                  if (dashboard.recentRollcalls.isNotEmpty || dashboard.recentComments.isNotEmpty) ...[
                    _buildSectionTitle('Son Aktiviteler'),
                    const SizedBox(height: 12),
                    _buildRecentActivityTimeline(
                      dashboard.recentRollcalls,
                      dashboard.recentComments,
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
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Çocuklar',
          stats.totalChildren.toString(),
          Icons.child_care,
          Colors.blue,
        ),
        _buildStatCard(
          'Toplam Ödeme',
          '${stats.totalPayments.toStringAsFixed(0)} ₺',
          Icons.payment,
          Colors.green,
        ),
        _buildStatCard(
          'Bekleyen Ödev',
          stats.totalPendingAssignments.toString(),
          Icons.assignment,
          Colors.orange,
        ),
        _buildStatCard(
          'Aktif Ders',
          stats.totalActiveSessions.toString(),
          Icons.school,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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

  Widget _buildQuickAccessButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildAccessButton(
            title: 'Ödemeler',
            icon: Icons.payment,
            color: Colors.green,
            onTap: () {
              Navigator.pushNamed(context, '/parent/payments');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAccessButton(
            title: 'Öğretmen Yorumları',
            icon: Icons.comment,
            color: Colors.purple,
            onTap: () {
              Navigator.pushNamed(context, '/parent/comments');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccessButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenSection(List<Child> children) {
    return Column(
      children: children.map((child) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/parent/child-detail',
                arguments: child.id,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'child-avatar-${child.id}',
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: child.profilePicUrl != null
                              ? NetworkImage(child.profilePicUrl!)
                              : null,
                          backgroundColor: child.gender == 1
                              ? Colors.blue[100]
                              : Colors.pink[100],
                          child: child.profilePicUrl == null
                              ? Text(
                                  child.initials,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: child.gender == 1
                                        ? Colors.blue[700]
                                        : Colors.pink[700],
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (child.school != null)
                              Row(
                                children: [
                                  Icon(Icons.school, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      child.school!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            if (child.age != null)
                              Row(
                                children: [
                                  Icon(Icons.cake, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${child.age} yaş',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat(Icons.assignment, '0', 'Ödev'),
                      _buildQuickStat(Icons.event, '95%', 'Devam'),
                      _buildQuickStat(Icons.folder, '0', 'Proje'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
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

  Widget _buildRecentActivityTimeline(List rollcalls, List comments) {
    final activities = <_ActivityItem>[];

    for (var rollcall in rollcalls) {
      activities.add(_ActivityItem(
        type: 'rollcall',
        date: DateTime.parse(rollcall.date),
        title: rollcall.lessonSubject,
        subtitle: '${rollcall.studentName} - ${rollcall.rollcallDisplay}',
        icon: rollcall.rollcall ? Icons.check_circle : Icons.cancel,
        color: rollcall.rollcall ? Colors.green : Colors.red,
      ));
    }

    for (var comment in comments) {
      if (comment.hasComment && comment.descToStudent != null) {
        activities.add(_ActivityItem(
          type: 'comment',
          date: DateTime.parse(comment.date),
          title: 'Öğretmen Yorumu',
          subtitle: comment.descToStudent!,
          icon: Icons.comment,
          color: Colors.purple,
        ));
      }
    }

    activities.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.take(5).length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isLast = index == activities.length - 1 || index == 4;
        return _buildTimelineItem(activity, isLast);
      },
    );
  }

  Widget _buildTimelineItem(_ActivityItem activity, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activity.color.withOpacity(0.2),
                border: Border.all(color: activity.color, width: 2),
              ),
              child: Icon(activity.icon, size: 20, color: activity.color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimeAgo(activity.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('dd.MM.yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}

class _ActivityItem {
  final String type;
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  _ActivityItem({
    required this.type,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
