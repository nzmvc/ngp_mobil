# NGP Flutter Mobile App - User Type Based Routing Guide

## 📱 Genel Bakış

NGP mobil uygulamasında 5 farklı kullanıcı tipi bulunmaktadır. Login sonrası API'den dönen `user_type` bilgisine göre kullanıcılar farklı ekranlara yönlendirilmelidir.

---

## 🔐 Login API Response

### Endpoint: `POST /api/token/`

**Request:**
```dart
final response = await http.post(
  Uri.parse('https://ngp.teknolikya.com.tr/api/token/'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'username': usernameController.text,
    'password': passwordController.text,
  }),
);
```

**Response:**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user_type": "student",  // ⚡ KEY FIELD FOR ROUTING
  "user": {
    "id": 45,
    "username": "student123",
    "email": "student@example.com",
    "first_name": "Ali",
    "last_name": "Demir",
    "full_name": "Ali Demir"
  },
  "profile": {
    "id": 34,
    "profile_pic": "https://ngp.teknolikya.com.tr/media/students/ali.jpg",
    "gender": "male",
    "school": "Ankara İlkokulu",
    "birthday": "2010-05-15"
  }
}
```

---

## 🎯 Kullanıcı Tipleri ve Yönlendirme

### 1. **`student` - Öğrenci**
- **Dashboard:** `/student/dashboard`
- **Özellikler:**
  - Ödevler (assignments)
  - Kurslar (courses)
  - Dersler (lessons)
  - Görevler (tasks - sadece kendi görevleri)
  - Projeler (student projects)
  - Ruh hali tracker (mood tracking)
  - Öğrenme araçları (learning tools)
- **API Base:** `/api/student/`

### 2. **`parent` - Veli**
- **Dashboard:** `/parent/dashboard`
- **Özellikler:**
  - Çocuklar listesi (children list)
  - Çocuk detayları (child details)
  - Çocuk ödevleri (child assignments)
  - Yoklama kayıtları (attendance)
  - Ödemeler (payments)
  - Öğretmen yorumları (teacher comments)
- **API Base:** `/api/parent/`

### 3. **`teacher` - Öğretmen**
- **Dashboard:** `/teacher/dashboard`
- **Özellikler:**
  - Öğrenci listesi (student list)
  - Ders programı (lesson schedule)
  - Ödev oluştur/değerlendir (homework management)
  - Yoklama (roll call)
  - Öğrenci yorumları (student comments)
- **API Base:** `/api/teacher/` *(henüz implement edilmedi)*

### 4. **`pdr` - PDR Uzmanı (Psikolojik Danışma ve Rehberlik)**
- **Dashboard:** `/pdr/dashboard`
- **Özellikler:**
  - Öğrenci duygusal analiz (student emotional analysis)
  - Haftalık raporlar (weekly reports)
  - Mesajlaşma (messaging)
  - Anket soruları (survey questions)
  - Risk değerlendirme (risk assessment)
- **API Base:** `/api/pdr/` *(henüz implement edilmedi)*

### 5. **`admin` - Admin/Manager**
- **Dashboard:** `/admin/dashboard`
- **Özellikler:**
  - Tüm kullanıcı yönetimi (all user management)
  - Raporlar (reports)
  - Sistem ayarları (system settings)
  - İstatistikler (statistics)
- **API Base:** `/api/admin/` *(henüz implement edilmedi)*

---

## 💻 Flutter Implementation

### 1. Login Service

```dart
// lib/services/auth_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'https://ngp.teknolikya.com.tr';
  final storage = const FlutterSecureStorage();
  
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Token'ları kaydet
        await storage.write(key: 'access_token', value: data['access']);
        await storage.write(key: 'refresh_token', value: data['refresh']);
        await storage.write(key: 'user_type', value: data['user_type']);
        
        // Kullanıcı bilgilerini kaydet
        await storage.write(key: 'user_id', value: data['user']['id'].toString());
        await storage.write(key: 'username', value: data['user']['username']);
        await storage.write(key: 'full_name', value: data['user']['full_name']);
        
        // Profil bilgilerini kaydet (JSON string olarak)
        await storage.write(key: 'profile', value: jsonEncode(data['profile']));
        
        return {
          'success': true,
          'user_type': data['user_type'],
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Kullanıcı adı veya şifre hatalı',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Bağlantı hatası: $e',
      };
    }
  }
  
  Future<String?> getUserType() async {
    return await storage.read(key: 'user_type');
  }
  
  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'access_token');
    return token != null;
  }
  
  Future<void> logout() async {
    await storage.deleteAll();
  }
}
```

### 2. Login Screen with Routing

```dart
// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      final userType = result['user_type'];
      
      // ⚡ USER TYPE BASED ROUTING
      switch (userType) {
        case 'student':
          Navigator.pushReplacementNamed(context, '/student/dashboard');
          break;
        case 'parent':
          Navigator.pushReplacementNamed(context, '/parent/dashboard');
          break;
        case 'teacher':
          Navigator.pushReplacementNamed(context, '/teacher/dashboard');
          break;
        case 'pdr':
          Navigator.pushReplacementNamed(context, '/pdr/dashboard');
          break;
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bilinmeyen kullanıcı tipi')),
          );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 40),
                
                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kullanıcı adı gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Giriş Yap', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

