# API Configuration

## Backend URL

The app is currently configured to use a placeholder API URL. Before running the app with real data, you need to update the API base URL.

### How to Update

1. Open `lib/services/api_service.dart`
2. Find the line: `static const String baseUrl = 'https://your-api-url.com/api';`
3. Replace with your actual backend API URL, for example:
   - Local development: `http://10.0.2.2:8000/api` (for Android emulator)
   - Local development: `http://localhost:8000/api` (for iOS simulator or web)
   - Production: `https://your-domain.com/api`

### API Endpoints

The app expects the following endpoints:

- **Authentication**
  - POST `/token/` - Login with username and password
    - Request: `{"username": "...", "password": "..."}`
    - Response: `{"access": "...", "refresh": "..."}`

- **Student Data**
  - GET `/student/courses/` - Get enrolled courses
  - GET `/student/assignments/` - Get assignments
  - POST `/student/assignments/{id}/complete/` - Mark assignment as complete

- **Course Data**
  - GET `/courses/{id}/lessons/` - Get lessons for a course

### Security Notes

- All API requests (except login) require authentication
- The app uses JWT Bearer token authentication
- Tokens are stored securely using flutter_secure_storage
- Always use HTTPS in production

### Testing

For testing without a backend, you can:
1. Use a mock API service like JSON Server or MockAPI
2. Create a test server with the expected endpoints
3. Use the app's UI to see the layout and flow (it will show "no data" states)
