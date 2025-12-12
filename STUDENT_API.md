# 🎓 NGP Student Mobile API - Complete Documentation

> **Mobil Geliştirici için Copilot Prompt Dosyası**  
> Bu dosyayı Copilot'a vererek Flutter/React Native öğrenci uygulamasını faz faz geliştirebilirsiniz.

---

## 📋 Genel Bilgiler

**Base URL:** `https://ngp.teknolikya.com.tr/api/`  
**Authentication:** JWT Bearer Token  
**User Type:** `student`  
**Dil:** Türkçe  
**Platform:** Flutter / React Native

---

## 🔐 Authentication

### Login (Token Al)

**Endpoint:** `POST /api/token/`

**Request:**
```json
{
  "username": "student123",
  "password": "1234"
}
```

**Response (200 OK):**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user_type": "student",
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
    "gender": 0,
    "school": "Ankara İlkokulu",
    "birthday": "2010-05-15"
  }
}
```

**Flutter Örnek:**
```dart
// lib/services/auth_service.dart
Future<LoginResponse> login(String username, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/token/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'password': password}),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    await storage.write(key: 'access_token', value: data['access']);
    await storage.write(key: 'refresh_token', value: data['refresh']);
    await storage.write(key: 'user_type', value: data['user_type']);
    return LoginResponse.fromJson(data);
  }
  throw Exception('Login failed');
}
```

---

## 📊 Phase 1: Dashboard (Ana Sayfa)

### ✅ IMPLEMENTED - Student Dashboard

**Endpoint:** `GET /api/student/dashboard/`

**Authentication:** Required

**Response:**
```json
{
  "student": {
    "id": 34,
    "full_name": "Ali Demir",
    "username": "student123",
    "email": "student@example.com"
  },
  "stats": {
    "total_courses": 5,
    "total_assignments": 20,
    "pending_assignments": 8,
    "completed_assignments": 10,
    "overdue_assignments": 2,
    "total_lessons": 60
  },
  "recent_assignments": [
    {
      "id": 123,
      "title": "Math Homework 1",
      "status": "pending",
      "due_date": "2025-12-31",
      "is_overdue": false
    }
  ],
  "recent_courses": [
    {
      "id": 10,
      "title": "Introduction to Math",
      "lesson_count": 12
    }
  ]
}
```

**UI Tasarım:**
- 📈 **Stat Cards:** 4 renkli kart (kurslar, ödevler, dersler, tamamlama oranı)
- 📚 **Recent Assignments:** Horizontal scroll view
- 🎓 **Recent Courses:** Grid view (2 columns)
- 🔔 **Notifications Badge:** Overdue assignments count

**Flutter Widget Yapısı:**
```dart
// lib/screens/student/dashboard_screen.dart
class StudentDashboardScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: FutureBuilder<DashboardData>(
        future: ApiService().getStudentDashboard(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildStatsCards(snapshot.data!.stats),
                  _buildRecentAssignments(snapshot.data!.recentAssignments),
                  _buildRecentCourses(snapshot.data!.recentCourses),
                ],
              ),
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
```

---

## 📝 Phase 2: Assignments (Ödevler)

### ✅ IMPLEMENTED - List Assignments

**Endpoint:** `GET /api/student/assignments/`

**Query Parameters:**
- `status`: `pending|submitted|graded|late|missing`
- `course_id`: Integer (kursa göre filtrele)
- `is_overdue`: `true|false`

**Response:**
```json
{
  "count": 10,
  "assignments": [
    {
      "id": 123,
      "title": "Math Homework 1",
      "description": "Complete exercises 1-10",
      "homework_type": "assignment",
      "difficulty": "medium",
      "due_date": "2025-12-31",
      "status": "pending",
      "status_display": "Bekliyor",
      "is_overdue": false,
      "days_remaining": 10,
      "course_name": "Math 101",
      "lesson_name": "Algebra Basics",
      "submission_date": null,
      "has_submission": false,
      "grade": null,
      "feedback": null
    }
  ]
}
```

**UI Tasarım:**
- 📋 **Tab Bar:** Tümü / Bekleyen / Teslim Edildi / Değerlendirildi
- 🔍 **Search Bar:** Başlık ve açıklamada ara
- 🎯 **Filter Chips:** Kursa göre, süreye göre, zorluk seviyesine göre
- 🃏 **Assignment Card:** Sol badge (durum), sağ countdown timer
- ⚠️ **Overdue Badge:** Kırmızı uyarı

### 🚧 TODO - Assignment Detail

**Endpoint:** `GET /api/student/assignments/{id}/`

**Backend Geliştirme:**
```python
# education/api_views.py
class StudentAssignmentDetailAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request, assignment_id):
        assignment = get_object_or_404(
            HomeworkAssignment,
            id=assignment_id,
            student__user=request.user
        )
        serializer = HomeworkAssignmentDetailSerializer(assignment)
        return Response(serializer.data)
