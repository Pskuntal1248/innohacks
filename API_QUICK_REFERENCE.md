# 🎯 Quick Reference Card - API Cheat Sheet

## 🔗 Base URL
```
http://localhost:8080
```

## 🔐 Authentication
```javascript
// Login
window.location.href = 'http://localhost:8080/oauth2/authorization/google';

// Always include credentials for authenticated endpoints
fetch(url, { credentials: 'include' })
```

## 📋 Quick Endpoints

### 🔓 Public (No Auth)
```javascript
// Get all resources
GET /api/resources

// Get resource details (increments view count)
GET /api/resources/{id}/details

// Search
GET /api/resources/search?keyword=react&category=Education

// Get categories
GET /api/resources/categories

// Get comments
GET /api/resources/{id}/comments

// Download file
GET /api/resources/download/{filename}

// Increment download count
POST /api/resources/download/{id}/increment
```

### 🔒 Protected (Requires Auth)
```javascript
// Upload file
POST /api/resources
Body: FormData with file, title, description, categories

// Rate (1-5 stars, once per user)
POST /api/resources/{id}/rate
Body: { "rating": 5 }

// Comment
POST /api/resources/{id}/comments
Body: { "content": "Great resource!" }

// Toggle favorite
POST /api/resources/{id}/favorite

// Get my favorites
GET /api/resources/favorites
```

## 💡 Code Snippets

### Check if Logged In
```javascript
const isLoggedIn = async () => {
  const res = await fetch('http://localhost:8080/api/resources/favorites', {
    credentials: 'include'
  });
  return res.status === 200;
};
```

### Upload File
```javascript
const formData = new FormData();
formData.append('file', file);
formData.append('title', 'My File');
formData.append('description', 'Description');
formData.append('categories', 'Education');

fetch('http://localhost:8080/api/resources', {
  method: 'POST',
  credentials: 'include',
  body: formData
});
```

### Add Comment
```javascript
fetch(`http://localhost:8080/api/resources/${id}/comments`, {
  method: 'POST',
  credentials: 'include',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ content: 'Nice!' })
});
```

### Toggle Favorite
```javascript
const res = await fetch(
  `http://localhost:8080/api/resources/${id}/favorite`,
  { method: 'POST', credentials: 'include' }
);
const data = await res.json();
// data.favorited = true/false
// data.message = "Added to favorites" or "Removed from favorites"
```

### Rate Resource
```javascript
fetch(`http://localhost:8080/api/resources/${id}/rate`, {
  method: 'POST',
  credentials: 'include',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ rating: 5 })
});
```

## 📦 Response Examples

### Resource Object
```json
{
  "id": 1,
  "title": "React Guide",
  "description": "Learn React",
  "filePath": "abc123-file.pdf",
  "uploaderId": 5,
  "averageRating": 4.5,
  "viewCount": 120,
  "downloadCount": 45,
  "categories": [{"name": "Education", "iconEmoji": "📚"}],
  "createdAt": "2025-11-04T10:30:00"
}
```

### Resource Details
```json
{
  "id": 1,
  "title": "React Guide",
  "uploaderName": "John Doe",
  "uploaderEmail": "john@example.com",
  "averageRating": 4.5,
  "viewCount": 121,
  "commentCount": 8,
  "favoriteCount": 15,
  "isFavoritedByCurrentUser": true,
  "categories": ["Education", "Technology"]
}
```

### Comment
```json
{
  "id": 1,
  "content": "Great resource!",
  "userName": "Alice Smith",
  "userEmail": "alice@example.com",
  "createdAt": "2025-11-04T11:00:00"
}
```

### Category
```json
{
  "id": 1,
  "name": "Education",
  "description": "Educational resources",
  "iconEmoji": "📚"
}
```

## ⚠️ Important

1. **Always use `credentials: 'include'`** for authenticated requests
2. **Don't set Content-Type** for file uploads (browser sets it)
3. **Handle 401 responses** - redirect to login
4. **URL encode** search parameters
5. **Rating validation** - Must be 1-5, once per user per resource

## 🎨 Available Categories
- 📚 Education
- 🔬 Research
- 💻 Technology
- 🧪 Science
- 🎨 Arts
- 💼 Business

## 🚨 Error Codes
- **200** - Success
- **400** - Bad Request (validation error)
- **401** - Not authenticated (redirect to login)
- **404** - Not found
- **500** - Server error

## 🔄 Typical Workflows

### Resource List Page
1. Fetch `/api/resources` or `/api/resources/search`
2. Display resources with categories, ratings
3. Show login button if not authenticated

### Resource Detail Page
1. Fetch `/api/resources/{id}/details` (increments view)
2. Fetch `/api/resources/{id}/comments`
3. Show download button (increment count on click)
4. Show favorite button (toggle on click)
5. Show rating stars (submit rating)
6. Show comment form (add comment)

### Upload Page
1. Check authentication
2. Fetch categories
3. Create form with file, title, description, categories
4. Submit to `/api/resources`
5. Redirect to uploaded resource

### My Favorites Page
1. Check authentication
2. Fetch `/api/resources/favorites`
3. Display user's favorite resources

---

**For detailed docs, see FRONTEND_INTEGRATION_GUIDE.md**
