# Innohacks API Documentation for Frontend Integration

## Base URL
```
http://localhost:8080
```

## Database Connection
- **Database**: `innohacks` (PostgreSQL)
- **Connection**: Successfully connected
- **Status**: ✅ All endpoints tested and working

---

## Test Endpoints (For Frontend Development)
**Base Path**: `/api/test`

⚠️ **Important**: These endpoints bypass OAuth2 authentication for easier frontend development. Use `/api/resources` endpoints for production with Google OAuth.

---

## 📋 Endpoints Overview

### 1. **List All Resources**
Get all uploaded resources from the database.

**Endpoint**: `GET /api/test/resources`

**Example**:
```bash
curl -X GET http://localhost:8080/api/test/resources
```

**Response**:
```json
[
  {
    "id": 1,
    "title": "My First Resource",
    "description": "This is the file for ID 1.",
    "filePath": "e8a5f37e-c23e-4829-83fd-963d2390272d_test.pdf",
    "uploaderId": 1,
    "averageRating": 4.0,
    "createdAt": "2025-11-04T03:47:21.493762"
  }
]
```

---

### 2. **Get Single Resource**
Get a specific resource by ID.

**Endpoint**: `GET /api/test/resources/{id}`

**Example**:
```bash
curl -X GET http://localhost:8080/api/test/resources/1
```

**Response**: Same as single resource object above

---

### 3. **Upload a Resource**
Upload a new resource with file, title, and description.

**Endpoint**: `POST /api/test/resources`

**Parameters**:
- `file` (multipart/form-data) - The file to upload
- `title` (string) - Resource title
- `description` (string) - Resource description
- `userEmail` (optional, string) - Email of uploader (defaults to `test@example.com`)

**Example**:
```bash
curl -X POST http://localhost:8080/api/test/resources \
  -F 'title=My First Resource' \
  -F 'description=This is the file for ID 1.' \
  -F 'file=@/path/to/your/file.pdf'
```

**Response**:
```json
{
  "message": "File uploaded successfully",
  "filename": "e8a5f37e-c23e-4829-83fd-963d2390272d_test.pdf",
  "resourceId": 1,
  "resource": {
    "id": 1,
    "title": "My First Resource",
    "description": "This is the file for ID 1.",
    "filePath": "e8a5f37e-c23e-4829-83fd-963d2390272d_test.pdf",
    "uploaderId": 1,
    "averageRating": null,
    "createdAt": null
  }
}
```

---

### 4. **Rate a Resource**
Submit a rating for a resource (1-5 stars).

**Endpoint**: `POST /api/test/resources/{id}/rate`

**Parameters**:
- `userEmail` (optional, query param) - Email of the rater (defaults to `test@example.com`)

**Request Body** (JSON):
```json
{
  "rating": 5
}
```

**Example**:
```bash
curl -X POST 'http://localhost:8080/api/test/resources/1/rate?userEmail=user@example.com' \
  -H 'Content-Type: application/json' \
  -d '{"rating": 5}'
```

**Response**:
```json
{
  "message": "Rating submitted successfully",
  "resource": {
    "id": 1,
    "title": "My First Resource",
    "description": "This is the file for ID 1.",
    "filePath": "e8a5f37e-c23e-4829-83fd-963d2390272d_test.pdf",
    "uploaderId": 1,
    "averageRating": 5.0,
    "createdAt": "2025-11-04T03:47:21.493762"
  }
}
```

**Error Response** (if user already rated):
```
You have already rated this resource.
```
Status Code: `400 Bad Request`

---

### 5. **Download a File**
Download an uploaded file by filename.

**Endpoint**: `GET /api/test/resources/download/{filename}`

**Example**:
```bash
curl -O http://localhost:8080/api/test/resources/download/e8a5f37e-c23e-4829-83fd-963d2390272d_test.pdf
```

**Response**: File download with appropriate headers

---

### 6. **List All Users**
Get all registered users.

**Endpoint**: `GET /api/test/users`

**Example**:
```bash
curl -X GET http://localhost:8080/api/test/users
```

