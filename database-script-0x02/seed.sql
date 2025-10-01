-- ==================================================================================
-- Sample Data Inserts
-- Note: UUIDs are hardcoded here for demonstrative purposes to ensure 
-- referential integrity between the INSERT statements.
-- ==================================================================================

-- ----------------------------
-- Sample UUIDs
-- ----------------------------
-- USERS
-- Alice is a Host
SET @u_host_alice = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
-- Bob is a Guest
SET @u_guest_bob = 'b1fde0c1-3a0f-4b7c-b03a-0e9bd28d11b2';
-- Charlie is an Admin
SET @u_admin_charlie = 'c20d7e5d-4a1c-4d8e-a2b1-5f0c1d634c23';

-- PROPERTY
SET @p_cabin = 'd31f0c2a-5a2e-4e6f-a991-8d2b7e190f34';

-- BOOKING
SET @b_cabin_1 = 'e42f7c0b-6d3a-4f5c-8b1d-9c3f0a401e56';

-- PAYMENT
SET @pay_1 = 'f53d9e8c-7b4a-4d7e-9c2f-0d5b1e602f78';

-- REVIEW
SET @rev_1 = 'a64e1f9d-8c5b-4e8f-b03d-1e7c2f803g90';

-- MESSAGE
SET @msg_1 = 'b75f3a0e-9d6c-4f9a-c14e-2f9d3a904h12';


-- ----------------------------
-- 1. USER Inserts
-- ----------------------------

INSERT INTO "USER" (user_id, first_name, last_name, email, password_hash, role) VALUES
(@u_host_alice, 'Alice', 'Smith', 'alice.host@example.com', 'hashed_pass_alice_1234', 'host'),
(@u_guest_bob, 'Bob', 'Jones', 'bob.guest@example.com', 'hashed_pass_bob_5678', 'guest'),
(@u_admin_charlie, 'Charlie', 'Admin', 'charlie.admin@example.com', 'hashed_pass_charlie_0000', 'admin');


-- ----------------------------
-- 2. PROPERTY Inserts (Hosted by Alice)
-- ----------------------------

INSERT INTO PROPERTY (property_id, host_id, name, description, location, pricepernight) VALUES
(@p_cabin, @u_host_alice, 'Secluded Mountain Cabin', 'A cozy, remote cabin perfect for a weekend getaway.', 'Aspen, CO, USA', 150.00),
('f13c5d8a-1e2b-4c3d-9f4e-0a1b2c3d4e5f', @u_host_alice, 'Downtown Loft', 'Modern loft near all city attractions.', 'New York, NY, USA', 300.50);


-- ----------------------------
-- 3. BOOKING Inserts (Bob books the Cabin)
-- ----------------------------

INSERT INTO BOOKING (booking_id, property_id, user_id, start_date, end_date, total_price, status) VALUES
(@b_cabin_1, @p_cabin, @u_guest_bob, '2024-11-10', '2024-11-15', 750.00, 'confirmed'),
('11223344-5566-7788-9900-aabbccddeeff', @p_cabin, @u_guest_bob, '2024-12-01', '2024-12-03', 300.00, 'pending');


-- ----------------------------
-- 4. PAYMENT Inserts (Payment for the confirmed booking)
-- ----------------------------

INSERT INTO PAYMENT (payment_id, booking_id, amount, payment_method) VALUES
(@pay_1, @b_cabin_1, 750.00, 'credit_card');


-- ----------------------------
-- 5. REVIEW Inserts (Bob reviews the Cabin)
-- ----------------------------

INSERT INTO REVIEW (review_id, property_id, user_id, rating, comment) VALUES
(@rev_1, @p_cabin, @u_guest_bob, 5, 'Absolutely fantastic stay! The cabin was spotless and the host was very responsive.'),
('33445566-7788-9900-aabb-ccddeeff1122', 'f13c5d8a-1e2b-4c3d-9f4e-0a1b2c3d4e5f', @u_guest_bob, 4, 'Great location, though the noise from the street was a bit much at night.');


-- ----------------------------
-- 6. MESSAGE Inserts (Bob messaging Alice)
-- ----------------------------

INSERT INTO MESSAGE (message_id, sender_id, recipient_id, message_body) VALUES
(@msg_1, @u_guest_bob, @u_host_alice, 'Hi Alice, what is the best way to get to the cabin from the airport?'),
('44556677-8899-00aa-bbcc-ddeeff112233', @u_host_alice, @u_guest_bob, 'Hi Bob, I recommend taking the shuttle service. I can send you the details.');
