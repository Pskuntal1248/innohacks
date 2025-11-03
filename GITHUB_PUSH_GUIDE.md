# 🚀 GitHub Push & Deployment Guide

This guide will help you push your project to GitHub and prepare it for hackathon collaboration.

---

## ⚠️ IMPORTANT: Before You Push

### 1. **Protect Sensitive Data**

Your `application.properties` file contains sensitive credentials. You have two options:

#### Option A: Use Environment Variables (RECOMMENDED)
Create a separate file `application.properties.example`:
```properties
spring.application.name=innohacks
server.port=8080

spring.datasource.url=jdbc:postgresql://localhost:5432/innohacks
spring.datasource.username=postgres
spring.datasource.password=YOUR_PASSWORD_HERE

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

spring.security.oauth2.client.registration.google.client-id=YOUR_CLIENT_ID_HERE
spring.security.oauth2.client.registration.google.client-secret=YOUR_CLIENT_SECRET_HERE
spring.security.oauth2.client.registration.google.scope=profile,email
spring.security.oauth2.client.registration.google.redirect-uri=http://localhost:8080/login/oauth2/code/google

spring.servlet.multipart.max-file-size=100MB
spring.servlet.multipart.max-request-size=100MB
```

Then add this to `.gitignore`:
```
src/main/resources/application.properties
```

#### Option B: Keep Credentials Public (For Private Repos Only)
If your repo is private and only accessible to your team, you can keep credentials in the file.

### 2. **Check Upload Directory**

The `uploads/` directory is already in `.gitignore` - user uploaded files won't be pushed to GitHub.

---

## 📋 Step-by-Step GitHub Push

### Step 1: Initialize Git Repository

```bash
cd "/Users/testuser/Desktop/demo 2"
git init
```

### Step 2: Add Files to Git

```bash
# Add all files
git add .

# Check what will be committed
git status
```

**Expected output:**
```
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  new file:   .gitignore
  new file:   README.md
  new file:   FRONTEND_INTEGRATION_GUIDE.md
  new file:   SETUP_GUIDE.md
  new file:   mockup_data.sql
  new file:   mockup_data.json
  new file:   pom.xml
  new file:   src/...
  ...
```

### Step 3: Commit Changes

```bash
git commit -m "Initial commit - Backend API complete with documentation"
```

### Step 4: Create GitHub Repository

1. Go to https://github.com
2. Click "+" in top right → "New repository"
3. Repository name: `resource-sharing-platform` (or your choice)
4. Description: `A Spring Boot REST API for resource sharing with Google OAuth, file uploads, ratings, and comments`
5. Choose **Private** or **Public** (see note below)
6. **DO NOT** check "Add a README" (you already have one)
7. Click "Create repository"