**Response**:
```json
[
  {
    "id": 1,
    "name": "Test User",
    "email": "test@example.com",
    "createdAt": "2025-11-04T03:47:21.477597"
  }
]
```

---

### 7. **Create a User**
Create a new user (auto-created during upload/rating if not exists).

**Endpoint**: `POST /api/test/users`

**Parameters**:
- `email` (string) - User email
- `name` (string) - User name

**Example**:
```bash
curl -X POST http://localhost:8080/api/test/users \
  -F 'email=newuser@example.com' \
  -F 'name=New User'
```

**Response**:
```json
{
  "id": 4,
  "name": "New User",
  "email": "newuser@example.com",
  "createdAt": "2025-11-04T04:00:00.000000"
}
```

---

## 🎯 Frontend Integration Examples

### React/JavaScript Example

#### Fetch All Resources
```javascript
const fetchResources = async () => {
  const response = await fetch('http://localhost:8080/api/test/resources');
  const data = await response.json();
  return data;
};
```

#### Upload a Resource
```javascript
const uploadResource = async (file, title, description) => {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('title', title);
  formData.append('description', description);
  
  const response = await fetch('http://localhost:8080/api/test/resources', {
    method: 'POST',
    body: formData,
  });
  
  const data = await response.json();
  return data;
};
```

#### Rate a Resource
```javascript
const rateResource = async (resourceId, rating, userEmail = 'test@example.com') => {
  const response = await fetch(
    `http://localhost:8080/api/test/resources/${resourceId}/rate?userEmail=${userEmail}`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ rating }),
    }
  );
  
  const data = await response.json();
  return data;
};
```

#### Download a File
```javascript
const downloadFile = (filename) => {
  window.open(`http://localhost:8080/api/test/resources/download/${filename}`, '_blank');
};
```

---

## 🔒 Production Endpoints (OAuth2 Required)

For production, use these endpoints which require Google OAuth2 authentication:

- `GET /api/resources` - List all resources (public)
- `POST /api/resources` - Upload resource (requires login)
- `GET /api/resources/download/{filename}` - Download file (public)
- `POST /api/resources/{id}/rate` - Rate resource (requires login)

**Authentication Flow**:
1. User clicks "Login with Google"
2. Redirect to `/oauth2/authorization/google`
3. After successful login, user is redirected to your frontend
4. Session cookie (JSESSIONID) is automatically managed by the browser

---

## ✅ Test Results Summary

All endpoints have been tested and are working correctly:

1. ✅ **GET /api/test/resources** - Returns list of all resources
2. ✅ **GET /api/test/resources/{id}** - Returns single resource
3. ✅ **POST /api/test/resources** - File upload working
4. ✅ **POST /api/test/resources/{id}/rate** - Rating system working
5. ✅ **GET /api/test/resources/download/{filename}** - File download working
6. ✅ **GET /api/test/users** - User listing working
7. ✅ **POST /api/test/users** - User creation working
8. ✅ **Database triggers** - Average rating calculation working correctly
9. ✅ **Duplicate rating prevention** - Working as expected

---

## 📊 Database Schema

### Resources Table
- `id` (BIGSERIAL, Primary Key)
- `title` (VARCHAR, NOT NULL)
- `description` (TEXT)
- `file_path` (VARCHAR, NOT NULL)
- `uploader_id` (BIGINT, NOT NULL)
- `average_rating` (DOUBLE, calculated by trigger)
- `created_at` (TIMESTAMP, auto-generated)

### Users Table
- `id` (BIGSERIAL, Primary Key)
- `name` (VARCHAR, NOT NULL)
- `email` (VARCHAR, UNIQUE, NOT NULL)
- `created_at` (TIMESTAMP, auto-generated)

### Ratings Table
- `id` (BIGSERIAL, Primary Key)
- `rating_value` (INTEGER, NOT NULL, 1-5)
- `user_id` (BIGINT, NOT NULL)
- `resource_id` (BIGINT, NOT NULL)
- `created_at` (TIMESTAMP, auto-generated)
- **UNIQUE constraint**: (user_id, resource_id) - prevents duplicate ratings

---

## 🚀 Quick Start Commands

```bash
# Start the Spring Boot application
cd /Users/testuser/Desktop/demo\ 2
./mvnw spring-boot:run

