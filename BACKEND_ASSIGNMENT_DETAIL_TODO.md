# 🎯 Backend TODO: Student Assignment Detail Endpoint

## 📋 Gereksinim Özeti

Mobile app'te öğrencilerin ödev detayını görüntüleyebilmeleri için backend endpoint'i gerekiyor. Şu anda endpoint 404 dönüyor.

---

## 🔧 Copilot Prompt (Backend Developer için)

```
@workspace Django DRF ile öğrenci ödev detay endpoint'i oluştur.

ENDPOINT: GET /api/student/assignments/{assignment_id}/

AUTHENTICATION: 
- JWT Bearer Token required
- User type: student
- Permission: Öğrenci sadece kendine atanan ödevleri görebilir

GEREKSINIMLER:

1. View oluştur (education/api_views.py):
   - Class-based view (APIView veya RetrieveAPIView)
   - HomeworkAssignment modelinden assignment_id ile ödev bul
   - Assignment'ın student field'ı request.user'a ait olmalı (ownership check)
   - 404 döndür eğer ödev bulunamazsa veya öğrenciye ait değilse

2. Serializer oluştur:
   - HomeworkAssignmentDetailSerializer
   - Homework (parent) bilgilerini nested olarak serialize et
   - Submission bilgilerini dahil et (varsa)
   - Grade bilgilerini dahil et (varsa)

3. Response formatı (JSON):
{
  "id": 123,
  "title": "Math Homework 1",
  "description": "# Instructions\n\n1. Read chapter 3\n2. Complete exercises 1-10",
  "homework": {
    "id": 45,
    "homework_type": "assignment",
    "homework_type_display": "Ödev",
    "difficulty": "medium",
    "difficulty_display": "Orta",
    "allow_late_submission": true,
    "allow_resubmission": false,
    "attachment_url": "http://127.0.0.1:8000/media/homework/math_hw1.pdf"
  },
  "course_name": "Math 101",
  "lesson_name": "Algebra Basics",
  "assigned_date": "2025-12-01T10:00:00+03:00",
  "due_date": "2025-12-31T23:59:59+03:00",
  "status": "pending",
  "status_display": "Bekliyor",
  "is_overdue": false,
  "days_remaining": 19,
  "submission": {
    "id": 789,
    "text": "Bu ödevde şunları öğrendim...",
    "file1_url": "http://127.0.0.1:8000/media/submissions/file1.pdf",
    "file2_url": null,
    "file3_url": null,
    "submitted_at": "2025-12-20T15:30:00+03:00",
    "is_late": false,
    "version": 1
  },
  "grade": {
    "id": 456,
    "score": 85,
    "max_score": 100,
    "percentage": 85.0,
    "teacher_feedback": "Excellent work! Well done.",
    "graded_date": "2025-12-21T10:00:00+03:00"
  },
  "teacher_notes": "Focus on understanding concepts"
}

4. Field açıklamaları:
   - description: Markdown formatında (# başlıklar, liste, vb)
   - homework.attachment_url: Ödevin ek dosyası (PDF, Word, vb) - opsiyonel
   - submission: Null olabilir (henüz teslim edilmemişse)
   - grade: Null olabilir (henüz değerlendirilmemişse)
   - status: "pending", "submitted", "graded", "late", "missing"
   - is_overdue: Boolean - due_date geçti mi?
   - days_remaining: Integer - bugünden due_date'e kaç gün kaldı (negatif olabilir)

5. URL routing (education/urls.py):
   path('student/assignments/<int:assignment_id>/', StudentAssignmentDetailAPIView.as_view())

6. Permission kontrolü:
   - request.user bir Students instance olmalı
   - HomeworkAssignment.student == request.user.students profili
   - Company ID kontrolü: assignment.homework.company_id == request.user.students.company_id

7. Test için örnek request:
   curl -H "Authorization: Bearer <token>" \
        http://127.0.0.1:8000/api/student/assignments/123/

ÖNEMLI NOTLAR:
- Tüm tarihler timezone-aware olmalı (Europe/Istanbul +03:00)
- attachment_url ve file URL'leri absolute path olmalı
- Markdown description'da special karakterler escape edilmemeli (raw string)
- Missing submission veya grade için null döndür, boş object değil
- is_overdue ve days_remaining hesaplamaları serializer'da yapılmalı (property/method)

MOBİL TEST:
- User: elaavci / Aa12345
- Test assignment ID'leri: 169, 3 (şu anda 404 dönüyor)
- Mobil app bu endpoint'i assignment card'a tıklayınca çağırıyor

BACKEND MODEL REF:
- HomeworkAssignment model (education/models.py)
- Homework model (parent model)
- Students model (user/models.py)
- Submission model (varsa homework_submissions tablosu)
```

