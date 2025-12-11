# NGP Mobile API - User Type Based Authentication Summary

## 🎯 Yapılan Değişiklikler

### 1. Custom JWT Token Serializer (Backend)

**Dosya:** `user/serializers.py`
- `CustomTokenObtainPairSerializer` eklendi
- Login response'a `user_type` ve `profile` bilgisi eklendi
- 5 kullanıcı tipi desteği: student, parent, teacher, pdr, admin

### 2. Custom Token View (Backend)

**Dosya:** `user/api_views.py`
- `CustomTokenObtainPairView` eklendi
- Standart JWT view'den türetildi
- Custom serializer'ı kullanıyor

### 3. URL Configuration (Backend)

**Dosya:** `TNGP/urls.py`
- Token endpoint güncellendi
- `CustomTokenObtainPairView` kullanılıyor
- Yorum güncellendi: "Custom - returns user_type"

### 4. API Documentation Updates

**Dosyalar:** `API.md`, `API_PARENT.md`
- Login endpoint dökümanları güncellendi
- Response örneklerine `user_type` ve `profile` eklendi
- Kullanıcı tipi açıklamaları eklendi

### 5. Flutter Mobile Developer Guide

**Dosya:** `FLUTTER_MOBILE_ROUTING_GUIDE.md` (YENİ)
- Kapsamlı Flutter entegrasyon rehberi
- 5 kullanıcı tipi için routing stratejisi
- Code snippets (AuthService, LoginScreen, SplashScreen)
- Auto-login logic
- Token refresh implementation
- Security best practices
- UI/UX recommendations

---

## 📊 Login API Response Format

### Örnek Request
```bash
POST https://ngp.teknolikya.com.tr/api/token/
Content-Type: application/json

{
  "username": "student123",
  "password": "password123"
}
```

### Örnek Response (Student)
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
    "gender": "male",
    "school": "Ankara İlkokulu",
    "birthday": "2010-05-15"
  }
}
```

### Örnek Response (Parent)
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user_type": "parent",
  "user": {
    "id": 28,
    "username": "ayse_veli",
    "email": "ayse@example.com",
    "first_name": "Ayşe",
    "last_name": "Yılmaz",
    "full_name": "Ayşe Yılmaz"
  },
  "profile": {
    "id": 5,
    "profile_pic": "https://ngp.teknolikya.com.tr/media/parents/ayse.jpg",
    "telephone": "05321234567",
    "gender": "female"
  }
}
```

---

## 🚀 User Type Based Routing

| User Type | Route | API Base |
|-----------|-------|----------|
| `student` | `/student/dashboard` | `/api/student/` |
| `parent` | `/parent/dashboard` | `/api/parent/` |
| `teacher` | `/teacher/dashboard` | `/api/teacher/` *(TBD)* |
| `pdr` | `/pdr/dashboard` | `/api/pdr/` *(TBD)* |
| `admin` | `/admin/dashboard` | `/api/admin/` *(TBD)* |

---

## 💻 Flutter Implementation (Quick Reference)

### 1. Login & Save Tokens
```dart
final response = await http.post(
  Uri.parse('https://ngp.teknolikya.com.tr/api/token/'),
  body: jsonEncode({'username': username, 'password': password}),
);

final data = jsonDecode(response.body);

// Save to secure storage
await storage.write(key: 'access_token', value: data['access']);
await storage.write(key: 'user_type', value: data['user_type']);
```

### 2. Route Based on User Type
```dart
final userType = data['user_type'];

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
}
```

### 3. Auto-Login on App Start
```dart
@override
void initState() {
  super.initState();
  _checkLoginStatus();
}

Future<void> _checkLoginStatus() async {
  final isLoggedIn = await _authService.isLoggedIn();
  if (isLoggedIn) {
    final userType = await _authService.getUserType();
    // Route to appropriate dashboard
    switch (userType) { ... }
  } else {
    Navigator.pushReplacementNamed(context, '/login');
  }
}
```

---

## 🔒 Security Features

1. ✅ JWT Token in response
2. ✅ User type validation server-side
3. ✅ Profile data included (no extra API call needed)
4. ✅ Access token (1 day) + Refresh token (7 days)
5. ✅ Secure storage recommendation (flutter_secure_storage)
6. ✅ HTTPS enforced in production

---

## 📝 Testing

### Test Different User Types

```bash
# Student Login
curl -X POST https://ngp.teknolikya.com.tr/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"student_username","password":"password"}'

# Parent Login
curl -X POST https://ngp.teknolikya.com.tr/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"parent_username","password":"password"}'

# Teacher Login
curl -X POST https://ngp.teknolikya.com.tr/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"teacher_username","password":"password"}'

# PDR Login
curl -X POST https://ngp.teknolikya.com.tr/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"pdr_username","password":"password"}'

# Admin Login
curl -X POST https://ngp.teknolikya.com.tr/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin_username","password":"password"}'
```

---

## 📚 Documentation Files

1. **API.md** - Student API documentation (güncellenmiş)
2. **API_PARENT.md** - Parent API documentation (güncellenmiş)
3. **FLUTTER_MOBILE_ROUTING_GUIDE.md** - Flutter developer guide (YENİ)
4. **MOBILE_USER_TYPE_AUTH_SUMMARY.md** - Bu dosya (YENİ)

---

## ✅ Implementation Status

- ✅ Backend: Custom JWT serializer with user_type
- ✅ Backend: Profile data in login response
- ✅ Backend: 5 user types supported
- ✅ API Docs: Updated with user_type examples
- ✅ Flutter Guide: Complete implementation guide
- ⏳ Teacher API: Not yet implemented
- ⏳ PDR API: Not yet implemented
- ⏳ Admin API: Not yet implemented

---

## 🎯 Next Steps for Mobile Developer

1. ✅ **Read:** `FLUTTER_MOBILE_ROUTING_GUIDE.md`
2. ✅ **Implement:** AuthService with user_type handling
3. ✅ **Create:** 5 dashboard screens (start with student/parent)
4. ✅ **Test:** Login flow with different user types
5. ✅ **Add:** Auto-login on app start
6. ✅ **Implement:** Token refresh logic
7. ⏳ **Build:** Teacher dashboard (when API ready)
8. ⏳ **Build:** PDR dashboard (when API ready)
9. ⏳ **Build:** Admin dashboard (when API ready)

---

## 📞 Support

**Backend Team:**
- API endpoint: `https://ngp.teknolikya.com.tr/api/`
- Student API: `/api/student/*` (LIVE)
- Parent API: `/api/parent/*` (LIVE)
- Teacher API: Coming soon
- PDR API: Coming soon
- Admin API: Coming soon

**Documentation:**
- Student API: `API.md`
- Parent API: `API_PARENT.md`
- Flutter Guide: `FLUTTER_MOBILE_ROUTING_GUIDE.md`

---

**Created:** 2025-12-11  
**Version:** 1.0.0  
**Status:** Production Ready (Student + Parent)
