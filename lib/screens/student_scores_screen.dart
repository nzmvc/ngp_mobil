import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/student_provider.dart';
import '../models/score.dart';

class StudentScoresScreen extends StatefulWidget {
  const StudentScoresScreen({Key? key}) : super(key: key);

  @override
  State<StudentScoresScreen> createState() => _StudentScoresScreenState();
}

class _StudentScoresScreenState extends State<StudentScoresScreen> {
  bool _showAllScores = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puanlarım'),
        elevation: 0,
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.scoreStats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.scoreStats == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
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
                      provider.error ?? 'Bilinmeyen hata',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => provider.fetchScores(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.scoreStats == null) {
            return const Center(child: Text('Puan bilgisi yok'));
          }

          final stats = provider.scoreStats!;

          return RefreshIndicator(
            onRefresh: () => provider.fetchScores(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top statistics cards
                  _buildStatisticsCards(stats),
                  const SizedBox(height: 24),

                  // Score by type
                  if (stats.scoreByType.isNotEmpty) ...[
                    Text(
                      'Kategorilere Göre Puanlar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildScoreByType(stats.scoreByType),
                    const SizedBox(height: 24),
                  ],

                  // Recent/All scores header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _showAllScores ? 'Tüm Puanlar' : 'Son Puanlar',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (stats.allScores.length > stats.recentScores.length)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllScores = !_showAllScores;
                            });
                          },
                          child: Text(_showAllScores ? 'Daha Az' : 'Tümünü Gör'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Scores timeline
                  _buildScoresTimeline(
                    _showAllScores ? stats.allScores : stats.recentScores,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCards(StudentScoreStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Toplam Puan',
          stats.totalScore.toString(),
          Icons.stars,
          Colors.blue,
        ),
        _buildStatCard(
          'Ortalama',
          stats.averageScore.toStringAsFixed(1),
          Icons.analytics,
          Colors.green,
        ),
        _buildStatCard(
          'En Yüksek',
          stats.highestScore.toString(),
          Icons.trending_up,
          Colors.orange,
        ),
        _buildStatCard(
          'Puan Sayısı',
          stats.scoreCount.toString(),
          Icons.format_list_numbered,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const Spacer(),
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
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreByType(Map<String, Map<String, dynamic>> scoreByType) {
    return Column(
      children: scoreByType.entries.map((entry) {
        final typeName = entry.key;
        final total = entry.value['total'] ?? 0;
        final count = entry.value['count'] ?? 0;
        final average = count > 0 ? total / count : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTypeColor(typeName).withOpacity(0.2),
              child: Icon(
                _getTypeIcon(typeName),
                color: _getTypeColor(typeName),
              ),
            ),
            title: Text(
              typeName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$count puan • Ortalama: ${average.toStringAsFixed(1)}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTypeColor(typeName).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+$total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getTypeColor(typeName),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScoresTimeline(List<Score> scores) {
    if (scores.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.stars_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Henüz puan kaydı yok',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: scores.map((score) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: score.score >= 0
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              radius: 24,
              child: Text(
                score.score >= 0 ? '+${score.score}' : '${score.score}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: score.score >= 0 ? Colors.green : Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
            title: Text(
              score.scoreTypeName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (score.description != null && score.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      score.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        score.givenByName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatRelativeDate(score.createdDate),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getTypeColor(String typeName) {
    if (typeName.contains('Katılım') || typeName.contains('Devam')) {
      return Colors.blue;
    } else if (typeName.contains('Ödev')) {
      return Colors.orange;
    } else if (typeName.contains('Proje')) {
      return Colors.purple;
    } else if (typeName.contains('Sınav')) {
      return Colors.red;
    }
    return Colors.green;
  }

  IconData _getTypeIcon(String typeName) {
    if (typeName.contains('Katılım') || typeName.contains('Devam')) {
      return Icons.event_available;
    } else if (typeName.contains('Ödev')) {
      return Icons.assignment;
    } else if (typeName.contains('Proje')) {
      return Icons.folder_special;
    } else if (typeName.contains('Sınav')) {
      return Icons.quiz;
    }
    return Icons.stars;
  }

  String _formatRelativeDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
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
    } catch (e) {
      return dateStr;
    }
  }
}
