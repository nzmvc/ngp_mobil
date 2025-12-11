import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final Function(int)? onToggleComplete;
  final VoidCallback? onTap;

  const AssignmentCard({
    super.key,
    required this.assignment,
    this.onToggleComplete,
    this.onTap,
  });

  Color _getStatusColor() {
    if (assignment.isOverdue) return Colors.red;
    switch (assignment.status) {
      case 'pending':
        return Colors.orange;
      case 'submitted':
        return Colors.blue;
      case 'graded':
        return Colors.green;
      case 'late':
        return Colors.red;
      case 'missing':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    if (assignment.isOverdue) return Icons.warning;
    switch (assignment.status) {
      case 'pending':
        return Icons.schedule;
      case 'submitted':
        return Icons.upload_file;
      case 'graded':
        return Icons.check_circle;
      case 'late':
        return Icons.warning;
      case 'missing':
        return Icons.cancel;
      default:
        return Icons.assignment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = assignment.status == 'graded' || assignment.status == 'submitted';
    final statusColor = _getStatusColor();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: assignment.isOverdue
            ? BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Course and Lesson info
                        if (assignment.courseName != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.book,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  assignment.courseName!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                        ],
                        if (assignment.lessonName != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.school,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  assignment.lessonName!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Status Badge
                  Chip(
                    label: Text(
                      assignment.statusDisplay ?? assignment.status.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: statusColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: statusColor),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Due Date and Additional Info
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (assignment.dueDate != null) ...[
                    _InfoChip(
                      icon: Icons.calendar_today,
                      label: DateFormat('dd.MM.yyyy').format(assignment.dueDate!),
                      color: assignment.isOverdue ? Colors.red : Colors.grey,
                    ),
                  ],
                  if (assignment.daysRemaining != null && !assignment.isOverdue) ...[
                    _InfoChip(
                      icon: Icons.access_time,
                      label: '${assignment.daysRemaining} gün',
                      color: assignment.daysRemaining! <= 3 ? Colors.orange : Colors.grey,
                    ),
                  ],
                  if (assignment.homeworkType != null) ...[
                    _InfoChip(
                      icon: Icons.category,
                      label: assignment.homeworkTypeDisplay,
                      color: Colors.blue,
                    ),
                  ],
                  if (assignment.difficulty != null) ...[
                    _InfoChip(
                      icon: Icons.signal_cellular_alt,
                      label: assignment.difficultyDisplay,
                      color: assignment.difficulty == 'hard'
                          ? Colors.red
                          : assignment.difficulty == 'medium'
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ],
                ],
              ),
              // Grade info if graded
              if (assignment.grade != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Not: ${assignment.grade!.score}/${assignment.grade!.maxScore} (${assignment.grade!.percentage.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Feedback if available
              if (assignment.feedback != null && assignment.feedback!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.comment, color: Colors.blue[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          assignment.feedback!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