```

**Response:**
```json
{
  "id": 123,
  "title": "Math Homework 1",
  "description": "# Instructions\n\n1. Read chapter 3\n2. Complete exercises 1-10",
  "homework": {
    "id": 45,
    "homework_type": "assignment",
    "difficulty": "medium",
    "allow_late_submission": true,
    "allow_resubmission": false,
    "attachment_url": "https://ngp.teknolikya.com.tr/media/homework/math_hw1.pdf"
  },
  "due_date": "2025-12-31T23:59:59+03:00",
  "status": "pending",
  "submission": null,
  "grade": null,
  "teacher_notes": "Focus on understanding concepts"
}
```

### 🚧 TODO - Submit Assignment

**Endpoint:** `POST /api/student/assignments/{id}/submit/`

**Request (multipart/form-data):**
```
text: "Bu ödevde şunları öğrendim..."
file1: [File]
file2: [File]
file3: [File]
```

**Response:**
```json
{
  "success": true,
  "submission": {
    "id": 789,
    "submitted_at": "2025-12-20T15:30:00+03:00",
    "is_late": false,
    "version": 1
  }
}
```

---

## 🎓 Phase 3: Courses & Lessons (Kurslar ve Dersler)

### ✅ IMPLEMENTED - List Courses

**Endpoint:** `GET /api/student/courses/`

**Response:**
```json
{
  "count": 5,
  "courses": [
    {
      "id": 10,
      "title": "Introduction to Math",
      "shortNot": "Basic algebra and geometry",
      "description": "Complete course description...",
      "lessonCategory": "math",
      "category_display": "Matematik",
      "lesson_count": 12,
      "image_url": "https://ngp.teknolikya.com.tr/media/courses/math101.jpg",
      "price": 1000.00,
      "enrollment_date": "2025-09-01T10:00:00Z"
    }
  ]
}
```

### ✅ IMPLEMENTED - Course Lessons

**Endpoint:** `GET /api/courses/{course_id}/lessons/`

**Response:**
```json
{
  "course": {
    "id": 10,
    "title": "Introduction to Math",
    "lesson_count": 12
  },
  "lessons": [
    {
      "id": 101,
      "subject": "Lesson 1: Basic Algebra",
      "description_preview": "Introduction to algebraic concepts...",
      "order": 1,
      "video_url": "https://www.youtube.com/watch?v=abc123",
      "has_video": true,
      "has_attachment": false,
      "created_date": "2025-09-01T10:00:00Z"
    }
  ]
}
```

### ✅ IMPLEMENTED - Lesson Detail

**Endpoint:** `GET /api/lessons/{lesson_id}/`

**Response:**
```json
{
  "id": 101,
  "subject": "Lesson 1: Basic Algebra",
  "description": "# Full lesson content in Markdown\n\n## Variables\n...",
  "order": 1,
  "video_url": "https://www.youtube.com/watch?v=abc123",
  "file_url": "https://ngp.teknolikya.com.tr/media/lessons/algebra.pdf",
  "has_video": true,
  "has_attachment": true,
  "homework_count": 3
}
```

---

## 🎯 Phase 4: Personal Development (Kişisel Gelişim)

### 🚧 TODO - My Goals

**Endpoint:** `GET /api/student/goals/`

**Backend:**
```python
# user/api_views.py
class StudentGoalsAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        student = get_object_or_404(Students, user=request.user)
        goals = StudentGoal.objects.filter(
            student=student,
            company_id=student.company_id
        ).order_by('-created_date')
        
        return Response({
            'active_goals': goals.filter(status='active'),
            'completed_goals': goals.filter(status='completed'),
        })
