# ALX Airbnb Database — Advanced SQL Scripts

This project contains advanced SQL queries and database optimization scripts for the ALX Airbnb database project. Below is a summary of the tasks completed in this directory.

---

## 📁 1. Joins Queries (`joins_queries.sql`)

- **INNER JOIN**: Retrieves all bookings with respective user details.
- **LEFT JOIN**: Retrieves all properties and their reviews, including properties without reviews.
- **FULL OUTER JOIN**: Retrieves all users and all bookings, even if a user has no booking or a booking has no linked user.

---

## 📁 2. Subqueries (`subqueries.sql`)

- **Non-correlated Subquery**: Finds all properties where the average rating is greater than 4.0.
- **Correlated Subquery**: Retrieves users who have made more than 3 bookings.

---

## 📁 3. Aggregations & Window Functions (`aggregations_and_window_functions.sql`)

- **Aggregations**: Calculates total bookings made by each user using `COUNT` and `GROUP BY`.
- **Window Functions**: Ranks properties based on the number of bookings using `RANK()` with `OVER (ORDER BY)`.

---

## 📁 4. Index Performance (`database_index.sql`, `index_performance.md`)

- Created indexes on frequently used columns such as `user_id`, `property_id`, and `booking_id` to improve query performance.
- Measured performance before and after indexing using `EXPLAIN ANALYZE`.
- Documented query cost and execution time improvements in `index_performance.md`.

---

## 📁 5. Query Performance Optimization (`perfomance.sql`, `optimization_report.md`)

- Wrote a complex query retrieving bookings with user, property, and payment details.
- Analyzed performance using `EXPLAIN ANALYZE`.
- Refactored the query by reducing selected columns, using table aliases, and ensuring indexes existed.
- Reported improvements in `optimization_report.md`.

---

## 📁 6. Summary

This directory demonstrates practical application of:
- SQL joins (INNER, LEFT, FULL OUTER)
- Subqueries (correlated and non-correlated)
- Aggregations and window functions
- Database indexing for performance
- Query optimization and execution plan analysis

---

## 📄 Author

Pacifique Shimirwa — ALX Software Engineering Program  
