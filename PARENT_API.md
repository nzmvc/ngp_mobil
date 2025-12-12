# 👨‍👩‍👧‍👦 NGP Parent Mobile API - Complete Documentation

> **Mobil Geliştirici için Copilot Prompt Dosyası**  
> Bu dosyayı Copilot'a vererek Flutter/React Native veli uygulamasını faz faz geliştirebilirsiniz.

---

## 📋 Genel Bilgiler

**Base URL:** `https://ngp.teknolikya.com.tr/api/`  
**Authentication:** JWT Bearer Token  
**User Type:** `parent`  
**Dil:** Türkçe  
**Platform:** Flutter / React Native

---

## 🔐 Authentication

### Login (Token Al)

**Endpoint:** `POST /api/token/`

**Request:**
```json
{
  "username": "pazizeavci",
  "password": "1234"
}
```

**Response (200 OK):**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user_type": "parent",
  "user": {
    "id": 25,
    "username": "pazizeavci",
    "email": "azize.avci@hotmail.com",
    "first_name": "Azize",
    "last_name": "Avcı",
    "full_name": "Azize Avcı"
  },
  "profile": {
    "id": 7,
    "profile_pic": null,
    "telephone": "5332216477",
    "gender": 1,
    "job": "Öğretmen"
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

### ✅ IMPLEMENTED - Parent Dashboard

**Endpoint:** `GET /api/parent/dashboard/`

**Authentication:** Required

**Response (200 OK):**
```json
{
  "parent": {
    "id": 7,
    "full_name": "Azize Avcı",
    "username": "pazizeavci",
    "email": "azize.avci@hotmail.com",
    "telephone": "5332216477",
    "profile_pic_url": null
  },
  "children": [
    {
      "id": 31,
      "full_name": "deniz avcı",
      "username": "denizavci",
      "profile_pic_url": null,
      "gender": 0,
      "school": "oo",
      "birthday": "2005-11-28",
      "age": 20
    }
  ],
  "statistics": {
    "total_children": 1,
    "total_payments": 0.0,
    "total_pending_assignments": 1,
    "total_active_sessions": 0
  },
  "recent_payments": [],
  "recent_rollcalls": [
    {
      "id": 2,
      "student_name": "deniz avcı",
      "lesson_subject": "Milo ve Hareket sensoru",
      "date": "2022-01-25T00:00:00+03:00",
      "attendance_status": "present",
      "attendance_display": "Geldi",
      "desc_to_student": null,
      "has_comment": false
    }
  ],
  "recent_comments": []
}
```

**UI Tasarım:**
- 👨‍👩‍👧‍👦 **Children Cards:** Her çocuk için özel kart (avatar, isim, okul, yaş)
- 📊 **Quick Stats:** 4 stat card (çocuk sayısı, ödemeler, bekleyen ödevler, aktif dersler)
- 📅 **Recent Activity:** Yoklamalar ve yorumlar timeline
- 💰 **Payment Summary:** Toplam ödeme ve son 3 ödeme

**Flutter Widget Yapısı:**
```dart
// lib/screens/parent/dashboard_screen.dart
class ParentDashboardScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Veliler Paneli'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: FutureBuilder<ParentDashboard>(
        future: ApiService().getParentDashboard(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RefreshIndicator(
              onRefresh: _refreshDashboard,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildChildrenSection(snapshot.data!.children),
                    _buildStatsCards(snapshot.data!.statistics),
                    _buildRecentActivity(snapshot.data!.recentRollcalls),
                    _buildPaymentSummary(snapshot.data!.recentPayments),
                  ],
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

**⚠️ CRITICAL BUG FIX:**
Backend API doğru çalışıyor (test edildi). Mobil tarafta bu kontroller yapılmalı:
1. ✅ JSON parse: `children` array'i doğru okunuyor mu?
2. ✅ Model mapping: `full_name` (snake_case) → `fullName` (camelCase) dönüşümü
3. ✅ State update: `setState()` veya `notifyListeners()` çağrılıyor mu?
4. ✅ UI rendering: ListView `itemCount` doğru mu?

---

## 👶 Phase 2: Children Management (Çocuk Yönetimi)

### ✅ IMPLEMENTED - List Children

**Endpoint:** `GET /api/parent/children/`

**Response:**
```json
{
  "children": [
    {
      "id": 31,
      "full_name": "deniz avcı",
      "username": "denizavci",
      "email": "deniz@example.com",
      "profile_pic_url": null,
      "gender": 0,
      "school": "oo",
      "birthday": "2005-11-28",
      "age": 20,
      "enrollment_date": "2020-09-01T10:00:00+03:00"
    }
  ]
}
```

**UI Tasarım:**
- 🃏 **Child Card:** Avatar, isim, yaş, okul
- 📱 **Quick Actions:** Ödevleri gör, yoklamaları gör, mesaj gönder
- 🔍 **Search:** Çocuk ara (multiple children için)
- ➕ **Add Child Button:** Yeni çocuk kayıt isteği gönder (admin approval)

### ✅ IMPLEMENTED - Child Detail

**Endpoint:** `GET /api/parent/children/{child_id}/`

**Response:**
```json
{
  "id": 31,
  "full_name": "deniz avcı",
  "username": "denizavci",
  "email": "deniz@example.com",
  "profile_pic_url": null,
  "gender": 0,
  "school": "oo",
  "birthday": "2005-11-28",
  "age": 20,
  "courses": [
    {
      "id": 10,
      "title": "Python Programming",
      "lesson_count": 24,
      "enrollment_date": "2025-09-01"
    }
  ],
  "recent_assignments": [],
  "recent_rollcalls": [
    {
      "lesson_subject": "Milo ve Hareket sensoru",
      "date": "2022-01-25",
      "attendance_status": "present"
    }
  ],
  "statistics": {
    "total_courses": 1,
    "total_assignments": 1,
    "pending_assignments": 1,
    "attendance_rate": 95.5
  }
}
```

**UI Tasarım:**
- 📊 **Tab Bar:** Genel Bakış / Ödevler / Yoklamalar / Kurslar / Kişisel Gelişim
- 📈 **Progress Chart:** Attendance rate, assignment completion
- 🎯 **Achievement Badges:** Çocuğun kazandığı rozetler
- 💬 **Teacher Comments:** Öğretmen yorumları timeline

### 🚧 TODO - Child Personal Development

**Endpoint:** `GET /api/parent/children/{child_id}/development/`

**Backend:**
```python
# user/api_views.py
class ParentChildDevelopmentAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request, child_id):
        parent = get_object_or_404(Parents, user=request.user)
        child = get_object_or_404(Students, id=child_id, parents=parent)
        
        # Get SWOT analysis
        development = StudentDevelopment.objects.filter(
            child=child,
            is_current=True
        ).first()
        
        # Get active goals
        active_goals = StudentGoal.objects.filter(
            student=child,
            status='active'
        )
        
        # Get monthly progress
        progress = GoalMonthlyProgress.objects.filter(
            goal__student=child
        ).order_by('-month')[:6]
        
        return Response({
            'swot': {
                'strengths': development.strengths if development else '',
                'weaknesses': development.weaknesses if development else '',
                'opportunities': development.opportunities if development else '',
                'threats': development.threats if development else '',
            },
            'active_goals': StudentGoalSerializer(active_goals, many=True).data,
            'recent_progress': MonthlyProgressSerializer(progress, many=True).data,
        })
