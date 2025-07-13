-- ===============================================
-- TABLE PARTITIONING IMPLEMENTATION
-- ALX Airbnb Database - Booking Table Optimization
-- ===============================================

-- ===============================================
-- STEP 1: CREATE PARTITIONED BOOKING TABLE
-- ===============================================

-- First, let's create a backup of existing data (if any)
CREATE TABLE bookings_backup AS SELECT * FROM bookings;

-- Drop the existing bookings table to recreate as partitioned
DROP TABLE IF EXISTS bookings CASCADE;

-- Create the main partitioned bookings table
CREATE TABLE bookings (
    booking_id SERIAL,
    property_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT bookings_pkey PRIMARY KEY (booking_id, start_date),
    CONSTRAINT bookings_user_fkey FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT bookings_property_fkey FOREIGN KEY (property_id) REFERENCES properties(property_id),
    CONSTRAINT bookings_dates_check CHECK (end_date > start_date),
    CONSTRAINT bookings_status_check CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled'))
) PARTITION BY RANGE (start_date);

-- ===============================================
-- STEP 2: CREATE PARTITIONS BY DATE RANGES
-- ===============================================

-- Create partitions for different date ranges
-- Partition for 2023 bookings
CREATE TABLE bookings_2023 PARTITION OF bookings
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

-- Partition for Q1 2024 (January - March)
CREATE TABLE bookings_2024_q1 PARTITION OF bookings
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

-- Partition for Q2 2024 (April - June)
CREATE TABLE bookings_2024_q2 PARTITION OF bookings
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

-- Partition for Q3 2024 (July - September)
CREATE TABLE bookings_2024_q3 PARTITION OF bookings
    FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');

-- Partition for Q4 2024 (October - December)
CREATE TABLE bookings_2024_q4 PARTITION OF bookings
    FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');

-- Partition for 2025 bookings
CREATE TABLE bookings_2025 PARTITION OF bookings
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Default partition for future dates
CREATE TABLE bookings_default PARTITION OF bookings DEFAULT;

-- ===============================================
-- STEP 3: CREATE INDEXES ON PARTITIONED TABLE
-- ===============================================

-- Create indexes on the main table (will be inherited by partitions)
CREATE INDEX idx_bookings_start_date ON bookings (start_date);
CREATE INDEX idx_bookings_user_id ON bookings (user_id);
CREATE INDEX idx_bookings_property_id ON bookings (property_id);
CREATE INDEX idx_bookings_status ON bookings (status);
CREATE INDEX idx_bookings_end_date ON bookings (end_date);

-- Create composite indexes for common query patterns
CREATE INDEX idx_bookings_property_date ON bookings (property_id, start_date);
CREATE INDEX idx_bookings_user_date ON bookings (user_id, start_date);
CREATE INDEX idx_bookings_status_date ON bookings (status, start_date);

-- ===============================================
-- STEP 4: INSERT SAMPLE DATA FOR TESTING
-- ===============================================

-- Insert sample data across different partitions
INSERT INTO bookings (property_id, user_id, start_date, end_date, total_price, status) VALUES
-- 2023 data
(1, 1, '2023-06-15', '2023-06-20', 750.00, 'completed'),
(2, 2, '2023-08-10', '2023-08-15', 1500.00, 'completed'),
(3, 3, '2023-12-20', '2023-12-25', 1000.00, 'completed'),

-- 2024 Q1 data
(1, 2, '2024-01-15', '2024-01-20', 750.00, 'completed'),
(2, 3, '2024-02-10', '2024-02-15', 1500.00, 'completed'),
(3, 1, '2024-03-05', '2024-03-10', 1000.00, 'confirmed'),

-- 2024 Q2 data
(1, 3, '2024-04-15', '2024-04-20', 750.00, 'confirmed'),
(2, 1, '2024-05-10', '2024-05-15', 1500.00, 'confirmed'),
(3, 2, '2024-06-05', '2024-06-10', 1000.00, 'pending'),

-- 2024 Q3 data
(1, 2, '2024-07-15', '2024-07-20', 750.00, 'confirmed'),
(2, 3, '2024-08-10', '2024-08-15', 1500.00, 'pending'),
(3, 1, '2024-09-05', '2024-09-10', 1000.00, 'confirmed'),

-- 2024 Q4 data
(1, 3, '2024-10-15', '2024-10-20', 750.00, 'confirmed'),
(2, 1, '2024-11-10', '2024-11-15', 1500.00, 'pending'),
(3, 2, '2024-12-05', '2024-12-10', 1000.00, 'confirmed'),

-- 2025 data
(1, 1, '2025-01-15', '2025-01-20', 800.00, 'confirmed'),
(2, 2, '2025-02-10', '2025-02-15', 1600.00, 'pending'),
(3, 3, '2025-06-15', '2025-06-20', 1200.00, 'confirmed');

-- ===============================================
-- STEP 5: PERFORMANCE TESTING QUERIES
-- ===============================================

-- Enable query timing and analysis
\timing on

-- ===============================================
-- TEST 1: Date Range Query (Should use partition pruning)
-- ===============================================

-- Query 1: Fetch bookings for Q1 2024 (should only scan bookings_2024_q1 partition)
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT 
    booking_id,
    property_id,
    user_id,
    start_date,
    end_date,
    total_price,
    status
FROM bookings
WHERE start_date >= '2024-01-01' 
  AND start_date < '2024-04-01'
ORDER BY start_date;

-- Query 2: Fetch bookings for a specific month (should use partition pruning)
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT 
    booking_id,
    start_date,
    end_date,
    total_price
