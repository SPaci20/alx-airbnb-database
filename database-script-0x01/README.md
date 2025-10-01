Airbnb Schema (SQL DDL)
This document outlines the database schema for a system modeling core functionalities of a vacation rental platform (like Airbnb). The schema is defined using SQL Data Definition Language (DDL) and is designed to be compatible with PostgreSQL or MySQL.

Key Features
UUID Primary Keys: All primary keys use the UUID data type for global uniqueness.

Strong Constraints: Includes NOT NULL, UNIQUE, and CHECK constraints to ensure data integrity (e.g., email uniqueness, rating range 1−5, valid roles).

Referential Integrity: Foreign keys are defined with appropriate ON DELETE actions to manage related data cleanup.

Performance: Indexes are explicitly created on foreign key columns and the USER.email column for faster lookups.

Entities (Tables)
Entity

Description

Relationships

USER

Stores guest, host, and admin details. Includes unique email and role constraints.

1:N with PROPERTY (host), BOOKING, REVIEW, MESSAGE (sender/recipient)

PROPERTY

Details of the rental listings. Linked to the host via host_id.

1:N with BOOKING and REVIEW

BOOKING

Records reservations, linking a specific user to a specific property for a date range.

1:1 with PAYMENT; 1:N with USER and PROPERTY

PAYMENT

Records the transaction details for a booking. Uses a UNIQUE foreign key on booking_id to enforce a 1:1 relationship.

1:1 with BOOKING

REVIEW

Stores user ratings and comments on properties.

1:1 with USER and PROPERTY

MESSAGE

Facilitates communication between users (hosts and guests). Uses self-referencing foreign keys for sender_id and recipient_id.

N:1 with USER (two foreign keys)

