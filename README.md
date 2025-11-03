# 🎓 Resource Sharing Platform - Backend API

A full-featured Spring Boot REST API for a resource sharing platform with file uploads, ratings, comments, and favorites.

[![Java](https://img.shields.io/badge/Java-17+-orange.svg)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.7-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18.0-blue.svg)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🚀 Features

### Core Functionality
- ✅ **File Upload & Download** - Upload and share any file type
- ✅ **User Ratings** - 5-star rating system with average calculation
- ✅ **Comments** - Discussion on resources
- ✅ **Favorites** - Bookmark resources for later
- ✅ **Categories** - Organize resources by topics
- ✅ **Search** - Find resources by keyword and category
- ✅ **View/Download Tracking** - Analytics for resource popularity

### Authentication & Security
- ✅ **Google OAuth 2.0** - Secure authentication
- ✅ **Session Management** - Cookie-based sessions
- ✅ **CORS Configuration** - Ready for frontend integration
- ✅ **Protected Routes** - Authentication required for write operations

### Technical Features
- ✅ **RESTful API** - 25 well-documented endpoints
- ✅ **PostgreSQL Database** - Robust relational database
- ✅ **Database Triggers** - Automatic rating calculations
- ✅ **Test Endpoints** - Development mode without authentication
- ✅ **Comprehensive Documentation** - Complete API reference

---

## 📋 Quick Start

### Prerequisites
- Java 17 or higher
- Maven 3.6+
- PostgreSQL 12+
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd demo-2
   ```

2. **Set up PostgreSQL**
   ```bash
   # Create database
   psql -U postgres -c "CREATE DATABASE innohacks;"
   
   # Load schema and test data
   psql -U postgres -d innohacks -f mockup_data.sql
   ```

3. **Configure application**
   
   Edit `src/main/resources/application.properties`:
   ```properties
   spring.datasource.password=your_postgres_password
   ```

4. **Run the application**
   ```bash
   mvn spring-boot:run
   ```

5. **Verify it's running**
   ```bash
   curl http://localhost:8080/api/resources
   ```

**Detailed setup instructions:** See [SETUP_GUIDE.md](SETUP_GUIDE.md)

---

## 📚 Documentation

### For Frontend Developers
- **[FRONTEND_INTEGRATION_GUIDE.md](FRONTEND_INTEGRATION_GUIDE.md)** - Complete API documentation with examples
- **[API_QUICK_REFERENCE.md](API_QUICK_REFERENCE.md)** - Quick reference cheat sheet
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Step-by-step setup instructions

### For Backend Developers
- **[DATABASE_STATUS_REPORT.md](DATABASE_STATUS_REPORT.md)** - Database schema details
- **[ENDPOINT_TEST_RESULTS.md](ENDPOINT_TEST_RESULTS.md)** - All endpoint test results
- **[OAUTH_TEST_RESULTS.md](OAUTH_TEST_RESULTS.md)** - OAuth authentication tests

### Test Data
- **[mockup_data.sql](mockup_data.sql)** - SQL script with schema and test data
- **[mockup_data.json](mockup_data.json)** - JSON mockup for offline development

---

## 🔌 API Endpoints

### Public Endpoints (No Authentication)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/resources` | List all resources |
| GET | `/api/resources/{id}/details` | Get resource details |
| GET | `/api/resources/{id}/comments` | Get comments |
| GET | `/api/resources/search` | Search resources |
| GET | `/api/resources/categories` | Get all categories |
| GET | `/api/resources/download/{filename}` | Download file |
| POST | `/api/resources/download/{id}/increment` | Increment download count |

### Protected Endpoints (Authentication Required)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/resources` | Upload new resource |
| POST | `/api/resources/{id}/rate` | Rate a resource |
| POST | `/api/resources/{id}/comments` | Add comment |
| POST | `/api/resources/{id}/favorite` | Toggle favorite |
| GET | `/api/resources/favorites` | Get user's favorites |

### Test Endpoints (Development Only)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/test/users` | Create test user |
| POST | `/api/test/resources` | Upload without auth |
| POST | `/api/test/resources/{id}/rate` | Rate without auth |
| GET | `/api/test/resources` | List resources |

**Complete API documentation:** [FRONTEND_INTEGRATION_GUIDE.md](FRONTEND_INTEGRATION_GUIDE.md)

---

## 🗄️ Database Schema

### Tables
- **users** - User accounts (Google OAuth)
- **resources** - Uploaded files/resources
- **categories** - Resource categories
- **ratings** - User ratings (1-5 stars)
- **comments** - User comments
- **favorites** - User bookmarks
- **resource_categories** - Many-to-many relationship

### Built-in Categories
📚 Education | 🔬 Research | 💻 Technology | 🧪 Science | 🎨 Arts | 💼 Business | ⚙️ Programming | 🎯 Design

---

## 🔐 Authentication

### Google OAuth 2.0
```javascript
// Redirect to login
window.location.href = 'http://localhost:8080/oauth2/authorization/google';

// Make authenticated requests
fetch('http://localhost:8080/api/resources/favorites', {
  credentials: 'include' // Important: sends session cookie
});
```

### Development Mode (No Auth)
Use `/api/test/*` endpoints during development to bypass authentication.

---

## 💻 Tech Stack

- **Framework:** Spring Boot 3.5.7
- **Language:** Java 17
- **Database:** PostgreSQL 18.0
- **ORM:** Hibernate / JPA
- **Security:** Spring Security + OAuth 2.0
- **Build Tool:** Maven
- **Authentication:** Google OAuth 2.0
- **Session Management:** Cookie-based (JSESSIONID)

---

## 📁 Project Structure

```
src/
├── main/
│   ├── java/com/example/demo/
│   │   ├── InnohacksApplication.java       # Main application
│   │   ├── Config/
│   │   │   └── SecurityConfig.java         # Security & CORS config
│   │   ├── Controllers/
│   │   │   ├── ResourceController.java     # Main API
│   │   │   └── TestController.java         # Test API
│   │   ├── Entities/                       # JPA entities
│   │   │   ├── User.java
│   │   │   ├── Resource.java
│   │   │   ├── Category.java
│   │   │   ├── Rating.java
│   │   │   ├── Comment.java
│   │   │   └── Favorite.java
│   │   ├── Repositories/                   # Database access
│   │   ├── Services/                       # Business logic
│   │   └── DTO/                           # Data transfer objects
│   └── resources/
│       └── application.properties          # Configuration
└── test/                                   # Unit tests
```

---

## 🧪 Testing

### Run Endpoint Tests
```bash
# Run all endpoint tests
./test_endpoints.sh

# Run authenticated endpoint tests (need session cookie)
./test_authenticated_endpoints.sh
```

### Manual Testing
```bash
# Get all resources
curl http://localhost:8080/api/resources

# Search resources
curl "http://localhost:8080/api/resources/search?keyword=react"

# Get categories
curl http://localhost:8080/api/resources/categories

# Upload file (test endpoint - no auth)
curl -X POST http://localhost:8080/api/test/resources \
  -F "file=@myfile.pdf" \
  -F "title=Test File" \
  -F "description=Testing upload" \
  -F "userEmail=test@example.com"
```

---

## ⚙️ Configuration

### Database Configuration
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/innohacks
spring.datasource.username=postgres
spring.datasource.password=your_password
```

### OAuth Configuration
```properties
spring.security.oauth2.client.registration.google.client-id=your-client-id
spring.security.oauth2.client.registration.google.client-secret=your-client-secret
spring.security.oauth2.client.registration.google.redirect-uri=http://localhost:8080/login/oauth2/code/google
```

### CORS Configuration
```java
// In SecurityConfig.java
configuration.setAllowedOrigins(Arrays.asList("http://localhost:3000"));
```

---

## 🚨 Troubleshooting

### Common Issues

**Backend won't start**
- Check Java version: `java -version` (need 17+)
- Check PostgreSQL is running: `pg_isready`
- Verify database exists and credentials are correct

**Database connection failed**
- Ensure PostgreSQL is running
- Check password in `application.properties`
- Verify database `innohacks` exists

**CORS errors**
- Verify frontend origin in `SecurityConfig.java`
- Use `credentials: 'include'` in fetch requests
- Restart backend after config changes

**File upload fails**
- Check `uploads/` directory exists and has write permissions
- Verify file size is within limits
- Check logs for detailed error

**More help:** See [SETUP_GUIDE.md](SETUP_GUIDE.md#-troubleshooting)

---

## 📊 Test Data

The database comes pre-loaded with:
- **8 test users**
- **20 sample resources** (various categories)
- **10 categories** (Education, Technology, Science, etc.)
- **Multiple ratings** (demonstrating average calculation)
- **Comments** (demonstrating discussion feature)
- **Favorites** (demonstrating bookmarking)

All test data is realistic and suitable for frontend development and demos.

---

## 🎯 Use Cases

Perfect for:
- 📚 Educational resource sharing platforms
- 📄 Document management systems
- 🎓 Course material distribution
- 🔬 Research paper repositories
- 💼 Corporate knowledge bases
- 🎨 Creative portfolio sharing

---

## 🤝 Contributing

This is a hackathon/educational project. Feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Use as a learning resource

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 👥 Team

- **Backend Developer:** [Your Name]
- **Frontend Developer:** [Team Member Name]

---

## 🙏 Acknowledgments

- Spring Boot team for the excellent framework
- PostgreSQL community
- Google OAuth 2.0 documentation
- All open source contributors

---

## 📞 Support

- 📖 Documentation: See markdown files in repository
- 🐛 Issues: GitHub Issues
- 💬 Questions: Check SETUP_GUIDE.md first

---

## 🚀 Deployment

### Local Development
```bash
mvn spring-boot:run
```

### Production Build
```bash
mvn clean package
java -jar target/innohacks-0.0.1-SNAPSHOT.jar
```

### Docker (Optional)
```dockerfile
# Dockerfile example (create this file if needed)
FROM openjdk:17-jdk-slim
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
```

---

## 📈 Future Enhancements

Potential additions:
- [ ] File type validation
- [ ] User profiles and avatars
- [ ] Resource versioning
- [ ] Notifications system
- [ ] Admin dashboard
- [ ] Resource tags
- [ ] Advanced search filters
- [ ] Resource recommendations
- [ ] Usage analytics
- [ ] Export/import functionality

---

**Built with ❤️ for hackathon and learning**

🌟 Star this repo if you found it helpful!
