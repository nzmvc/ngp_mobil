# Backend Task: Student Profile Photo Upload API

## 📋 Genel Bakış
Öğrenci profil fotoğrafı yükleme/güncelleme özelliği için backend API endpoint'i geliştir.

## 🎯 Gereksinimler

### Endpoint
```
PATCH /api/student/profile/photo/
```

### Authentication
- JWT Bearer Token (required)
- User type: `student` only

### Request Format
**Content-Type:** `multipart/form-data`

**Fields:**
```
profile_photo: File (required)
  - Accepted formats: JPG, JPEG, PNG, WEBP
  - Max size: 5 MB
  - Recommended dimensions: 500x500px (square)
  - Auto-resize if larger than 1000x1000
```

### Response Format

**Success (200 OK):**
```json
{
  "success": true,
  "message": "Profil fotoğrafı başarıyla güncellendi",
  "profile_photo_url": "https://example.com/media/profile_photos/student_49_abc123.jpg",
  "thumbnail_url": "https://example.com/media/profile_photos/thumbs/student_49_abc123_thumb.jpg"
}
```

**Error (400 Bad Request):**
```json
{
  "error": "Invalid file format. Allowed formats: JPG, JPEG, PNG, WEBP"
}
```

**Error (413 Payload Too Large):**
```json
{
  "error": "File size exceeds 5 MB limit"
}
```

**Error (401 Unauthorized):**
```json
{
  "error": "Authentication required"
}
```

## 🔧 İmplementasyon Detayları

### 1. Model Değişiklikleri (education/models.py)
```python
from django.db import models
from django.contrib.auth import get_user_model

class Student(models.Model):
    # ... existing fields ...
    
    profile_photo = models.ImageField(
        upload_to='profile_photos/',
        null=True,
        blank=True,
        help_text='Student profile photo'
    )
    
    def __str__(self):
        return self.user.username
```

### 2. Serializer (education/serializers.py)
```python
from rest_framework import serializers
from .models import Student

class StudentProfilePhotoSerializer(serializers.ModelSerializer):
    profile_photo_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Student
        fields = ['profile_photo', 'profile_photo_url']
    
    def get_profile_photo_url(self, obj):
        if obj.profile_photo:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.profile_photo.url)
        return None
    
    def validate_profile_photo(self, value):
        # File size validation (5 MB)
        max_size = 5 * 1024 * 1024  # 5 MB in bytes
        if value.size > max_size:
            raise serializers.ValidationError("File size exceeds 5 MB limit")
        
        # File format validation
        allowed_formats = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
        if value.content_type not in allowed_formats:
            raise serializers.ValidationError(
                "Invalid file format. Allowed formats: JPG, JPEG, PNG, WEBP"
            )
        
        return value
```

### 3. View (education/api_views.py)
```python
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser
from .models import Student
from .serializers import StudentProfilePhotoSerializer

class StudentProfilePhotoUploadAPIView(APIView):
    """
    Upload or update student profile photo
    
    PATCH /api/student/profile/photo/
    """
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]
    
    def patch(self, request):
        # Validate user type
        if request.user.user_type != 'student':
            return Response(
                {'error': 'Only students can access this endpoint'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        try:
            # Get student profile
            student = Student.objects.get(user=request.user)
            
            # Validate and save photo
            serializer = StudentProfilePhotoSerializer(
                student,
                data=request.data,
                partial=True,
                context={'request': request}
            )
            
            if serializer.is_valid():
                # Delete old photo if exists
                if student.profile_photo:
                    old_photo = student.profile_photo
                    # Delete from storage
                    if old_photo.name:
                        old_photo.delete(save=False)
                
                # Save new photo
                serializer.save()
                
                # Get updated photo URL
                photo_url = serializer.data.get('profile_photo_url')
                
                return Response({
                    'success': True,
                    'message': 'Profil fotoğrafı başarıyla güncellendi',
                    'profile_photo_url': photo_url
                }, status=status.HTTP_200_OK)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        except Student.DoesNotExist:
            return Response(
                {'error': 'Student profile not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
```

