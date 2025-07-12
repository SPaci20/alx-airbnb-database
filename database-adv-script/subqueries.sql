-- 1️⃣ Non-Correlated Subquery:
-- Find all properties where the average rating is greater than 4.0

SELECT 
    properties.id,
    properties.name,
    properties.location
FROM properties
WHERE properties.id IN (
    SELECT 
        reviews.property_id
    FROM reviews
    GROUP BY reviews.property_id
    HAVING AVG(reviews.rating) > 4.0
);


-- 2️⃣ Correlated Subquery:
-- Find users who have made more than 3 bookings

SELECT 
    users.id,
    users.first_name,
    users.last_name
FROM users
WHERE (
    SELECT COUNT(*) 
    FROM bookings 
    WHERE bookings.user_id = users.id
) > 3;