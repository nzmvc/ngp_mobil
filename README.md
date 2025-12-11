# NGP Mobil - Öğrenci Uygulaması

NGP (Next Generation Platform) için geliştirilmiş Flutter mobil uygulaması. Öğrencilerin kurslarını, derslerini ve ödevlerini takip edebilecekleri kapsamlı bir mobil deneyim sunar.

## Özellikler

### ✅ Kullanıcı Kimlik Doğrulama
- JWT tabanlı güvenli giriş sistemi
- Token'ların güvenli saklanması (Flutter Secure Storage)
- Otomatik oturum kontrolü
- Çıkış yapma özelliği

### 📚 Kurslar
- Kayıtlı olunan kursların listesi
- Kurs detayları (başlık, açıklama, eğitmen)
- Her kurs için ilerleme göstergesi
- Kursa ait derslere kolay erişim

### 📝 Görevler/Ödevler
- Tüm ödevlerin listesi
- Görev durumları (Bekleyen, Tamamlanan, Gecikmiş)
- Son tarih takibi ve uyarılar
- Görevleri tamamlandı olarak işaretleme
- Yaklaşan görevler için bildirimler

### 🎓 Dersler
- Kurs içindeki derslerin sıralı listesi
- Ders içerikleri (açıklama, video, dosyalar)
- Video oynatıcı ile ders videoları
- Ders materyallerine erişim

### 📊 Dashboard
- Genel istatistikler (Aktif kurslar, görevler vb.)
- Yaklaşan görev özetleri
- Hızlı erişim butonları
- Kullanıcı karşılama ekranı

## Teknik Detaylar

### Kullanılan Paketler
- **provider**: State management için
- **http**: API istekleri için
- **flutter_secure_storage**: Güvenli token saklama
- **video_player**: Video oynatma
- **intl**: Tarih formatlama (Türkçe dil desteği)

### Proje Yapısı
```
lib/
├── models/           # Veri modelleri (User, Course, Assignment, Lesson)
├── providers/        # State management (StudentProvider)
├── screens/          # Uygulama ekranları
├── services/         # API servisleri
├── widgets/          # Yeniden kullanılabilir UI bileşenleri
└── main.dart         # Ana uygulama dosyası
```

## Kurulum

### Gereksinimler
- Flutter SDK (3.10.1 veya üzeri)
- Dart SDK
- Android Studio / Xcode (mobil geliştirme için)
- VS Code veya Android Studio IDE

### Adımlar

1. **Repository'yi klonlayın**
   ```bash
   cd /path/to/ngp_mobil
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **API URL'sini yapılandırın**
   - `lib/services/api_service.dart` dosyasını açın
   - `baseUrl` değişkenini backend API URL'niz ile güncelleyin
   - Detaylar için `API_CONFIG.md` dosyasına bakın

4. **Uygulamayı çalıştırın**
   ```bash
   # Web için
   flutter run -d chrome
   
   # Android için
   flutter run -d android
   
   # iOS için
   flutter run -d ios
   ```

## API Entegrasyonu

Uygulama aşağıdaki backend endpoint'lerini kullanır:

- `POST /api/token/` - Kullanıcı girişi
- `GET /api/student/courses/` - Öğrenci kursları
- `GET /api/student/assignments/` - Öğrenci görevleri
- `GET /api/courses/{id}/lessons/` - Kurs dersleri
- `POST /api/student/assignments/{id}/complete/` - Görevi tamamla

Detaylı API dokümantasyonu için `API_CONFIG.md` dosyasına bakın.

## Geliştirme

### State Management
Uygulama Provider pattern kullanır. `StudentProvider` tüm öğrenci verilerini (kurslar, görevler) ve authentication durumunu yönetir.

### Güvenlik
- Tüm API istekleri JWT Bearer token ile korunur
- Token'lar cihazda güvenli şekilde saklanır
- Hassas veriler loglanmaz
- Production'da HTTPS kullanılmalıdır

### Error Handling
- Network hataları yakalanır ve kullanıcıya bildirilir
- Token süresi dolduğunda otomatik logout
- Her ekranda uygun error mesajları
- Retry mekanizmaları

## Test

### Manuel Test
1. Test kullanıcı hesabı ile giriş yapın
2. Dashboard'da veri görünümünü kontrol edin
3. Kurslar listesini inceleyin
4. Görevler ekranında farklı durumları test edin
5. Bir kursa girip dersleri görüntüleyin
6. Video oynatıcıyı test edin

### Edge Cases
- İnternet bağlantısı yok
- Henüz görev/kurs yok
- Token süresi dolmuş
- API hataları

## Bilinen Sınırlamalar

1. **Dosya İndirme**: Ders materyallerini indirme özelliği henüz implement edilmedi
2. **Offline Mode**: Çevrimdışı mod desteği yok
3. **Push Notifications**: Bildirim sistemi henüz eklenmedi
4. **Video Formats**: Sadece network URL'leri desteklenir

## Gelecek Özellikler

- [ ] Push notifications
- [ ] Offline data caching
- [ ] Dosya indirme ve yönetimi
- [ ] Profil düzenleme
- [ ] Dark mode
- [ ] Çoklu dil desteği
- [ ] Assignment submission (ödev gönderme)
- [ ] Quiz/exam özelliği

## Lisans

Bu proje özel bir projedir.

## İletişim

Sorularınız için lütfen proje sahibi ile iletişime geçin.

---

**Not**: Backend API'nin hazır olması gerekir. Test için mock API kullanılabilir.
