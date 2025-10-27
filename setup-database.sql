-- Create database for DevOps project
CREATE DATABASE devops_db;

-- Connect to the database
\c devops_db;

-- Create a simple test table to verify connection
CREATE TABLE IF NOT EXISTS connection_test (
    id SERIAL PRIMARY KEY,
    message VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test data
INSERT INTO connection_test (message) VALUES ('Database connection successful!');

-- Show confirmation
SELECT * FROM connection_test;