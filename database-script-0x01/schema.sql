-- ==================================================================================
-- Airbnb Database Schema Definition (SQL DDL)
-- Target RDBMS: Compatible with PostgreSQL/MySQL syntax for constraints and types.
-- ==================================================================================

-- ----------------------------------------------------------------------------------
-- 1. USER Table
-- ----------------------------------------------------------------------------------

CREATE TABLE "USER" (
    user_id UUID PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role VARCHAR(50) NOT NULL, -- Simulating ENUM(guest, host, admin)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- ENUM constraint simulation
    CONSTRAINT chk_user_role CHECK (role IN ('guest', 'host', 'admin'))
);

-- Indexing for lookup on email, as specified
CREATE UNIQUE INDEX idx_user_email ON "USER" (email);


-- ----------------------------------------------------------------------------------
-- 2. PROPERTY Table
-- ----------------------------------------------------------------------------------

CREATE TABLE PROPERTY (
    property_id UUID PRIMARY KEY,
    host_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    pricepernight DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Note: ON UPDATE CURRENT_TIMESTAMP syntax is RDBMS-specific. 
    -- This representation is common in MySQL/MariaDB.
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,

    -- Foreign Key Constraint
    FOREIGN KEY (host_id) REFERENCES "USER"(user_id)
        ON DELETE CASCADE -- If a host user is deleted, their properties are also deleted
);

-- Indexing for lookup by host
CREATE INDEX idx_property_host_id ON PROPERTY (host_id);


-- ----------------------------------------------------------------------------------
-- 3. BOOKING Table
-- ----------------------------------------------------------------------------------

CREATE TABLE BOOKING (
    booking_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL, -- Simulating ENUM(pending, confirmed, canceled)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraints
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id)
        ON DELETE RESTRICT, -- Prevent deleting property if active bookings exist
    FOREIGN KEY (user_id) REFERENCES "USER"(user_id)
        ON DELETE CASCADE,

    -- ENUM constraint simulation
    CONSTRAINT chk_booking_status CHECK (status IN ('pending', 'confirmed', 'canceled')),

    -- Logical Constraint: start date must be before end date
    CONSTRAINT chk_dates CHECK (start_date < end_date)
);

-- Indexing for performance lookups
CREATE INDEX idx_booking_property_id ON BOOKING (property_id);
CREATE INDEX idx_booking_user_id ON BOOKING (user_id);


-- ----------------------------------------------------------------------------------
-- 4. PAYMENT Table
-- ----------------------------------------------------------------------------------

CREATE TABLE PAYMENT (
    payment_id UUID PRIMARY KEY,
    booking_id UUID UNIQUE NOT NULL, -- UNIQUE ensures a strict 1:1 relationship with BOOKING
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50) NOT NULL, -- Simulating ENUM(credit_card, paypal, stripe)

    -- Foreign Key Constraint
    FOREIGN KEY (booking_id) REFERENCES BOOKING(booking_id)
        ON DELETE CASCADE, -- Payment must be deleted if the corresponding booking is deleted

    -- ENUM constraint simulation
    CONSTRAINT chk_payment_method CHECK (payment_method IN ('credit_card', 'paypal', 'stripe'))
);

-- Indexing on booking_id for quick payment lookup
CREATE UNIQUE INDEX idx_payment_booking_id ON PAYMENT (booking_id);


-- ----------------------------------------------------------------------------------
-- 5. REVIEW Table
-- ----------------------------------------------------------------------------------

CREATE TABLE REVIEW (
    review_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraints
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id)
        ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES "USER"(user_id)
        ON DELETE CASCADE,

    -- Constraint on rating value
    CONSTRAINT chk_review_rating CHECK (rating >= 1 AND rating <= 5)
);

-- Indexing for performance lookups
CREATE INDEX idx_review_property_id ON REVIEW (property_id);
CREATE INDEX idx_review_user_id ON REVIEW (user_id);


-- ----------------------------------------------------------------------------------
-- 6. MESSAGE Table
-- ----------------------------------------------------------------------------------

CREATE TABLE MESSAGE (
    message_id UUID PRIMARY KEY,
    sender_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraints (Self-referential to USER table)
    FOREIGN KEY (sender_id) REFERENCES "USER"(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES "USER"(user_id)
        ON DELETE CASCADE,

    -- Optional: Ensure sender is not recipient (though often allowed in real apps)
    CONSTRAINT chk_different_parties CHECK (sender_id <> recipient_id)
);

-- Indexing for quick message retrieval by sender or recipient
CREATE INDEX idx_message_sender_id ON MESSAGE (sender_id);
CREATE INDEX idx_message_recipient_id ON MESSAGE (recipient_id);
