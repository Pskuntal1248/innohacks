# 🚀 Project Setup Guide

## For Frontend Developer - Quick Start

This guide will help you set up the complete backend locally so you can develop the frontend during the hackathon.

---

## 📋 Prerequisites

### Required Software
1. **Java 17 or higher**
   - Check: `java -version`
   - Download: https://www.oracle.com/java/technologies/downloads/

2. **Maven 3.6+**
   - Check: `mvn -version`
   - Download: https://maven.apache.org/download.cgi

3. **PostgreSQL 12+**
   - Check: `psql --version`
   - Download: https://www.postgresql.org/download/

4. **Git**
   - Check: `git --version`
   - Download: https://git-scm.com/downloads

---

## 🔧 Setup Instructions

### Step 1: Clone the Repository
```bash
git clone <repository-url>
cd demo-2
```

### Step 2: Set Up PostgreSQL Database

#### 2.1 Start PostgreSQL
```bash
# macOS (with Homebrew)
brew services start postgresql

# Linux
sudo service postgresql start

# Windows
# PostgreSQL should start automatically, or use Services
```

#### 2.2 Create Database
```bash
# Login to PostgreSQL
psql -U postgres

# In PostgreSQL prompt:
CREATE DATABASE innohacks;
\q
```

#### 2.3 Load Database Schema & Data
```bash
# Navigate to project directory
cd /path/to/demo-2

# Run the mockup data script (includes schema and test data)
psql -U postgres -d innohacks -f mockup_data.sql
```

**This will create:**
- ✅ All 7 tables (users, resources, ratings, comments, favorites, categories, resource_categories)
- ✅ 8 test users
- ✅ 10 categories
- ✅ 20 sample resources
- ✅ Multiple ratings, comments, and favorites
- ✅ All relationships and constraints

#### 2.4 Verify Database Setup
```bash
psql -U postgres -d innohacks -c "\dt"
```

You should see 7 tables:
- categories
- comments  
- favorites
- ratings
- resource_categories
- resources
- users

### Step 3: Configure Application

#### 3.1 Update Database Password
Edit `src/main/resources/application.properties`:
```properties
spring.datasource.password=your_postgres_password
```
**Replace `your_postgres_password` with your actual PostgreSQL password**

#### 3.2 (Optional) Configure Google OAuth

If you want to test OAuth login, update these in `application.properties`:
```properties
spring.security.oauth2.client.registration.google.client-id=your-client-id
spring.security.oauth2.client.registration.google.client-secret=your-client-secret
```

**For hackathon, you can skip this and use the `/api/test/*` endpoints instead!**

### Step 4: Run the Backend

#### Option 1: Using Maven (Recommended)
```bash
mvn spring-boot:run
```

#### Option 2: Using IDE
1. Open project in IntelliJ IDEA or Eclipse
2. Run `InnohacksApplication.java`

**Backend will start at:** `http://localhost:8080`

### Step 5: Verify Backend is Running

Open browser or use curl:
```bash
# Test public endpoint
curl http://localhost:8080/api/resources

# You should see a JSON array of resources
```

---

## 🧪 Testing Without OAuth

During development, use the **Test Endpoints** that don't require authentication:

### Create Test User
```bash
curl -X POST "http://localhost:8080/api/test/users?email=dev@test.com&name=Dev%20User"
```

### Upload Resource (No Auth)
```bash
curl -X POST http://localhost:8080/api/test/resources \
  -F "file=@yourfile.pdf" \
  -F "title=Test Upload" \
  -F "description=Testing" \
  -F "userEmail=dev@test.com"
```

### Rate Resource (No Auth)
```bash
curl -X POST "http://localhost:8080/api/test/resources/1/rate?userEmail=dev@test.com" \
  -H "Content-Type: application/json" \
  -d '{"rating":5}'
```

**See `API_QUICK_REFERENCE.md` for all test endpoints!**

---

## 📁 Project Structure

```
demo-2/
├── src/
│   ├── main/
│   │   ├── java/com/example/demo/
│   │   │   ├── InnohacksApplication.java    # Main application
│   │   │   ├── Config/
│   │   │   │   └── SecurityConfig.java      # OAuth & CORS config
│   │   │   ├── Controllers/
│   │   │   │   ├── ResourceController.java  # Main API endpoints
│   │   │   │   └── TestController.java      # Test endpoints (no auth)
│   │   │   ├── Entities/                    # Database models
│   │   │   ├── Repositories/                # Database queries
│   │   │   ├── Services/                    # Business logic
│   │   │   └── DTO/                         # Request/Response objects
│   │   └── resources/
│   │       └── application.properties       # Configuration
│   └── test/                                # Unit tests
├── uploads/                                 # Uploaded files storage
├── mockup_data.sql                         # Database setup & test data
├── mockup_data.json                        # JSON mockup for frontend
├── FRONTEND_INTEGRATION_GUIDE.md           # Complete API documentation
├── API_QUICK_REFERENCE.md                  # Quick reference cheat sheet
└── pom.xml                                 # Maven dependencies
```