**Public vs Private:**
- **Public:** Everyone can see your code (⚠️ Don't commit credentials!)
- **Private:** Only you and collaborators can access (safer for hackathons)

### Step 5: Add Remote & Push

GitHub will show you commands. Use these:

```bash
# Add remote repository (replace with your URL)
git remote add origin https://github.com/YOUR_USERNAME/resource-sharing-platform.git

# Set main branch
git branch -M main

# Push to GitHub
git push -u origin main
```

### Step 6: Add Collaborator (Frontend Developer)

1. Go to your repository on GitHub
2. Click "Settings" tab
3. Click "Collaborators" in left sidebar
4. Click "Add people"
5. Enter your frontend developer's GitHub username
6. They'll receive an invitation email

---

## 🗄️ Database Setup for Your Friend

Your frontend developer needs the database schema and test data. You have 3 options:

### Option 1: Use mockup_data.sql (EASIEST - Already Done ✅)

Your friend just needs to run:
```bash
psql -U postgres -d innohacks -f mockup_data.sql
```

This file is already in your repository and contains:
- All table schemas
- 20 sample resources
- 8 test users
- 10 categories
- Ratings, comments, favorites

**This is the recommended approach!**

### Option 2: Export Current Database

If you want to export your actual current database:

```bash
# Export schema only
pg_dump -U postgres -d innohacks --schema-only > schema.sql

# Export schema + all data
pg_dump -U postgres -d innohacks > full_database_backup.sql

# Add to git
git add schema.sql
git commit -m "Add database schema export"
git push
```

### Option 3: Let JPA Auto-Create

Your friend can let Hibernate create tables automatically (already configured):
- `spring.jpa.hibernate.ddl-auto=update` in application.properties
- But they'll need to load mockup_data.sql for test data

**Recommendation:** Option 1 (mockup_data.sql) is best - it's already done and tested!

---

## 👥 Collaboration Workflow

### For You (Backend Developer)

```bash
# Make changes
git add .
git commit -m "Your change description"
git push
```

### For Your Frontend Developer

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/resource-sharing-platform.git
cd resource-sharing-platform

# Follow SETUP_GUIDE.md to set up environment

# Work on their branch
git checkout -b frontend-development
git add .
git commit -m "Add React frontend"
git push origin frontend-development
```

---

## 🎯 Hackathon-Specific Tips

### Same Laptop Setup

Since you mentioned your friend will work on the same laptop:

1. **Backend (You):** Port 8080
   ```bash
   mvn spring-boot:run
   ```

2. **Frontend (Your Friend):** Port 3000 (CORS already configured!)
   ```bash
   npm start   # or yarn start
   ```

3. **Database:** Same PostgreSQL instance
   - Both use `localhost:5432/innohacks`
   - Same credentials

### Quick Handoff Checklist

- [ ] Code pushed to GitHub
- [ ] `mockup_data.sql` included in repo
- [ ] `.gitignore` prevents sensitive data
- [ ] README.md explains project
- [ ] SETUP_GUIDE.md has setup steps
- [ ] FRONTEND_INTEGRATION_GUIDE.md has API docs
- [ ] Backend is running on port 8080
- [ ] Database has test data loaded
- [ ] OAuth credentials configured
- [ ] Friend added as collaborator

---

## 🔒 Security Checklist Before Push

- [ ] **Check .gitignore includes:**
  - `uploads/` ✅
  - `.DS_Store` ✅
  - `*.log` ✅
  - Optional: `application.properties` (if public repo)

- [ ] **Review files to be committed:**
  ```bash
  git status
  ```

- [ ] **Check for sensitive data:**
  ```bash
  git diff --cached
  ```

- [ ] **Verify no large files:**
  ```bash
  find . -type f -size +10M
  ```

---

## 📊 What Gets Pushed to GitHub

### ✅ WILL BE PUSHED:
- Source code (`.java` files)
- Configuration files (`pom.xml`, `.gitignore`)
- Documentation (`.md` files)
- Database scripts (`mockup_data.sql`)
- Static resources
- Test files

### ❌ WILL NOT BE PUSHED (in .gitignore):
- `target/` - Compiled classes
- `uploads/` - User uploaded files
- `.DS_Store` - macOS system files
- `*.log` - Log files
- `.idea/`, `.vscode/` - IDE settings

### ⚠️ OPTIONAL (You Decide):
- `application.properties` - Contains passwords/secrets
  - **Private repo:** Safe to include
  - **Public repo:** Add to .gitignore and create `.example` version

---

## 🐛 Common Issues

### "Permission denied (publickey)"
You need to set up SSH keys or use HTTPS with Personal Access Token.

**Solution:** Use HTTPS URL and GitHub will prompt for credentials:
```bash
git remote set-url origin https://github.com/YOUR_USERNAME/repo.git
```

### "Repository not found"
Wrong repository URL or you don't have access.

**Solution:** Double-check URL on GitHub repository page.

### "Failed to push some refs"
Someone else pushed changes first.

**Solution:**
```bash
git pull origin main
git push origin main
```

### "Large files detected"
You have files over 100MB (GitHub limit).

**Solution:**
```bash
# Find large files
find . -type f -size +100M

# Add to .gitignore if needed
echo "large-file.zip" >> .gitignore
```

---

## 📱 Quick Commands Reference

```bash
# Check status
git status

# See what changed
git diff

# Add specific file
git add src/main/java/com/example/demo/Controllers/ResourceController.java

# Add all changes
git add .

# Commit
git commit -m "Description of changes"

# Push
git push

# Pull latest changes
git pull

# See commit history
git log --oneline

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all uncommitted changes
git checkout .
```

---

## 🎓 Post-Push Setup for Frontend Developer

After you push, your friend should:

1. **Clone repository**
   ```bash
   git clone <repo-url>
   cd resource-sharing-platform
   ```

2. **Read SETUP_GUIDE.md**
   - Install prerequisites
   - Set up PostgreSQL
   - Configure application

3. **Load database**
   ```bash
   psql -U postgres -d innohacks -f mockup_data.sql
   ```

4. **Start backend**
   ```bash
   mvn spring-boot:run
   ```

5. **Test API**
   ```bash
   curl http://localhost:8080/api/resources
   ```

6. **Read FRONTEND_INTEGRATION_GUIDE.md**
   - Understand API endpoints
   - See authentication flow
   - Use code examples

---

## 🚀 Ready to Push?

Run these commands now:

```bash
# Navigate to project
cd "/Users/testuser/Desktop/demo 2"

# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - Backend API with documentation and test data"

# Go to GitHub and create repository, then:
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git branch -M main
git push -u origin main
```

---

## ✅ Success Indicators

After pushing, verify:
- [ ] Repository shows all files on GitHub
- [ ] README.md displays nicely on repo homepage
- [ ] No `uploads/` directory visible
- [ ] No `target/` directory visible
- [ ] Documentation files are readable
- [ ] `mockup_data.sql` is present
- [ ] File count is reasonable (not thousands of compiled files)

---

## 💡 Pro Tips

1. **Commit Messages:** Be descriptive
   - ✅ "Add comment endpoint with user validation"
   - ❌ "Update"

2. **Branch Strategy:**
   - `main` - Stable code
   - `development` - Work in progress
   - `feature/xxx` - New features

3. **Regular Commits:** Commit often, push when stable

4. **Documentation:** Keep README.md updated

5. **Collaboration:** Use Issues and Pull Requests for team coordination

---

## 🎉 You're Ready!

Your project is now ready to be pushed to GitHub and shared with your frontend developer friend for the hackathon. Good luck! 🚀

If you need any help during the push process, refer back to this guide or the troubleshooting section in SETUP_GUIDE.md.