### 4. URL Configuration (education/urls.py)
```python
from django.urls import path
from .api_views import StudentProfilePhotoUploadAPIView

urlpatterns = [
    # ... existing patterns ...
    path('student/profile/photo/', StudentProfilePhotoUploadAPIView.as_view(), name='student-profile-photo'),
]
```

### 5. Settings Configuration (settings.py)
```python
# Media files configuration
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# File upload settings
FILE_UPLOAD_MAX_MEMORY_SIZE = 5 * 1024 * 1024  # 5 MB
DATA_UPLOAD_MAX_MEMORY_SIZE = 5 * 1024 * 1024  # 5 MB

# Install Pillow for image processing
# pip install Pillow
```

### 6. URL Configuration (main urls.py)
```python
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    # ... your patterns ...
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

## 🧪 Test Senaryosu

### Postman/cURL Test
```bash
curl -X PATCH http://127.0.0.1:8000/api/student/profile/photo/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "profile_photo=@/path/to/photo.jpg"
```

### Test Cases
1. ✅ Valid JPG upload (< 5 MB)
2. ✅ Valid PNG upload (< 5 MB)
3. ❌ File > 5 MB (should return 400)
4. ❌ Invalid format (PDF, GIF) (should return 400)
5. ❌ No authentication (should return 401)
6. ❌ Parent/Teacher user (should return 403)
7. ✅ Update existing photo (old photo should be deleted)
8. ✅ Photo URL in response is accessible

## 📦 Opsiyonel İyileştirmeler (Bonus)

### Image Processing (Pillow)
```python
from PIL import Image
from io import BytesIO
from django.core.files.uploadedfile import InMemoryUploadedFile

def optimize_image(image_field):
    """Resize and optimize uploaded image"""
    img = Image.open(image_field)
    
    # Convert RGBA to RGB
    if img.mode in ('RGBA', 'LA', 'P'):
        img = img.convert('RGB')
    
    # Resize if too large
    max_size = (1000, 1000)
    img.thumbnail(max_size, Image.Resampling.LANCZOS)
    
    # Save optimized image
    output = BytesIO()
    img.save(output, format='JPEG', quality=85, optimize=True)
    output.seek(0)
    
    return InMemoryUploadedFile(
        output, 'ImageField', 
        f"{image_field.name.split('.')[0]}.jpg",
        'image/jpeg', 
        output.getbuffer().nbytes, 
        None
    )
```

### Thumbnail Generation
```python
def create_thumbnail(image_field, size=(200, 200)):
    """Create thumbnail version"""
    img = Image.open(image_field)
    img.thumbnail(size, Image.Resampling.LANCZOS)
    # ... save as separate file
```

## ✅ Checklist
- [ ] Model'e `profile_photo` field eklendi
- [ ] Migration yapıldı (`python manage.py makemigrations && python manage.py migrate`)
- [ ] Serializer oluşturuldu (validation dahil)
- [ ] View oluşturuldu (authentication + file upload)
- [ ] URL pattern eklendi
- [ ] `Pillow` paketi yüklendi (`pip install Pillow`)
- [ ] Media files settings yapılandırıldı
- [ ] Test edildi (valid/invalid cases)
- [ ] Old photo deletion çalışıyor
- [ ] Photo URL response'da dönüyor

## 📚 Referanslar
- Django File Uploads: https://docs.djangoproject.com/en/stable/topics/http/file-uploads/
- DRF Parsers: https://www.django-rest-framework.org/api-guide/parsers/
- Pillow Documentation: https://pillow.readthedocs.io/

## 🔗 Frontend Integration Note
Mobil app bu endpoint'i şu şekilde kullanacak:
- HTTP Method: PATCH
- Header: `Authorization: Bearer {token}`
- Body: `multipart/form-data` with `profile_photo` file
- Response: JSON with `profile_photo_url`

Flutter package kullanılacak: `http` (multipart request için)
