# 🚀 Frontend Integration Guide - Resource Sharing Platform API

**Last Updated:** November 4, 2025  
**API Version:** 1.0  
**Base URL:** `http://localhost:8080`

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Authentication](#authentication)
3. [API Endpoints Reference](#api-endpoints-reference)
4. [Request/Response Examples](#requestresponse-examples)
5. [Error Handling](#error-handling)
6. [Data Models](#data-models)
7. [Testing & Development](#testing--development)
8. [Common Workflows](#common-workflows)

---

## 🚀 Quick Start

### Prerequisites
- Backend running at `http://localhost:8080`
- Frontend running at `http://localhost:3000`
- CORS is already configured for `localhost:3000`

### Important Notes
1. **Session-based Authentication:** Uses cookies (JSESSIONID)
2. **CORS:** Already enabled for your frontend
3. **Content-Type:** Use `application/json` for JSON requests
4. **File Uploads:** Use `multipart/form-data`

---

## 🔐 Authentication

### OAuth 2.0 Flow (Google)

#### 1. Redirect User to Login
```javascript
// Redirect to this URL to start OAuth flow
window.location.href = 'http://localhost:8080/oauth2/authorization/google';
```

#### 2. Handle Callback
After successful login, user is redirected to `http://localhost:3000` with a session cookie automatically set.

#### 3. Check Authentication Status
```javascript
// Check if user is logged in
fetch('http://localhost:8080/api/resources/favorites', {
  credentials: 'include' // Important: sends cookies
})
.then(response => {
  if (response.status === 200) {
    console.log('User is authenticated');
  } else if (response.status === 401) {
    console.log('User is not authenticated');
  }
});
```

#### 4. Logout
```javascript
// Logout endpoint (if implemented) or clear session
window.location.href = 'http://localhost:8080/logout';
```

### Important: Always Include Credentials
```javascript
// For fetch API
fetch(url, {
  credentials: 'include' // This sends cookies with request
});

// For axios
axios.defaults.withCredentials = true;
```

---

## 📚 API Endpoints Reference

### 🔓 Public Endpoints (No Authentication Required)

#### 1. Get All Resources
```
GET /api/resources
```
**Description:** Get list of all resources  
**Auth Required:** No  
**Response:** Array of Resource objects

**Example Request:**
```javascript
fetch('http://localhost:8080/api/resources')
  .then(response => response.json())
  .then(data => console.log(data));
```

**Example Response:**
```json
[
  {
    "id": 1,
    "title": "Introduction to React",
    "description": "A beginner's guide to React",
    "filePath": "abc123-react-guide.pdf",
    "uploaderId": 5,
    "averageRating": 4.5,
    "viewCount": 120,
    "downloadCount": 45,
    "categories": [],
    "comments": [],
    "favorites": [],
    "createdAt": "2025-11-04T10:30:00"
  }
]
```

---

#### 2. Get Resource Details
```
GET /api/resources/{id}/details
```
**Description:** Get detailed information about a specific resource (increments view count)  
**Auth Required:** No (but shows favorite status if authenticated)  
**Path Parameters:** 
- `id` (Long) - Resource ID

**Example Request:**
```javascript
fetch('http://localhost:8080/api/resources/1/details', {
  credentials: 'include' // Include if you want favorite status
})
  .then(response => response.json())
  .then(data => console.log(data));
```

**Example Response:**
```json
{
  "id": 1,
  "title": "Introduction to React",
  "description": "A beginner's guide to React",
  "filePath": "abc123-react-guide.pdf",
  "uploaderId": 5,
  "uploaderName": "John Doe",
  "uploaderEmail": "john@example.com",
  "averageRating": 4.5,
  "viewCount": 121,
  "downloadCount": 45,
  "categories": ["Education", "Technology"],
  "commentCount": 8,
  "favoriteCount": 15,
  "isFavoritedByCurrentUser": true,
  "createdAt": "2025-11-04T10:30:00"
}
```

---

#### 3. Get Comments for Resource
```
GET /api/resources/{id}/comments
```
**Description:** Get all comments for a resource  
**Auth Required:** No  
**Path Parameters:**
- `id` (Long) - Resource ID

**Example Request:**
```javascript
fetch('http://localhost:8080/api/resources/1/comments')
  .then(response => response.json())
  .then(data => console.log(data));
```

**Example Response:**
```json
[
  {
    "id": 1,
    "content": "Great resource! Very helpful.",
    "userName": "Alice Smith",
    "userEmail": "alice@example.com",
    "createdAt": "2025-11-04T11:00:00"
  },
  {
    "id": 2,
    "content": "Thanks for sharing!",
    "userName": "Bob Johnson",
    "userEmail": "bob@example.com",
    "createdAt": "2025-11-04T11:15:00"
  }
]
```

---

#### 4. Search Resources
```
GET /api/resources/search?keyword={keyword}&category={category}
```
**Description:** Search resources by keyword and/or category  
**Auth Required:** No  
**Query Parameters:**
- `keyword` (String, optional) - Search in title and description
- `category` (String, optional) - Filter by category name

**Example Request:**
```javascript
// Search by keyword
fetch('http://localhost:8080/api/resources/search?keyword=react')
  .then(response => response.json())
  .then(data => console.log(data));

// Search by category
fetch('http://localhost:8080/api/resources/search?category=Education')
  .then(response => response.json())
  .then(data => console.log(data));

// Search by both
fetch('http://localhost:8080/api/resources/search?keyword=react&category=Education')
  .then(response => response.json())
  .then(data => console.log(data));
```

**Example Response:**
```json
[
  {
    "id": 1,
    "title": "Introduction to React",
    "description": "A beginner's guide to React",
    "filePath": "abc123-react-guide.pdf",
    "uploaderId": 5,
    "averageRating": 4.5,
    "viewCount": 120,
    "downloadCount": 45,
    "categories": [
      {
        "id": 1,
        "name": "Education",
        "description": "Educational resources",
        "iconEmoji": "📚"
      }
    ],
    "comments": [],
    "favorites": [],
    "createdAt": "2025-11-04T10:30:00"
  }
]
```

---

#### 5. Get All Categories
```
GET /api/resources/categories
```
**Description:** Get list of all available categories  
**Auth Required:** No

**Example Request:**
```javascript
fetch('http://localhost:8080/api/resources/categories')
  .then(response => response.json())
  .then(data => console.log(data));
```

**Example Response:**
```json
[
  {
    "id": 1,
    "name": "Education",
    "description": "Educational resources and materials",
    "iconEmoji": "📚",
    "createdAt": "2025-11-04T00:00:00"
  },
  {
    "id": 2,
    "name": "Research",
    "description": "Research papers and publications",
    "iconEmoji": "🔬",
    "createdAt": "2025-11-04T00:00:00"
  },
  {
    "id": 3,
    "name": "Technology",
    "description": "Tech tutorials and guides",
    "iconEmoji": "💻",
    "createdAt": "2025-11-04T00:00:00"
  },
  {
    "id": 4,
    "name": "Science",
    "description": "Scientific resources",
    "iconEmoji": "🧪",
    "createdAt": "2025-11-04T00:00:00"
  },
  {
    "id": 5,
    "name": "Arts",
    "description": "Creative and artistic content",
    "iconEmoji": "🎨",
    "createdAt": "2025-11-04T00:00:00"
  },
  {
    "id": 6,
    "name": "Business",
    "description": "Business and entrepreneurship",
    "iconEmoji": "💼",
    "createdAt": "2025-11-04T00:00:00"
  }
]
```

---

#### 6. Download File
```
GET /api/resources/download/{filename}
```
**Description:** Download a file  
**Auth Required:** No  
**Path Parameters:**
- `filename` (String) - The filename from resource.filePath

**Example Request:**
```javascript
// Option 1: Direct link in HTML
<a href="http://localhost:8080/api/resources/download/abc123-react-guide.pdf" 
   download>Download</a>

// Option 2: JavaScript download
fetch('http://localhost:8080/api/resources/download/abc123-react-guide.pdf')
  .then(response => response.blob())
  .then(blob => {
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'react-guide.pdf';
    a.click();
  });
```

---

#### 7. Increment Download Count
```
POST /api/resources/download/{id}/increment
```
**Description:** Increment the download count for a resource  
**Auth Required:** No  
**Path Parameters:**
- `id` (Long) - Resource ID

**Example Request:**
```javascript
fetch('http://localhost:8080/api/resources/download/1/increment', {
  method: 'POST'
})
  .then(response => response.text())
  .then(message => console.log(message));
```

**Example Response:**
```
Download count incremented
```

---

### 🔒 Protected Endpoints (Authentication Required)

**Important:** All protected endpoints require `credentials: 'include'` in fetch requests!

#### 8. Upload Resource
```
POST /api/resources
```
**Description:** Upload a new resource file  
**Auth Required:** ✅ Yes  
**Content-Type:** `multipart/form-data`  
**Request Body:**
- `file` (File) - The file to upload
- `title` (String) - Resource title
- `description` (String) - Resource description
- `categories` (Array<String>, optional) - List of category names

**Example Request:**
```javascript
const formData = new FormData();
formData.append('file', fileInput.files[0]);
formData.append('title', 'My Awesome Resource');
formData.append('description', 'This is a great resource for learning');
formData.append('categories', 'Education');
formData.append('categories', 'Technology');

fetch('http://localhost:8080/api/resources', {
  method: 'POST',
  credentials: 'include', // Important!
  body: formData
  // Do NOT set Content-Type header, browser will set it automatically
})
  .then(response => response.text())
  .then(message => console.log(message));
```

**Example Response:**
```
File uploaded successfully: abc123-my-file.pdf
```

**React Example:**
```jsx
const handleUpload = async (file, title, description, categories) => {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('title', title);
  formData.append('description', description);
  
  // Add multiple categories
  categories.forEach(cat => {
    formData.append('categories', cat);
  });

  try {
    const response = await fetch('http://localhost:8080/api/resources', {
      method: 'POST',
      credentials: 'include',
      body: formData
    });
    
    if (response.ok) {
      const message = await response.text();
      console.log('Success:', message);
    } else if (response.status === 401) {
      console.log('Please login first');
    }
  } catch (error) {
    console.error('Error:', error);
  }
};
```

---

#### 9. Rate Resource
```
POST /api/resources/{id}/rate
```
**Description:** Rate a resource (1-5 stars, one rating per user)  
**Auth Required:** ✅ Yes  
**Path Parameters:**
- `id` (Long) - Resource ID
**Request Body:**
```json
{
  "rating": 5
}
```

**Example Request:**
```javascript
fetch('http://localhost:8080/api/resources/1/rate', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ rating: 5 })
})
  .then(response => response.text())
  .then(message => console.log(message));
```

**Example Response (Success):**
```
Rating submitted.
```

**Example Response (Already Rated):**
```
Status: 400 Bad Request
Body: You have already rated this resource.
```

**Validation:**
- Rating must be between 1 and 5
- User can only rate each resource once
- Average rating is automatically calculated by database trigger

---

#### 10. Add Comment
```
POST /api/resources/{id}/comments
```
**Description:** Add a comment to a resource  
**Auth Required:** ✅ Yes  
**Path Parameters:**
- `id` (Long) - Resource ID
**Request Body:**
```json
{
  "content": "Your comment text here"
}
```

**Example Request:**
```javascript
fetch('http://localhost:8080/api/resources/1/comments', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ 
    content: 'Great resource! Very helpful for beginners.' 
  })
})
  .then(response => response.text())
  .then(message => console.log(message));
```

**Example Response:**
```
Comment added successfully
```

**React Example:**
```jsx
const handleAddComment = async (resourceId, commentText) => {
  try {
    const response = await fetch(
      `http://localhost:8080/api/resources/${resourceId}/comments`,
      {
        method: 'POST',
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ content: commentText })
      }
    );
    
    if (response.ok) {
      console.log('Comment added!');
      // Refresh comments list
      fetchComments(resourceId);
    } else if (response.status === 401) {
      alert('Please login to comment');
    }
  } catch (error) {
    console.error('Error:', error);
  }
};
```

---

#### 11. Toggle Favorite
```
POST /api/resources/{id}/favorite
```
**Description:** Add or remove resource from favorites (toggle)  
**Auth Required:** ✅ Yes  
**Path Parameters:**
- `id` (Long) - Resource ID

**Example Request:**
```javascript
fetch('http://localhost:8080/api/resources/1/favorite', {
  method: 'POST',
  credentials: 'include'
})
  .then(response => response.json())
  .then(data => console.log(data));
```

**Example Response (Added):**
```json
{
  "favorited": true,
  "message": "Added to favorites"
}
```

**Example Response (Removed):**
```json
{
  "favorited": false,
  "message": "Removed from favorites"
}
```

**React Example:**
```jsx
const handleToggleFavorite = async (resourceId) => {
  try {
    const response = await fetch(
      `http://localhost:8080/api/resources/${resourceId}/favorite`,
      {
        method: 'POST',
        credentials: 'include'
      }
    );
    
    const data = await response.json();
    
    if (data.favorited) {
      console.log('Added to favorites ⭐');
    } else {
      console.log('Removed from favorites ☆');
    }
    
    // Update UI
    setIsFavorited(data.favorited);
  } catch (error) {
    console.error('Error:', error);
  }
};
```

---

#### 12. Get User's Favorites
```
GET /api/resources/favorites
```
**Description:** Get all resources favorited by the current user  
**Auth Required:** ✅ Yes

**Example Request:**
```javascript
fetch('http://localhost:8080/api/resources/favorites', {
  credentials: 'include'
})
  .then(response => response.json())
  .then(favorites => console.log(favorites));
```

**Example Response:**
```json
[
  {
    "id": 1,
    "title": "Introduction to React",
    "description": "A beginner's guide to React",
    "filePath": "abc123-react-guide.pdf",
    "uploaderId": 5,
    "averageRating": 4.5,
    "viewCount": 120,
    "downloadCount": 45,
    "categories": [],
    "comments": [],
    "favorites": [],
    "createdAt": "2025-11-04T10:30:00"
  }
]
```

---

### 🧪 Test Endpoints (For Development Only)

**⚠️ WARNING: These endpoints should be DISABLED in production!**

These endpoints don't require authentication and are useful during development.

#### Test: Create User
```
POST /api/test/users?email={email}&name={name}
```

#### Test: Upload Resource
```
POST /api/test/resources
```

#### Test: Rate Resource
```
POST /api/test/resources/{id}/rate?userEmail={email}
```

---

## 📦 Data Models

### Resource
```typescript
interface Resource {
  id: number;
  title: string;
  description: string;
  filePath: string;
  uploaderId: number;
  averageRating: number | null;
  viewCount: number;
  downloadCount: number;
  categories: Category[];
  comments: Comment[];
  favorites: Favorite[];
  createdAt: string; // ISO 8601 format
}
```

### ResourceDetailResponse
```typescript
interface ResourceDetailResponse {
  id: number;
  title: string;
  description: string;
  filePath: string;
  uploaderId: number;
  uploaderName: string;
  uploaderEmail: string;
  averageRating: number | null;
  viewCount: number;
  downloadCount: number;
  categories: string[]; // Array of category names
  commentCount: number;
  favoriteCount: number;
  isFavoritedByCurrentUser: boolean; // Only if authenticated
  createdAt: string;
}
```

### Category
```typescript
interface Category {
  id: number;
  name: string;
  description: string;
  iconEmoji: string;
  createdAt: string;
}
```

### Comment
```typescript
interface Comment {
  id: number;
  content: string;
  resource: Resource; // Full resource object in some responses
  user: User;         // Full user object in some responses
  createdAt: string;
}
```

### CommentResponse
```typescript
interface CommentResponse {
  id: number;
  content: string;
  userName: string;
  userEmail: string;
  createdAt: string;
}
```

### RatingRequest
```typescript
interface RatingRequest {
  rating: number; // Must be 1-5
}
```

### CommentRequest
```typescript
interface CommentRequest {
  content: string;
}
```

---

## ⚠️ Error Handling

### HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Process response normally |
| 400 | Bad Request | Show validation error to user |
| 401 | Unauthorized | Redirect to login |
| 404 | Not Found | Show "Resource not found" |
| 500 | Server Error | Show generic error message |

### Example Error Handling

```javascript
const handleApiCall = async (url, options) => {
  try {
    const response = await fetch(url, {
      credentials: 'include',
      ...options
    });
    
    if (response.status === 200) {
      return await response.json();
    } else if (response.status === 401) {
      // Not authenticated
      window.location.href = '/login';
      throw new Error('Please login first');
    } else if (response.status === 400) {
      // Validation error
      const errorMessage = await response.text();
      throw new Error(errorMessage);
    } else if (response.status === 404) {
      throw new Error('Resource not found');
    } else if (response.status === 500) {
      throw new Error('Server error. Please try again later.');
    }
  } catch (error) {
    console.error('API Error:', error);
    throw error;
  }
};
```

---

## 🧪 Testing & Development

### Using Browser Console

```javascript
// Test public endpoint
fetch('http://localhost:8080/api/resources')
  .then(r => r.json())
  .then(console.log);

// Test authenticated endpoint
fetch('http://localhost:8080/api/resources/favorites', {
  credentials: 'include'
})
  .then(r => r.json())
  .then(console.log);
```

### Using Postman

1. **For public endpoints:** Just send the request
2. **For authenticated endpoints:**
   - First, login via browser at `http://localhost:8080/oauth2/authorization/google`
   - Get JSESSIONID cookie from browser DevTools
   - In Postman, add Cookie header: `Cookie: JSESSIONID=your-session-id`

### Test User Accounts

For development, you can use `/api/test/*` endpoints to create test data without OAuth.

---

## 🔄 Common Workflows

### 1. User Login Flow

```javascript
// Step 1: Check if user is logged in
const checkAuth = async () => {
  try {
    const response = await fetch(
      'http://localhost:8080/api/resources/favorites',
      { credentials: 'include' }
    );
    return response.status === 200;
  } catch {
    return false;
  }
};

// Step 2: Redirect to login if not authenticated
const requireAuth = async () => {
  const isAuthenticated = await checkAuth();
  if (!isAuthenticated) {
    window.location.href = 'http://localhost:8080/oauth2/authorization/google';
  }
};

// Step 3: Use in your components
useEffect(() => {
  requireAuth();
}, []);
```

### 2. Display Resource List with Filters

```javascript
const ResourceList = () => {
  const [resources, setResources] = useState([]);
  const [keyword, setKeyword] = useState('');
  const [category, setCategory] = useState('');

  const fetchResources = async () => {
    let url = 'http://localhost:8080/api/resources';
    
    if (keyword || category) {
      url = `http://localhost:8080/api/resources/search?`;
      if (keyword) url += `keyword=${encodeURIComponent(keyword)}&`;
      if (category) url += `category=${encodeURIComponent(category)}`;
    }
    
    const response = await fetch(url);
    const data = await response.json();
    setResources(data);
  };

  useEffect(() => {
    fetchResources();
  }, [keyword, category]);

  return (
    <div>
      <input 
        type="text" 
        value={keyword}
        onChange={(e) => setKeyword(e.target.value)}
        placeholder="Search..."
      />
      <select 
        value={category}
        onChange={(e) => setCategory(e.target.value)}
      >
        <option value="">All Categories</option>
        <option value="Education">Education</option>
        <option value="Technology">Technology</option>
        {/* ... */}
      </select>
      
      {resources.map(resource => (
        <ResourceCard key={resource.id} resource={resource} />
      ))}
    </div>
  );
};
```

### 3. Resource Detail Page

```javascript
const ResourceDetail = ({ resourceId }) => {
  const [resource, setResource] = useState(null);
  const [comments, setComments] = useState([]);
  const [newComment, setNewComment] = useState('');

  // Fetch resource details
  useEffect(() => {
    fetch(`http://localhost:8080/api/resources/${resourceId}/details`, {
      credentials: 'include'
    })
      .then(r => r.json())
      .then(setResource);
    
    // Fetch comments
    fetch(`http://localhost:8080/api/resources/${resourceId}/comments`)
      .then(r => r.json())
      .then(setComments);
  }, [resourceId]);

  // Add comment
  const handleAddComment = async () => {
    await fetch(`http://localhost:8080/api/resources/${resourceId}/comments`, {
      method: 'POST',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ content: newComment })
    });
    
    setNewComment('');
    // Refresh comments
    const response = await fetch(
      `http://localhost:8080/api/resources/${resourceId}/comments`
    );
    setComments(await response.json());
  };

  // Toggle favorite
  const handleToggleFavorite = async () => {
    const response = await fetch(
      `http://localhost:8080/api/resources/${resourceId}/favorite`,
      {
        method: 'POST',
        credentials: 'include'
      }
    );
    const data = await response.json();
    setResource({ ...resource, isFavoritedByCurrentUser: data.favorited });
  };

  // Rate resource
  const handleRate = async (rating) => {
    await fetch(`http://localhost:8080/api/resources/${resourceId}/rate`, {
      method: 'POST',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ rating })
    });
    
    // Refresh resource details to get new average
    const response = await fetch(
      `http://localhost:8080/api/resources/${resourceId}/details`,
      { credentials: 'include' }
    );
    setResource(await response.json());
  };

  // Download file
  const handleDownload = async () => {
    // Increment download count
    await fetch(
      `http://localhost:8080/api/resources/download/${resourceId}/increment`,
      { method: 'POST' }
    );
    
    // Download file
    window.location.href = 
      `http://localhost:8080/api/resources/download/${resource.filePath}`;
  };

  if (!resource) return <div>Loading...</div>;

  return (
    <div>
      <h1>{resource.title}</h1>
      <p>{resource.description}</p>
      <p>Uploader: {resource.uploaderName}</p>
      <p>Average Rating: {resource.averageRating || 'No ratings yet'}</p>
      <p>Views: {resource.viewCount} | Downloads: {resource.downloadCount}</p>
      
      <button onClick={handleToggleFavorite}>
        {resource.isFavoritedByCurrentUser ? '⭐ Favorited' : '☆ Add to Favorites'}
      </button>
      
      <button onClick={handleDownload}>Download</button>
      
      <div>
        <h3>Rate this resource:</h3>
        {[1, 2, 3, 4, 5].map(star => (
          <button key={star} onClick={() => handleRate(star)}>
            {star}⭐
          </button>
        ))}
      </div>
      
      <div>
        <h3>Comments ({comments.length})</h3>
        {comments.map(comment => (
          <div key={comment.id}>
            <p><strong>{comment.userName}</strong>: {comment.content}</p>
            <small>{new Date(comment.createdAt).toLocaleString()}</small>
          </div>
        ))}
        
        <textarea 
          value={newComment}
          onChange={(e) => setNewComment(e.target.value)}
          placeholder="Add a comment..."
        />
        <button onClick={handleAddComment}>Post Comment</button>
      </div>
    </div>
  );
};
```

### 4. Upload Resource Form

```javascript
const UploadForm = () => {
  const [file, setFile] = useState(null);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [selectedCategories, setSelectedCategories] = useState([]);
  const [categories, setCategories] = useState([]);

  // Load categories
  useEffect(() => {
    fetch('http://localhost:8080/api/resources/categories')
      .then(r => r.json())
      .then(setCategories);
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    const formData = new FormData();
    formData.append('file', file);
    formData.append('title', title);
    formData.append('description', description);
    selectedCategories.forEach(cat => {
      formData.append('categories', cat);
    });

    try {
      const response = await fetch('http://localhost:8080/api/resources', {
        method: 'POST',
        credentials: 'include',
        body: formData
      });
      
      if (response.ok) {
        alert('File uploaded successfully!');
        // Reset form
        setFile(null);
        setTitle('');
        setDescription('');
        setSelectedCategories([]);
      } else if (response.status === 401) {
        alert('Please login first');
      }
    } catch (error) {
      console.error('Upload error:', error);
      alert('Upload failed');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="file"
        onChange={(e) => setFile(e.target.files[0])}
        required
      />
      
      <input
        type="text"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Title"
        required
      />
      
      <textarea
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        placeholder="Description"
      />
      
      <div>
        <h4>Select Categories:</h4>
        {categories.map(cat => (
          <label key={cat.id}>
            <input
              type="checkbox"
              checked={selectedCategories.includes(cat.name)}
              onChange={(e) => {
                if (e.target.checked) {
                  setSelectedCategories([...selectedCategories, cat.name]);
                } else {
                  setSelectedCategories(
                    selectedCategories.filter(c => c !== cat.name)
                  );
                }
              }}
            />
            {cat.iconEmoji} {cat.name}
          </label>
        ))}
      </div>
      
      <button type="submit">Upload</button>
    </form>
  );
};
```

---

## 📝 Important Notes

### 1. CORS Configuration
- Backend is configured to accept requests from `http://localhost:3000`
- Always use `credentials: 'include'` for authenticated requests
- Cookies are automatically sent with this setting

### 2. File Uploads
- Maximum file size: Check with backend (not specified in config)
- Files are stored in `uploads/` directory on server
- Filename is automatically generated (UUID + original filename)

### 3. Authentication
- Session-based using cookies (JSESSIONID)
- Sessions persist until logout or timeout
- No need to manually manage tokens

### 4. Rating System
- Users can rate each resource only once
- Ratings are 1-5 stars
- Average rating is automatically calculated by database trigger
- Attempting to rate again returns 400 error

### 5. Comments
- Unlimited comments per resource
- Comments are tied to user account
- Comments cannot be edited or deleted (feature not implemented)

### 6. Favorites
- Toggle functionality (add/remove in one call)
- Unique constraint prevents duplicates
- Response tells you if it was added or removed

### 7. View/Download Counts
- View count increments automatically when accessing `/details` endpoint
- Download count must be manually incremented via `/download/{id}/increment`
- Call increment endpoint when user clicks download button

---

## 🚨 Common Pitfalls

### 1. Forgetting `credentials: 'include'`
❌ **Wrong:**
```javascript
fetch('http://localhost:8080/api/resources/favorites')
```

✅ **Correct:**
```javascript
fetch('http://localhost:8080/api/resources/favorites', {
  credentials: 'include'
})
```

### 2. Setting Content-Type for File Uploads
❌ **Wrong:**
```javascript
fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': 'multipart/form-data' // Don't set this!
  },
  body: formData
})
```

✅ **Correct:**
```javascript
fetch(url, {
  method: 'POST',
  body: formData
  // Browser sets Content-Type automatically with boundary
})
```

### 3. Not Handling 401 Responses
❌ **Wrong:**
```javascript
fetch(url).then(r => r.json()) // Might fail if 401
```

✅ **Correct:**
```javascript
fetch(url)
  .then(r => {
    if (r.status === 401) {
      window.location.href = '/login';
      throw new Error('Not authenticated');
    }
    return r.json();
  })
```

### 4. Not URL Encoding Search Parameters
❌ **Wrong:**
```javascript
fetch(`/search?keyword=${keyword}`)
```

✅ **Correct:**
```javascript
fetch(`/search?keyword=${encodeURIComponent(keyword)}`)
```

---

## 🎯 Quick Reference

### Base URL
```
http://localhost:8080
```

### Public Endpoints Summary
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/resources` | List all resources |
| GET | `/api/resources/{id}/details` | Get resource details |
| GET | `/api/resources/{id}/comments` | Get comments |
| GET | `/api/resources/search` | Search resources |
| GET | `/api/resources/categories` | Get categories |
| GET | `/api/resources/download/{filename}` | Download file |
| POST | `/api/resources/download/{id}/increment` | Increment download count |

### Protected Endpoints Summary
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/resources` | Upload resource |
| POST | `/api/resources/{id}/rate` | Rate resource |
| POST | `/api/resources/{id}/comments` | Add comment |
| POST | `/api/resources/{id}/favorite` | Toggle favorite |
| GET | `/api/resources/favorites` | Get user's favorites |

### Authentication
| URL | Purpose |
|-----|---------|
| `/oauth2/authorization/google` | Start Google OAuth login |
| `/logout` | Logout (if implemented) |

---

## 📞 Support

If you encounter any issues:
1. Check browser console for errors
2. Verify backend is running at `http://localhost:8080`
3. Ensure you're using `credentials: 'include'` for authenticated requests
4. Check that CORS is configured for your frontend origin
5. Verify OAuth credentials are correct in backend

---

**Happy Coding! 🚀**

*Last Updated: November 4, 2025*