---

## 🔍 Mobil Tarafta Kullanım

**API Service (lib/services/api_service.dart):**
```dart
Future<Map<String, dynamic>> fetchAssignmentDetail(int assignmentId) async {
  try {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/student/assignments/$assignmentId/');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Assignment not found');
    } else {
      throw Exception('Failed to load assignment detail');
    }
  } catch (e) {
    throw Exception('Error fetching assignment detail: ${e.toString()}');
  }
}
```

**Screen (lib/screens/assignment_detail_screen.dart):**
- Markdown rendering için `flutter_markdown` package kullanıyor
- File download için `url_launcher` package kullanıyor
- Status chips, metadata display
- Teacher notes, submission info, grade display

---

## 🧪 Test Senaryoları

**Test 1: Başarılı response**
- User: elaavci (student)
- Assignment ID: 169
- Expected: 200 OK + full JSON

**Test 2: 404 - Assignment bulunamadı**
- Assignment ID: 99999
- Expected: 404 Not Found

**Test 3: 403 - Başka öğrencinin ödevi**
- User: elaavci
- Assignment ID: Başka öğrenciye ait
- Expected: 404 (güvenlik için 403 yerine)

**Test 4: Null submission ve grade**
- Henüz teslim edilmemiş ödev
- Expected: submission: null, grade: null

**Test 5: Overdue assignment**
- due_date < bugün
- Expected: is_overdue: true, days_remaining: -X

**Test 6: Markdown description rendering**
- Description with # headers, lists, bold text
- Mobile app markdown parser test

---

## 📊 Veritabanı İlişkileri

```
HomeworkAssignment
├── homework (ForeignKey → Homework)
│   ├── homework_type
│   ├── difficulty
│   ├── attachment (FileField)
│   └── company (ForeignKey → Company)
├── student (ForeignKey → Students)
├── lesson (ForeignKey → Lesson)
│   └── course (ForeignKey → Course)
├── title (CharField)
├── description (TextField)
├── due_date (DateTimeField)
└── assigned_date (DateTimeField)

HomeworkSubmission (opsiyonel)
├── assignment (ForeignKey → HomeworkAssignment)
├── text (TextField)
├── file1, file2, file3 (FileField)
├── submitted_at (DateTimeField)
└── version (IntegerField)

HomeworkGrade (opsiyonel)
├── assignment (ForeignKey → HomeworkAssignment)
├── score (IntegerField)
├── max_score (IntegerField)
├── feedback (TextField)
└── graded_date (DateTimeField)
```

---

## ✅ Implementasyon Checklist

Backend developer için adımlar:

- [ ] `education/serializers.py` - HomeworkDetailSerializer oluştur
- [ ] `education/serializers.py` - HomeworkAssignmentDetailSerializer oluştur
- [ ] `education/api_views.py` - StudentAssignmentDetailAPIView oluştur
- [ ] Permission kontrolü: student ownership check
- [ ] is_overdue ve days_remaining hesaplama methodları
- [ ] URL routing ekle
- [ ] Test with Postman/curl
- [ ] Migration gerekli mi kontrol et
- [ ] CORS ayarları (mobil için 127.0.0.1)
- [ ] Mobil test: elaavci user ile assignment 169 çağır

---

## 🚀 Deployment Notları

- Base URL mobilde: `http://127.0.0.1:8000/api`
- Production'da: `https://ngp.teknolikya.com.tr/api`
- Media files serve edilmeli (MEDIA_URL, MEDIA_ROOT)
- Timezone: Europe/Istanbul (+03:00)

---

**Öncelik:** 🔴 HIGH (Mobil Sprint 1 bitti, bu endpoint olmadan ödev detayları görüntülenemiyor)

**Beklenen Süre:** 2-3 saat (serializer + view + test)

**Mobil Status:** ✅ READY (endpoint hazır olunca direkt çalışacak)
