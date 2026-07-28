-- Insert sample data into HELLO_WORLD table
-- This file is executed via EXECUTE IMMEDIATE FROM @repo
INSERT INTO HELLO_WORLD_DB.DEMO_SCHEMA.HELLO_WORLD (FIRST_NAME, LAST_NAME, EMAIL, PHONE)
VALUES
    ('Alice', 'Johnson', 'alice@example.com', '555-0101'),
    ('Bob', 'Smith', 'bob@example.com', '555-0202'),
    ('Charlie', 'Brown', 'charlie@example.com', '555-0303');
