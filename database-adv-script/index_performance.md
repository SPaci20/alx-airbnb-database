# Index Performance Analysis — ALX Airbnb Database

## Overview

This document explains the indexing strategy applied to improve query performance in the ALX Airbnb database, focusing on high-usage columns used in JOIN, WHERE, and ORDER BY clauses.

## Indexes Created

- `users.id` — Frequently used in JOIN and WHERE conditions.
- `bookings.user_id` — Often used in JOINs and WHERE conditions.
- `bookings.property_id` — Frequently involved in JOINs.
- `properties.id` — Used in JOIN and ORDER BY clauses.
- `reviews.property_id` — Involved in JOIN operations.

## SQL Commands

Indexes were created using:

```sql
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
