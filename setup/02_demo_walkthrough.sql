-- ============================================================================
-- Approach 2: Snowflake Git Integration — Demo Walkthrough
-- ============================================================================
-- Model B: Snowflake pulls FROM GitHub. No runners. No Actions.
--
-- Run setup/01_git_integration_setup.sql first.
-- ============================================================================
USE ROLE SCHEMACHANGE_DEPLOY_ROLE;

-- ============================================================
-- 1. FETCH — Pull latest code from GitHub into Snowflake
-- ============================================================
ALTER GIT REPOSITORY CICD_METADATA.PUBLIC.CICD_REPO FETCH;

-- Say: "This is Snowflake calling the GitHub API. No runner. No Actions.
--       Snowflake pulls the code to itself."

-- ============================================================
-- 2. BROWSE — The repo looks like a Snowflake stage
-- ============================================================
LS @CICD_METADATA.PUBLIC.CICD_REPO/branches/main/;
LS @CICD_METADATA.PUBLIC.CICD_REPO/branches/main/jobs/;

-- Say: "Every file in the GitHub repo is visible as a stage path.
--       Navigate the folder structure as if it were a Snowflake internal stage."

-- ============================================================
-- 3. EXECUTE — Run a file directly from GitHub
-- ============================================================
EXECUTE IMMEDIATE FROM
  @CICD_METADATA.PUBLIC.CICD_REPO/branches/main/jobs/add_sample_data.sql;

-- Say: "One command — Snowflake fetched that file and ran it.
--       No copy-paste. No local file. The code came from GitHub."

-- Verify the data landed:
SELECT * FROM HELLO_WORLD_DB.DEMO_SCHEMA.HELLO_WORLD;

-- ============================================================
-- 4. SELF-UPDATING TASK — Task body is a pointer to GitHub
-- ============================================================
CREATE OR REPLACE TASK HELLO_WORLD_DB.DEMO_SCHEMA.REFRESH_DATA_TASK
  WAREHOUSE = DEMO_WH
  SCHEDULE = '60 MINUTE'
AS
  EXECUTE IMMEDIATE FROM
    @CICD_METADATA.PUBLIC.CICD_REPO/branches/main/jobs/add_sample_data.sql;

ALTER TASK HELLO_WORLD_DB.DEMO_SCHEMA.REFRESH_DATA_TASK RESUME;

-- Say: "The Task has no SQL in its body — just a pointer to a GitHub file.
--       When the task fires, it fetches the latest version of that file and runs it.
--       Edit the GitHub file, the next task run is different.
--       Zero redeployment of the Task itself."

-- ============================================================
-- 5. DEMONSTRATE CHANGE — Modify GitHub, then FETCH + execute
-- ============================================================
-- (In GitHub, edit jobs/add_sample_data.sql — e.g. add a new row:
--   ('Charlie', 'Brown', 'charlie@example.com', '555-0303')
-- Then come back here and run:)

ALTER GIT REPOSITORY CICD_METADATA.PUBLIC.CICD_REPO FETCH;

EXECUTE IMMEDIATE FROM
  @CICD_METADATA.PUBLIC.CICD_REPO/branches/main/jobs/add_sample_data.sql;

-- Verify new data:
SELECT * FROM HELLO_WORLD_DB.DEMO_SCHEMA.HELLO_WORLD;

-- Say: "The change went live the moment that ran. No migration file.
--       No PR pipeline. Just a file change in GitHub picked up on the next fetch."

-- ============================================================
-- KEY DEMO MOMENT
-- ============================================================
-- The Task has no SQL in its body. Changing the GitHub file changes
-- what the Task does — without touching or redeploying the Task object itself.
