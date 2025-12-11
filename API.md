# NGP Mobile API Documentation

## Overview

This document describes the REST API endpoints for the NGP (Next Generation Person) Mobile Application. All endpoints require JWT authentication unless otherwise specified.

**Base URL:** `https://ngp.teknolikya.com.tr/api/`

**Authentication:** JWT Bearer Token

---

## Table of Contents

1. [Authentication](#authentication)
2. [Student Dashboard](#student-dashboard)
3. [Student Assignments](#student-assignments)
4. [Student Courses](#student-courses)
5. [Course Lessons](#course-lessons)
6. [Lesson Detail](#lesson-detail)
7. [Error Handling](#error-handling)

---

## Authentication

### Obtain JWT Token

**Endpoint:** `POST /api/token/`

**Description:** Login and obtain JWT access and refresh tokens.

**Request Body:**
```json
{
  "username": "student123",
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

**Usage:**
- Use the `access` token in the `Authorization` header for all API requests
- Header format: `Authorization: Bearer <access_token>`
- Access token is valid for 1 day
- Refresh token is valid for 7 days

---

### Refresh JWT Token

**Endpoint:** `POST /api/token/refresh/`

**Description:** Obtain a new access token using a refresh token.

**Request Body:**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

**Response (200 OK):**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

---

### Verify JWT Token

**Endpoint:** `POST /api/token/verify/`

**Description:** Verify if a token is valid.

**Request Body:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

**Response (200 OK):**
```json
{}
```

**Response (401 Unauthorized):**
```json
{
  "detail": "Token is invalid or expired",
  "code": "token_not_valid"
}
```

---

## Student Dashboard

### Get Student Dashboard

**Endpoint:** `GET /api/student/dashboard/`

**Description:** Get student dashboard overview with statistics and recent data.

**Authentication:** Required (JWT Bearer Token)

**Response (200 OK):**
```json
{
  "student": {
    "id": 34,
    "full_name": "Ahmet Yılmaz",
    "username": "ahmet123",
    "email": "ahmet@example.com"
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

---

## Student Assignments

### Get Student Assignments

**Endpoint:** `GET /api/student/assignments/`

**Description:** Get all homework assignments for the authenticated student.

**Authentication:** Required (JWT Bearer Token)

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | string | Filter by status: `pending`, `submitted`, `graded`, `late`, `missing` |
| `course_id` | integer | Filter by course ID |
| `is_overdue` | boolean | Filter overdue assignments: `true` or `false` |

**Example Request:**
```
GET /api/student/assignments/?status=pending&is_overdue=false
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "count": 10,
  "assignments": [
    {
      "id": 123,
      "title": "Math Homework 1",
      "description": "Complete exercises 1-10 from the textbook",
      "homework_type": "Assignment",
      "difficulty": "Medium",
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
      "feedback": null,
      "assigned_date": "2025-12-01T10:00:00Z",
      "is_seen": true
    },
    {
      "id": 124,
      "title": "Science Project",
      "description": "Create a presentation about solar system",
      "homework_type": "Project",
      "difficulty": "Hard",
      "due_date": "2025-12-25",
      "status": "submitted",
      "status_display": "Teslim Edildi",
      "is_overdue": false,
      "days_remaining": 5,
      "course_name": "Science 101",
      "lesson_name": "Astronomy",
      "submission_date": "2025-12-20T14:30:00Z",
      "has_submission": true,
      "grade": {
        "score": 85,
        "max_score": 100,
        "percentage": 85.0,
        "graded_date": "2025-12-21T10:00:00Z"
      },
      "feedback": "Great work! Well organized presentation.",
      "assigned_date": "2025-12-01T10:00:00Z",
      "is_seen": true
    }
  ]
}
```

**Homework Types:**
- `assignment`: Normal homework
- `project`: Long-term project
- `research`: Research assignment
- `practice`: Practice exercises
- `quiz`: Quiz/test
- `reading`: Reading assignment
- `presentation`: Presentation

**Difficulty Levels:**
- `easy`: Easy
- `medium`: Medium
- `hard`: Hard

**Status Values:**
- `pending`: Not yet submitted
- `submitted`: Submitted, waiting for grading
- `graded`: Graded by teacher
- `late`: Submitted after deadline
- `missing`: Not submitted and overdue

---

## Student Courses

### Get Student Courses

**Endpoint:** `GET /api/student/courses/`

**Description:** Get all courses the authenticated student is enrolled in.

**Authentication:** Required (JWT Bearer Token)

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `category` | string | Filter by course category |

**Example Request:**
```
GET /api/student/courses/?category=math
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "count": 5,
  "courses": [
    {
      "id": 10,
      "title": "Introduction to Math",
      "shortNot": "Basic algebra and geometry",
      "description": "This course covers fundamental mathematical concepts including algebra, geometry, and problem-solving techniques.",
      "lessonCategory": "math",
      "category_display": "Matematik",
      "lesson_count": 12,
      "image_url": "https://ngp.teknolikya.com.tr/media/courses/math101.jpg",
      "price": 1000.00,
      "enrollment_date": "2025-09-01T10:00:00Z"
    },
    {
      "id": 15,
      "title": "Python Programming",
      "shortNot": "Learn Python from scratch",
      "description": "Complete Python programming course for beginners. Learn syntax, data structures, and algorithms.",
      "lessonCategory": "coding",
      "category_display": "Kodlama",
      "lesson_count": 24,
      "image_url": "https://ngp.teknolikya.com.tr/media/courses/python.jpg",
      "price": 1500.00,
      "enrollment_date": "2025-09-01T10:00:00Z"
    }
  ]
}
```

**Course Categories:**
- `coding`: Kodlama
- `math`: Matematik
- `robotics`: Robotik
- `design`: Tasarım
- `electronics`: Elektronik
- `other`: Diğer

---

## Course Lessons

### Get Lessons for a Course

**Endpoint:** `GET /api/courses/<course_id>/lessons/`

**Description:** Get all lessons in a specific course. Student must be enrolled in the course.

**Authentication:** Required (JWT Bearer Token)

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `course_id` | integer | Course ID |

**Example Request:**
```
GET /api/courses/10/lessons/
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
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
      "description_preview": "Introduction to basic algebraic concepts including variables, expressions, and equations...",
      "order": 1,
      "video_url": "https://www.youtube.com/watch?v=abc123",
      "has_video": true,
      "has_attachment": false,
      "created_date": "2025-09-01T10:00:00Z"
    },
    {
      "id": 102,
      "subject": "Lesson 2: Solving Equations",
      "description_preview": "Learn how to solve linear equations step by step...",
      "order": 2,
      "video_url": null,
      "has_video": false,
      "has_attachment": true,
      "created_date": "2025-09-08T10:00:00Z"
    }
  ]
}
```

**Response (403 Forbidden):**
```json
{
  "error": "You are not enrolled in this course."
}
```

---

## Lesson Detail

### Get Lesson Details

**Endpoint:** `GET /api/lessons/<lesson_id>/`

**Description:** Get full details of a specific lesson including complete content.

**Authentication:** Required (JWT Bearer Token)

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `lesson_id` | integer | Lesson ID |

**Example Request:**
```
GET /api/lessons/101/
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response (200 OK):**
```json
{
  "id": 101,
  "subject": "Lesson 1: Basic Algebra",
  "description": "# Basic Algebra\n\n## Introduction\nAlgebra is a branch of mathematics...\n\n## Variables\nA variable is a symbol...",
  "description_preview": "Introduction to basic algebraic concepts...",
  "order": 1,
  "video_url": "https://www.youtube.com/watch?v=abc123",
  "file_url": "https://ngp.teknolikya.com.tr/media/lessons/algebra_basics.pdf",
  "has_video": true,
  "has_attachment": true,
  "homework_count": 3,
  "created_date": "2025-09-01T10:00:00Z"
}
```

**Response (403 Forbidden):**
```json
{
  "error": "You are not enrolled in the course for this lesson."
}
```

---

## Error Handling

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Resource created successfully |
| 400 | Bad Request - Invalid request data |
| 401 | Unauthorized - Authentication required or token invalid |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource not found |
| 500 | Internal Server Error - Server error |

### Error Response Format

All error responses follow this format:

```json
{
  "error": "Error message description",
  "detail": "Additional error details (optional)",
  "code": "error_code (optional)"
}
```

### Common Errors

**Authentication Required:**
```json
{
  "detail": "Authentication credentials were not provided."
}
```

**Invalid Token:**
```json
{
  "detail": "Given token not valid for any token type",
  "code": "token_not_valid",
  "messages": [
    {
      "token_class": "AccessToken",
      "token_type": "access",
      "message": "Token is invalid or expired"
    }
  ]
}
```

**Student Profile Not Found:**
```json
{
  "error": "Student profile not found for this user."
}
```

**Not Enrolled:**
```json
{
  "error": "You are not enrolled in this course."
}
```

---

## Integration Notes

### Security Best Practices

1. **Always use HTTPS** in production
2. **Store tokens securely** in mobile app (use secure storage)
3. **Refresh tokens before expiration** (implement token refresh logic)
4. **Handle 401 errors** by redirecting to login
5. **Validate all input** on client side before sending to API

### Mobile App Integration

**Flutter Example (Token Storage):**
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Save tokens
await storage.write(key: 'access_token', value: accessToken);
await storage.write(key: 'refresh_token', value: refreshToken);

// Read token
String? accessToken = await storage.read(key: 'access_token');

// Add token to requests
headers: {
  'Authorization': 'Bearer $accessToken',
  'Content-Type': 'application/json',
}
```

**Flutter Example (API Call):**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> getStudentAssignments() async {
  final accessToken = await storage.read(key: 'access_token');
  
  final response = await http.get(
    Uri.parse('https://ngp.teknolikya.com.tr/api/student/assignments/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else if (response.statusCode == 401) {
    // Token expired, refresh it
    await refreshAccessToken();
    return getStudentAssignments(); // Retry
  } else {
    throw Exception('Failed to load assignments');
  }
}
```

### Testing

**Using cURL:**
```bash
# 1. Login and get token
curl -X POST https://ngp.teknolikya.com.tr/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"student123","password":"password123"}'

# 2. Use token in API calls
curl -X GET https://ngp.teknolikya.com.tr/api/student/assignments/ \
  -H "Authorization: Bearer <your_access_token>"
```

**Using Postman:**
1. Create a new request
2. Set method to POST for login (`/api/token/`)
3. Add body with username and password
4. Copy access token from response
5. For other requests, add header: `Authorization: Bearer <token>`

---

## Support

For API support and questions:
- **Email:** info@teknolikya.com.tr
- **Documentation:** This file
- **Backend:** Django 3.2.10 with Django REST Framework

---

## Changelog

### Version 1.0.0 (2025-12-04)
- Initial API release
- JWT authentication
- Student dashboard endpoint
- Student assignments endpoint
- Student courses endpoint
- Course lessons endpoint
- Lesson detail endpoint
