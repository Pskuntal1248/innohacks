-- ============================================
-- Clean Database Schema Creation Script
-- ============================================
-- This script creates all tables from scratch without any data
-- Use this for a fresh database setup
-- ============================================

-- Drop existing tables if they exist (in correct order due to foreign keys)
DROP TABLE IF EXISTS resource_categories CASCADE;
DROP TABLE IF EXISTS favorites CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS ratings CASCADE;
DROP TABLE IF EXISTS resources CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================
-- 1. USERS TABLE
-- ============================================
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    picture VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. CATEGORIES TABLE
-- ============================================
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 3. RESOURCES TABLE
-- ============================================
CREATE TABLE resources (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_path VARCHAR(500) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size BIGINT,
    file_type VARCHAR(100),
    uploader_id BIGINT NOT NULL,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    view_count INTEGER DEFAULT 0 NOT NULL,
    download_count INTEGER DEFAULT 0 NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uploader_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- 4. RATINGS TABLE
-- ============================================
CREATE TABLE ratings (
    id BIGSERIAL PRIMARY KEY,
    resource_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (resource_id, user_id)
);

-- ============================================
-- 5. COMMENTS TABLE
-- ============================================
CREATE TABLE comments (
    id BIGSERIAL PRIMARY KEY,
    resource_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- 6. FAVORITES TABLE
-- ============================================
CREATE TABLE favorites (
    id BIGSERIAL PRIMARY KEY,
    resource_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (resource_id, user_id)
);

-- ============================================
-- 7. RESOURCE_CATEGORIES TABLE (Many-to-Many)
-- ============================================
CREATE TABLE resource_categories (
    resource_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    PRIMARY KEY (resource_id, category_id),
    FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- ============================================
-- TRIGGERS
-- ============================================

-- Function to calculate average rating
CREATE OR REPLACE FUNCTION update_average_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE resources
    SET average_rating = (
        SELECT COALESCE(AVG(rating), 0)
        FROM ratings
        WHERE resource_id = COALESCE(NEW.resource_id, OLD.resource_id)
    )
    WHERE id = COALESCE(NEW.resource_id, OLD.resource_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger to update average rating on INSERT, UPDATE, DELETE
DROP TRIGGER IF EXISTS rating_changed ON ratings;
CREATE TRIGGER rating_changed
AFTER INSERT OR UPDATE OR DELETE ON ratings
FOR EACH ROW
EXECUTE FUNCTION update_average_rating();

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Index on user emails for faster OAuth lookups
CREATE INDEX idx_users_email ON users(email);

-- Index on resource uploader for faster queries
CREATE INDEX idx_resources_uploader ON resources(uploader_id);

-- Index on ratings for faster average calculations
CREATE INDEX idx_ratings_resource ON ratings(resource_id);
CREATE INDEX idx_ratings_user ON ratings(user_id);

-- Index on comments for faster retrieval
CREATE INDEX idx_comments_resource ON comments(resource_id);
CREATE INDEX idx_comments_user ON comments(user_id);

-- Index on favorites for faster user queries
CREATE INDEX idx_favorites_user ON favorites(user_id);
CREATE INDEX idx_favorites_resource ON favorites(resource_id);

-- Index on resource_categories for faster category filtering
CREATE INDEX idx_resource_categories_resource ON resource_categories(resource_id);
CREATE INDEX idx_resource_categories_category ON resource_categories(category_id);

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Verify all tables were created
SELECT 
    tablename,
    schemaname
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- Verify all triggers
SELECT 
    trigger_name,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public';

-- Show table counts (should all be 0)
SELECT 'users' AS table_name, COUNT(*) AS count FROM users
UNION ALL
SELECT 'categories', COUNT(*) FROM categories
UNION ALL
SELECT 'resources', COUNT(*) FROM resources
UNION ALL
SELECT 'ratings', COUNT(*) FROM ratings
UNION ALL
SELECT 'comments', COUNT(*) FROM comments
UNION ALL
SELECT 'favorites', COUNT(*) FROM favorites
UNION ALL
SELECT 'resource_categories', COUNT(*) FROM resource_categories;

-- ============================================
-- SCRIPT COMPLETE
-- ============================================
-- All tables created successfully!
-- Database is ready for use.
--
-- To load test data later, run: mockup_data.sql
-- ============================================