```

**Response:**
```json
{
  "swot": {
    "strengths": "Problem çözme, matematik",
    "weaknesses": "Zaman yönetimi",
    "opportunities": "Yeni teknolojiler",
    "threats": "Motivasyon düşüklüğü"
  },
  "active_goals": [
    {
      "id": 12,
      "title": "Python öğrenmek",
      "category": "technical",
      "progress": 65,
      "target_date": "2026-06-01",
      "smart_criteria": {
        "specific": "Python ile web app geliştirmek",
        "measurable": "5 proje tamamlamak"
      }
    }
  ],
  "recent_progress": [
    {
      "month": "2025-12",
      "self_rating": 4,
      "achievements": "2 proje tamamlandı",
      "challenges": "Async öğrenme zorlandı",
      "mood": "positive"
    }
  ]
}
```

**UI Tasarım:**
- 🎯 **SWOT Cards:** 4 renkli kart (Strengths, Weaknesses, Opportunities, Threats)
- 📈 **Goals Progress:** Linear progress bar + percentage
- 📅 **Monthly Timeline:** Mood emoji + achievements
- 👍 **Parent Encouragement:** Velinin destekleyici mesaj gönderebilmesi

---

## 📝 Phase 3: Assignments Tracking (Ödev Takibi)

### ✅ IMPLEMENTED - Child Assignments

**Endpoint:** `GET /api/parent/children/{child_id}/assignments/`

**Query Parameters:**
- `status`: `pending|submitted|graded|late|missing`
- `course_id`: Integer
- `date_range`: `week|month|all`

**Response:**
```json
{
  "child": {
    "id": 31,
    "full_name": "deniz avcı"
  },
  "summary": {
    "total": 20,
    "pending": 5,
    "submitted": 8,
    "graded": 7,
    "overdue": 2,
    "average_score": 85.5
  },
  "assignments": [
    {
      "id": 123,
      "title": "Math Homework 1",
      "course_name": "Math 101",
      "lesson_name": "Algebra",
      "due_date": "2025-12-31",
      "status": "pending",
      "status_display": "Bekliyor",
      "is_overdue": false,
      "days_remaining": 10,
      "submission_date": null,
      "grade": null,
      "teacher_feedback": null
    },
    {
      "id": 124,
      "title": "Science Project",
      "course_name": "Science 101",
      "due_date": "2025-12-25",
      "status": "graded",
      "submission_date": "2025-12-20",
      "grade": {
        "score": 85,
        "max_score": 100,
        "percentage": 85.0
      },
      "teacher_feedback": "Great work!"
    }
  ]
}
```

**UI Tasarım:**
- 📊 **Summary Cards:** Total, Pending, Graded, Average Score
- 📋 **Filter Chips:** Tümü / Bekleyen / Teslim Edildi / Gecikmiş
- 🔔 **Overdue Badge:** Kırmızı uyarı badge
- 📈 **Score Chart:** Son 10 ödevin puan grafiği
- 🔍 **Detail Modal:** Ödev detayı, öğretmen feedback

### 🚧 TODO - Assignment Detail for Parents

**Endpoint:** `GET /api/parent/assignments/{assignment_id}/`

**Response:**
```json
{
  "id": 123,
  "child": {
    "id": 31,
    "full_name": "deniz avcı"
  },
  "title": "Math Homework 1",
  "description": "Complete exercises 1-10",
  "course_name": "Math 101",
  "teacher_name": "Ahmet Öğretmen",
  "assigned_date": "2025-12-01",
  "due_date": "2025-12-31",
  "status": "graded",
  "submission": {
    "text": "Öğrenci cevabı...",
    "files": [
      "https://.../homework_file1.pdf"
    ],
    "submitted_at": "2025-12-20T15:30:00+03:00",
    "is_late": false
  },
  "grade": {
    "score": 85,
    "max_score": 100,
    "percentage": 85.0,
    "rubric": {
      "content": 40,
      "presentation": 30,
      "creativity": 15
    },
    "teacher_feedback": "Excellent work! Well done.",
    "graded_date": "2025-12-21T10:00:00+03:00"
  }
}
```

---

## 📅 Phase 4: Attendance Tracking (Yoklama Takibi)

### ✅ IMPLEMENTED - Child Rollcalls

**Endpoint:** `GET /api/parent/children/{child_id}/rollcalls/`

**Query Parameters:**
- `start_date`: YYYY-MM-DD
- `end_date`: YYYY-MM-DD
- `lesson_id`: Integer

**Response:**
```json
{
  "child": {
    "id": 31,
    "full_name": "deniz avcı"
  },
  "date_range": {
    "start": "2025-12-01",
    "end": "2025-12-31"
  },
  "statistics": {
    "total_sessions": 50,
    "present": 45,
    "absent": 3,
    "late": 2,
    "attendance_rate": 90.0
  },
  "rollcalls": [
    {
      "id": 456,
      "lesson_subject": "Python Basics",
      "course_name": "Python Programming",
      "date": "2025-12-10T10:00:00+03:00",
      "attendance_status": "present",
      "attendance_display": "Geldi",
      "teacher_comment": "Aktif katılım",
      "has_comment": true
    }
  ]
}
```

**UI Tasarım:**
- 📊 **Attendance Chart:** Pie chart (present, absent, late)
- 📅 **Calendar View:** Aylık takvim (yeşil: geldi, kırmızı: gelmedi, sarı: geç)
- 📋 **List View:** Timeline format, her kayıt detaylı
- 💬 **Teacher Comments:** Öğretmen yorumları vurgulanmış
- 📈 **Trend Line:** Son 6 aylık yoklama trendi

### ✅ IMPLEMENTED - Teacher Comments

**Endpoint:** `GET /api/parent/comments/`

**Query Parameters:**
- `child_id`: Integer (opsiyonel)

**Response:**
```json
{
  "comments": [
    {
      "id": 789,
      "child": {
        "id": 31,
        "full_name": "deniz avcı"
      },
      "lesson_subject": "Python Basics",
      "teacher_name": "Ahmet Öğretmen",
      "comment": "Bugün çok aktifti, harika sorular sordu",
      "date": "2025-12-10T14:30:00+03:00",
      "is_read": false
    }
  ],
  "unread_count": 3
}
```

**UI Tasarım:**
- 🔔 **Badge:** Unread count
- 💬 **Comment Card:** Avatar, öğretmen, çocuk, yorum, tarih
- ✅ **Mark as Read:** Swipe action
- 🔍 **Filter:** Çocuğa göre filtrele

---

## 💰 Phase 5: Payments (Ödemeler)

### ✅ IMPLEMENTED - Payment History

**Endpoint:** `GET /api/parent/payments/`

**Query Parameters:**
- `start_date`: YYYY-MM-DD
- `end_date`: YYYY-MM-DD
- `child_id`: Integer

**Response:**
```json
{
  "total_paid": 15000.00,
  "payments": [
    {
      "id": 456,
      "child": {
        "id": 31,
        "full_name": "deniz avcı"
      },
      "amount": 5000.00,
      "payment_type": "course_fee",
      "payment_type_display": "Kurs Ücreti",
      "description": "Python Programming - Ara Dönem",
      "date": "2025-12-01T10:00:00+03:00",
      "receipt_number": "ODM-2025-123"
    }
  ]
}
```

**UI Tasarım:**
- 💵 **Total Banner:** Toplam ödenen miktar (büyük font)
- 📊 **Monthly Chart:** Son 12 aylık ödeme grafiği
- 📄 **Payment List:** Tarih, tutar, açıklama, fiş no
- 🔍 **Filter:** Tarih aralığı, çocuk, ödeme tipi
- 📥 **Download Receipt:** PDF indirme butonu

### 🚧 TODO - Payment Detail

**Endpoint:** `GET /api/parent/payments/{payment_id}/`

**Response:**
```json
{
  "id": 456,
  "child": {
    "id": 31,
    "full_name": "deniz avcı"
  },
  "amount": 5000.00,
  "payment_type": "course_fee",
  "payment_method": "credit_card",
  "description": "Python Programming - Ara Dönem",
  "date": "2025-12-01T10:00:00+03:00",
  "receipt_number": "ODM-2025-123",
  "receipt_url": "https://.../receipts/ODM-2025-123.pdf",
  "notes": "Online ödeme ile alındı"
}
```

### 🚧 TODO - Create Payment Request

**Endpoint:** `POST /api/parent/payment-requests/`

**Request:**
```json
{
  "child_id": 31,
  "amount": 5000.00,
  "payment_type": "course_fee",
  "description": "Robotik kursu kayıt ücreti",
  "preferred_date": "2025-12-25"
}
```

**Response:**
```json
{
  "request_id": 789,
  "status": "pending",
  "message": "Ödeme talebiniz alındı. Yönetici onayı bekleniyor.",
  "admin_contact": "info@teknolikya.com.tr"
}
```

---

## 🚀 Phase 6: Projects (Çocuk Projeleri)

### 🚧 TODO - Child Projects

**Endpoint:** `GET /api/parent/children/{child_id}/projects/`

**Response:**
```json
{
  "child": {
    "id": 31,
    "full_name": "deniz avcı"
  },
  "projects": [
    {
      "id": 45,
      "title": "İlk Robotum",
      "slug": "ilk-robotum-2025-12",
      "category": "robotics",
      "difficulty_level": "medium",
      "status": "published",
      "cover_image": "https://.../projects/robot.jpg",
      "view_count": 120,
      "like_count": 15,
      "awards": [
        {
          "name": "İlk Proje",
          "icon": "🎯"
        }
      ],
      "created_date": "2025-12-01"
    }
  ]
}
```

**UI Tasarım:**
- 🃏 **Project Card:** Cover image, title, category badge, stats (views, likes)
- 🏆 **Awards Badge:** Kazanılan rozetler
- 👁️ **View Detail:** Projenin tam detayını göster
- 👍 **Like Button:** Veli projeyi beğenebilir
- 📤 **Share:** WhatsApp/Instagram share

---

## 💬 Phase 7: Messaging (Mesajlaşma)

### 🚧 TODO - Inbox

**Endpoint:** `GET /api/parent/messages/`

**Query Parameters:**
- `type`: `inbox|sent`
- `is_read`: `true|false`

**Response:**
```json
{
  "unread_count": 5,
  "messages": [
    {
      "id": 123,
      "from_user": {
        "id": 12,
        "full_name": "Ahmet Öğretmen",
        "role": "teacher"
      },
      "to_user": {
        "id": 7,
        "full_name": "Azize Avcı",
        "role": "parent"
      },
      "related_child": {
        "id": 31,
        "full_name": "deniz avcı"
      },
      "subject": "Deniz'in dersleri hakkında",
      "text": "Merhabalar, Deniz son derslerde çok başarılı...",
      "is_read": false,
      "created_date": "2025-12-10T15:30:00+03:00",
      "parent_message_id": null
    }
  ]
}
```

**Backend:**
```python
# user/api_views.py
class ParentMessagesAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        parent = get_object_or_404(Parents, user=request.user)
        message_type = request.query_params.get('type', 'inbox')
        
        if message_type == 'inbox':
            messages = Message.objects.filter(
                to_user=request.user,
                company_id=parent.company_id
            )
        else:
            messages = Message.objects.filter(
                from_user=request.user,
                company_id=parent.company_id
            )
        
        return Response({
            'unread_count': messages.filter(is_read=False).count(),
            'messages': MessageSerializer(messages, many=True).data,
        })
