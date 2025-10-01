Sample Data Seed (sample_data.sql)
This SQL script is designed to populate the core tables of the Airbnb-like schema with realistic, connected data for testing and demonstration purposes. All Foreign Key relationships are maintained using hardcoded UUID variables.

Key Test Entities
The script creates three main user accounts to represent different roles:

Variable

User Name

Role

Purpose

@u_host_alice

Alice Smith

host

Owns properties and receives messages/bookings.

@u_guest_bob

Bob Jones

guest

Makes bookings and leaves reviews.

@u_admin_charlie

Charlie Admin

admin

Setup for testing admin-level access (no related transactions yet).

Data Summary
Table

Count

Details

PROPERTY

2

Alice hosts a 'Secluded Mountain Cabin' (Aspen) and a 'Downtown Loft' (NYC).

BOOKING

2

Bob has one confirmed booking and one pending booking, both for the Mountain Cabin.

PAYMENT

1

A $750.00 credit_card payment is recorded for the confirmed booking.

REVIEW

2

Bob has left a 5-star review for the Cabin and a 4-star review for the Loft.

MESSAGE

2

A two-way conversation thread exists between Bob (guest) and Alice (host).

This seed data provides a quick way to test joins between all tables and verify constraints like payment being strictly 1:1 with a confirmed booking.