-- Create index on users.id (primary key, but included for completeness)
CREATE INDEX IF NOT EXISTS idx_users_id ON users(id);

-- Create index on bookings.user_id
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);

-- Create index on bookings.property_id
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings(property_id);

-- Create index on properties.id (primary key, but included for completeness)
CREATE INDEX IF NOT EXISTS idx_properties_id ON properties(id);

-- Create index on reviews.property_id
CREATE INDEX IF NOT EXISTS idx_reviews_property_id ON reviews(property_id);


-- ===============================================
-- PERFORMANCE MEASUREMENT USING EXPLAIN ANALYZE
-- ===============================================

-- Test 1: Query performance analysis for JOIN operations
-- This query tests the performance of JOINs that benefit from indexes

EXPLAIN ANALYZE
SELECT 
    u.first_name,
    u.last_name,
    u.email,
    b.booking_id,
    b.start_date,
    b.end_date,
    p.name AS property_name
FROM users u
INNER JOIN bookings b ON u.user_id = b.user_id
INNER JOIN properties p ON b.property_id = p.property_id
WHERE u.user_id = 1;

-- Test 2: Query performance analysis for aggregation with JOINs
-- This query tests the performance of aggregations that benefit from indexes

EXPLAIN ANALYZE
SELECT 
    p.property_id,
    p.name AS property_name,
    COUNT(b.booking_id) AS total_bookings,
    AVG(r.rating) AS average_rating
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
LEFT JOIN reviews r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name
ORDER BY total_bookings DESC;

-- Test 3: Query performance analysis for filtered searches
-- This query tests the performance of WHERE clauses that benefit from indexes

EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    u.first_name,
    u.last_name
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
WHERE b.property_id = 1
  AND b.start_date >= '2024-01-01'
ORDER BY b.start_date;

-- Test 4: Query performance analysis for reviews lookup
-- This query tests the performance of property-based review searches

EXPLAIN ANALYZE
SELECT 
    r.review_id,
    r.rating,
    r.comment,
    u.first_name,
    u.last_name,
    p.name AS property_name
FROM reviews r
INNER JOIN users u ON r.user_id = u.user_id
INNER JOIN properties p ON r.property_id = p.property_id
WHERE r.property_id = 1
ORDER BY r.rating DESC;

-- ===============================================
-- INSTRUCTIONS FOR PERFORMANCE TESTING
-- ===============================================

/*
To measure performance before and after adding indexes:

1. BEFORE ADDING INDEXES:
   - Drop all indexes first (except primary keys)
   - Run the EXPLAIN ANALYZE queries above
   - Note the execution times and query plans

2. AFTER ADDING INDEXES:
   - Create the indexes using the CREATE INDEX statements above
   - Run the same EXPLAIN ANALYZE queries again
   - Compare execution times and query plans

3. WHAT TO LOOK FOR:
   - Lower execution times (in milliseconds)
   - "Index Scan" instead of "Seq Scan" in query plans
   - Lower "cost" values in the execution plan
   - Fewer "rows" examined in the execution plan

Example command to drop indexes for testing:
DROP INDEX IF EXISTS idx_users_id;
DROP INDEX IF EXISTS idx_bookings_user_id;
DROP INDEX IF EXISTS idx_bookings_property_id;
DROP INDEX IF EXISTS idx_properties_id;
DROP INDEX IF EXISTS idx_reviews_property_id;
*/
