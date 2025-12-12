import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/student_profile.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final ApiService _apiService = ApiService();
  StudentProfile? _profile;
  bool _isLoading = true;
  String? _error;
  bool _isEditMode = false;

  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService.fetchStudentProfile();
      setState(() {
        _profile = StudentProfile.fromJson(data);
        _bioController.text = _profile!.bio ?? '';
        _schoolController.text = _profile!.school ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.updateStudentProfile(
        bio: _bioController.text.trim(),
        school: _schoolController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditMode = false;
        });
        await _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        elevation: 0,
        actions: [
          if (!_isEditMode && _profile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditMode = true;
                });
              },
            ),
          if (_isEditMode) ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                  _bioController.text = _profile!.bio ?? '';
                  _schoolController.text = _profile!.school ?? '';
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isLoading ? null : _saveProfile,
            ),
          ],
        ],
      ),
      body: _isLoading && _profile == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _profile == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Hata',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadProfile,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final profile = _profile!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with avatar
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: profile.profilePic != null
                      ? NetworkImage(profile.profilePic!)
                      : null,
                  child: profile.profilePic == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  profile.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${profile.username}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),

          // Stats cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Başarılar',
                    profile.achievementsCount.toString(),
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Projeler',
                    profile.projectsCount.toString(),
                    Icons.folder,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ),

          // Profile details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kişisel Bilgiler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Email
                _buildInfoCard(
                  icon: Icons.email,
                  label: 'E-posta',
                  value: profile.email,
                ),
                const SizedBox(height: 12),

                // School (editable)
                if (_isEditMode)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.school, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 12),
                              const Text(
                                'Okul',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _schoolController,
                            decoration: const InputDecoration(
                              hintText: 'Okul adı',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (profile.school != null)
                  _buildInfoCard(
                    icon: Icons.school,
                    label: 'Okul',
                    value: profile.school!,
                  ),
                const SizedBox(height: 12),

                // Gender
                if (profile.gender != null) ...[
                  _buildInfoCard(
                    icon: Icons.wc,
                    label: 'Cinsiyet',
                    value: profile.genderDisplay,
                  ),
                  const SizedBox(height: 12),
                ],

                // Birthday
                if (profile.birthday != null) ...[
                  _buildInfoCard(
                    icon: Icons.cake,
                    label: 'Doğum Tarihi',
                    value: profile.formattedBirthday,
                    trailing: profile.age != null ? '${profile.age} yaş' : null,
                  ),
                  const SizedBox(height: 12),
                ],

                // Bio (editable)
                const SizedBox(height: 8),
                Text(
                  'Hakkımda',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                if (_isEditMode)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _bioController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Kendiniz hakkında bir şeyler yazın...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        profile.bio ?? 'Henüz bir şey yazmadınız.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: profile.bio == null ? Colors.grey : null,
                          fontStyle: profile.bio == null ? FontStyle.italic : null,
                        ),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    String? trailing,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing != null
            ? Chip(
                label: Text(trailing),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              )
            : null,
      ),
    );
  }
}
