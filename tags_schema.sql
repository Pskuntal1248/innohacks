
DROP TABLE IF EXISTS resource_tags CASCADE;
DROP TABLE IF EXISTS tags CASCADE;


CREATE TABLE tags (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_predefined BOOLEAN DEFAULT FALSE,
    created_by BIGINT,
    usage_count INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE resource_tags (
    resource_id BIGINT NOT NULL,
    tag_id BIGINT NOT NULL,
    PRIMARY KEY (resource_id, tag_id),
    FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

CREATE INDEX idx_tags_name ON tags(name);
CREATE INDEX idx_tags_is_predefined ON tags(is_predefined);
CREATE INDEX idx_tags_usage_count ON tags(usage_count DESC);
CREATE INDEX idx_tags_created_by ON tags(created_by);
CREATE INDEX idx_resource_tags_resource ON resource_tags(resource_id);
CREATE INDEX idx_resource_tags_tag ON resource_tags(tag_id);

-- ============================================
-- INSERT 150+ PREDEFINED TAGS
-- ============================================
-- These are organized by subject areas for RDBMS and educational content

-- Database & RDBMS Concepts
INSERT INTO tags (name, description, is_predefined) VALUES
('SQL', 'Structured Query Language basics and advanced topics', TRUE),
('Database-Design', 'Database design principles and normalization', TRUE),
('Normalization', 'Database normalization techniques (1NF, 2NF, 3NF, BCNF)', TRUE),
('ER-Diagram', 'Entity-Relationship diagrams and modeling', TRUE),
('Primary-Key', 'Primary key concepts and implementation', TRUE),
('Foreign-Key', 'Foreign key relationships and constraints', TRUE),
('Indexes', 'Database indexing for performance optimization', TRUE),
('Transactions', 'ACID properties and transaction management', TRUE),
('Stored-Procedures', 'Stored procedures and functions', TRUE),
('Triggers', 'Database triggers and automation', TRUE),
('Views', 'Database views and materialized views', TRUE),
('Query-Optimization', 'SQL query optimization techniques', TRUE),
('Joins', 'SQL JOIN operations (INNER, OUTER, CROSS)', TRUE),
('Subqueries', 'Nested queries and subqueries', TRUE),
('Aggregation', 'GROUP BY, HAVING, and aggregate functions', TRUE),
('Data-Types', 'SQL data types and constraints', TRUE),
('Constraints', 'CHECK, UNIQUE, NOT NULL constraints', TRUE),
('Relationships', 'One-to-One, One-to-Many, Many-to-Many', TRUE),
('Schema-Design', 'Database schema design patterns', TRUE),
('Backup-Recovery', 'Database backup and recovery strategies', TRUE),

-- Database Systems
('PostgreSQL', 'PostgreSQL specific content', TRUE),
('MySQL', 'MySQL specific content', TRUE),
('Oracle', 'Oracle Database specific content', TRUE),
('SQL-Server', 'Microsoft SQL Server specific content', TRUE),
('MongoDB', 'MongoDB and NoSQL databases', TRUE),
('NoSQL', 'NoSQL database concepts', TRUE),
('Redis', 'Redis in-memory database', TRUE),
('SQLite', 'SQLite database', TRUE),

-- Programming Languages
('Java', 'Java programming language', TRUE),
('Python', 'Python programming language', TRUE),
('JavaScript', 'JavaScript programming', TRUE),
('TypeScript', 'TypeScript programming', TRUE),
('C-Sharp', 'C# programming language', TRUE),
('PHP', 'PHP programming language', TRUE),
('Ruby', 'Ruby programming language', TRUE),
('Go', 'Go programming language', TRUE),
('Rust', 'Rust programming language', TRUE),
('Kotlin', 'Kotlin programming language', TRUE),

-- Web Development
('HTML', 'HTML markup language', TRUE),
('CSS', 'CSS styling', TRUE),
('React', 'React framework', TRUE),
('Angular', 'Angular framework', TRUE),
('Vue', 'Vue.js framework', TRUE),
('Node-JS', 'Node.js backend development', TRUE),
('Express', 'Express.js framework', TRUE),
('Spring-Boot', 'Spring Boot framework', TRUE),
('Django', 'Django framework', TRUE),
('Flask', 'Flask framework', TRUE),
('REST-API', 'RESTful API design and development', TRUE),
('GraphQL', 'GraphQL API', TRUE),
('Microservices', 'Microservices architecture', TRUE),

-- Data Structures & Algorithms
('Data-Structures', 'Data structures concepts', TRUE),
('Algorithms', 'Algorithm design and analysis', TRUE),
('Arrays', 'Array data structure', TRUE),
('Linked-Lists', 'Linked list data structure', TRUE),
('Trees', 'Tree data structures', TRUE),
('Graphs', 'Graph algorithms', TRUE),
('Sorting', 'Sorting algorithms', TRUE),
('Searching', 'Searching algorithms', TRUE),
('Dynamic-Programming', 'Dynamic programming techniques', TRUE),
('Recursion', 'Recursive algorithms', TRUE),
('Hash-Tables', 'Hash tables and hashing', TRUE),
('Stacks-Queues', 'Stack and Queue data structures', TRUE),

-- Software Engineering
('OOP', 'Object-Oriented Programming', TRUE),
('Design-Patterns', 'Software design patterns', TRUE),
('SOLID-Principles', 'SOLID design principles', TRUE),
('Clean-Code', 'Clean code practices', TRUE),
('Testing', 'Software testing', TRUE),
('Unit-Testing', 'Unit testing practices', TRUE),
('TDD', 'Test-Driven Development', TRUE),
('Agile', 'Agile methodologies', TRUE),
('Git', 'Git version control', TRUE),
('CI-CD', 'Continuous Integration/Deployment', TRUE),
('DevOps', 'DevOps practices', TRUE),
('Docker', 'Docker containerization', TRUE),
('Kubernetes', 'Kubernetes orchestration', TRUE),

-- Academic Levels
('Beginner', 'Beginner level content', TRUE),
('Intermediate', 'Intermediate level content', TRUE),
('Advanced', 'Advanced level content', TRUE),
('Tutorial', 'Tutorial or how-to guide', TRUE),
('Reference', 'Reference material', TRUE),
('Cheat-Sheet', 'Quick reference cheat sheet', TRUE),
('Exercise', 'Practice exercises', TRUE),
('Project', 'Project-based learning', TRUE),
('Assignment', 'Assignment or homework', TRUE),
('Exam-Prep', 'Exam preparation material', TRUE),

-- Content Types
('Lecture-Notes', 'Lecture notes from class', TRUE),
('Slides', 'Presentation slides', TRUE),
('Code-Examples', 'Code examples and samples', TRUE),
('Video-Transcript', 'Video transcripts', TRUE),
('Research-Paper', 'Research papers and articles', TRUE),
('Book-Chapter', 'Book chapters', TRUE),
('Documentation', 'Technical documentation', TRUE),
('Lab-Exercise', 'Laboratory exercises', TRUE),
('Case-Study', 'Case studies', TRUE),
('Workshop', 'Workshop materials', TRUE),

-- Topics & Domains
('Machine-Learning', 'Machine learning concepts', TRUE),
('Artificial-Intelligence', 'AI topics', TRUE),
('Data-Science', 'Data science and analytics', TRUE),
('Big-Data', 'Big data technologies', TRUE),
('Cloud-Computing', 'Cloud computing platforms', TRUE),
('AWS', 'Amazon Web Services', TRUE),
('Azure', 'Microsoft Azure', TRUE),
('GCP', 'Google Cloud Platform', TRUE),
('Cybersecurity', 'Security and encryption', TRUE),
('Networking', 'Computer networking', TRUE),
('Operating-Systems', 'OS concepts', TRUE),
('Linux', 'Linux operating system', TRUE),
('Windows', 'Windows operating system', TRUE),
('Mobile-Development', 'Mobile app development', TRUE),
('Android', 'Android development', TRUE),
('iOS', 'iOS development', TRUE),

-- Specific Database Topics
('ACID', 'ACID properties in databases', TRUE),
('CAP-Theorem', 'CAP theorem in distributed systems', TRUE),
('Sharding', 'Database sharding techniques', TRUE),
('Replication', 'Database replication', TRUE),
('Partitioning', 'Data partitioning strategies', TRUE),
('Concurrency-Control', 'Concurrency control mechanisms', TRUE),
('Locking', 'Database locking mechanisms', TRUE),
('Deadlock', 'Deadlock detection and prevention', TRUE),
('MVCC', 'Multi-Version Concurrency Control', TRUE),
('Data-Warehousing', 'Data warehouse concepts', TRUE),
('ETL', 'Extract, Transform, Load processes', TRUE),
('OLAP', 'Online Analytical Processing', TRUE),
('OLTP', 'Online Transaction Processing', TRUE),

-- Additional Programming Concepts
('Functional-Programming', 'Functional programming paradigm', TRUE),
('Async-Programming', 'Asynchronous programming', TRUE),
('Multi-Threading', 'Multi-threading concepts', TRUE),
('Memory-Management', 'Memory management techniques', TRUE),
('Performance-Optimization', 'Performance optimization', TRUE),
('Code-Review', 'Code review practices', TRUE),
('Debugging', 'Debugging techniques', TRUE),
('Logging', 'Application logging', TRUE),
('Error-Handling', 'Error handling patterns', TRUE),
('Security', 'Application security', TRUE),
('Authentication', 'User authentication', TRUE),
('Authorization', 'User authorization', TRUE),
('OAuth', 'OAuth authentication protocol', TRUE),
('JWT', 'JSON Web Tokens', TRUE),

-- Mathematics & Theory
('Discrete-Mathematics', 'Discrete math concepts', TRUE),
('Linear-Algebra', 'Linear algebra', TRUE),
('Calculus', 'Calculus concepts', TRUE),
('Statistics', 'Statistical analysis', TRUE),
('Probability', 'Probability theory', TRUE),
('Complexity-Theory', 'Computational complexity', TRUE),
('Big-O-Notation', 'Algorithm complexity notation', TRUE),

-- Tools & Technologies
('VS-Code', 'Visual Studio Code editor', TRUE),
('IntelliJ', 'IntelliJ IDEA IDE', TRUE),
('Postman', 'API testing with Postman', TRUE),
('JUnit', 'JUnit testing framework', TRUE),
('Maven', 'Maven build tool', TRUE),
('Gradle', 'Gradle build tool', TRUE),
('NPM', 'Node Package Manager', TRUE),
('Webpack', 'Webpack bundler', TRUE),
('Babel', 'Babel JavaScript compiler', TRUE);

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Count predefined tags
SELECT COUNT(*) as predefined_tag_count 
FROM tags 
WHERE is_predefined = TRUE;

-- List all tags
SELECT id, name, description, is_predefined, usage_count 
FROM tags 
ORDER BY name;

-- Show table structure
\d tags
\d resource_tags

-- ============================================
-- SCRIPT COMPLETE
-- ============================================
-- Tags system successfully added!
-- 150+ predefined tags inserted
-- Teachers can now create custom tags
-- Resources can be tagged for better search and recommendations
-- ============================================
