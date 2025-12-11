# NGP Admin Mobile API Documentation

## Genel Bakış

Bu doküman NGP (Next Generation Person) Admin/Yönetici Mobile Uygulaması için REST API endpoint'lerini açıklar. Tüm endpoint'ler JWT authentication ve **superuser yetkisi** gerektirir.

**Base URL:** `https://ngp.teknolikya.com.tr/api/`

**Authentication:** JWT Bearer Token (Admin/Superuser)

---

## İçindekiler

1. [Authentication](#authentication)
2. [Admin Dashboard](#admin-dashboard)
3. [Kullanıcı Yönetimi](#kullanıcı-yönetimi)
4. [Öğrenci Yönetimi](#öğrenci-yönetimi)
5. [Öğretmen Yönetimi](#öğretmen-yönetimi)
6. [Veli Yönetimi](#veli-yönetimi)
7. [Kurs Yönetimi](#kurs-yönetimi)
8. [Finansal Raporlar](#finansal-raporlar)
9. [Sistem Logları](#sistem-logları)
10. [Detaylı İstatistikler](#detaylı-i̇statistikler)
11. [Hata Yönetimi](#hata-yönetimi)

---

## Authentication

### JWT Token Alma

**Endpoint:** `POST /api/token/`

**Açıklama:** Admin girişi yaparak JWT access ve refresh token'ları alın.

**Request Body:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response (200 OK):**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user_type": "admin",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@teknolikya.com.tr",
    "first_name": "System",
    "last_name": "Admin",
    "full_name": "System Admin"
  },
  "profile": null
}
```

**Not:** Admin kullanıcıları `is_superuser=True` olan User kayıtlarıdır ve ayrı bir profile tablosu yoktur.

---

## Admin Dashboard

### Dashboard Özet Bilgileri

**Endpoint:** `GET /api/admin/dashboard/`

**Açıklama:** Admin için kapsamlı sistem özeti. Kullanıcılar, finansal durum, aktiviteler ve sistem sağlığı.

**Authentication:** Required (JWT Bearer Token - admin)

**Response (200 OK):**
```json
{
  "admin_user": {
    "id": 1,
    "full_name": "System Admin",
    "username": "admin",
    "email": "admin@teknolikya.com.tr"
  },
  "statistics": {
    "total_students": 120,
    "total_teachers": 15,
    "total_parents": 80,
    "total_pdr": 3,
    "total_courses": 35,
    "total_homeworks": 200,
    "total_tasks": 450
  },
  "financial_summary": {
    "total_income": 125000.50,
    "total_expense": 45000.75,
    "net_profit": 79999.75,
    "period": "Son 30 gün"
  },
  "recent_activities": [
    {
      "id": 1234,
      "user_name": "Ahmet Yılmaz",
      "operation": "Öğrenci Eklendi",
      "date": "2025-12-11T10:30:00Z"
    }
  ],
  "system_health": {
    "active_students": 115,
    "active_teachers": 14,
    "database_status": "healthy",
    "last_backup": null
  },
  "user_distribution": {
    "students": 120,
    "teachers": 15,
    "parents": 80,
    "pdr": 3
  }
}
```

---

## Kullanıcı Yönetimi

### Tüm Kullanıcıları Listele

**Endpoint:** `GET /api/admin/users/`

**Açıklama:** Sistemdeki tüm kullanıcıları listeler. Filtreleme yapılabilir.

**Authentication:** Required (JWT Bearer Token - admin)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `user_type` | string | Kullanıcı tipi (student, teacher, parent, pdr, admin) |
| `search` | string | Ad, soyad, username veya email ile arama |
| `is_active` | boolean | Aktif durumu (true/false) |

**Örnek İstek:**
```
GET /api/admin/users/?user_type=teacher&is_active=true
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "count": 15,
  "users": [
    {
      "id": 25,
      "username": "mehmet_ogretmen",
      "email": "mehmet@example.com",
      "first_name": "Mehmet",
      "last_name": "Demir",
      "full_name": "Mehmet Demir",
      "user_type": "teacher",
      "is_active": true,
      "date_joined": "2024-01-15T08:00:00Z"
    }
  ]
}
```

---

## Öğrenci Yönetimi

### Öğrenci Listesi

**Endpoint:** `GET /api/admin/students/`

**Açıklama:** Tüm öğrencileri detaylı bilgileriyle listeler.

**Authentication:** Required (JWT Bearer Token - admin)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `search` | string | Ad, soyad, username veya okul ile arama |

**Response (200 OK):**
```json
{
  "count": 120,
  "students": [
    {
      "id": 45,
      "full_name": "Ali Yılmaz",
      "username": "ali123",
      "email": "ali@example.com",
      "profile_pic_url": "https://ngp.teknolikya.com.tr/media/students/ali.jpg",
      "gender": 1,
      "school": "Ankara İlkokulu",
      "birthday": "2010-05-15",
      "age": 15,
      "telephone": "05551234567",
      "total_courses": 5,
      "total_homeworks": 25,
      "attendance_rate": 92.5
    }
  ]
}
```

**Öğrenci İstatistikleri:**
- `total_courses`: Kayıtlı olduğu kurs sayısı
- `total_homeworks`: Atanmış ödev sayısı
- `attendance_rate`: Devam oranı (%)

---

## Öğretmen Yönetimi

### Öğretmen Listesi

**Endpoint:** `GET /api/admin/teachers/`

**Açıklama:** Tüm öğretmenleri detaylı bilgileriyle listeler.

**Authentication:** Required (JWT Bearer Token - admin)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `search` | string | Ad, soyad veya username ile arama |

**Response (200 OK):**
```json
{
  "count": 15,
  "teachers": [
    {
      "id": 8,
      "full_name": "Mehmet Demir",
      "username": "mehmet_ogretmen",
      "email": "mehmet@example.com",
      "profile_pic_url": "https://ngp.teknolikya.com.tr/media/teachers/mehmet.jpg",
      "gender": 1,
      "telephone": "05559876543",
      "sube": "A Şubesi",
      "total_courses": 8,
      "total_students": 45
    }
  ]
}
```

---

## Veli Yönetimi

### Veli Listesi

**Endpoint:** `GET /api/admin/parents/`

**Açıklama:** Tüm velileri detaylı bilgileriyle listeler.

**Authentication:** Required (JWT Bearer Token - admin)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `search` | string | Ad, soyad veya username ile arama |

**Response (200 OK):**
```json
{
  "count": 80,
  "parents": [
    {
      "id": 12,
      "full_name": "Ayşe Kara",
      "username": "ayse_veli",
      "email": "ayse@example.com",
      "profile_pic_url": "https://ngp.teknolikya.com.tr/media/parents/ayse.jpg",
      "gender": 0,
      "telephone": "05551112233",
      "job": "Öğretmen",
      "total_children": 2
    }
  ]
}
```

---

## Kurs Yönetimi

### Kurs Listesi

**Endpoint:** `GET /api/admin/courses/`

**Açıklama:** Tüm kursları detaylı bilgileriyle listeler.

**Authentication:** Required (JWT Bearer Token - admin)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `search` | string | Kurs adı veya açıklaması ile arama |
| `category` | string | Kategori filtresi (1: Yazılım, 2: Robotik, vb.) |

**Response (200 OK):**
```json
{
  "count": 35,
  "courses": [
    {
      "id": 10,
      "title": "Python Programlama",
      "shortNot": "Temel Python eğitimi",
      "lessonCategory": 1,
      "price": 1500.00,
      "teacher_name": "Mehmet Demir",
      "total_students": 25,
      "total_lessons": 12
    }
  ]
}
```

**Kategori Kodları:**
- `1`: Yazılım
- `2`: Robotik
- `3`: Oyun Tasarımı
- `4`: Web Tasarımı
- `5`: Mobil Uygulama
- `6`: Diğer

---

## Finansal Raporlar

### Finansal Özet

**Endpoint:** `GET /api/admin/financial/`

**Açıklama:** Gelir-gider raporu. Tarih aralığı filtresi uygulanabilir.

**Authentication:** Required (JWT Bearer Token - admin)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `start_date` | string | Başlangıç tarihi (YYYY-MM-DD) |
| `end_date` | string | Bitiş tarihi (YYYY-MM-DD) |

**Örnek İstek:**
```
GET /api/admin/financial/?start_date=2025-01-01&end_date=2025-12-31
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "total_income": 125000.50,
  "total_expense": 45000.75,
  "net_profit": 79999.75,
  "income_count": 250,
  "expense_count": 120
}
```

**Finansal Metrikler:**
- `total_income`: Toplam gelir (TL)
- `total_expense`: Toplam gider (TL)
- `net_profit`: Net kâr (gelir - gider)
- `income_count`: Gelir kaydı sayısı
- `expense_count`: Gider kaydı sayısı

---

## Sistem Logları

### Log Kayıtları

**Endpoint:** `GET /api/admin/logs/`

**Açıklama:** Sistem aktivite loglarını listeler. En son 100 kayıt döner.

**Authentication:** Required (JWT Bearer Token - admin)

**Query Parameters:**
| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `user_id` | integer | Kullanıcıya göre filtrele |
| `operation` | string | İşlem adı ile arama |
| `start_date` | string | Başlangıç tarihi (YYYY-MM-DD) |
| `end_date` | string | Bitiş tarihi (YYYY-MM-DD) |

**Response (200 OK):**
```json
{
  "count": 100,
  "logs": [
    {
      "id": 5678,
      "user_name": "Mehmet Demir",
      "operation": "Öğrenci Eklendi: Ali Yılmaz",
      "ip": "192.168.1.100",
      "date": "2025-12-11T10:30:00Z"
    }
  ]
}
```

**Örnek İşlemler:**
- "Kullanıcı Giriş Yaptı"
- "Öğrenci Eklendi: ..."
- "Kurs Güncellendi: ..."
- "Ödev Oluşturuldu: ..."
- "Ödeme Alındı: ..."

---

## Detaylı İstatistikler

### Kapsamlı Sistem İstatistikleri

**Endpoint:** `GET /api/admin/statistics/`

**Açıklama:** Sistemin tüm modüllerinden detaylı istatistikler.

**Authentication:** Required (JWT Bearer Token - admin)

**Response (200 OK):**
```json
{
  "users": {
    "total_students": 120,
    "active_students": 115,
    "total_teachers": 15,
    "total_parents": 80,
    "total_pdr": 3
  },
  "education": {
    "total_courses": 35,
    "total_lessons": 420,
    "total_enrollments": 600,
    "total_homeworks": 200,
    "pending_homeworks": 45
  },
  "financial": {
    "total_income": 125000.50,
    "total_expense": 45000.75,
    "net_profit": 79999.75
  },
  "engagement": {
    "total_tasks": 450,
    "completed_tasks": 380,
    "total_scores": 1200,
    "avg_score": 85.5
  },
  "pdr": {
    "total_questions": 45,
    "total_answers": 890,
    "total_analyses": 180,
    "high_risk_students": 8
  },
  "growth": {
    "new_students": 12,
    "new_courses": 3,
    "new_homeworks": 18
  }
}
```

**İstatistik Kategorileri:**
1. **users**: Kullanıcı sayıları ve aktif durumlar
2. **education**: Eğitim içeriği ve katılım
3. **financial**: Finansal özet (tüm zamanlar)
4. **engagement**: Görevler, puanlar ve ortalamalar
5. **pdr**: Psikolojik danışma verileri
6. **growth**: Son 30 gün büyüme metrikleri

---

## Hata Yönetimi

### HTTP Status Kodları

| Kod | Anlamı |
|-----|--------|
| 200 | OK - İstek başarılı |
| 400 | Bad Request - Geçersiz istek |
| 401 | Unauthorized - Authentication gerekli |
| 403 | Forbidden - Admin yetkisi gerekli |
| 404 | Not Found - Kaynak bulunamadı |
| 500 | Internal Server Error - Sunucu hatası |

### Yaygın Hatalar

**Admin Yetkisi Yok:**
```json
{
  "error": "Admin access required."
}
```

**Geçersiz Tarih Formatı:**
```json
{
  "error": "Invalid date format. Use YYYY-MM-DD."
}
```

---

## Flutter Entegrasyon Örnekleri

### Admin Dashboard

```dart
Future<Map<String, dynamic>> getAdminDashboard() async {
  final accessToken = await storage.read(key: 'access_token');
  
  final response = await http.get(
    Uri.parse('https://ngp.teknolikya.com.tr/api/admin/dashboard/'),
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

### Öğrenci Listesi

```dart
Future<List<dynamic>> getStudents({String? search}) async {
  final accessToken = await storage.read(key: 'access_token');
  
  String url = 'https://ngp.teknolikya.com.tr/api/admin/students/';
  if (search != null && search.isNotEmpty) {
    url += '?search=$search';
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

### Finansal Rapor

```dart
Future<Map<String, dynamic>> getFinancialReport({
  String? startDate,
  String? endDate,
}) async {
  final accessToken = await storage.read(key: 'access_token');
  
  String url = 'https://ngp.teknolikya.com.tr/api/admin/financial/';
  List<String> params = [];
  
  if (startDate != null) params.add('start_date=$startDate');
  if (endDate != null) params.add('end_date=$endDate');
  
  if (params.isNotEmpty) {
    url += '?${params.join('&')}';
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
    throw Exception('Finansal rapor yüklenemedi');
  }
}
```

### Sistem İstatistikleri

```dart
Future<Map<String, dynamic>> getSystemStatistics() async {
  final accessToken = await storage.read(key: 'access_token');
  
  final response = await http.get(
    Uri.parse('https://ngp.teknolikya.com.tr/api/admin/statistics/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('İstatistikler yüklenemedi');
  }
}
```

---

## API Endpoint Özeti

| Endpoint | Method | Açıklama |
|----------|--------|----------|
| `/api/token/` | POST | JWT token al (admin login) |
| `/api/admin/dashboard/` | GET | Dashboard özeti |
| `/api/admin/users/` | GET | Tüm kullanıcılar |
| `/api/admin/students/` | GET | Öğrenci listesi |
| `/api/admin/teachers/` | GET | Öğretmen listesi |
| `/api/admin/parents/` | GET | Veli listesi |
| `/api/admin/courses/` | GET | Kurs listesi |
| `/api/admin/financial/` | GET | Finansal rapor |
| `/api/admin/logs/` | GET | Sistem logları |
| `/api/admin/statistics/` | GET | Detaylı istatistikler |

---

## Güvenlik Notları

1. **Superuser Kontrolü**: Tüm endpoint'ler `is_superuser=True` kontrolü yapar
2. **Multi-tenant İzolasyon**: Tüm sorgular `company_id` filtrelenir
3. **JWT Token**: Access token 1 gün, refresh token 7 gün geçerli
4. **HTTPS**: Production'da tüm istekler HTTPS üzerinden yapılmalıdır
5. **Rate Limiting**: API rate limiting uygulanması önerilir (Gelecek faz)

---

## Admin Rolleri ve Yetkiler

NGP sisteminde admin kullanıcıları **tam yetkilidir** ve şunları yapabilir:

- ✅ Tüm kullanıcıları (öğrenci, öğretmen, veli, PDR) görüntüle/düzenle
- ✅ Kursları ve dersleri yönet
- ✅ Finansal raporları görüntüle
- ✅ Sistem loglarını incele
- ✅ Tüm modüllere erişim
- ✅ Şirket (company) ayarlarını yönet
- ✅ Bildirim ve mesaj yönetimi
- ✅ Raporlama ve analitik

---

## Destek

API desteği ve sorularınız için:
- **Email:** info@teknolikya.com.tr
- **Dokümantasyon:** Bu dosya
- **Backend:** Django 3.2.10 with Django REST Framework

---

## Değişiklik Geçmişi

### Versiyon 1.0.0 (2025-12-11)
- İlk Admin API release
- JWT authentication with user_type
- 9 ana endpoint
- Kapsamlı kullanıcı yönetimi
- Finansal raporlama
- Sistem log takibi
- Detaylı istatistik dashboard
