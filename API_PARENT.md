# NGP Veli Mobile API Documentation

## Genel Bakış

Bu doküman NGP (Next Generation Person) Veli Mobile Uygulaması için REST API endpoint'lerini açıklar. Tüm endpoint'ler aksi belirtilmedikçe JWT authentication gerektirir.

**Base URL:** `https://ngp.teknolikya.com.tr/api/`

**Authentication:** JWT Bearer Token

---

## İçindekiler

1. [Authentication](#authentication)
2. [Veli Dashboard](#veli-dashboard)
3. [Çocuklar Listesi](#çocuklar-listesi)
4. [Çocuk Detayı](#çocuk-detayı)
5. [Çocuk Ödevleri](#çocuk-ödevleri)
6. [Çocuk Yoklama](#çocuk-yoklama)
7. [Ödemeler](#ödemeler)
8. [Öğretmen Yorumları](#öğretmen-yorumları)
9. [Hata Yönetimi](#hata-yönetimi)

---

## Authentication

### JWT Token Alma

**Endpoint:** `POST /api/token/`

**Açıklama:** Veli girişi yaparak JWT access ve refresh token'ları alın.

**Request Body:**
```json
{
  "username": "ayse_veli",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

**Kullanım:**
- `access` token'ı tüm API isteklerinde `Authorization` header'ında kullanın
- Header formatı: `Authorization: Bearer <access_token>`
- Access token 1 gün geçerlidir
- Refresh token 7 gün geçerlidir

---

## Veli Dashboard

### Veli Dashboard Özeti

**Endpoint:** `GET /api/parent/dashboard/`

**Açıklama:** Veli için özet dashboard bilgilerini getirir. Çocuklar, ödemeler, yoklama ve yorumlar dahil.

**Authentication:** Required (JWT Bearer Token)

**Response (200 OK):**
```json
{
  "parent": {
    "id": 5,
    "full_name": "Ayşe Yılmaz",
    "username": "ayse_veli",
    "email": "ayse@example.com",
    "telephone": "05321234567",
    "profile_pic_url": "https://ngp.teknolikya.com.tr/media/parents/ayse.jpg"
  },
  "children": [
    {
      "id": 34,
      "full_name": "Ahmet Yılmaz",
      "username": "ahmet123",
      "profile_pic_url": "https://ngp.teknolikya.com.tr/media/students/ahmet.jpg",
      "gender": "male",
      "school": "Ankara İlkokulu",
      "birthday": "2010-05-15",
      "age": 15
    },
    {
      "id": 35,
      "full_name": "Elif Yılmaz",
      "username": "elif456",
      "profile_pic_url": null,
      "gender": "female",
      "school": "Ankara İlkokulu",
      "birthday": "2012-08-20",
      "age": 13
    }
  ],
  "statistics": {
    "total_children": 2,
    "total_payments": 5000.00,
    "total_pending_assignments": 8,
    "total_active_sessions": 4
  },
  "recent_payments": [
    {
      "id": 101,
      "student_name": "Ahmet Yılmaz",
      "amount": 500.00,
      "date": "2025-12-01",
      "description": "Aralık ayı kursu"
    },
    {
      "id": 102,
      "student_name": "Elif Yılmaz",
      "amount": 500.00,
      "date": "2025-12-01",
      "description": "Aralık ayı kursu"
    }
  ],
  "recent_rollcalls": [
    {
      "id": 456,
      "student_name": "Ahmet Yılmaz",
      "lesson_subject": "Python Programlama - Ders 5",
      "session_date": "2025-12-10",
      "date": "2025-12-10",
      "rollcall": true,
      "rollcall_display": "Geldi",
      "desc_to_student": null,
      "has_comment": false
    },
    {
      "id": 457,
      "student_name": "Elif Yılmaz",
      "lesson_subject": "Robotik - Ders 3",
      "session_date": "2025-12-09",
      "date": "2025-12-09",
      "rollcall": true,
      "rollcall_display": "Geldi",
      "desc_to_student": "Derste çok aktif ve başarılı",
      "has_comment": true
    }
  ],
  "recent_comments": [
    {
      "id": 457,
      "student_name": "Elif Yılmaz",
      "lesson_subject": "Robotik - Ders 3",
      "session_date": "2025-12-09",
      "date": "2025-12-09",
      "rollcall": true,
      "rollcall_display": "Geldi",
      "desc_to_student": "Derste çok aktif ve başarılı",
      "has_comment": true
    }
  ]
}
```

**Notlar:**
- `statistics.total_payments`: Velinin tüm çocukları için toplam ödeme miktarı
- `statistics.total_pending_assignments`: Tüm çocukların bekleyen ödevleri toplamı
- `statistics.total_active_sessions`: Aktif oturumlar toplamı
- `recent_payments`: Son 5 ödeme
- `recent_rollcalls`: Son 10 yoklama kaydı
- `recent_comments`: Son 5 öğretmen yorumu

---

## Çocuklar Listesi

### Velinin Tüm Çocuklarını Listele

**Endpoint:** `GET /api/parent/children/`

**Açıklama:** Velinin kayıtlı tüm çocuklarını listeler.

**Authentication:** Required (JWT Bearer Token)

**Response (200 OK):**
```json
{
  "count": 2,
  "children": [
    {
      "id": 34,
      "full_name": "Ahmet Yılmaz",
      "username": "ahmet123",
      "profile_pic_url": "https://ngp.teknolikya.com.tr/media/students/ahmet.jpg",
      "gender": "male",
      "school": "Ankara İlkokulu",
      "birthday": "2010-05-15",
      "age": 15
    },
    {
      "id": 35,
      "full_name": "Elif Yılmaz",
      "username": "elif456",
      "profile_pic_url": null,
      "gender": "female",
      "school": "Ankara İlkokulu",
      "birthday": "2012-08-20",
      "age": 13
    }
  ]
}
```

---

## Çocuk Detayı

### Çocuk Detaylı Bilgileri

**Endpoint:** `GET /api/parent/children/<child_id>/`

**Açıklama:** Belirli bir çocuğun detaylı bilgilerini ve istatistiklerini getirir.

**Authentication:** Required (JWT Bearer Token)

**Path Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `child_id` | integer | Çocuk (öğrenci) ID |

**Örnek İstek:**
```
GET /api/parent/children/34/
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "id": 34,
  "full_name": "Ahmet Yılmaz",
  "username": "ahmet123",
  "email": "ahmet@example.com",
  "profile_pic_url": "https://ngp.teknolikya.com.tr/media/students/ahmet.jpg",
  "gender": "male",
  "school": "Ankara İlkokulu",
  "birthday": "2010-05-15",
  "age": 15,
  "stats": {
    "total_sessions": 48,
    "total_rollcalls": 45,
    "present_rollcalls": 42,
    "attendance_rate": 93.3,
    "total_assignments": 20,
    "completed_assignments": 15,
    "pending_assignments": 5
  }
}
```

**İstatistik Açıklamaları:**
- `total_sessions`: Çocuğun katıldığı toplam ders oturumu sayısı
- `total_rollcalls`: Toplam yoklama kaydı sayısı
- `present_rollcalls`: Geldiği ders sayısı
- `attendance_rate`: Devamsızlık oranı (%)
- `total_assignments`: Toplam ödev sayısı
- `completed_assignments`: Tamamlanan ödev sayısı
- `pending_assignments`: Bekleyen ödev sayısı

**Response (403 Forbidden):**
```json
{
  "detail": "Not found."
}
```
*Bu hata, veli bu çocuğun velisi değilse döner.*

---

## Çocuk Ödevleri

### Çocuğun Ödevlerini Listele

**Endpoint:** `GET /api/parent/children/<child_id>/assignments/`

**Açıklama:** Belirli bir çocuğun tüm ödevlerini listeler.

**Authentication:** Required (JWT Bearer Token)

**Path Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `child_id` | integer | Çocuk (öğrenci) ID |

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `status` | string | Duruma göre filtrele: `pending`, `submitted`, `graded`, `late`, `missing` |
| `is_overdue` | boolean | Gecikmiş ödevler: `true` veya `false` |

**Örnek İstek:**
```
GET /api/parent/children/34/assignments/?status=pending
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "child": {
    "id": 34,
    "full_name": "Ahmet Yılmaz"
  },
  "count": 5,
  "assignments": [
    {
      "id": 123,
      "title": "Python Temelleri - Alıştırmalar",
      "description": "1-10 arası alıştırmaları tamamlayın",
      "homework_type": "Assignment",
      "difficulty": "Medium",
      "due_date": "2025-12-31",
      "status": "pending",
      "status_display": "Bekliyor",
      "is_overdue": false,
      "days_remaining": 20,
      "course_name": "Python Programlama",
      "lesson_name": "Ders 5: Döngüler",
      "submission_date": null,
      "has_submission": false,
      "grade": null,
      "feedback": null,
      "assigned_date": "2025-12-01T10:00:00Z",
      "is_seen": true
    },
    {
      "id": 124,
      "title": "Robotik Proje",
      "description": "Engelden kaçan robot tasarla",
      "homework_type": "Project",
      "difficulty": "Hard",
      "due_date": "2025-12-25",
      "status": "graded",
      "status_display": "Değerlendirildi",
      "is_overdue": false,
      "days_remaining": 14,
      "course_name": "Robotik",
      "lesson_name": "Ders 8: Sensörler",
      "submission_date": "2025-12-15T14:30:00Z",
      "has_submission": true,
      "grade": {
        "score": 90,
        "max_score": 100,
        "percentage": 90.0,
        "graded_date": "2025-12-16T10:00:00Z"
      },
      "feedback": "Harika bir proje! Sensör kullanımı çok başarılı.",
      "assigned_date": "2025-12-01T10:00:00Z",
      "is_seen": true
    }
  ]
}
```

**Ödev Durumları:**
- `pending`: Henüz teslim edilmedi
- `submitted`: Teslim edildi, değerlendirme bekleniyor
- `graded`: Değerlendirildi
- `late`: Geç teslim edildi
- `missing`: Teslim edilmedi ve süresi geçti

---

## Çocuk Yoklama

### Çocuğun Yoklama Kayıtları

**Endpoint:** `GET /api/parent/children/<child_id>/rollcall/`

**Açıklama:** Belirli bir çocuğun yoklama kayıtlarını listeler.

**Authentication:** Required (JWT Bearer Token)

**Path Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `child_id` | integer | Çocuk (öğrenci) ID |

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `limit` | integer | Sonuç limiti (varsayılan: 30) |
| `month` | string | Aya göre filtrele (YYYY-MM formatında, örn: 2025-12) |

**Örnek İstek:**
```
GET /api/parent/children/34/rollcall/?month=2025-12&limit=50
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "child": {
    "id": 34,
    "full_name": "Ahmet Yılmaz"
  },
  "count": 45,
  "attendance_rate": 93.3,
  "rollcalls": [
    {
      "id": 456,
      "student_name": "Ahmet Yılmaz",
      "lesson_subject": "Python Programlama - Ders 5",
      "session_date": "2025-12-10",
      "date": "2025-12-10",
      "rollcall": true,
      "rollcall_display": "Geldi",
      "desc_to_student": null,
      "has_comment": false
    },
    {
      "id": 455,
      "student_name": "Ahmet Yılmaz",
      "lesson_subject": "Python Programlama - Ders 4",
      "session_date": "2025-12-08",
      "date": "2025-12-08",
      "rollcall": true,
      "rollcall_display": "Geldi",
      "desc_to_student": "Derste çok aktif. Problem çözme becerisi harika!",
      "has_comment": true
    },
    {
      "id": 454,
      "student_name": "Ahmet Yılmaz",
      "lesson_subject": "Python Programlama - Ders 3",
      "session_date": "2025-12-06",
      "date": "2025-12-06",
      "rollcall": false,
      "rollcall_display": "Gelmedi",
      "desc_to_student": null,
      "has_comment": false
    }
  ]
}
```

**Açıklamalar:**
- `count`: Toplam yoklama kaydı sayısı
- `attendance_rate`: Devamsızlık oranı (%)
- `rollcall`: true = Geldi, false = Gelmedi
- `desc_to_student`: Öğretmenin öğrenciye özel notu (varsa)
- `has_comment`: Öğretmen notu var mı?

---

## Ödemeler

### Veli Ödeme Kayıtları

**Endpoint:** `GET /api/parent/payments/`

**Açıklama:** Velinin tüm ödeme kayıtlarını listeler.

**Authentication:** Required (JWT Bearer Token)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `child_id` | integer | Çocuğa göre filtrele |
| `year` | integer | Yıla göre filtrele (örn: 2025) |
| `month` | integer | Aya göre filtrele (1-12) |

**Örnek İstek:**
```
GET /api/parent/payments/?year=2025&month=12
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "count": 12,
  "total_amount": 6000.00,
  "payments": [
    {
      "id": 101,
      "student_name": "Ahmet Yılmaz",
      "amount": 500.00,
      "date": "2025-12-01",
      "description": "Aralık ayı Python kursu"
    },
    {
      "id": 102,
      "student_name": "Elif Yılmaz",
      "amount": 500.00,
      "date": "2025-12-01",
      "description": "Aralık ayı Robotik kursu"
    },
    {
      "id": 103,
      "student_name": "Ahmet Yılmaz",
      "amount": 1000.00,
      "date": "2025-11-01",
      "description": "Kasım ayı Python kursu"
    }
  ]
}
```

**Açıklamalar:**
- `count`: Toplam ödeme sayısı
- `total_amount`: Filtrelenmiş ödemelerin toplam tutarı
- Ödemeler tarih sırasına göre (en yeni → en eski) listelenir

---

## Öğretmen Yorumları

### Öğretmen Yorumları Listesi

**Endpoint:** `GET /api/parent/comments/`

**Açıklama:** Velinin tüm çocukları için öğretmen yorumlarını listeler.

**Authentication:** Required (JWT Bearer Token)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `child_id` | integer | Çocuğa göre filtrele |
| `limit` | integer | Sonuç limiti (varsayılan: 20) |

**Örnek İstek:**
```
GET /api/parent/comments/?child_id=34&limit=10
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "count": 15,
  "comments": [
    {
      "id": 457,
      "student_name": "Ahmet Yılmaz",
      "lesson_subject": "Python Programlama - Ders 5",
      "session_date": "2025-12-10",
      "date": "2025-12-10",
      "rollcall": true,
      "rollcall_display": "Geldi",
      "desc_to_student": "Derste çok aktif ve başarılı. Problem çözme becerisi harika!",
      "has_comment": true
    },
    {
      "id": 456,
      "student_name": "Ahmet Yılmaz",
      "lesson_subject": "Python Programlama - Ders 4",
      "session_date": "2025-12-08",
      "date": "2025-12-08",
      "rollcall": true,
      "rollcall_display": "Geldi",
      "desc_to_student": "Kodlama mantığını çok iyi kavramış. Tebrikler!",
      "has_comment": true
    },
    {
      "id": 450,
      "student_name": "Elif Yılmaz",
      "lesson_subject": "Robotik - Ders 3",
      "session_date": "2025-12-09",
      "date": "2025-12-09",
      "rollcall": true,
      "rollcall_display": "Geldi",
      "desc_to_student": "Robot montajında çok yaratıcı çözümler üretmiş.",
      "has_comment": true
    }
  ]
}
```

**Açıklamalar:**
- Sadece öğretmen yorumu olan (`desc_to_student` dolu) kayıtlar döner
- Yorumlar tarih sırasına göre (en yeni → en eski) listelenir
- `child_id` parametresi belirtilmezse tüm çocukların yorumları gelir

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

Tüm hatalar şu formatta döner:

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

**Geçersiz Token:**
```json
{
  "detail": "Given token not valid for any token type",
  "code": "token_not_valid"
}
```

**Veli Profili Bulunamadı:**
```json
{
  "error": "Parent profile not found for this user."
}
```

**Yetkisiz Erişim (Başka Velinin Çocuğu):**
```json
{
  "detail": "Not found."
}
```

---

## Entegrasyon Notları

### Güvenlik En İyi Uygulamalar

1. **Her zaman HTTPS kullanın** (production'da)
2. **Token'ları güvenli saklayın** (mobile app'te secure storage kullanın)
3. **Token'ları süre dolmadan yenileyin** (token refresh logic uygulayın)
4. **401 hatalarını yakalayın** ve login ekranına yönlendirin
5. **Tüm input'ları validate edin** (client tarafında API'ye göndermeden önce)

### Mobile App Entegrasyonu

**Flutter Örnek (Token Storage):**
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Token'ları kaydet
await storage.write(key: 'access_token', value: accessToken);
await storage.write(key: 'refresh_token', value: refreshToken);

// Token'ı oku
String? accessToken = await storage.read(key: 'access_token');

// İsteklere token ekle
headers: {
  'Authorization': 'Bearer $accessToken',
  'Content-Type': 'application/json',
}
```

**Flutter Örnek (Veli Dashboard):**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> getParentDashboard() async {
  final accessToken = await storage.read(key: 'access_token');
  
  final response = await http.get(
    Uri.parse('https://ngp.teknolikya.com.tr/api/parent/dashboard/'),
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
    return getParentDashboard(); // Tekrar dene
  } else {
    throw Exception('Dashboard yüklenemedi');
  }
}
```

**Flutter Örnek (Çocuk Ödevleri):**
```dart
Future<Map<String, dynamic>> getChildAssignments(int childId, {String? status}) async {
  final accessToken = await storage.read(key: 'access_token');
  
  String url = 'https://ngp.teknolikya.com.tr/api/parent/children/$childId/assignments/';
  if (status != null) {
    url += '?status=$status';
  }
  
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Ödevler yüklenemedi');
  }
}
```

### Test Etme

**cURL Kullanarak:**
```bash
# 1. Login ve token al
curl -X POST https://ngp.teknolikya.com.tr/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"ayse_veli","password":"password123"}'

# 2. Token'ı API çağrılarında kullan
curl -X GET https://ngp.teknolikya.com.tr/api/parent/dashboard/ \
  -H "Authorization: Bearer <your_access_token>"

# 3. Çocuk detayı
curl -X GET https://ngp.teknolikya.com.tr/api/parent/children/34/ \
  -H "Authorization: Bearer <your_access_token>"

# 4. Çocuk ödevleri (filtrelenmiş)
curl -X GET "https://ngp.teknolikya.com.tr/api/parent/children/34/assignments/?status=pending" \
  -H "Authorization: Bearer <your_access_token>"
```

**Postman Kullanarak:**
1. Yeni bir request oluşturun
2. Login için method'u POST yapın (`/api/token/`)
3. Body'de username ve password ekleyin
4. Response'dan access token'ı kopyalayın
5. Diğer istekler için header ekleyin: `Authorization: Bearer <token>`

---

## API Endpoint Özeti

| Endpoint | Method | Açıklama |
|----------|--------|----------|
| `/api/token/` | POST | JWT token al (login) |
| `/api/token/refresh/` | POST | JWT token yenile |
| `/api/token/verify/` | POST | JWT token doğrula |
| `/api/parent/dashboard/` | GET | Veli dashboard özeti |
| `/api/parent/children/` | GET | Çocukları listele |
| `/api/parent/children/<id>/` | GET | Çocuk detayı |
| `/api/parent/children/<id>/assignments/` | GET | Çocuk ödevleri |
| `/api/parent/children/<id>/rollcall/` | GET | Çocuk yoklama |
| `/api/parent/payments/` | GET | Ödeme kayıtları |
| `/api/parent/comments/` | GET | Öğretmen yorumları |

---

## Destek

API desteği ve sorularınız için:
- **Email:** info@teknolikya.com.tr
- **Dokümantasyon:** Bu dosya
- **Backend:** Django 3.2.10 with Django REST Framework

---

## Değişiklik Geçmişi

### Versiyon 1.0.0 (2025-12-11)
- İlk veli API release
- JWT authentication
- Veli dashboard endpoint
- Çocuklar listesi ve detay endpoint'leri
- Çocuk ödevleri endpoint
- Çocuk yoklama endpoint
- Ödeme kayıtları endpoint
- Öğretmen yorumları endpoint