```

### 🚧 TODO - Send Message

**Endpoint:** `POST /api/parent/messages/`

**Request:**
```json
{
  "to_user_id": 12,
  "related_child_id": 31,
  "subject": "Deniz'in dersleri",
  "text": "Merhaba, Deniz'in son durumu hakkında bilgi alabilir miyim?"
}
```

### 🚧 TODO - Reply to Message

**Endpoint:** `POST /api/parent/messages/{message_id}/reply/`

**Request:**
```json
{
  "text": "Teşekkürler, bilgilendirme için..."
}
```

---

## 🔔 Phase 8: Notifications (Bildirimler)

### 🚧 TODO - Get Notifications

**Endpoint:** `GET /api/parent/notifications/`

**Response:**
```json
{
  "unread_count": 7,
  "notifications": [
    {
      "id": 456,
      "type": "assignment",
      "title": "Yeni Ödev Atandı",
      "message": "deniz avcı'ya Math Homework 1 ödevi atandı",
      "related_child": {
        "id": 31,
        "full_name": "deniz avcı"
      },
      "is_read": false,
      "created_date": "2025-12-10T14:30:00+03:00",
      "action_url": "/children/31/assignments/123"
    },
    {
      "id": 457,
      "type": "comment",
      "title": "Yeni Öğretmen Yorumu",
      "message": "Ahmet Öğretmen yorum yaptı: 'Çok başarılı'",
      "related_child": {
        "id": 31,
        "full_name": "deniz avcı"
      },
      "is_read": false,
      "created_date": "2025-12-10T15:00:00+03:00"
    }
  ]
}
```

**Notification Types:**
- `assignment`: Yeni ödev
- `grade`: Ödev değerlendirildi
- `comment`: Öğretmen yorumu
- `attendance`: Yoklama kaydı
- `payment`: Ödeme bildirimi
- `project`: Çocuğun projesi yayınlandı
- `message`: Yeni mesaj

---

## 👤 Phase 9: Profile & Settings (Profil)

### 🚧 TODO - My Profile

**Endpoint:** `GET /api/parent/profile/`

**Response:**
```json
{
  "id": 7,
  "user": {
    "username": "pazizeavci",
    "email": "azize.avci@hotmail.com",
    "first_name": "Azize",
    "last_name": "Avcı"
  },
  "profile_pic": null,
  "telephone": "5332216477",
  "gender": 1,
  "job": "Öğretmen",
  "children_count": 1,
  "registered_date": "2020-09-01"
}
```

### 🚧 TODO - Update Profile

**Endpoint:** `PATCH /api/parent/profile/`

**Request:**
```json
{
  "telephone": "5321234567",
  "job": "Doktor",
  "email": "newemail@example.com"
}
```

### 🚧 TODO - Change Password

**Endpoint:** `POST /api/parent/change-password/`

**Request:**
```json
{
  "old_password": "1234",
  "new_password": "newpass123"
}
```

---

## 🛠️ Copilot Kullanım Talimatları

### Faz 1: Authentication ve Dashboard
```
@workspace /new Flutter projesi oluştur. NGP Parent Mobile App.

