-- ============================================
-- MOCKUP DATA FOR FRONTEND TESTING
-- Resource Sharing Platform
-- ============================================
-- Run this script to populate the database with test data
-- Usage: psql -U postgres -d innohacks -f mockup_data.sql

-- ============================================
-- CLEAR EXISTING DATA (OPTIONAL - UNCOMMENT TO RESET)
-- ============================================
-- TRUNCATE TABLE comments CASCADE;
-- TRUNCATE TABLE favorites CASCADE;
-- TRUNCATE TABLE ratings CASCADE;
-- TRUNCATE TABLE resource_categories CASCADE;
-- TRUNCATE TABLE resources CASCADE;
-- TRUNCATE TABLE categories CASCADE;
-- TRUNCATE TABLE users CASCADE;

-- ============================================
-- 1. INSERT TEST USERS
-- ============================================
INSERT INTO users (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Charlie Brown', 'charlie@example.com'),
('Diana Prince', 'diana@example.com'),
('Eve Martinez', 'eve@example.com'),
('Frank Zhang', 'frank@example.com'),
('Grace Lee', 'grace@example.com'),
('Henry Wilson', 'henry@example.com')
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- 2. ENSURE CATEGORIES EXIST
-- ============================================
INSERT INTO categories (name, description, icon_emoji) VALUES
('Education', 'Educational resources and materials', '📚'),
('Research', 'Research papers and publications', '🔬'),
('Technology', 'Tech tutorials and guides', '💻'),
('Science', 'Scientific resources', '🧪'),
('Arts', 'Creative and artistic content', '🎨'),
('Business', 'Business and entrepreneurship', '💼'),
('Health', 'Health and wellness resources', '💊'),
('Mathematics', 'Math resources and tutorials', '🔢'),
('Programming', 'Coding tutorials and examples', '⚙️'),
('Design', 'UI/UX and graphic design', '🎯')
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- 3. INSERT SAMPLE RESOURCES
-- ============================================
-- Note: For file_path, we'll use placeholder names since actual files may not exist
-- Frontend can handle missing files gracefully

INSERT INTO resources (title, description, file_path, uploader_id, view_count, download_count) VALUES
-- Education Resources
(
    'Introduction to Machine Learning',
    'A comprehensive guide covering the fundamentals of machine learning, including supervised and unsupervised learning, neural networks, and practical applications.',
    'ml-guide-2024.pdf',
    1,
    234,
    89
),
(
    'Complete Python Course',
    'From beginner to advanced Python programming. Includes examples, exercises, and real-world projects.',
    'python-complete-course.pdf',
    2,
    456,
    123
),
(
    'Web Development Bootcamp',
    'Learn HTML, CSS, JavaScript, React, Node.js and build full-stack applications.',
    'web-dev-bootcamp.pdf',
    3,
    589,
    201
),

-- Research Papers
(
    'Quantum Computing Research 2024',
    'Latest research on quantum algorithms and their applications in cryptography and optimization.',
    'quantum-research-2024.pdf',
    4,
    145,
    67
),
(
    'Climate Change Data Analysis',
    'Statistical analysis of climate data from the past 50 years with predictive models.',
    'climate-analysis.pdf',
    5,
    298,
    112
),

-- Technology Tutorials
(
    'Docker & Kubernetes Guide',
    'Complete containerization guide with Docker and orchestration with Kubernetes.',
    'docker-k8s-guide.pdf',
    1,
    512,
    234
),
(
    'AWS Cloud Architecture',
    'Best practices for designing scalable cloud infrastructure on AWS.',
    'aws-architecture.pdf',
    2,
    367,
    156
),

-- Science Resources
(
    'Organic Chemistry Basics',
    'Fundamental concepts in organic chemistry with reaction mechanisms and synthesis pathways.',
    'organic-chem-basics.pdf',
    6,
    289,
    98
),
(
    'Physics Problem Set Solutions',
    'Detailed solutions to common physics problems covering mechanics, thermodynamics, and electromagnetism.',
    'physics-solutions.pdf',
    7,
    412,
    178
),

-- Arts & Design
(
    'Digital Art Techniques',
    'Modern digital art techniques using Photoshop, Procreate, and other tools.',
    'digital-art-techniques.pdf',
    8,
    234,
    87
),
(
    'UI/UX Design Principles',
    'Essential design principles for creating beautiful and functional user interfaces.',
    'uiux-principles.pdf',
    3,
    567,
    223
),

-- Business Resources
(
    'Startup Business Plan Template',
    'Complete business plan template with examples from successful startups.',
    'business-plan-template.pdf',
    4,
    678,
    289
),
(
    'Digital Marketing Strategy',
    'Comprehensive guide to digital marketing including SEO, social media, and content marketing.',
    'digital-marketing.pdf',
    5,
    445,
    167
),

-- Mathematics
(
    'Calculus Made Easy',
    'Simplified explanations of calculus concepts with step-by-step examples.',
    'calculus-made-easy.pdf',
    6,
    523,
    198
),
(
    'Linear Algebra Applications',
    'Practical applications of linear algebra in computer graphics, machine learning, and physics.',
    'linear-algebra-apps.pdf',
    7,
    367,
    145
),

-- Programming
(
    'React Hooks Complete Guide',
    'In-depth guide to React Hooks with examples and best practices.',
    'react-hooks-guide.pdf',
    1,
    789,
    312
),
(
    'Data Structures in Java',
    'Implementation of common data structures in Java with complexity analysis.',
    'java-data-structures.pdf',
    2,
    456,
    189
),
(
    'Git Version Control Mastery',
    'Advanced Git techniques for team collaboration and workflow management.',
    'git-mastery.pdf',
    8,
    634,
    267
),

-- Health & Wellness
(
    'Nutrition and Meal Planning',
    'Science-based nutrition guide with meal plans and recipes.',
    'nutrition-guide.pdf',
    3,
    345,
    123
),
(
    'Yoga for Beginners',
    'Complete guide to starting your yoga practice with illustrated poses.',
    'yoga-beginners.pdf',
    4,
    289,
    98
);

-- ============================================
-- 4. LINK RESOURCES TO CATEGORIES
-- ============================================
-- Get IDs dynamically (assuming sequential IDs from 1-20)

-- ML Guide: Education, Technology, Science
INSERT INTO resource_categories (resource_id, category_id) VALUES
(1, (SELECT id FROM categories WHERE name = 'Education')),
(1, (SELECT id FROM categories WHERE name = 'Technology')),
(1, (SELECT id FROM categories WHERE name = 'Science'));

-- Python Course: Education, Programming, Technology
INSERT INTO resource_categories (resource_id, category_id) VALUES
(2, (SELECT id FROM categories WHERE name = 'Education')),
(2, (SELECT id FROM categories WHERE name = 'Programming')),
(2, (SELECT id FROM categories WHERE name = 'Technology'));

-- Web Dev Bootcamp: Education, Programming, Technology
INSERT INTO resource_categories (resource_id, category_id) VALUES
(3, (SELECT id FROM categories WHERE name = 'Education')),
(3, (SELECT id FROM categories WHERE name = 'Programming')),
(3, (SELECT id FROM categories WHERE name = 'Technology'));

-- Quantum Computing: Research, Science, Technology
INSERT INTO resource_categories (resource_id, category_id) VALUES
(4, (SELECT id FROM categories WHERE name = 'Research')),
(4, (SELECT id FROM categories WHERE name = 'Science')),
(4, (SELECT id FROM categories WHERE name = 'Technology'));

-- Climate Change: Research, Science
INSERT INTO resource_categories (resource_id, category_id) VALUES
(5, (SELECT id FROM categories WHERE name = 'Research')),
(5, (SELECT id FROM categories WHERE name = 'Science'));

-- Docker K8s: Technology, Programming
INSERT INTO resource_categories (resource_id, category_id) VALUES
(6, (SELECT id FROM categories WHERE name = 'Technology')),
(6, (SELECT id FROM categories WHERE name = 'Programming'));

-- AWS: Technology, Business
INSERT INTO resource_categories (resource_id, category_id) VALUES
(7, (SELECT id FROM categories WHERE name = 'Technology')),
(7, (SELECT id FROM categories WHERE name = 'Business'));

-- Organic Chemistry: Science, Education
INSERT INTO resource_categories (resource_id, category_id) VALUES
(8, (SELECT id FROM categories WHERE name = 'Science')),
(8, (SELECT id FROM categories WHERE name = 'Education'));

-- Physics: Science, Education, Mathematics
INSERT INTO resource_categories (resource_id, category_id) VALUES
(9, (SELECT id FROM categories WHERE name = 'Science')),
(9, (SELECT id FROM categories WHERE name = 'Education')),
(9, (SELECT id FROM categories WHERE name = 'Mathematics'));

-- Digital Art: Arts, Design, Technology
INSERT INTO resource_categories (resource_id, category_id) VALUES
(10, (SELECT id FROM categories WHERE name = 'Arts')),
(10, (SELECT id FROM categories WHERE name = 'Design')),
(10, (SELECT id FROM categories WHERE name = 'Technology'));

-- UI/UX: Design, Technology, Arts
INSERT INTO resource_categories (resource_id, category_id) VALUES
(11, (SELECT id FROM categories WHERE name = 'Design')),
(11, (SELECT id FROM categories WHERE name = 'Technology')),
(11, (SELECT id FROM categories WHERE name = 'Arts'));

-- Business Plan: Business
INSERT INTO resource_categories (resource_id, category_id) VALUES
(12, (SELECT id FROM categories WHERE name = 'Business'));

-- Digital Marketing: Business, Technology
INSERT INTO resource_categories (resource_id, category_id) VALUES
(13, (SELECT id FROM categories WHERE name = 'Business')),
(13, (SELECT id FROM categories WHERE name = 'Technology'));

-- Calculus: Mathematics, Education
INSERT INTO resource_categories (resource_id, category_id) VALUES
(14, (SELECT id FROM categories WHERE name = 'Mathematics')),
(14, (SELECT id FROM categories WHERE name = 'Education'));

-- Linear Algebra: Mathematics, Science, Technology
INSERT INTO resource_categories (resource_id, category_id) VALUES
(15, (SELECT id FROM categories WHERE name = 'Mathematics')),
(15, (SELECT id FROM categories WHERE name = 'Science')),
(15, (SELECT id FROM categories WHERE name = 'Technology'));

-- React Hooks: Programming, Technology, Education
INSERT INTO resource_categories (resource_id, category_id) VALUES
(16, (SELECT id FROM categories WHERE name = 'Programming')),
(16, (SELECT id FROM categories WHERE name = 'Technology')),
(16, (SELECT id FROM categories WHERE name = 'Education'));

-- Java Data Structures: Programming, Education, Technology
INSERT INTO resource_categories (resource_id, category_id) VALUES
(17, (SELECT id FROM categories WHERE name = 'Programming')),
(17, (SELECT id FROM categories WHERE name = 'Education')),
(17, (SELECT id FROM categories WHERE name = 'Technology'));

-- Git Mastery: Programming, Technology
INSERT INTO resource_categories (resource_id, category_id) VALUES
(18, (SELECT id FROM categories WHERE name = 'Programming')),
(18, (SELECT id FROM categories WHERE name = 'Technology'));

-- Nutrition: Health
INSERT INTO resource_categories (resource_id, category_id) VALUES
(19, (SELECT id FROM categories WHERE name = 'Health'));

-- Yoga: Health
INSERT INTO resource_categories (resource_id, category_id) VALUES
(20, (SELECT id FROM categories WHERE name = 'Health'));

-- ============================================
-- 5. INSERT RATINGS
-- ============================================
-- Multiple users rating different resources

-- Resource 1 (ML Guide) - Average ~4.5
INSERT INTO ratings (user_id, resource_id, rating_value) VALUES
(1, 1, 5),
(2, 1, 4),
(3, 1, 5),
(4, 1, 4),
(5, 1, 5);

-- Resource 2 (Python Course) - Average ~4.7
INSERT INTO ratings (user_id, resource_id, rating_value) VALUES
(1, 2, 5),
(2, 2, 5),
(3, 2, 4),
(6, 2, 5);

-- Resource 3 (Web Dev) - Average ~4.3
INSERT INTO ratings (user_id, resource_id, rating_value) VALUES
(1, 3, 4),
(4, 3, 5),
(5, 3, 4),
(7, 3, 4);

-- Resource 6 (Docker) - Average ~5.0
INSERT INTO ratings (user_id, resource_id, rating_value) VALUES
(1, 6, 5),
(2, 6, 5),
(8, 6, 5);

-- Resource 11 (UI/UX) - Average ~4.8
INSERT INTO ratings (user_id, resource_id, rating_value) VALUES
(3, 11, 5),
(4, 11, 5),
(5, 11, 4),
(6, 11, 5);

-- Resource 16 (React Hooks) - Average ~4.6
INSERT INTO ratings (user_id, resource_id, rating_value) VALUES
(1, 16, 5),
(2, 16, 4),
(3, 16, 5),
(7, 16, 5),
(8, 16, 4);

-- Resource 12 (Business Plan) - Average ~4.0
INSERT INTO ratings (user_id, resource_id, rating_value) VALUES
(4, 12, 4),
(5, 12, 4),
(6, 12, 4);

-- ============================================
-- 6. INSERT COMMENTS
-- ============================================

-- Comments for Resource 1 (ML Guide)
INSERT INTO comments (resource_id, user_id, content) VALUES
(1, 2, 'Excellent resource! The explanations are clear and the examples are very practical.'),
(1, 3, 'This helped me understand neural networks finally. Thank you for sharing!'),
(1, 5, 'Great introduction to ML. Would love to see a follow-up on deep learning.'),
(1, 7, 'Very comprehensive. Used this for my university project.');

-- Comments for Resource 2 (Python Course)
INSERT INTO comments (resource_id, user_id, content) VALUES
(2, 1, 'Perfect for beginners! I went from zero to building my first web scraper.'),
(2, 4, 'The exercises are challenging but rewarding. Highly recommend!'),
(2, 6, 'Clear explanations and good progression. Well structured course.');

-- Comments for Resource 3 (Web Dev Bootcamp)
INSERT INTO comments (resource_id, user_id, content) VALUES
(3, 2, 'Everything you need to become a full-stack developer. Amazing!'),
(3, 5, 'Built 3 projects following this guide. Got my first dev job! 🎉'),
(3, 8, 'The React section is particularly good. Very up-to-date.');

-- Comments for Resource 6 (Docker)
INSERT INTO comments (resource_id, user_id, content) VALUES
(6, 3, 'Finally understood containers! This guide is a lifesaver.'),
(6, 4, 'Best Docker tutorial I have found. Clear and practical.'),
(6, 7, 'The Kubernetes section helped me deploy my first cluster.');

-- Comments for Resource 11 (UI/UX)
INSERT INTO comments (resource_id, user_id, content) VALUES
(11, 1, 'Transformed how I think about design. Essential reading for developers.'),
(11, 2, 'Great principles that I apply daily in my design work.'),
(11, 7, 'Wish I had read this before starting my last project!');

-- Comments for Resource 16 (React Hooks)
INSERT INTO comments (resource_id, user_id, content) VALUES
(16, 4, 'useEffect finally makes sense! Thank you for the clear examples.'),
(16, 5, 'Comprehensive guide with real-world use cases. Bookmarked!'),
(16, 6, 'This is now my go-to reference for hooks. Excellent work.'),
(16, 8, 'The custom hooks section is gold. Learned so much!');

-- Comments for Resource 12 (Business Plan)
INSERT INTO comments (resource_id, user_id, content) VALUES
(12, 1, 'Used this template for my startup pitch. Got funded! 💰'),
(12, 3, 'Very thorough template. Covers everything investors want to see.');

-- Random comments on other resources
INSERT INTO comments (resource_id, user_id, content) VALUES
(4, 6, 'Fascinating research! Quantum computing is the future.'),
(5, 8, 'Important work. The data visualization is particularly insightful.'),
(7, 2, 'Helped me design our company AWS infrastructure. Thank you!'),
(9, 4, 'The solutions are detailed and easy to follow. Great study material.'),
(14, 3, 'Finally understand calculus! This is so well explained.'),
(17, 5, 'Best explanation of binary trees I have seen. Crystal clear.'),
(19, 7, 'Started following this meal plan. Already feeling better!');

-- ============================================
-- 7. INSERT FAVORITES
-- ============================================

-- User 1's favorites (Alice)
INSERT INTO favorites (user_id, resource_id) VALUES
(1, 1),  -- ML Guide
(1, 2),  -- Python Course
(1, 6),  -- Docker
(1, 16); -- React Hooks

-- User 2's favorites (Bob)
INSERT INTO favorites (user_id, resource_id) VALUES
(2, 1),
(2, 3),
(2, 11),
(2, 16);

-- User 3's favorites (Charlie)
INSERT INTO favorites (user_id, resource_id) VALUES
(3, 2),
(3, 6),
(3, 11),
(3, 14);

-- User 4's favorites (Diana)
INSERT INTO favorites (user_id, resource_id) VALUES
(4, 3),
(4, 4),
(4, 12),
(4, 16);

-- User 5's favorites (Eve)
INSERT INTO favorites (user_id, resource_id) VALUES
(5, 1),
(5, 3),
(5, 13),
(5, 17);

-- User 6's favorites (Frank)
INSERT INTO favorites (user_id, resource_id) VALUES
(6, 2),
(6, 4),
(6, 8),
(6, 15);

-- User 7's favorites (Grace)
INSERT INTO favorites (user_id, resource_id) VALUES
(7, 6),
(7, 9),
(7, 16),
(7, 19);

-- User 8's favorites (Henry)
INSERT INTO favorites (user_id, resource_id) VALUES
(8, 3),
(8, 10),
(8, 16),
(8, 18);

-- ============================================
-- 8. VERIFICATION QUERIES
-- ============================================

-- Check total counts
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Categories', COUNT(*) FROM categories
UNION ALL
SELECT 'Resources', COUNT(*) FROM resources
UNION ALL
SELECT 'Ratings', COUNT(*) FROM ratings
UNION ALL
SELECT 'Comments', COUNT(*) FROM comments
UNION ALL
SELECT 'Favorites', COUNT(*) FROM favorites;

-- Show resources with their average ratings
SELECT 
    r.id,
    r.title,
    r.average_rating,
    r.view_count,
    r.download_count,
    COUNT(DISTINCT c.id) as comment_count,
    COUNT(DISTINCT f.id) as favorite_count
FROM resources r
LEFT JOIN comments c ON r.id = c.resource_id
LEFT JOIN favorites f ON r.id = f.resource_id
GROUP BY r.id, r.title, r.average_rating, r.view_count, r.download_count
ORDER BY r.id
LIMIT 10;

-- Show category distribution
SELECT 
    c.name,
    c.icon_emoji,
    COUNT(rc.resource_id) as resource_count
FROM categories c
LEFT JOIN resource_categories rc ON c.id = rc.category_id
GROUP BY c.id, c.name, c.icon_emoji
ORDER BY resource_count DESC;

-- ============================================
-- DONE!
-- ============================================

SELECT '✅ Mockup data inserted successfully!' as status;
SELECT '📊 Database is now populated with realistic test data' as message;