FROM bookings
WHERE start_date >= '2024-06-01' 
  AND start_date < '2024-07-01'
  AND status = 'confirmed';

-- ===============================================
-- TEST 2: Cross-Partition Query Performance
-- ===============================================

-- Query 3: Fetch bookings across multiple partitions
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT 
    booking_id,
    property_id,
    start_date,
    end_date,
    status
FROM bookings
WHERE start_date >= '2024-01-01' 
  AND start_date <= '2024-12-31'
  AND property_id = 1
ORDER BY start_date;

-- Query 4: Aggregation query across partitions
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT 
    DATE_TRUNC('month', start_date) AS booking_month,
    COUNT(*) AS total_bookings,
    SUM(total_price) AS total_revenue,
    AVG(total_price) AS average_booking_value
FROM bookings
WHERE start_date >= '2024-01-01' 
  AND start_date <= '2024-12-31'
GROUP BY DATE_TRUNC('month', start_date)
ORDER BY booking_month;

-- ===============================================
-- TEST 3: JOIN Performance with Partitioned Table
-- ===============================================

-- Query 5: JOIN with users table
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT 
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
WHERE b.start_date >= '2024-06-01' 
  AND b.start_date < '2024-09-01'
  AND b.status = 'confirmed'
ORDER BY b.start_date;

-- Query 6: Complex JOIN with multiple tables
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT 
    p.name AS property_name,
    p.location,
    u.first_name || ' ' || u.last_name AS guest_name,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN properties p ON b.property_id = p.property_id
WHERE b.start_date >= '2024-07-01' 
  AND b.start_date < '2024-10-01'
ORDER BY b.start_date DESC;

-- ===============================================
-- TEST 4: Partition-Specific Queries
-- ===============================================

-- Query 7: Direct partition access (most efficient)
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT COUNT(*) AS q1_2024_bookings
FROM bookings_2024_q1;

-- Query 8: Partition comparison
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT 
    'Q1 2024' AS quarter,
    COUNT(*) AS booking_count,
    SUM(total_price) AS total_revenue
FROM bookings_2024_q1
UNION ALL
SELECT 
    'Q2 2024' AS quarter,
    COUNT(*) AS booking_count,
    SUM(total_price) AS total_revenue
FROM bookings_2024_q2
UNION ALL
SELECT 
    'Q3 2024' AS quarter,
    COUNT(*) AS booking_count,
    SUM(total_price) AS total_revenue
FROM bookings_2024_q3;

-- ===============================================
-- TEST 5: Maintenance Operations on Partitions
-- ===============================================

-- Query 9: Partition maintenance - Check partition sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables 
WHERE tablename LIKE 'bookings%'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Query 10: Partition constraint verification
SELECT 
    tableowner,
    tablename,
    partitionkey,
    partitionrangestart,
    partitionrangeend
FROM pg_partitions 
WHERE tablename LIKE 'bookings%';

-- ===============================================
-- PARTITION PRUNING VERIFICATION
-- ===============================================

-- Enable partition pruning logging (PostgreSQL 11+)
SET enable_partition_pruning = on;
SET constraint_exclusion = partition;

-- Verify partition pruning is working
EXPLAIN (ANALYZE, BUFFERS, VERBOSE, COSTS OFF)
SELECT COUNT(*) 
FROM bookings 
WHERE start_date = '2024-06-15';

-- Show which partitions are being accessed
SELECT COUNT(*) FROM bookings WHERE start_date >= '2024-01-01' AND start_date < '2024-04-01'; -- Should only access bookings_2024_q1
SELECT COUNT(*) FROM bookings WHERE start_date >= '2024-07-01' AND start_date < '2024-10-01'; -- Should only access bookings_2024_q3

\timing off

-- ===============================================
-- UTILITY FUNCTIONS FOR PARTITION MANAGEMENT
-- ===============================================

-- Function to automatically create monthly partitions
CREATE OR REPLACE FUNCTION create_monthly_partition(start_date DATE)
RETURNS VOID AS $$
DECLARE
    partition_name TEXT;
    start_range DATE;
    end_range DATE;
BEGIN
    start_range := DATE_TRUNC('month', start_date);
    end_range := start_range + INTERVAL '1 month';
    partition_name := 'bookings_' || TO_CHAR(start_range, 'YYYY_MM');
    
    EXECUTE format('CREATE TABLE %I PARTITION OF bookings
                    FOR VALUES FROM (%L) TO (%L)',
                   partition_name, start_range, end_range);
                   
    RAISE NOTICE 'Created partition % for range % to %', partition_name, start_range, end_range;
END;
$$ LANGUAGE plpgsql;

-- Example usage: Create partition for March 2025
-- SELECT create_monthly_partition('2025-03-01');

-- ===============================================
-- NOTES AND BEST PRACTICES
-- ===============================================

/*
PARTITIONING BENEFITS:
1. Improved query performance through partition pruning
2. Faster maintenance operations (VACUUM, REINDEX)
3. Parallel query execution across partitions
4. Easier data archival and deletion
5. Better concurrent access patterns

BEST PRACTICES IMPLEMENTED:
1. Partition key (start_date) is part of most WHERE clauses
2. Logical partition boundaries (quarterly/monthly)
3. Appropriate indexes on each partition
4. Constraint exclusion enabled
5. Regular partition maintenance planned

PERFORMANCE CONSIDERATIONS:
1. Queries spanning multiple partitions may be slower
2. Unique constraints must include partition key
3. Foreign keys require careful planning
4. Cross-partition JOINs can be expensive
5. Partition pruning depends on query structure
*/