```

**Response:**
```json
{
  "active_goals": [
    {
      "id": 12,
      "title": "Python öğrenmek",
      "category": "technical",
      "progress": 65,
      "target_date": "2026-06-01",
      "smart_criteria": {
        "specific": "Python ile web uygulaması geliştirmek",
        "measurable": "5 proje tamamlamak",
        "achievable": "Haftada 3 saat çalışarak",
        "relevant": "Yazılım kariyeri için gerekli",
        "time_bound": "6 ay içinde"
      }
    }
  ],
  "completed_goals": []
}
```

### 🚧 TODO - Add/Update Monthly Progress

**Endpoint:** `POST /api/student/goals/{goal_id}/progress/`

**Request:**
```json
{
  "self_rating": 4,
  "achievements": "Bu ay 2 proje tamamladım",
  "challenges": "Async programlamada zorlandım",
  "mood": "positive"
}
```

### 🚧 TODO - SWOT Analysis

**Endpoint:** `GET /api/student/development/swot/`

**Response:**
```json
{
  "strengths": "Problem çözme, matematik",
  "weaknesses": "Zaman yönetimi",
  "opportunities": "Yeni teknolojiler öğrenme",
  "threats": "Motivasyon düşüklüğü"
}
```

---

## 🚀 Phase 5: Projects (Proje Galerisi)

### 🚧 TODO - My Projects

**Endpoint:** `GET /api/student/projects/`

**Response:**
```json
{
  "projects": [
    {
      "id": 45,
      "slug": "my-first-robot-2025-12",
      "title": "İlk Robotum",
      "difficulty_level": "medium",
      "category": "robotics",
      "status": "published",
      "cover_image": "https://.../projects/robot.jpg",
      "view_count": 120,
      "like_count": 15,
      "created_date": "2025-12-01"
    }
  ]
}
```

### 🚧 TODO - Create Project

**Endpoint:** `POST /api/student/projects/`

**Request (multipart/form-data):**
```
title: "İlk Robotum"
difficulty_level: "medium"  # simple|medium|advanced
category: "robotics"
what_i_made: "Arduino ile hareket eden robot"
cover_image: [File]
video_url: "https://youtube.com/..."
materials: "Arduino, motor, tekerlek"
privacy: "public"  # public|private|school_only
```

---

## 📅 Phase 6: Attendance (Yoklama)

### 🚧 TODO - My Attendance

**Endpoint:** `GET /api/student/attendance/`

**Query Parameters:**
- `start_date`: YYYY-MM-DD
- `end_date`: YYYY-MM-DD
- `lesson_id`: Integer

**Response:**
```json
{
  "attendance_records": [
    {
      "id": 456,
      "lesson_subject": "Python Basics",
      "date": "2025-12-10T10:00:00+03:00",
      "attendance_status": "present",
      "attendance_display": "Geldi",
      "teacher_comment": "Aktif katılım gösterdi"
    }
  ],
  "statistics": {
    "total_sessions": 50,
    "present": 45,
    "absent": 3,
    "late": 2,
    "attendance_rate": 90.0
  }
}
```

---

## 🎨 Phase 7: Profile & Settings (Profil)

### 🚧 TODO - My Profile

**Endpoint:** `GET /api/student/profile/`

**Response:**
```json
{
  "id": 34,
  "user": {
    "username": "student123",
    "email": "student@example.com",
    "first_name": "Ali",
    "last_name": "Demir"
  },
  "profile_pic": "https://.../students/ali.jpg",
  "gender": 0,
  "school": "Ankara İlkokulu",
  "birthday": "2010-05-15",
  "age": 15,
  "bio": "Python ve robotik seviyorum",
  "achievements_count": 12,
  "projects_count": 5
}
```

### 🚧 TODO - Update Profile

**Endpoint:** `PATCH /api/student/profile/`

**Request:**
```json
{
  "bio": "Yeni bio",
  "school": "Yeni okul adı"
}
```

### 🚧 TODO - Change Password

**Endpoint:** `POST /api/student/change-password/`

**Request:**
```json
{
  "old_password": "1234",
  "new_password": "newpass123"
}
```

---

## 📱 Phase 8: Notifications (Bildirimler)

### 🚧 TODO - Get Notifications

**Endpoint:** `GET /api/student/notifications/`

**Response:**
```json
{
  "unread_count": 3,
  "notifications": [
    {
      "id": 789,
      "title": "Yeni Ödev",
      "message": "Math Homework 1 atandı",
      "type": "assignment",
      "is_read": false,
      "created_date": "2025-12-10T14:30:00+03:00",
      "action_url": "/assignments/123"
    }
  ]
}
```

### 🚧 TODO - Mark as Read

**Endpoint:** `POST /api/student/notifications/{id}/read/`

---

## 🎮 Phase 9: Gamification (Rozet ve Puanlar)

### 🚧 TODO - My Achievements

**Endpoint:** `GET /api/student/achievements/`

**Response:**
```json
{
  "total_score": 1250,
  "level": 8,
  "next_level_score": 1500,
  "badges": [
    {
      "id": 12,
      "name": "İlk Proje",
      "description": "İlk projenizi yayınladınız",
      "icon": "🎯",
      "earned_date": "2025-12-01"
    }
  ],
  "recent_scores": [
    {
      "points": 50,
      "reason": "Ödev teslimi",
      "date": "2025-12-10"
    }
  ]
}
```

---

## 🛠️ Copilot Kullanım Talimatları

### Faz 1: Authentication ve Dashboard
```
@workspace /new Flutter projesi oluştur. NGP Student Mobile App.

