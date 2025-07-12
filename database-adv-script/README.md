# Advanced SQL Joins — ALX Airbnb Database

## Overview

This directory contains SQL scripts demonstrating the use of different types of joins on the ALX Airbnb database schema.

## Files

- `joins_queries.sql`: Contains SQL queries using INNER JOIN, LEFT JOIN, and FULL OUTER JOIN.
- `README.md`: Documentation for the queries and directory.

## Queries

1. **INNER JOIN**  
   Retrieves all bookings along with the users who made those bookings.

2. **LEFT JOIN**  
   Retrieves all properties and any associated reviews, including properties that have no reviews.

3. **FULL OUTER JOIN**  
   Retrieves all users and all bookings — displaying them even if a user has no bookings or a booking is not linked to a user.

## How to Run

Ensure you’re connected to your PostgreSQL or MySQL database, and execute the `joins_queries.sql` file:

```bash
psql -d your_database_name -f joins_queries.sql