---

## 📚 Documentation Files

### For Frontend Development:
1. **FRONTEND_INTEGRATION_GUIDE.md** - Complete API documentation with examples
2. **API_QUICK_REFERENCE.md** - Quick reference cheat sheet
3. **mockup_data.json** - JSON mockup data for offline development

### For Backend Understanding:
1. **DATABASE_STATUS_REPORT.md** - Database schema information
2. **ENDPOINT_TEST_RESULTS.md** - All endpoint test results
3. **OAUTH_TEST_RESULTS.md** - OAuth authentication test results

---

## 🔑 Important Configuration

### CORS Settings
Backend is configured to accept requests from:
```
http://localhost:3000
```

If your frontend runs on a different port, update `SecurityConfig.java`:
```java
configuration.setAllowedOrigins(Arrays.asList("http://localhost:YOUR_PORT"));
```

### File Uploads
- Files are stored in `uploads/` directory
- Maximum file size: Default Spring Boot limit (1MB)
- To increase, add to `application.properties`:
  ```properties
  spring.servlet.multipart.max-file-size=10MB
  spring.servlet.multipart.max-request-size=10MB
  ```

---

## 🗄️ Database Information

### Connection Details
- **Host:** localhost
- **Port:** 5432 (default PostgreSQL)
- **Database:** innohacks
- **Username:** postgres
- **Password:** (your PostgreSQL password)

### Access Database Directly
```bash
psql -U postgres -d innohacks
```

### Useful PostgreSQL Commands
```sql
-- List all tables
\dt

-- View table structure
\d resources

-- View all resources
SELECT * FROM resources;

-- View all users
SELECT * FROM users;

-- View resources with ratings
SELECT r.id, r.title, r.average_rating 
FROM resources r 
ORDER BY r.average_rating DESC;

-- Exit
\q
```

---

## 🎯 Quick Start Checklist

- [ ] Java 17+ installed
- [ ] Maven installed
- [ ] PostgreSQL installed and running
- [ ] Database `innohacks` created
- [ ] Mockup data loaded (`mockup_data.sql`)
- [ ] `application.properties` configured (database password)
- [ ] Backend running on `http://localhost:8080`
- [ ] Test endpoint works: `curl http://localhost:8080/api/resources`
- [ ] Read `FRONTEND_INTEGRATION_GUIDE.md`
- [ ] Read `API_QUICK_REFERENCE.md`

---

## 🚨 Troubleshooting

### Backend won't start
1. **Check Java version:** `java -version` (need 17+)
2. **Check PostgreSQL is running:** `psql -U postgres -d innohacks -c "SELECT 1;"`
3. **Check port 8080 is free:** `lsof -i :8080`
4. **Check logs:** Look for errors in terminal output

### Database connection failed
1. **Check PostgreSQL is running:** `pg_isready`
2. **Verify password in `application.properties`**
3. **Verify database exists:** `psql -U postgres -l | grep innohacks`
4. **Check PostgreSQL is accepting connections:** `psql -U postgres -c "SELECT version();"`

### OAuth not working
**For hackathon:** Just use `/api/test/*` endpoints! They don't require authentication.

### Can't upload files
1. **Check `uploads/` directory exists:** `mkdir uploads`
2. **Check file permissions:** `chmod 755 uploads`
3. **Check file size limit in `application.properties`**

### CORS errors in browser
1. **Verify frontend URL in `SecurityConfig.java`**
2. **Restart backend after changing config**
3. **Use `credentials: 'include'` in fetch requests**

---

## 🆘 Need Help During Hackathon?

### Check These First:
1. ✅ Is PostgreSQL running? `pg_isready`
2. ✅ Is backend running? `curl http://localhost:8080/api/resources`
3. ✅ Are you using the correct endpoint? Check `API_QUICK_REFERENCE.md`
4. ✅ For authenticated endpoints, are you including `credentials: 'include'`?

### Error Messages:
- **401 Unauthorized** → Use `/api/test/*` endpoints instead, or login via OAuth
- **400 Bad Request** → Check request body format (see examples in docs)
- **404 Not Found** → Check URL and resource ID
- **500 Server Error** → Check backend logs in terminal

### View Backend Logs:
The terminal where you ran `mvn spring-boot:run` shows all logs including:
- Incoming requests
- Database queries
- Errors and stack traces

---

## 📞 Contact Backend Developer

If you encounter issues that aren't covered here:
1. Check the error message in backend logs
2. Check browser console for frontend errors
3. Verify the request format matches the examples in documentation
4. Try the same request using curl to isolate frontend/backend issues

---

## 🎉 You're Ready!

Backend is fully functional with:
- ✅ 25 API endpoints (20 public + 5 protected)
- ✅ Complete database with test data
- ✅ File upload/download
- ✅ Ratings, comments, favorites
- ✅ Search and categories
- ✅ OAuth authentication (optional)

**Focus on building an amazing frontend!** 🚀

All API details are in `FRONTEND_INTEGRATION_GUIDE.md`

Good luck with the hackathon! 💪
