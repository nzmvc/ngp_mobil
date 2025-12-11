import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../providers/parent_provider.dart';
import '../providers/teacher_provider.dart';
import '../providers/pdr_provider.dart';
import '../providers/admin_provider.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Use ApiService to login and get user_type
      final apiService = ApiService();
      
      final result = await apiService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result['success'] == true) {
          final userType = result['user_type'] ?? 'student';
          
          // Route based on user type
          if (userType == 'student') {
            // Fetch student data
            final studentProvider = context.read<StudentProvider>();
            await studentProvider.fetchDashboard();
            
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          } else if (userType == 'parent') {
            // Fetch parent data
            final parentProvider = context.read<ParentProvider>();
            await parentProvider.fetchDashboard();
            
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/parent/dashboard');
            }
          } else if (userType == 'teacher') {
            // Fetch teacher data
            final teacherProvider = context.read<TeacherProvider>();
            await teacherProvider.loadDashboard();
            
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/teacher/dashboard');
            }
          } else if (userType == 'pdr') {
            // Fetch PDR data
            final pdrProvider = context.read<PdrProvider>();
            await pdrProvider.loadDashboard();
            
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/pdr/dashboard');
            }
          } else if (userType == 'admin') {
            // Fetch Admin data
            final adminProvider = context.read<AdminProvider>();
            await adminProvider.loadDashboard();
            
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/admin/dashboard');
            }
          } else {
            // For unknown user types, show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$userType girişi henüz desteklenmiyor'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Giriş başarısız'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Title
                  Icon(
                    Icons.school,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NGP Mobil',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Giriş Yap',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kullanıcı adı gerekli';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Şifre gerekli';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Giriş Yap',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