Gereksinimler:
1. JWT authentication (flutter_secure_storage)
2. Login sayfası
3. Dashboard sayfası (stats cards, recent assignments, recent courses)
4. API servis katmanı (http package)
5. State management (Provider/Riverpod)

API Dokümantasyonu: STUDENT_API.md

Lütfen:
- Clean Architecture kullan
- Error handling ekle
- Loading states ekle
- Token refresh logic ekle
```

### Faz 2: Assignments (Ödevler)
```
@workspace Ödev modülünü ekle.

Sayfalar:
1. AssignmentsListScreen (tab bar, filter, search)
2. AssignmentDetailScreen (markdown rendering, file download)
3. AssignmentSubmitScreen (file upload, text input)

API Endpoints:
- GET /api/student/assignments/
- GET /api/student/assignments/{id}/
- POST /api/student/assignments/{id}/submit/

Gerekli paketler:
- flutter_markdown
- file_picker
- http_parser (multipart upload)
```

### Faz 3-9: Diğer Modüller
Her faz için yukarıdaki format kullanılarak ayrı ayrı geliştirme yapılabilir.

---

## 🧪 Test Kullanıcıları

**Öğrenci 1:**
- Username: `student123`
- Password: `1234`
- Company ID: 1

**Öğrenci 2:**
- Username: `denizavci`
- Password: `1234`
- Company ID: 1

---

## 📊 API Status Table

| Endpoint | Method | Status | Phase |
|----------|--------|--------|-------|
| /api/token/ | POST | ✅ DONE | 1 |
| /api/student/dashboard/ | GET | ✅ DONE | 1 |
| /api/student/assignments/ | GET | ✅ DONE | 2 |
| /api/student/assignments/{id}/ | GET | 🚧 TODO | 2 |
| /api/student/assignments/{id}/submit/ | POST | 🚧 TODO | 2 |
| /api/student/courses/ | GET | ✅ DONE | 3 |
| /api/courses/{id}/lessons/ | GET | ✅ DONE | 3 |
| /api/lessons/{id}/ | GET | ✅ DONE | 3 |
| /api/student/goals/ | GET | 🚧 TODO | 4 |
| /api/student/goals/{id}/progress/ | POST | 🚧 TODO | 4 |
| /api/student/development/swot/ | GET | 🚧 TODO | 4 |
| /api/student/projects/ | GET | 🚧 TODO | 5 |
| /api/student/projects/ | POST | 🚧 TODO | 5 |
| /api/student/attendance/ | GET | 🚧 TODO | 6 |
| /api/student/profile/ | GET | 🚧 TODO | 7 |
| /api/student/profile/ | PATCH | 🚧 TODO | 7 |
| /api/student/change-password/ | POST | 🚧 TODO | 7 |
| /api/student/notifications/ | GET | 🚧 TODO | 8 |
| /api/student/achievements/ | GET | 🚧 TODO | 9 |

---

## 🎯 Backend Development Priority

**Immediate (Sprint 1):**
1. Assignment detail endpoint
2. Assignment submission endpoint
3. Profile GET/PATCH endpoints

**Short Term (Sprint 2):**
4. Goals API
5. SWOT analysis endpoint
6. Attendance API

**Medium Term (Sprint 3):**
7. Projects API (list, create, update)
8. Notifications API
9. Achievements/Gamification API

---

## 📝 Notes

- Tüm tarihler ISO 8601 format (timezone: Europe/Istanbul +03:00)
- Tüm image URL'ler absolute path
- Multi-tenant: Her request'te `company_id` kontrol edilir
- COPPA compliant: 13 yaş altı için parent approval gerekir

---

**Last Updated:** 2025-12-12  
**Version:** 1.0.0  
**Backend:** Django 3.2.10 + DRF 3.13.1