Gereksinimler:
1. JWT authentication (flutter_secure_storage)
2. Login sayfası (Magic Link support hazırlığı)
3. Parent Dashboard (çocuk listesi, stats, yoklamalar, ödemeler)
4. API servis katmanı (http package)
5. State management (Provider/Riverpod)

CRITICAL: JSON field mapping
- Backend: snake_case (full_name, profile_pic_url)
- Flutter: camelCase (fullName, profilePicUrl)
- Use json_serializable with @JsonKey(name: 'full_name')

API Dokümantasyonu: PARENT_API.md

Lütfen:
- Clean Architecture kullan
- Error handling ekle
- Pull-to-refresh ekle
- Empty states ekle (çocuk yoksa)
```

### Faz 2: Children Management
```
@workspace Çocuk yönetim modülünü ekle.

Sayfalar:
1. ChildrenListScreen (tüm çocuklar)
2. ChildDetailScreen (tab bar: overview, assignments, attendance, development)
3. ChildDevelopmentScreen (SWOT, goals, progress)

API Endpoints:
- GET /api/parent/children/
- GET /api/parent/children/{id}/
- GET /api/parent/children/{id}/development/

UI Tasarım:
- Material Design 3
- Çocuk kartları colorful
- Charts için fl_chart package
- Tab navigation
```

### Faz 3-9: Diğer Modüller
Her faz için yukarıdaki format kullanılarak ayrı ayrı geliştirme yapılabilir.

---

## 🧪 Test Kullanıcıları

**Veli 1:**
- Username: `pazizeavci`
- Password: `1234`
- Company ID: 1
- Children: deniz avcı (ID: 31)

**Veli 2 (Çoklu Çocuk Testi):**
- Backend'de oluşturulması gerekiyor
- 2-3 çocuğu olan veli

---

## 📊 API Status Table

| Endpoint | Method | Status | Phase |
|----------|--------|--------|-------|
| /api/token/ | POST | ✅ DONE | 1 |
| /api/parent/dashboard/ | GET | ✅ DONE | 1 |
| /api/parent/children/ | GET | ✅ DONE | 2 |
| /api/parent/children/{id}/ | GET | ✅ DONE | 2 |
| /api/parent/children/{id}/development/ | GET | 🚧 TODO | 2 |
| /api/parent/children/{id}/assignments/ | GET | ✅ DONE | 3 |
| /api/parent/assignments/{id}/ | GET | 🚧 TODO | 3 |
| /api/parent/children/{id}/rollcalls/ | GET | ✅ DONE | 4 |
| /api/parent/comments/ | GET | ✅ DONE | 4 |
| /api/parent/payments/ | GET | ✅ DONE | 5 |
| /api/parent/payments/{id}/ | GET | 🚧 TODO | 5 |
| /api/parent/payment-requests/ | POST | 🚧 TODO | 5 |
| /api/parent/children/{id}/projects/ | GET | 🚧 TODO | 6 |
| /api/parent/messages/ | GET | 🚧 TODO | 7 |
| /api/parent/messages/ | POST | 🚧 TODO | 7 |
| /api/parent/messages/{id}/reply/ | POST | 🚧 TODO | 7 |
| /api/parent/notifications/ | GET | 🚧 TODO | 8 |
| /api/parent/profile/ | GET | 🚧 TODO | 9 |
| /api/parent/profile/ | PATCH | 🚧 TODO | 9 |
| /api/parent/change-password/ | POST | 🚧 TODO | 9 |

---

## 🎯 Backend Development Priority

**Immediate (Sprint 1) - Kritik:**
1. ✅ Dashboard API (DONE - Tested)
2. ✅ Children list/detail (DONE)
3. Child development endpoint (SWOT + Goals)
4. Assignment detail for parents
5. Payment detail endpoint

**Short Term (Sprint 2):**
6. Messaging system (inbox, send, reply)
7. Notifications API
8. Profile GET/PATCH
9. Password change

**Medium Term (Sprint 3):**
10. Child projects list
11. Payment request creation
12. Advanced filtering (all endpoints)

---

## 🔒 Security & Privacy

**KVKK Uyumlu:**
- Veli sadece kendi çocuklarının verilerini görebilir
- Session-based filtering: `company_id` kontrolü
- Parent-child relation validation: `Students.objects.filter(parents=parent)`

**Permissions:**
- JWT required: `permissions.IsAuthenticated`
- Parent validation: `get_object_or_404(Parents, user=request.user)`
- Child ownership: `child.parents.filter(id=parent.id).exists()`

**Data Privacy:**
- Öğrenci TC kimlik no gösterilmez
- Diğer velilerin bilgileri gizli
- Öğretmen iletişim bilgileri sınırlı

---

## 📱 Mobile App Features

### Must Have (MVP):
- ✅ Login & Token management
- ✅ Dashboard (children, stats, activity)
- ✅ Child detail (assignments, attendance)
- ✅ Payment history
- ✅ Push notifications

### Nice to Have:
- 🚧 Messaging system
- 🚧 Child development tracking
- 🚧 Project gallery
- 🚧 Calendar view (attendance)
- 🚧 Dark mode

### Future:
- Magic Link authentication (passwordless)
- WhatsApp integration
- Offline mode
- Multi-language support

---

## 🐛 Known Issues & Fixes

### Issue 1: Empty Children List (SOLVED ✅)
**Problem:** Mobil tarafta children array boş geliyordu  
**Root Cause:** JSON field name mismatch (snake_case vs camelCase)  
**Solution:**
```dart
// ❌ Wrong
class Student {
  final String fullName;
  Student.fromJson(Map<String, dynamic> json) : fullName = json['fullName'];
}

// ✅ Correct
class Student {
  final String fullName;
  Student.fromJson(Map<String, dynamic> json) : fullName = json['full_name'];
}

// ✅ Better (json_serializable)
@JsonSerializable()
class Student {
  @JsonKey(name: 'full_name')
  final String fullName;
}
```

---

## 📝 Notes

- Tüm tarihler ISO 8601 format (timezone: Europe/Istanbul +03:00)
- Tüm image URL'ler absolute path
- Multi-tenant: Her request'te `company_id` kontrol edilir
- COPPA compliant: 13 yaş altı çocuklar için veli onayı var
- Gender codes: 0=Male, 1=Female, 2=Other

---

**Last Updated:** 2025-12-12  
**Version:** 1.0.0  
**Backend:** Django 3.2.10 + DRF 3.13.1  
**Tested:** pazizeavci user - Dashboard API working ✅