### 3. App Routes

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/parent/parent_dashboard.dart';
import 'screens/teacher/teacher_dashboard.dart';
import 'screens/pdr/pdr_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGP Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/student/dashboard': (context) => const StudentDashboard(),
        '/parent/dashboard': (context) => const ParentDashboard(),
        '/teacher/dashboard': (context) => const TeacherDashboard(),
        '/pdr/dashboard': (context) => const PDRDashboard(),
        '/admin/dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}
```

### 4. Auto Login (App Startup)

```dart
// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay

    final isLoggedIn = await _authService.isLoggedIn();
    
    if (isLoggedIn) {
      final userType = await _authService.getUserType();
      
      // ⚡ AUTO ROUTE TO USER DASHBOARD
      switch (userType) {
        case 'student':
          Navigator.pushReplacementNamed(context, '/student/dashboard');
          break;
        case 'parent':
          Navigator.pushReplacementNamed(context, '/parent/dashboard');
          break;
        case 'teacher':
          Navigator.pushReplacementNamed(context, '/teacher/dashboard');
          break;
        case 'pdr':
          Navigator.pushReplacementNamed(context, '/pdr/dashboard');
          break;
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 150),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('NGP Yükleniyor...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔄 Token Refresh Logic

```dart
// lib/services/auth_service.dart (ekleme)

class AuthService {
  // ... (önceki kodlar)
  
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'access_token', value: data['access']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }
}
```

---

## 📊 API Request Helper with Auto Token Refresh

```dart
// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://ngp.teknolikya.com.tr';
  final _authService = AuthService();
  
  Future<http.Response> get(String endpoint) async {
    final token = await _authService.getAccessToken();
    
    var response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    // Token expired, try refresh
    if (response.statusCode == 401) {
      final refreshed = await _authService.refreshToken();
      if (refreshed) {
        final newToken = await _authService.getAccessToken();
        response = await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Authorization': 'Bearer $newToken',
            'Content-Type': 'application/json',
          },
        );
      }
    }
    
    return response;
  }
  
  // POST, PUT, DELETE methodları benzer şekilde implement edilebilir
}
```

---

## ✅ Implementation Checklist

- [ ] `flutter_secure_storage` package ekle (`pubspec.yaml`)
- [ ] `http` package ekle
- [ ] `AuthService` oluştur (login, logout, token management)
- [ ] `ApiService` oluştur (API requests with auto refresh)
- [ ] `SplashScreen` ile auto-login implement et
- [ ] `LoginScreen` ile user type based routing ekle
- [ ] 5 farklı dashboard ekranı oluştur:
  - [ ] Student Dashboard
  - [ ] Parent Dashboard
  - [ ] Teacher Dashboard
  - [ ] PDR Dashboard
  - [ ] Admin Dashboard
- [ ] Route guards ekle (yetkisiz erişim kontrolü)
- [ ] Logout functionality tüm ekranlara ekle
- [ ] Error handling ve user feedback (SnackBar/Dialog)

---

## 📦 Required Flutter Packages

```yaml
# pubspec.yaml

dependencies:
  flutter:
    sdk: flutter
  
  # HTTP requests
  http: ^1.1.0
  
  # Secure storage for tokens
  flutter_secure_storage: ^9.0.0
  
  # State management (optional - choose one)
  provider: ^6.1.1
  # OR
  riverpod: ^2.4.9
  # OR
  bloc: ^8.1.2
```

---

## 🎨 UI/UX Recommendations

### Student Dashboard
- **Tema:** Genç, renkli, gamification
- **Ana Kartlar:** Ödevler, Kurslar, Görevler, Projeler
- **Mood Tracker:** Emoji picker ile günlük ruh hali
- **Bottom Navigation:** Dashboard, Ödevler, Kurslar, Profil

### Parent Dashboard
- **Tema:** Professional, family-oriented
- **Ana Kartlar:** Çocuklar, Ödemeler, Yoklama, Yorumlar
- **Quick Actions:** Çocuk seç, ödeme geçmişi, mesajlar
- **Bottom Navigation:** Dashboard, Çocuklar, Ödemeler, Profil

### Teacher Dashboard
- **Tema:** Professional, productivity-focused
- **Ana Kartlar:** Öğrenciler, Dersler, Ödevler, Yoklama
- **Quick Actions:** Yoklama al, ödev oluştur, öğrenci yorumu
- **Bottom Navigation:** Dashboard, Öğrenciler, Ödevler, Profil

### PDR Dashboard
- **Tema:** Calm, professional, empathy-focused
- **Ana Kartlar:** Risk değerlendirme, haftalık raporlar, mesajlar
- **Quick Actions:** Anket gönder, rapor görüntüle, mesaj yaz
- **Bottom Navigation:** Dashboard, Öğrenciler, Raporlar, Mesajlar

### Admin Dashboard
- **Tema:** Data-rich, analytics-focused
- **Ana Kartlar:** Kullanıcılar, İstatistikler, Raporlar, Ayarlar
- **Quick Actions:** Kullanıcı ekle, rapor oluştur, sistem ayarları
- **Bottom Navigation:** Dashboard, Kullanıcılar, Raporlar, Ayarlar

---

## 🔒 Security Best Practices

1. **Token Storage:** Always use `flutter_secure_storage` (never SharedPreferences)
2. **HTTPS Only:** Production'da sadece HTTPS kullanın
3. **Token Expiry:** Access token 1 gün, refresh token 7 gün
4. **Auto Logout:** Token refresh başarısız olursa login ekranına yönlendir
5. **Biometric Auth:** (Optional) Face ID / Touch ID ekle
6. **Certificate Pinning:** (Advanced) Man-in-the-middle attack'lara karşı
7. **Input Validation:** Tüm form input'larını client-side validate et

---

## 📞 Support

API sorularınız için:
- **Backend Developer:** Backend takımı
- **API Docs:** `API.md` (Student), `API_PARENT.md` (Parent)
- **Endpoint:** `https://ngp.teknolikya.com.tr/api/`

---

## 🚀 Quick Start Command

```bash
# Flutter project oluştur
flutter create ngp_mobile

# Dependencies ekle
flutter pub add http flutter_secure_storage

# Run
flutter run
```

---

**Son Güncelleme:** 2025-12-11  
**API Version:** 1.0.0  
**Flutter SDK:** >= 3.0.0