# Test the API
curl -X GET http://localhost:8080/api/test/resources

# Upload a file
curl -X POST http://localhost:8080/api/test/resources \
  -F 'title=My Resource' \
  -F 'description=Description here' \
  -F 'file=@/path/to/file.pdf'

# Rate a resource
curl -X POST 'http://localhost:8080/api/test/resources/1/rate?userEmail=user@example.com' \
  -H 'Content-Type: application/json' \
  -d '{"rating": 5}'
```

---

## ⚠️ Important Notes

1. **CORS is configured** for `http://localhost:3000` - your React app will work without issues
2. **File uploads** are stored in the `uploads/` directory
3. **Test endpoints** should be disabled/removed in production
4. **Average ratings** are automatically calculated by database triggers
5. **Users can only rate once** per resource (enforced by database constraint)
6. **Passwords** in `application.properties` should be secured in production

---

## 🐛 Common Issues & Solutions

### Issue: Port 8080 already in use
```bash
# Kill the process
kill -9 $(lsof -ti:8080)
```

### Issue: Database connection failed
- Verify PostgreSQL is running
- Check database name is `innohacks`
- Verify credentials in `application.properties`

### Issue: File upload fails
- Check `uploads/` directory exists and has write permissions
- Verify file size limits in Spring Boot configuration

---

## 📞 Support

If you encounter any issues:
1. Check the application logs in the terminal
2. Verify database connection
3. Ensure all dependencies are installed (`./mvnw clean install`)
4. Test endpoints using the curl commands above

---

4. Test endpoints using the curl commands above

---

## 🏷️ Tag Management Endpoints
**Base Path**: `/api/tags`

Tags allow you to categorize and organize resources. Tags can be predefined (system-wide) or custom (user-created).

### 1. **Get All Tags** (Public)
Get all available tags from the system.

**Endpoint**: `GET /api/tags`

**Example**:
```bash
curl -X GET http://localhost:8080/api/tags
```

**Response**:
```json
[
  {
    "id": 1,
    "name": "Technology",
    "description": "Technology-related resources",
    "isPredefined": true,
    "usageCount": 45
  },
  {
    "id": 2,
    "name": "Education",
    "description": "Educational materials and resources",
    "isPredefined": true,
    "usageCount": 32
  }
]
```

---

### 2. **Get Predefined Tags** (Public)
Get only system predefined tags.

**Endpoint**: `GET /api/tags/predefined`

**Example**:
```bash
curl -X GET http://localhost:8080/api/tags/predefined
```

**Response**: Same structure as /api/tags but only predefined tags

---

### 3. **Get Popular Tags** (Public)
Get tags sorted by usage count (most used first).

**Endpoint**: `GET /api/tags/popular?limit=20`

**Query Parameters**:
- `limit` (optional, default: 20) - Maximum number of tags to return

**Example**:
```bash
curl -X GET "http://localhost:8080/api/tags/popular?limit=10"
```

**Response**: Same structure as /api/tags, sorted by usageCount

---

### 4. **Search Tags** (Public)
Search for tags by keyword (case-insensitive).

**Endpoint**: `GET /api/tags/search?keyword=tech`

**Query Parameters**:
- `keyword` (required) - Search term for tag names

**Example**:
```bash
curl -X GET "http://localhost:8080/api/tags/search?keyword=science"
```

**Response**: Same structure as /api/tags, filtered by keyword

---

### 5. **Get Tag Details** (Public)
Get details for a specific tag.

**Endpoint**: `GET /api/tags/{id}`

**Example**:
```bash
curl -X GET http://localhost:8080/api/tags/1
```

**Response**:
```json
{
  "id": 1,
  "name": "Technology",
  "description": "Technology-related resources",
  "isPredefined": true,
  "usageCount": 45
}
```

---

### 6. **Get Resources by Tag** (Public)
Get all resources associated with a specific tag.

**Endpoint**: `GET /api/tags/{tagId}/resources`

**Example**:
```bash
curl -X GET http://localhost:8080/api/tags/1/resources
```

