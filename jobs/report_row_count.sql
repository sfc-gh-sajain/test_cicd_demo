-- Report current row count in HELLO_WORLD table
-- This file is executed via EXECUTE IMMEDIATE FROM @repo
SELECT COUNT(*) AS total_rows, CURRENT_TIMESTAMP() AS checked_at
FROM HELLO_WORLD_DB.DEMO_SCHEMA.HELLO_WORLD;
