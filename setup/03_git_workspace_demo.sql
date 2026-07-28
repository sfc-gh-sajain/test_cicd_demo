-- ============================================================================
-- Approach 3: Git Workspace
-- ============================================================================
-- Edit · commit · push — all from Snowsight · Zero terminal required
--
-- Git Workspace is Snowsight's built-in code editor connected directly to a
-- GitHub repository. Developers can browse files, run SQL, commit changes,
-- and push to GitHub without leaving Snowflake.
--
-- NO NEW SETUP REQUIRED — reuses the API Integration and GIT REPOSITORY
-- from Approach 2 (CICD_METADATA.PUBLIC.CICD_REPO).
-- ============================================================================

-- ============================================================
-- DEMO STEP 1: Open a Git Workspace in Snowsight
-- ============================================================
-- Navigate to: Snowsight → Projects → Workspaces → + Add New → From Git repository
--
--   Repository URL  : https://github.com/sfc-gh-sajain/test_cicd_demo.git
--   API Integration : GITHUB_API_INTEGRATION
--   Authentication  : Personal access token → select CICD_METADATA.PUBLIC.GITHUB_PAT
--   Click Create.
--
-- Say: "This is the same repo and the same credentials from Approach 2.
--       The workspace is just a window into GitHub that lives inside Snowflake."

-- ============================================================
-- DEMO STEP 2: Browse the file tree
-- ============================================================
-- In the left pane, expand the folder structure:
--   jobs/
--     add_sample_data.sql
--     report_row_count.sql
--   migrations/
--     V1.0.0__create_hello_world.sql
--     V1.1.0__add_email_column.sql
--     V1.2.0__add_phone_column.sql
--
-- Click jobs/add_sample_data.sql to open it.
--
-- Say: "A developer sees the full GitHub repo from here. Every folder, every file.
--       And they can run any SQL file directly from this editor against their
--       Snowflake account."

-- ============================================================
-- DEMO STEP 3: Run SQL directly from the workspace
-- ============================================================
-- With jobs/add_sample_data.sql open, click "Run" (or select the SQL and run).
-- Show the query results pane — data inserted into HELLO_WORLD_DB.DEMO_SCHEMA.HELLO_WORLD.
--
-- Say: "I just ran a file from GitHub against my Snowflake account. No download.
--       No copy-paste. The editor is connected to both GitHub and Snowflake."

-- ============================================================
-- DEMO STEP 4: Make a live edit
-- ============================================================
-- Edit jobs/add_sample_data.sql — add a new row:
--
--   ('Charlie', 'Brown', 'charlie@example.com', '555-0303')
--
-- Click the "Changes" tab in the left pane.
-- The file shows an M (modified) indicator.
-- Click the filename to see the visual diff — current vs. what is in GitHub.
--
-- Say: "This is VS Code Source Control, inside Snowflake. The developer can see
--       exactly what they changed before committing."

-- ============================================================
-- DEMO STEP 5: Commit and push — still in Snowsight
-- ============================================================
-- In the Changes tab:
--   Commit message: "add Charlie Brown to sample data"
--   Click Commit & Push
--
-- Say: "That commit just went to GitHub. From Snowsight. No terminal. No git
--       commands. The developer never left Snowflake."

-- ============================================================
-- DEMO STEP 6: Close the loop — show Git Integration picks up the change
-- ============================================================
-- Back in a SQL worksheet, run:

ALTER GIT REPOSITORY CICD_METADATA.PUBLIC.CICD_REPO FETCH;

EXECUTE IMMEDIATE FROM
  @CICD_METADATA.PUBLIC.CICD_REPO/branches/main/jobs/add_sample_data.sql;

SELECT * FROM HELLO_WORLD_DB.DEMO_SCHEMA.HELLO_WORLD;

-- Say: "The developer edited in Snowsight, pushed to GitHub, and the Git Integration
--       fetched and ran the new version. The entire workflow — code change to
--       production — without switching tools once."

-- ============================================================
-- KEY DEMO MOMENT
-- ============================================================
-- The developer committed and pushed without opening a terminal, VS Code, or
-- any tool outside Snowflake. The pipeline triggered automatically from that push.
--
-- Approach 2 (Git Integration) and Approach 3 (Git Workspace) work together:
--   - Git Workspace = the developer's editing experience (inside Snowsight)
--   - Git Integration = the execution engine (EXECUTE IMMEDIATE FROM @repo)
--   - Together = full CI/CD loop without leaving Snowflake

/* 
Option A: Shared PAT (simpler, less auditable)

Admin creates one SECRET (e.g., CICD_METADATA.PUBLIC.GITHUB_PAT) and one API INTEGRATION
Grants USAGE/READ to developer roles
All developers point to the same secret when creating their workspace
Downside: all commits show as the PAT owner's identity in GitHub
Option B: Individual PATs via OAuth (recommended)

Admin creates the API INTEGRATION with OAuth configured for GitHub
Each developer authenticates with their own GitHub account when creating the workspace
Commits show each developer's real GitHub identity
Better audit trail — you know who pushed what

*/