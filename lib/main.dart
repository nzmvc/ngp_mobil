import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/student_provider.dart';
import 'providers/parent_provider.dart';
import 'providers/teacher_provider.dart';
import 'providers/pdr_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/lessons_screen.dart';
import 'screens/lesson_detail_screen.dart';
import 'screens/parent/parent_dashboard_screen.dart';
import 'screens/teacher/teacher_dashboard_screen.dart';
import 'screens/pdr/pdr_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'models/course.dart';
import 'models/lesson.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Turkish date formatting
  await initializeDateFormatting('tr_TR', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => ParentProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => PdrProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'NGP Mobil',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: const CardThemeData(
            elevation: 2,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        initialRoute: '/splash',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/splash':
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );
            case '/login':
              return MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              );
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              );
            case '/parent/dashboard':
              return MaterialPageRoute(
                builder: (_) => const ParentDashboardScreen(),
              );
            case '/teacher/dashboard':
              return MaterialPageRoute(
                builder: (_) => const TeacherDashboardScreen(),
              );
            case '/pdr/dashboard':
              return MaterialPageRoute(
                builder: (_) => const PdrDashboardScreen(),
              );
            case '/admin/dashboard':
              return MaterialPageRoute(
                builder: (_) => const AdminDashboardScreen(),
              );
            case '/courses':
              return MaterialPageRoute(
                builder: (_) => const CoursesScreen(),
              );
            case '/tasks':
              return MaterialPageRoute(
                builder: (_) => const TasksScreen(),
              );
            case '/lessons':
              final course = settings.arguments as Course;
              return MaterialPageRoute(
                builder: (_) => LessonsScreen(course: course),
              );
            case '/lesson-detail':
              final lesson = settings.arguments as Lesson;
              return MaterialPageRoute(
                builder: (_) => LessonDetailScreen(lesson: lesson),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              );
          }
        },
      ),
    );
  }
}

// Splash screen that checks authentication
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait a bit for splash effect
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    final provider = context.read<StudentProvider>();
    final isAuthenticated = await provider.checkAuth();
    
    if (!mounted) return;
    
    if (isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'NGP Mobil',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
