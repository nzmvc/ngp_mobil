import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/parent_provider.dart';
import '../../models/child.dart';
import '../../models/assignment.dart';
import '../../models/attendance.dart';

class ChildDetailScreen extends StatefulWidget {
  final int childId;

  const ChildDetailScreen({Key? key, required this.childId}) : super(key: key);

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Child? _child;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChildDetail();
    _loadChildData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChildDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<ParentProvider>();
      await provider.selectChild(widget.childId);
      
      // Get selected child
      _child = provider.selectedChild;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadChildData() async {
    final provider = context.read<ParentProvider>();
    await provider.fetchChildAssignments(widget.childId);
    await provider.fetchChildAttendance(widget.childId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_child?.fullName ?? 'Çocuk Detayı'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ödevler'),
            Tab(text: 'Yoklamalar'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Hata: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadChildDetail,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAssignmentsTab(),
                    _buildAttendanceTab(),
                  ],
                ),
    );
  }

  Widget _buildAssignmentsTab() {
    return Consumer<ParentProvider>(
      builder: (context, provider, child) {
        if (provider.childAssignments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Henüz ödev yok'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchChildAssignments(widget.childId),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.childAssignments.length,
            itemBuilder: (context, index) {
              final assignment = provider.childAssignments[index];
              return _buildAssignmentCard(assignment);
            },
          ),
        );
      },
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    final isOverdue = assignment.isOverdue;
    final statusColor = assignment.status == 'completed'
        ? Colors.green
        : isOverdue
            ? Colors.red
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            assignment.status == 'completed'
                ? Icons.check_circle
                : isOverdue
                    ? Icons.warning
                    : Icons.pending,
            color: statusColor,
          ),
        ),
        title: Text(assignment.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assignment.courseName ?? 'Ders belirtilmemiş'),
            Text(
              'Son Tarih: ${assignment.formattedDueDate}',
              style: TextStyle(
                color: isOverdue ? Colors.red : null,
                fontWeight: isOverdue ? FontWeight.bold : null,
              ),
            ),
            if (assignment.grade != null)
              Text('Not: ${assignment.grade}/100'),
          ],
        ),
        trailing: Chip(
          label: Text(
            assignment.statusDisplay ?? 'Beklemede',
            style: const TextStyle(fontSize: 11),
          ),
          backgroundColor: statusColor.withOpacity(0.2),
          side: BorderSide(color: statusColor),
        ),
        onTap: () {
          // TODO: Navigate to assignment detail
        },
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return Consumer<ParentProvider>(
      builder: (context, provider, child) {
        if (provider.childAttendance.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Henüz yoklama kaydı yok'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchChildAttendance(widget.childId),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.childAttendance.length,
            itemBuilder: (context, index) {
              final attendance = provider.childAttendance[index];
              return _buildAttendanceCard(attendance);
            },
          ),
        );
      },
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    final statusColor = attendance.status == 'present'
        ? Colors.green
        : attendance.status == 'absent'
            ? Colors.red
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            attendance.status == 'present'
                ? Icons.check_circle
                : attendance.status == 'absent'
                    ? Icons.cancel
                    : Icons.help,
            color: statusColor,
          ),
        ),
        title: Text(attendance.lessonTitle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(attendance.formattedDate),
            if (attendance.comment != null && attendance.comment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  attendance.comment!,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
        trailing: Chip(
          label: Text(
            attendance.statusDisplay,
            style: const TextStyle(fontSize: 11),
          ),
          backgroundColor: statusColor.withOpacity(0.2),
          side: BorderSide(color: statusColor),
        ),
      ),
    );
  }
}
