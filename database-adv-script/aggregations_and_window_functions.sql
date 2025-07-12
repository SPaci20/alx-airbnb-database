-- 1️⃣ Aggregation: Total number of bookings made by each user

SELECT 
    users.id AS user_id,
    users.first_name,
    users.last_name,
    COUNT(bookings.id) AS total_bookings
FROM users
LEFT JOIN bookings ON users.id = bookings.user_id
GROUP BY users.id, users.first_name, users.last_name
ORDER BY total_bookings DESC;


-- 2️⃣ Window Function: Rank properties based on the total number of bookings

SELECT 
    properties.id AS property_id,
    properties.name AS property_name,
    COUNT(bookings.id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(bookings.id) DESC) AS rank
FROM properties
LEFT JOIN bookings ON properties.id = bookings.property_id
GROUP BY properties.id, properties.name
ORDER BY rank;
