-- ============================================================================
-- Approach 4: CREATE OR ALTER + Git Integration — Demo Walkthrough
-- ============================================================================
-- Desired-state SQL · One file per object group · Idempotent · Declarative
--
-- Instead of numbered migration deltas (V1.0, V1.1, V1.2...), you store the
-- desired state of every object in a single SQL file using CREATE OR ALTER.
-- Snowflake computes the diff — you just describe what should exist.
-- The file is safe to run 100 times: idempotent, data-preserving.
--
-- Reuses: CICD_METADATA.PUBLIC.CICD_REPO (created in Approach 2 setup)
-- NO NEW SETUP REQUIRED.
-- ============================================================================
USE ROLE SCHEMACHANGE_DEPLOY_ROLE;

-- ============================================================
-- DEMO STEP 1: Show the desired-state file in GitHub
-- ============================================================
-- Open: https://github.com/sfc-gh-sajain/test_cicd_demo/blob/main/objects/hello_world_objects.sql
--
-- Say: "No migration numbers. No CHANGE_HISTORY table.
--       This one file always describes what should exist.
--       I can point any environment at this file and reach the correct state."

-- ============================================================
-- DEMO STEP 2: Prove idempotency — run on an already-configured environment
-- ============================================================

-- Check rows before
SELECT COUNT(*) AS rows_before FROM HELLO_WORLD_DB.DEMO_SCHEMA.HELLO_WORLD;

-- Fetch latest from GitHub
ALTER GIT REPOSITORY CICD_METADATA.PUBLIC.CICD_REPO FETCH;

-- Execute the desired-state file
EXECUTE IMMEDIATE FROM
  @CICD_METADATA.PUBLIC.CICD_REPO/branches/main/objects/hello_world_objects.sql;

-- Check rows after
SELECT COUNT(*) AS rows_after FROM HELLO_WORLD_DB.DEMO_SCHEMA.HELLO_WORLD;

-- Say: "Same row count before and after. CREATE OR ALTER saw the table already
--       exists and applied only what was different — nothing.
--       In schemachange, running V1.0 a second time would hit an error."

-- ============================================================
-- DEMO STEP 3: Make a change — add a COUNTRY column
-- ============================================================
-- In GitHub (or Git Workspace), edit objects/hello_world_objects.sql.
-- Add one line to the column list:
--
--   COUNTRY  VARCHAR(100)
--
-- So the file becomes:
--   CREATE OR ALTER TABLE HELLO_WORLD_DB.DEMO_SCHEMA.HELLO_WORLD (
--       FIRST_NAME  VARCHAR(100),
--       LAST_NAME   VARCHAR(100),
--       EMAIL       VARCHAR(255),
--       PHONE       VARCHAR(20),
--       COUNTRY     VARCHAR(100)     -- ← one line added
--   );
--
-- Say: "In the GitHub PR diff, the reviewer sees ONE line added in ONE file.
--       No separate ALTER TABLE migration. No version number to manage."

-- ============================================================
-- DEMO STEP 4: Deploy — the complete pipeline, 2 commands
-- ============================================================

-- Pull latest from GitHub
ALTER GIT REPOSITORY CICD_METADATA.PUBLIC.CICD_REPO FETCH;

-- Deploy desired state
EXECUTE IMMEDIATE FROM
  @CICD_METADATA.PUBLIC.CICD_REPO/branches/main/objects/hello_world_objects.sql;

-- Verify the column was added and existing rows survived
DESCRIBE TABLE HELLO_WORLD_DB.DEMO_SCHEMA.HELLO_WORLD;
-- Expected: COUNTRY column present

SELECT * FROM HELLO_WORLD_DB.DEMO_SCHEMA.HELLO_WORLD;
-- Expected: existing rows intact, COUNTRY column shows NULL

-- Say: "That is the entire deployment pipeline. No runner. No CLI tool.
--       Two SQL commands. The file came from GitHub, Snowflake applied only
--       what changed."

-- ============================================================
-- DEMO STEP 5: Run it again — prove idempotency after the change
-- ============================================================
EXECUTE IMMEDIATE FROM
  @CICD_METADATA.PUBLIC.CICD_REPO/branches/main/objects/hello_world_objects.sql;

-- No error. No data loss. Same result every time.
--
-- Say: "Run this file 50 times. Same result every time. schemachange migrations
--       can only run once. CREATE OR ALTER files can run forever."

-- ============================================================
-- KEY DEMO MOMENT
-- ============================================================
-- Run the file twice — no errors, no data loss.
-- schemachange migrations can only run once.
-- CREATE OR ALTER files can run forever.
--
-- CONTRAST WITH APPROACH 1 (schemachange):
--   schemachange: V1.3.0__add_country_column.sql  ← new file every time
--   CREATE OR ALTER: edit one line in objects/hello_world_objects.sql
--
-- CONTRAST WITH APPROACH 2 (Git Integration):
--   Approach 2 executes any SQL from @repo (jobs/)
--   Approach 4 uses CREATE OR ALTER to make that SQL idempotent (objects/)
--
-- Together they form the complete pattern:
--   @repo = how Snowflake fetches the file
--   CREATE OR ALTER = why the file is safe to run repeatedly