**Response**:
```json
[
  {
    "id": 5,
    "title": "Introduction to AI",
    "description": "A comprehensive guide to artificial intelligence",
    "filePath": "abc123_ai_guide.pdf",
    "uploaderId": 2,
    "averageRating": 4.5,
    "viewCount": 120,
    "downloadCount": 45
  }
]
```

---

### 7. **Get Tags for Resource** (Public)
Get all tags associated with a specific resource.

**Endpoint**: `GET /api/resources/{resourceId}/tags`

**Example**:
```bash
curl -X GET http://localhost:8080/api/resources/5/tags
```

**Response**:
```json
[
  {
    "id": 1,
    "name": "Technology",
    "description": "Technology-related resources",
    "isPredefined": true,
    "usageCount": 45
  },
  {
    "id": 5,
    "name": "AI/ML",
    "description": "Artificial Intelligence and Machine Learning",
    "isPredefined": true,
    "usageCount": 28
  }
]
```

---

### 8. **Create Custom Tag** (🔒 Requires Authentication)
Create a new custom tag (for logged-in users only).

**Endpoint**: `POST /api/tags`

**Authentication**: Requires Google OAuth2 login

**Request Body**:
```json
{
  "name": "My Custom Tag",
  "description": "Description of my custom tag"
}
```

**Example**:
```bash
curl -X POST http://localhost:8080/api/tags \
  -H "Content-Type: application/json" \
  -H "Cookie: JSESSIONID=your_session_id" \
  -d '{
    "name": "Web Development",
    "description": "Resources about web development"
  }'
```

**Response**:
```json
{
  "id": 25,
  "name": "Web Development",
  "description": "Resources about web development",
  "isPredefined": false,
  "usageCount": 0
}
```

**Error Responses**:
- `401`: Not authenticated
- `409`: Tag already exists
- `400`: Tag name is empty

---

### 9. **Get My Tags** (🔒 Requires Authentication)
Get all tags created by the currently logged-in user.

**Endpoint**: `GET /api/tags/my-tags`

**Authentication**: Requires Google OAuth2 login

**Example**:
```bash
curl -X GET http://localhost:8080/api/tags/my-tags \
  -H "Cookie: JSESSIONID=your_session_id"
```

**Response**: Same structure as /api/tags, only user-created tags

---

### 10. **Delete Custom Tag** (🔒 Requires Authentication)
Delete a custom tag (only the creator can delete their own tags).

**Endpoint**: `DELETE /api/tags/{id}`

**Authentication**: Requires Google OAuth2 login

**Example**:
```bash
curl -X DELETE http://localhost:8080/api/tags/25 \
  -H "Cookie: JSESSIONID=your_session_id"
```

**Response**:
```json
"Tag deleted successfully"
```

**Error Responses**:
- `401`: Not authenticated
- `403`: Cannot delete predefined tags or tags created by others
- `404`: Tag not found

---

## 🏷️ Tag Usage Examples

### Frontend Integration Example (React)

```javascript
// Get all popular tags
const getPopularTags = async () => {
  const response = await fetch('http://localhost:8080/api/tags/popular?limit=10');
  const tags = await response.json();
  return tags;
};

// Search tags
const searchTags = async (keyword) => {
  const response = await fetch(`http://localhost:8080/api/tags/search?keyword=${keyword}`);
  const tags = await response.json();
  return tags;
};

// Get resources by tag
const getResourcesByTag = async (tagId) => {
  const response = await fetch(`http://localhost:8080/api/tags/${tagId}/resources`);
  const resources = await response.json();
  return resources;
};

// Create custom tag (requires authentication)
const createTag = async (tagData) => {
  const response = await fetch('http://localhost:8080/api/tags', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    credentials: 'include', // Important for OAuth session
    body: JSON.stringify(tagData)
  });
  
  if (response.status === 401) {
    // Redirect to login
    window.location.href = 'http://localhost:8080/oauth2/authorization/google';
    return;
  }
  
  return await response.json();
};
```

---

**Last Updated**: November 4, 2025
**Database**: innohacks (PostgreSQL)
**Backend**: Spring Boot 3.5.7
**Java Version**: 24.0.2

```
