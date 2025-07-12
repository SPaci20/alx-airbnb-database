-- Drop tables if they exist (to reset)
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS properties;
DROP TABLE IF EXISTS users;

-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE
);

-- Create properties table
CREATE TABLE properties (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    location VARCHAR(100)
);

-- Create bookings table
CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    property_id INTEGER REFERENCES properties(id),
    start_date DATE,
    end_date DATE
);

-- Create reviews table
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    property_id INTEGER REFERENCES properties(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT
);

-- Insert sample users
INSERT INTO users (first_name, last_name, email) VALUES
('Alice', 'Smith', 'alice@example.com'),
('Bob', 'Johnson', 'bob@example.com'),
('Carol', 'Davis', 'carol@example.com');

-- Insert sample properties
INSERT INTO properties (name, location) VALUES
('Cozy Cottage', 'Kigali'),
('Beach House', 'Gisenyi'),
('Mountain Cabin', 'Musanze');

-- Insert sample bookings
INSERT INTO bookings (user_id, property_id, start_date, end_date) VALUES
(1, 1, '2025-07-01', '2025-07-07'),
(1, 2, '2025-08-01', '2025-08-10'),
(2, 1, '2025-07-15', '2025-07-20'),
(3, 3, '2025-09-05', '2025-09-12'),
(1, 3, '2025-10-01', '2025-10-05');

-- Insert sample reviews
INSERT INTO reviews (property_id, rating, comment) VALUES
(1, 5, 'Great place!'),
(2, 4, 'Nice and cozy.'),
(3, 3, 'Good but a bit cold.');
