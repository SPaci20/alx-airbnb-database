-- ===============================================
-- QUERY PERFORMANCE OPTIMIZATION
-- ALX Airbnb Database - Performance Analysis
-- ===============================================

-- ===============================================
-- INITIAL COMPLEX QUERY (UNOPTIMIZED)
-- ===============================================

-- Initial Query: Retrieve all bookings with user details, property details, and payment details
-- This query demonstrates common performance issues

EXPLAIN ANALYZE
SELECT 
    -- Booking information
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status AS booking_status,
    b.created_at AS booking_created,
    
    -- User information
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role AS user_role,
    u.created_at AS user_created,
    
    -- Property information
    p.property_id,
    p.name AS property_name,
    p.description AS property_description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created,
    
    -- Host information (property owner)
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    
    -- Payment information
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method,
    
    -- Additional property stats (expensive calculations)
    (SELECT COUNT(*) FROM reviews r WHERE r.property_id = p.property_id) AS total_reviews,
    (SELECT AVG(rating) FROM reviews r WHERE r.property_id = p.property_id) AS avg_rating,
    (SELECT COUNT(*) FROM bookings b2 WHERE b2.property_id = p.property_id) AS total_bookings_for_property

FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN properties p ON b.property_id = p.property_id
INNER JOIN users h ON p.host_id = h.user_id  -- Host details
LEFT JOIN payments pay ON b.booking_id = pay.booking_id
WHERE b.status IN ('confirmed', 'completed')
  AND b.start_date >= '2024-01-01'
  AND u.role = 'guest'
ORDER BY b.created_at DESC, p.property_id;


-- ===============================================
-- PERFORMANCE ANALYSIS QUERIES
-- ===============================================

-- Analyze the query execution plan and identify bottlenecks
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    u.first_name,
    u.last_name,
    p.name AS property_name,
    pay.amount AS payment_amount
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed';


-- ===============================================
-- OPTIMIZED QUERIES - VERSION 1
-- ===============================================

-- Optimized Query 1: Remove unnecessary columns and joins
-- Focus only on essential data to reduce I/O

EXPLAIN ANALYZE
SELECT 
    -- Essential booking information only
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    -- Essential user information
    u.first_name,
    u.last_name,
    u.email,
    
    -- Essential property information
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    
    -- Payment amount only (most important payment info)
    pay.amount AS payment_amount

FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON b.booking_id = pay.booking_id
WHERE b.status IN ('confirmed', 'completed')
  AND b.start_date >= '2024-01-01'
ORDER BY b.start_date DESC;


-- ===============================================
-- OPTIMIZED QUERIES - VERSION 2
-- ===============================================

-- Optimized Query 2: Use subqueries for optional data
-- Separate expensive calculations into conditional subqueries

EXPLAIN ANALYZE
SELECT 
    booking_data.booking_id,
    booking_data.start_date,
    booking_data.end_date,
    booking_data.user_name,
    booking_data.property_name,
    booking_data.location,
    payment_data.payment_amount
FROM (
    -- Core booking data (fast)
    SELECT 
        b.booking_id,
        b.start_date,
        b.end_date,
        b.total_price,
        CONCAT(u.first_name, ' ', u.last_name) AS user_name,
        p.name AS property_name,
        p.location
    FROM bookings b
    INNER JOIN users u ON b.user_id = u.user_id
    INNER JOIN properties p ON b.property_id = p.property_id
    WHERE b.status = 'confirmed'
      AND b.start_date >= '2024-01-01'
) AS booking_data
LEFT JOIN (
    -- Payment data (separate query)
    SELECT 
        booking_id,
        amount AS payment_amount
    FROM payments
    WHERE payment_date >= '2024-01-01'
) AS payment_data ON booking_data.booking_id = payment_data.booking_id
ORDER BY booking_data.start_date DESC;


-- ===============================================
-- OPTIMIZED QUERIES - VERSION 3
-- ===============================================

-- Optimized Query 3: Use window functions instead of correlated subqueries
-- Replace expensive subqueries with window functions

EXPLAIN ANALYZE
SELECT DISTINCT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    u.first_name,
    u.last_name,
    p.name AS property_name,
    p.location,
    pay.amount AS payment_amount,
    
    -- Use window functions for aggregations (more efficient)
    COUNT(r.review_id) OVER (PARTITION BY p.property_id) AS total_reviews,
    AVG(r.rating) OVER (PARTITION BY p.property_id) AS avg_rating

FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON b.booking_id = pay.booking_id
LEFT JOIN reviews r ON p.property_id = r.property_id
WHERE b.status = 'confirmed'
  AND b.start_date >= '2024-01-01'
ORDER BY b.start_date DESC;


-- ===============================================
-- OPTIMIZED QUERIES - VERSION 4 (MOST EFFICIENT)
-- ===============================================

-- Optimized Query 4: Limit results and use appropriate indexes
-- Add LIMIT and ensure proper indexing

EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    u.first_name || ' ' || u.last_name AS guest_name,
    p.name AS property_name,
    p.location,
    pay.amount AS payment_amount

FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON b.booking_id = pay.booking_id

WHERE b.status = 'confirmed'
  AND b.start_date >= CURRENT_DATE - INTERVAL '1 year'
  
ORDER BY b.start_date DESC
LIMIT 100;  -- Limit results for better performance


-- ===============================================
-- INDEX RECOMMENDATIONS FOR OPTIMIZATION
-- ===============================================

-- Create composite indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_bookings_status_start_date ON bookings(status, start_date);
CREATE INDEX IF NOT EXISTS idx_bookings_user_property ON bookings(user_id, property_id);
CREATE INDEX IF NOT EXISTS idx_payments_booking_date ON payments(booking_id, payment_date);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_properties_host ON properties(host_id);
CREATE INDEX IF NOT EXISTS idx_reviews_property_rating ON reviews(property_id, rating);

-- ===============================================
-- PERFORMANCE COMPARISON QUERIES
-- ===============================================

-- Query to compare execution times
-- Run these before and after optimization

-- Before optimization (baseline)
\timing on

SELECT COUNT(*) as total_complex_query_rows
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN properties p ON b.property_id = p.property_id
INNER JOIN users h ON p.host_id = h.user_id
LEFT JOIN payments pay ON b.booking_id = pay.booking_id
WHERE b.status IN ('confirmed', 'completed')
  AND b.start_date >= '2024-01-01';

-- After optimization (optimized)
SELECT COUNT(*) as total_optimized_query_rows
FROM bookings b
WHERE b.status = 'confirmed'
  AND b.start_date >= '2024-01-01';

\timing off

-- ===============================================
-- NOTES FOR PERFORMANCE TESTING
-- ===============================================

/*
PERFORMANCE TESTING STEPS:

1. Run the initial complex query and note:
   - Execution time
   - Number of rows examined
   - Type of scans used (Seq Scan vs Index Scan)
   - Buffer usage

2. Apply the optimizations one by one:
   - Remove unnecessary columns/joins
   - Replace correlated subqueries with window functions
   - Add appropriate indexes
   - Add LIMIT clauses where appropriate

3. Compare performance metrics:
   - Look for reduced execution time
   - Verify index usage in EXPLAIN plans
   - Check for reduced buffer usage
   - Monitor CPU and memory usage

4. Key optimization techniques applied:
   - Reduced SELECT columns
   - Eliminated unnecessary JOINs
   - Replaced correlated subqueries with window functions
   - Added composite indexes
   - Used LIMIT for pagination
   - Optimized WHERE clause conditions
*/
