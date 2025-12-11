# NGP Öğretmen Mobile API Documentation

## Genel Bakış

Bu doküman NGP (Next Generation Person) Öğretmen Mobile Uygulaması için REST API endpoint'lerini açıklar. Tüm endpoint'ler JWT authentication gerektirir.

**Base URL:** `https://ngp.teknolikya.com.tr/api/`

**Authentication:** JWT Bearer Token

---

## İçindekiler

1. [Authentication](#authentication)
2. [Öğretmen Dashboard](#öğretmen-dashboard)
3. [Öğrenci Listesi](#öğrenci-listesi)
4. [Öğrenci Detayı](#öğrenci-detayı)
5. [Kurslar](#kurslar)
6. [Yoklama](#yoklama)
7. [Ödevler](#ödevler)
8. [Değerlendirme Bekleyenler](#değerlendirme-bekleyenler)
9. [İstatistikler](#i̇statistikler)
10. [Hata Yönetimi](#hata-yönetimi)

---

## Authentication

### JWT Token Alma

**Endpoint:** `POST /api/token/`

**Açıklama:** Öğretmen girişi yaparak JWT access ve refresh token'ları alın. Yanıtta kullanıcı tipi bilgisi mobil uygulamada yönlendirme için kullanılır.

**Request Body:**
```json
{
  "username": "mehmet_ogretmen",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user_type": "teacher",
  "user": {
    "id": 15,
    "username": "mehmet_ogretmen",
    "email": "mehmet@example.com",
    "first_name": "Mehmet",
    "last_name": "Kaya",
    "full_name": "Mehmet Kaya"
  },
  "profile": {
    "id": 8,
    "profile_pic": "https://ngp.teknolikya.com.tr/media/teachers/mehmet.jpg",
    "gender": 1,
    "sube": "Ankara Şubesi"
  }
}
```

**Kullanım:**
- `access` token'ı tüm API isteklerinde `Authorization` header'ında kullanın
- Header formatı: `Authorization: Bearer <access_token>`
- `user_type` bilgisini mobil uygulamada öğretmen dashboard'a yönlendirme için kullanın
- Access token 1 gün geçerlidir
- Refresh token 7 gün geçerlidir

---

## Öğretmen Dashboard

### Dashboard Özet Bilgileri

**Endpoint:** `GET /api/teacher/dashboard/`

**Açıklama:** Öğretmen için özet dashboard bilgilerini getirir. Öğrenciler, kurslar, ödevler ve yoklama istatistikleri dahil.

**Authentication:** Required (JWT Bearer Token - teacher)

**Response (200 OK):**
```json
{
  "teacher": {
    "id": 8,
    "full_name": "Mehmet Kaya",
    "username": "mehmet_ogretmen",
    "email": "mehmet@example.com",
    "profile_pic_url": "https://ngp.teknolikya.com.tr/media/teachers/mehmet.jpg",
    "sube": "Ankara Şubesi"
  },
  "statistics": {
    "total_students": 45,
    "total_courses": 6,
    "total_homeworks": 24,
    "pending_grading": 12,
    "today_rollcalls": 8
  },
  "recent_sessions": [
    {
      "id": 789,
      "student_name": "Ali Demir",
      "lesson_subject": "Python Programlama - Ders 5",
      "session_date": "2025-12-10",
      "date": "2025-12-10",
      "rollcall": true,
      "rollcall_display": "Geldi",
      "desc_to_student": "Derste çok aktif, kod yazma becerileri gelişiyor",
      "has_comment": true
    }
  ],
  "pending_homeworks": 12,
  "today_sessions": 3
}
```

**İstatistik Açıklamaları:**
- `total_students`: Sistemdeki toplam öğrenci sayısı
- `total_courses`: Toplam kurs sayısı
- `total_homeworks`: Öğretmenin oluşturduğu toplam ödev sayısı
- `pending_grading`: Değerlendirme bekleyen ödev sayısı
- `today_rollcalls`: Bugün yapılan yoklama sayısı
- `recent_sessions`: Son 10 yoklama kaydı
- `today_sessions`: Bugün için planlanan oturum sayısı

---

## Öğrenci Listesi

### Tüm Öğrencileri Listele

**Endpoint:** `GET /api/teacher/students/`

**Açıklama:** Öğretmenin erişebileceği tüm öğrencileri listeler.

**Authentication:** Required (JWT Bearer Token - teacher)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `search` | string | Öğrenci adı/soyadı/username ile arama |
| `course_id` | integer | Belirli bir kursa kayıtlı öğrencileri filtrele |

**Örnek İstek:**
```
GET /api/teacher/students/?search=ali&course_id=5
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "count": 45,
  "students": [
    {
      "id": 34,
      "full_name": "Ali Demir",
      "username": "ali123",
      "profile_pic_url": "https://ngp.teknolikya.com.tr/media/students/ali.jpg",
      "gender": 1,
      "school": "Ankara İlkokulu",
      "birthday": "2010-05-15",
      "age": 15,
      "total_sessions": 48,
      "attendance_rate": 93.8,
      "pending_assignments": 3
    },
    {
      "id": 35,
      "full_name": "Ayşe Yılmaz",
      "username": "ayse456",
      "profile_pic_url": null,
      "gender": 0,
      "school": "İstanbul Ortaokulu",
      "birthday": "2012-08-20",
      "age": 13,
      "total_sessions": 42,
      "attendance_rate": 97.6,
      "pending_assignments": 1
    }
  ]
}
```

**Açıklamalar:**
- `total_sessions`: Öğrencinin katıldığı toplam ders oturumu
- `attendance_rate`: Devamsızlık oranı (%)
- `pending_assignments`: Bekleyen ödev sayısı

---

## Öğrenci Detayı

### Öğrenci Detaylı Bilgileri

**Endpoint:** `GET /api/teacher/students/<student_id>/`

**Açıklama:** Belirli bir öğrencinin detaylı bilgilerini, istatistiklerini ve kurslarını getirir.

**Authentication:** Required (JWT Bearer Token - teacher)

**Path Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `student_id` | integer | Öğrenci ID |

**Örnek İstek:**
```
GET /api/teacher/students/34/
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "id": 34,
  "full_name": "Ali Demir",
  "username": "ali123",
  "email": "ali@example.com",
  "profile_pic_url": "https://ngp.teknolikya.com.tr/media/students/ali.jpg",
  "gender": 1,
  "school": "Ankara İlkokulu",
  "birthday": "2010-05-15",
  "stats": {
    "total_rollcalls": 48,
    "present_rollcalls": 45,
    "attendance_rate": 93.8,
    "total_assignments": 20,
    "completed_assignments": 17,
    "pending_assignments": 3,
    "average_grade": 87.5
  },
  "courses": [
    {
      "id": 5,
      "title": "Python Programlama",
      "start_date": "2025-09-01"
    },
    {
      "id": 8,
      "title": "Robotik",
      "start_date": "2025-10-01"
    }
  ]
}
```

**İstatistik Açıklamaları:**
- `total_rollcalls`: Toplam yoklama kaydı
- `present_rollcalls`: Geldiği ders sayısı
- `attendance_rate`: Devamsızlık oranı (%)
- `total_assignments`: Toplam ödev sayısı
- `completed_assignments`: Tamamlanan ödev sayısı
- `pending_assignments`: Bekleyen ödev sayısı
- `average_grade`: Ortalama not

---

## Kurslar

### Kurs Listesi

**Endpoint:** `GET /api/teacher/courses/`

**Açıklama:** Sistemdeki tüm kursları listeler.

**Authentication:** Required (JWT Bearer Token - teacher)

**Response (200 OK):**
```json
{
  "count": 6,
  "courses": [
    {
      "id": 5,
      "title": "Python Programlama",
      "shortNot": "Temel Python eğitimi",
      "description": "Python ile programlamaya giriş...",
      "img": "https://ngp.teknolikya.com.tr/media/courses/python.jpg",
      "lesson_count": 20,
      "student_count": 15,
      "session_count": 60
    },
    {
      "id": 8,
      "title": "Robotik",
      "shortNot": "Robot tasarım ve programlama",
      "description": "Robotik sistemler ve sensörler...",
      "img": "https://ngp.teknolikya.com.tr/media/courses/robotics.jpg",
      "lesson_count": 15,
      "student_count": 12,
      "session_count": 45
    }
  ]
}
```

**Açıklamalar:**
- `lesson_count`: Kurs içindeki ders sayısı
- `student_count`: Kursa kayıtlı öğrenci sayısı
- `session_count`: Toplam oturum sayısı

---

## Yoklama

### Yoklama Kayıtları

**Endpoint:** `GET /api/teacher/rollcall/`

**Açıklama:** Yoklama kayıtlarını listeler.

**Authentication:** Required (JWT Bearer Token - teacher)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `date` | string | Tarihe göre filtrele (YYYY-MM-DD formatında) |
| `student_id` | integer | Öğrenciye göre filtrele |
| `limit` | integer | Sonuç limiti (varsayılan: 50) |

**Örnek İstek:**
```
GET /api/teacher/rollcall/?date=2025-12-10&limit=20
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "count": 20,
  "rollcalls": [
    {
      "id": 789,
      "student_name": "Ali Demir",
      "lesson_subject": "Python Programlama - Ders 5",
      "session_date": "2025-12-10",
      "date": "2025-12-10",
      "rollcall": true,
      "rollcall_display": "Geldi",
      "desc_to_student": "Derste çok aktif, kod yazma becerileri gelişiyor",
      "has_comment": true
    },
    {
      "id": 788,
      "student_name": "Ayşe Yılmaz",
      "lesson_subject": "Robotik - Ders 3",
      "session_date": "2025-12-10",
      "date": "2025-12-10",
      "rollcall": false,
      "rollcall_display": "Gelmedi",
      "desc_to_student": null,
      "has_comment": false
    }
  ]
}
```

**Açıklamalar:**
- `rollcall`: true = Geldi, false = Gelmedi
- `desc_to_student`: Öğretmenin öğrenciye özel notu
- `has_comment`: Yorum var mı?

---

## Ödevler

### Öğretmenin Oluşturduğu Ödevler

**Endpoint:** `GET /api/teacher/homeworks/`

**Açıklama:** Öğretmenin oluşturduğu tüm ödevleri listeler.

**Authentication:** Required (JWT Bearer Token - teacher)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `course_id` | integer | Kursa göre filtrele |

**Örnek İstek:**
```
GET /api/teacher/homeworks/?course_id=5
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "count": 24,
  "homeworks": [
    {
      "id": 101,
      "title": "Python Temelleri - Alıştırmalar",
      "description": "1-10 arası alıştırmaları tamamlayın",
      "homework_type": "assignment",
      "homework_type_display": "Assignment",
      "difficulty": "medium",
      "difficulty_display": "Medium",
      "due_date": "2025-12-31",
      "course_name": "Python Programlama",
      "lesson_name": "Ders 5: Döngüler",
      "created_date": "2025-12-01T10:00:00Z",
      "total_assignments": 15,
      "submitted_count": 12,
      "graded_count": 10,
      "pending_count": 3
    },
    {
      "id": 102,
      "title": "Robotik Proje",
      "description": "Engelden kaçan robot tasarla",
      "homework_type": "project",
      "homework_type_display": "Project",
      "difficulty": "hard",
      "difficulty_display": "Hard",
      "due_date": "2025-12-25",
      "course_name": "Robotik",
      "lesson_name": "Ders 8: Sensörler",
      "created_date": "2025-11-15T10:00:00Z",
      "total_assignments": 12,
      "submitted_count": 11,
      "graded_count": 8,
      "pending_count": 1
    }
  ]
}
```

**Ödev İstatistikleri:**
- `total_assignments`: Toplam atama sayısı (öğrenci sayısı)
- `submitted_count`: Teslim edilen ödev sayısı
- `graded_count`: Değerlendirilen ödev sayısı
- `pending_count`: Bekleyen ödev sayısı

---

## Değerlendirme Bekleyenler

### Değerlendirme Bekleyen Ödev Teslimler

**Endpoint:** `GET /api/teacher/submissions/pending/`

**Açıklama:** Öğretmenin değerlendirmesi gereken ödev teslimlerini listeler.

**Authentication:** Required (JWT Bearer Token - teacher)

**Response (200 OK):**
```json
{
  "count": 12,
  "submissions": [
    {
      "id": 456,
      "student_name": "Ali Demir",
      "homework_title": "Python Temelleri - Alıştırmalar",
      "due_date": "2025-12-31",
      "submitted_date": "2025-12-15T14:30:00Z",
      "is_late": false,
      "submission_text": "Tüm alıştırmaları tamamladım. Kod dosyaları ektedir.",
      "file1": "https://ngp.teknolikya.com.tr/media/submissions/ali_homework1.py",
      "file2": null,
      "file3": null,
      "has_grade": false,
      "grade_info": null
    },
    {
      "id": 457,
      "student_name": "Ayşe Yılmaz",
      "homework_title": "Robotik Proje",
      "due_date": "2025-12-25",
      "submitted_date": "2025-12-26T10:00:00Z",
      "is_late": true,
      "submission_text": "Proje tamamlandı. Video ve kod dosyaları ektedir.",
      "file1": "https://ngp.teknolikya.com.tr/media/submissions/ayse_project.mp4",
      "file2": "https://ngp.teknolikya.com.tr/media/submissions/ayse_project.ino",
      "file3": null,
      "has_grade": false,
      "grade_info": null
    }
  ]
}
```

**Açıklamalar:**
- `is_late`: Geç teslim mi?
- `has_grade`: Değerlendirme yapılmış mı?
- `grade_info`: Değerlendirme yapılmışsa detayları (null ise henüz yapılmamış)

---

## İstatistikler

### Öğretmen Detaylı İstatistikler

**Endpoint:** `GET /api/teacher/statistics/`

**Açıklama:** Öğretmen için detaylı istatistikler ve analitics.

**Authentication:** Required (JWT Bearer Token - teacher)

**Response (200 OK):**
```json
{
  "general": {
    "total_students": 45,
    "total_courses": 6,
    "total_lessons": 80,
    "total_sessions": 240,
    "total_rollcalls": 180,
    "attendance_rate": 91.7
  },
  "homework": {
    "total_homeworks": 24,
    "total_assignments": 360,
    "submitted_assignments": 324,
    "graded_assignments": 280,
    "submission_rate": 90.0
  },
  "recent_activity": {
    "last_7_days_rollcalls": 56,
    "last_7_days_submissions": 28
  }
}
```

**İstatistik Grupları:**

**General (Genel):**
- `total_students`: Toplam öğrenci sayısı
- `total_courses`: Toplam kurs sayısı
- `total_lessons`: Toplam ders sayısı
- `total_sessions`: Toplam oturum sayısı
- `total_rollcalls`: Toplam yoklama kaydı
- `attendance_rate`: Genel devamsızlık oranı (%)

**Homework (Ödevler):**
- `total_homeworks`: Oluşturulan ödev sayısı
- `total_assignments`: Toplam ödev ataması sayısı
- `submitted_assignments`: Teslim edilen ödev sayısı
- `graded_assignments`: Değerlendirilen ödev sayısı
- `submission_rate`: Teslim etme oranı (%)

**Recent Activity (Son Aktivite):**
- `last_7_days_rollcalls`: Son 7 günde yapılan yoklama
- `last_7_days_submissions`: Son 7 günde teslim edilen ödev

---

## Hata Yönetimi

### HTTP Status Kodları

| Kod | Anlamı |
|-----|--------|
| 200 | OK - İstek başarılı |
| 201 | Created - Kaynak başarıyla oluşturuldu |
| 400 | Bad Request - Geçersiz istek |
| 401 | Unauthorized - Authentication gerekli veya token geçersiz |
| 403 | Forbidden - Yetkisiz erişim |
| 404 | Not Found - Kaynak bulunamadı |
| 500 | Internal Server Error - Sunucu hatası |

### Hata Response Formatı

```json
{
  "error": "Hata açıklaması",
  "detail": "Ek hata detayı (opsiyonel)",
  "code": "hata_kodu (opsiyonel)"
}
```

### Yaygın Hatalar

**Authentication Gerekli:**
```json
{
  "detail": "Authentication credentials were not provided."
}
```

**Öğretmen Profili Bulunamadı:**
```json
{
  "error": "Teacher profile not found for this user."
}
```

**Öğrenci Bulunamadı:**
```json
{
  "detail": "Not found."
}
```

---

## Entegrasyon Notları

### Flutter Örnek (Öğretmen Dashboard)

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> getTeacherDashboard() async {
  final accessToken = await storage.read(key: 'access_token');
  
  final response = await http.get(
    Uri.parse('https://ngp.teknolikya.com.tr/api/teacher/dashboard/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else if (response.statusCode == 401) {
    // Token süresi dolmuş, yenile
    await refreshAccessToken();
    return getTeacherDashboard(); // Tekrar dene
  } else {
    throw Exception('Dashboard yüklenemedi');
  }
}
```

### Flutter Örnek (Öğrenci Listesi)

```dart
Future<List<dynamic>> getTeacherStudents({String? search, int? courseId}) async {
  final accessToken = await storage.read(key: 'access_token');
  
  String url = 'https://ngp.teknolikya.com.tr/api/teacher/students/';
  List<String> queryParams = [];
  
  if (search != null && search.isNotEmpty) {
    queryParams.add('search=$search');
  }
  if (courseId != null) {
    queryParams.add('course_id=$courseId');
  }
  
  if (queryParams.isNotEmpty) {
    url += '?${queryParams.join('&')}';
  }
  
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['students'];
  } else {
    throw Exception('Öğrenci listesi yüklenemedi');
  }
}
```

### Flutter Örnek (Değerlendirme Bekleyen Ödevler)

```dart
Future<List<dynamic>> getPendingSubmissions() async {
  final accessToken = await storage.read(key: 'access_token');
  
  final response = await http.get(
    Uri.parse('https://ngp.teknolikya.com.tr/api/teacher/submissions/pending/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['submissions'];
  } else {
    throw Exception('Ödevler yüklenemedi');
  }
}
```

---

## API Endpoint Özeti

| Endpoint | Method | Açıklama |
|----------|--------|----------|
| `/api/token/` | POST | JWT token al (login) |
| `/api/teacher/dashboard/` | GET | Dashboard özeti |
| `/api/teacher/students/` | GET | Öğrenci listesi |
| `/api/teacher/students/<id>/` | GET | Öğrenci detayı |
| `/api/teacher/courses/` | GET | Kurs listesi |
| `/api/teacher/rollcall/` | GET | Yoklama kayıtları |
| `/api/teacher/homeworks/` | GET | Ödev listesi |
| `/api/teacher/submissions/pending/` | GET | Değerlendirme bekleyenler |
| `/api/teacher/statistics/` | GET | Detaylı istatistikler |

---

## Destek

API desteği ve sorularınız için:
- **Email:** info@teknolikya.com.tr
- **Dokümantasyon:** Bu dosya
- **Backend:** Django 3.2.10 with Django REST Framework

---

## Değişiklik Geçmişi

### Versiyon 1.0.0 (2025-12-11)
- İlk öğretmen API release
- JWT authentication with user_type
- 8 ana endpoint
- Dashboard, öğrenciler, kurslar, yoklama, ödevler
- Değerlendirme sistemi
- İstatistikler ve analitics
