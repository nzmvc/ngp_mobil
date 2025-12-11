# NGP PDR Uzmanı Mobile API Documentation

## Genel Bakış

Bu doküman NGP (Next Generation Person) PDR (Psikolojik Danışma ve Rehberlik) Uzmanı Mobile Uygulaması için REST API endpoint'lerini açıklar. Tüm endpoint'ler JWT authentication gerektirir.

**Base URL:** `https://ngp.teknolikya.com.tr/api/`

**Authentication:** JWT Bearer Token

---

## İçindekiler

1. [Authentication](#authentication)
2. [PDR Dashboard](#pdr-dashboard)
3. [Öğrenci Listesi](#öğrenci-listesi)
4. [Öğrenci Detayı](#öğrenci-detayı)
5. [Sorular](#sorular)
6. [Cevaplar](#cevaplar)
7. [Duygusal Analizler](#duygusal-analizler)
8. [Mesajlar](#mesajlar)
9. [İstatistikler](#i̇statistikler)
10. [Hata Yönetimi](#hata-yönetimi)

---

## Authentication

### JWT Token Alma

**Endpoint:** `POST /api/token/`

**Açıklama:** PDR Uzmanı girişi yaparak JWT access ve refresh token'ları alın.

**Request Body:**
```json
{
  "username": "pdr_uzman",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user_type": "pdr",
  "user": {
    "id": 12,
    "username": "pdr_uzman",
    "email": "pdr@example.com",
    "first_name": "Zeynep",
    "last_name": "Demir",
    "full_name": "Zeynep Demir"
  },
  "profile": {
    "id": 3,
    "profile_pic": "https://ngp.teknolikya.com.tr/media/pdr_experts/zeynep.jpg",
    "gender": 0,
    "specialization": "Çocuk ve Ergen Psikolojisi"
  }
}
```

**Kullanım:**
- `access` token'ı tüm API isteklerinde `Authorization` header'ında kullanın
- `user_type` bilgisini mobil uygulamada PDR dashboard'a yönlendirme için kullanın
- Access token 1 gün geçerlidir
- Refresh token 7 gün geçerlidir

---

## PDR Dashboard

### Dashboard Özet Bilgileri

**Endpoint:** `GET /api/pdr/dashboard/`

**Açıklama:** PDR Uzmanı için özet dashboard bilgilerini getirir. Öğrenciler, analizler ve mesajlar dahil.

**Authentication:** Required (JWT Bearer Token - pdr)

**Response (200 OK):**
```json
{
  "pdr_expert": {
    "id": 3,
    "full_name": "Zeynep Demir",
    "username": "pdr_uzman",
    "email": "pdr@example.com",
    "profile_pic_url": "https://ngp.teknolikya.com.tr/media/pdr_experts/zeynep.jpg",
    "specialization": "Çocuk ve Ergen Psikolojisi"
  },
  "statistics": {
    "total_students": 120,
    "total_questions": 45,
    "total_answers": 890,
    "total_analyses": 180,
    "high_risk_count": 8,
    "pending_review": 23
  },
  "high_risk_students": [
    {
      "id": 34,
      "full_name": "Ali Yılmaz",
      "username": "ali123",
      "profile_pic_url": "https://ngp.teknolikya.com.tr/media/students/ali.jpg",
      "gender": 1,
      "school": "Ankara İlkokulu",
      "birthday": "2010-05-15",
      "age": 15,
      "total_answers": 45,
      "last_emotion": {
        "emotion": "very_negative",
        "emotion_display": "Çok Olumsuz",
        "week": "2025-12-08"
      },
      "risk_level": "high"
    }
  ],
  "recent_analyses": [
    {
      "id": 234,
      "student_name": "Ali Yılmaz",
      "week": "2025-12-08",
      "week_display": "08 Aralık 2025 haftası",
      "week_number": 49,
      "year": 2025,
      "emotion": "very_negative",
      "emotion_display": "Çok Olumsuz",
      "risk_level": "high",
      "risk_level_display": "Yüksek",
      "ai_comment": "Öğrenci son hafta çok olumsuz duygular yaşıyor...",
      "strengths": "Arkadaşlarıyla iyi ilişkiler",
      "concerns": "Ders başarısında düşüş, motivasyon kaybı",
      "recommendations": "Birebir görüşme önerilir",
      "total_answers": 12,
      "positive_answers": 2,
      "negative_answers": 10,
      "expert_reviewed": false,
      "expert_notes": null,
      "expert_action_taken": null,
      "parent_notified": false
    }
  ],
  "unread_messages": 5
}
```

**İstatistik Açıklamaları:**
- `total_students`: Sistemdeki toplam öğrenci sayısı
- `total_questions`: Aktif PDR sorusu sayısı
- `total_answers`: Toplam cevap sayısı
- `total_analyses`: Yapılan duygusal analiz sayısı
- `high_risk_count`: Yüksek riskli öğrenci sayısı
- `pending_review`: İnceleme bekleyen cevap sayısı

---

## Öğrenci Listesi

### Tüm Öğrencileri Listele

**Endpoint:** `GET /api/pdr/students/`

**Açıklama:** PDR Uzmanının erişebileceği tüm öğrencileri listeler.

**Authentication:** Required (JWT Bearer Token - pdr)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `search` | string | Öğrenci adı/soyadı/username ile arama |
| `risk_level` | string | Risk seviyesine göre filtrele (low/medium/high/critical) |

**Örnek İstek:**
```
GET /api/pdr/students/?risk_level=high
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "count": 8,
  "students": [
    {
      "id": 34,
      "full_name": "Ali Yılmaz",
      "username": "ali123",
      "profile_pic_url": "https://ngp.teknolikya.com.tr/media/students/ali.jpg",
      "gender": 1,
      "school": "Ankara İlkokulu",
      "birthday": "2010-05-15",
      "age": 15,
      "total_answers": 45,
      "last_emotion": {
        "emotion": "very_negative",
        "emotion_display": "Çok Olumsuz",
        "week": "2025-12-08"
      },
      "risk_level": "high"
    }
  ]
}
```

---

## Öğrenci Detayı

### Öğrenci Detaylı Duygusal Analiz

**Endpoint:** `GET /api/pdr/students/<student_id>/`

**Açıklama:** Belirli bir öğrencinin detaylı duygusal analiz bilgilerini getirir.

**Authentication:** Required (JWT Bearer Token - pdr)

**Path Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `student_id` | integer | Öğrenci ID |

**Response (200 OK):**
```json
{
  "student": {
    "id": 34,
    "full_name": "Ali Yılmaz",
    "username": "ali123",
    "profile_pic_url": "https://ngp.teknolikya.com.tr/media/students/ali.jpg",
    "gender": 1,
    "school": "Ankara İlkokulu",
    "birthday": "2010-05-15",
    "age": 15,
    "total_answers": 45,
    "last_emotion": {
      "emotion": "very_negative",
      "emotion_display": "Çok Olumsuz",
      "week": "2025-12-08"
    },
    "risk_level": "high"
  },
  "statistics": {
    "total_answers": 45,
    "analyzed_answers": 42,
    "total_analyses": 8
  },
  "recent_analyses": [
    {
      "id": 234,
      "student_name": "Ali Yılmaz",
      "week": "2025-12-08",
      "week_display": "08 Aralık 2025 haftası",
      "emotion": "very_negative",
      "emotion_display": "Çok Olumsuz",
      "risk_level": "high",
      "ai_comment": "Son hafta öğrenci olumsuz duygular yaşıyor...",
      "strengths": "Arkadaş ilişkileri",
      "concerns": "Ders motivasyonu düşük",
      "recommendations": "Birebir görüşme yapılmalı"
    }
  ],
  "risk_history": [
    {
      "week": "2025-12-08",
      "risk_level": "high",
      "emotion": "very_negative"
    },
    {
      "week": "2025-12-01",
      "risk_level": "medium",
      "emotion": "negative"
    }
  ],
  "recent_answers": [
    {
      "id": 567,
      "student_name": "Ali Yılmaz",
      "question_text": "Bugün kendini nasıl hissediyorsun?",
      "question_category": "😊 Duygusal Durum",
      "answer_text": "Kendimi çok kötü hissediyorum",
      "emoji_answer": "😟",
      "ai_analyzed": true,
      "sentiment": "negative",
      "sentiment_display": "Olumsuz",
      "risk_level": "medium",
      "ai_comment": "Öğrenci olumsuz duygular ifade ediyor",
      "is_reviewed": false,
      "answered_date": "2025-12-10T14:30:00Z"
    }
  ]
}
```

---

## Sorular

### PDR Soru Listesi

**Endpoint:** `GET /api/pdr/questions/`

**Açıklama:** PDR sorularını listeler.

**Authentication:** Required (JWT Bearer Token - pdr)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `age_range` | string | Yaş aralığı (6-9, 10-14, 15-18, all) |
| `category` | string | Kategori (emotional, social, academic, vb.) |
| `is_active` | boolean | Aktif sorular (true/false, varsayılan: true) |

**Response (200 OK):**
```json
{
  "count": 45,
  "questions": [
    {
      "id": 101,
      "text": "Bugün kendini nasıl hissediyorsun?",
      "age_range": "6-9",
      "age_range_display": "6-9 Yaş (İlkokul)",
      "category": "emotional",
      "category_display": "😊 Duygusal Durum",
      "question_type": "emoji",
      "question_type_display": "😊 Emoji Seçimi (6-9 yaş)",
      "options": null,
      "emoji_options": [
        {"emoji": "😊", "label": "Çok mutlu"},
        {"emoji": "🙂", "label": "Mutlu"},
        {"emoji": "😐", "label": "Normal"},
        {"emoji": "😟", "label": "Üzgün"}
      ],
      "order": 1,
      "is_active": true,
      "answers_count": 234
    }
  ]
}
```

---

## Cevaplar

### Öğrenci Cevapları

**Endpoint:** `GET /api/pdr/answers/`

**Açıklama:** Öğrenci cevaplarını listeler.

**Authentication:** Required (JWT Bearer Token - pdr)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `student_id` | integer | Öğrenciye göre filtrele |
| `question_id` | integer | Soruya göre filtrele |
| `risk_level` | string | Risk seviyesi (low/medium/high/critical) |
| `is_reviewed` | boolean | İncelenmiş/İncelenmemiş |

**Response (200 OK):**
```json
{
  "count": 890,
  "answers": [
    {
      "id": 567,
      "student_name": "Ali Yılmaz",
      "question_text": "Bugün kendini nasıl hissediyorsun?",
      "question_category": "😊 Duygusal Durum",
      "answer_text": "Kendimi çok kötü hissediyorum",
      "emoji_answer": "😟",
      "scale_answer": null,
      "ai_analyzed": true,
      "sentiment": "negative",
      "sentiment_display": "Olumsuz",
      "risk_level": "medium",
      "risk_level_display": "Orta",
      "ai_comment": "Öğrenci olumsuz duygular ifade ediyor. Dikkat gerektirir.",
      "is_reviewed": false,
      "reviewed_by": null,
      "expert_notes": null,
      "answered_date": "2025-12-10T14:30:00Z"
    }
  ]
}
```

---

## Duygusal Analizler

### Haftalık Duygusal Analizler

**Endpoint:** `GET /api/pdr/analyses/`

**Açıklama:** Haftalık duygusal analizleri listeler.

**Authentication:** Required (JWT Bearer Token - pdr)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `student_id` | integer | Öğrenciye göre filtrele |
| `risk_level` | string | Risk seviyesine göre filtrele |
| `year` | integer | Yıla göre filtrele |
| `week_number` | integer | Hafta numarasına göre filtrele |

**Response (200 OK):**
```json
{
  "count": 180,
  "analyses": [
    {
      "id": 234,
      "student_name": "Ali Yılmaz",
      "week": "2025-12-08",
      "week_display": "08 Aralık 2025 haftası",
      "week_number": 49,
      "year": 2025,
      "emotion": "very_negative",
      "emotion_display": "Çok Olumsuz",
      "risk_level": "high",
      "risk_level_display": "Yüksek",
      "ai_comment": "Öğrenci son hafta çok olumsuz duygular yaşıyor. Derslerde motivasyon kaybı gözlemleniyor.",
      "strengths": "Arkadaşlarıyla iyi ilişkiler kuruyor, sosyal aktivitelerde aktif",
      "concerns": "Ders başarısında düşüş, ev ödevlerini yapmıyor, yorgun görünüyor",
      "recommendations": "Birebir görüşme yapılmalı. Aile ile iletişime geçilmeli. Akademik destek verilmeli.",
      "total_answers": 12,
      "positive_answers": 2,
      "negative_answers": 10,
      "expert_reviewed": false,
      "expert_notes": null,
      "expert_action_taken": null,
      "parent_notified": false
    }
  ]
}
```

**Duygu Seviyeleri:**
- `very_positive`: Çok Olumlu
- `positive`: Olumlu
- `neutral`: Nötr
- `negative`: Olumsuz
- `very_negative`: Çok Olumsuz

**Risk Seviyeleri:**
- `low`: Düşük
- `medium`: Orta
- `high`: Yüksek
- `critical`: Kritik

---

## Mesajlar

### Mesaj Listesi

**Endpoint:** `GET /api/pdr/messages/`

**Açıklama:** Gelen ve giden mesajları listeler.

**Authentication:** Required (JWT Bearer Token - pdr)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `type` | string | Mesaj tipi (inbox/sent, varsayılan: inbox) |
| `is_read` | boolean | Okunmuş/Okunmamış (sadece inbox için) |

**Response (200 OK):**
```json
{
  "count": 15,
  "messages": [
    {
      "id": 789,
      "from_user_name": "Ayşe Veli",
      "to_user_name": "Zeynep Demir",
      "related_student_name": "Ali Yılmaz",
      "subject": "Çocuğumun durumu hakkında",
      "text": "Merhaba, Ali'nin son günlerde çok üzgün olduğunu fark ettim...",
      "is_read": false,
      "read_date": null,
      "sent_date": "2025-12-10T15:00:00Z"
    }
  ]
}
```

---

## İstatistikler

### PDR Detaylı İstatistikler

**Endpoint:** `GET /api/pdr/statistics/`

**Açıklama:** PDR Uzmanı için detaylı istatistikler ve dağılımlar.

**Authentication:** Required (JWT Bearer Token - pdr)

**Response (200 OK):**
```json
{
  "general": {
    "total_students": 120,
    "total_questions": 45,
    "total_answers": 890,
    "total_analyses": 180
  },
  "risk_distribution": {
    "low": 85,
    "medium": 24,
    "high": 8,
    "critical": 3
  },
  "emotion_distribution": {
    "very_positive": 40,
    "positive": 55,
    "neutral": 45,
    "negative": 30,
    "very_negative": 10
  },
  "category_distribution": {
    "emotional": 250,
    "social": 180,
    "academic": 200,
    "family": 120,
    "self_esteem": 90,
    "anxiety": 50
  },
  "recent_activity": {
    "last_30_days_answers": 340,
    "last_30_days_analyses": 45
  }
}
```

---

## Hata Yönetimi

### HTTP Status Kodları

| Kod | Anlamı |
|-----|--------|
| 200 | OK - İstek başarılı |
| 400 | Bad Request - Geçersiz istek |
| 401 | Unauthorized - Authentication gerekli |
| 403 | Forbidden - Yetkisiz erişim |
| 404 | Not Found - Kaynak bulunamadı |
| 500 | Internal Server Error - Sunucu hatası |

### Yaygın Hatalar

**PDR Uzmanı Profili Bulunamadı:**
```json
{
  "error": "PDR Expert profile not found for this user."
}
```

---

## Flutter Entegrasyon Örnekleri

### PDR Dashboard

```dart
Future<Map<String, dynamic>> getPDRDashboard() async {
  final accessToken = await storage.read(key: 'access_token');
  
  final response = await http.get(
    Uri.parse('https://ngp.teknolikya.com.tr/api/pdr/dashboard/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Dashboard yüklenemedi');
  }
}
```

### Yüksek Riskli Öğrenciler

```dart
Future<List<dynamic>> getHighRiskStudents() async {
  final accessToken = await storage.read(key: 'access_token');
  
  final response = await http.get(
    Uri.parse('https://ngp.teknolikya.com.tr/api/pdr/students/?risk_level=high'),
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

### Öğrenci Detaylı Analiz

```dart
Future<Map<String, dynamic>> getStudentEmotionalAnalysis(int studentId) async {
  final accessToken = await storage.read(key: 'access_token');
  
  final response = await http.get(
    Uri.parse('https://ngp.teknolikya.com.tr/api/pdr/students/$studentId/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Öğrenci analizi yüklenemedi');
  }
}
```

---

## API Endpoint Özeti

| Endpoint | Method | Açıklama |
|----------|--------|----------|
| `/api/token/` | POST | JWT token al (login) |
| `/api/pdr/dashboard/` | GET | Dashboard özeti |
| `/api/pdr/students/` | GET | Öğrenci listesi |
| `/api/pdr/students/<id>/` | GET | Öğrenci detay analizi |
| `/api/pdr/questions/` | GET | PDR soru listesi |
| `/api/pdr/answers/` | GET | Öğrenci cevapları |
| `/api/pdr/analyses/` | GET | Haftalık analizler |
| `/api/pdr/messages/` | GET | Mesajlar |
| `/api/pdr/statistics/` | GET | Detaylı istatistikler |

---

## Destek

API desteği ve sorularınız için:
- **Email:** info@teknolikya.com.tr
- **Dokümantasyon:** Bu dosya
- **Backend:** Django 3.2.10 with Django REST Framework

---

## Değişiklik Geçmişi

### Versiyon 1.0.0 (2025-12-11)
- İlk PDR API release
- JWT authentication with user_type
- 8 ana endpoint
- Duygusal analiz sistemi
- Risk değerlendirme
- AI-powered insights
- Mesajlaşma sistemi
