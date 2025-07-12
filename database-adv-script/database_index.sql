-- Create index on users.id (primary key, but included for completeness)
CREATE INDEX IF NOT EXISTS idx_users_id ON users(id);

-- Create index on bookings.user_id
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);

-- Create index on bookings.property_id
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings(property_id);

-- Create index on properties.id (primary key, but included for completeness)
CREATE INDEX IF NOT EXISTS idx_properties_id ON properties(id);

-- Create index on reviews.property_id
CREATE INDEX IF NOT EXISTS idx_reviews_property_id ON reviews(property_id);
