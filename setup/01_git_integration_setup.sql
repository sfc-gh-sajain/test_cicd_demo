-- ============================================================================
-- Approach 2: Snowflake Git Integration — One-Time Setup
-- ============================================================================
-- Snowflake orchestrates · Snowflake calls GitHub API · No external runners
--
-- Prerequisites:
--   - GitHub PAT with 'repo' scope for sfc-gh-sajain/test_cicd_demo
--   - ACCOUNTADMIN role
--   - HELLO_WORLD_DB.DEMO_SCHEMA already exists (created by schemachange demo)
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE CICD_METADATA;
USE SCHEMA PUBLIC;

-- Step 1: Store GitHub PAT as a secret
CREATE OR REPLACE SECRET CICD_METADATA.PUBLIC.GITHUB_PAT
  TYPE = PASSWORD
  USERNAME = 'sfc-gh-sajain'
  PASSWORD = '<your-github-pat>';   -- Replace with your actual PAT

-- Step 2: API Integration (allows Snowflake to call GitHub API)
CREATE OR REPLACE API INTEGRATION GITHUB_API_INTEGRATION
  API_PROVIDER = GIT_HTTPS_API
  API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-sajain/')
  ALLOWED_AUTHENTICATION_SECRETS = (CICD_METADATA.PUBLIC.GITHUB_PAT)
  ENABLED = TRUE;

-- Step 3: Create the Git Repository object
CREATE OR REPLACE GIT REPOSITORY CICD_METADATA.PUBLIC.CICD_REPO
  ORIGIN = 'https://github.com/sfc-gh-sajain/test_cicd_demo.git'
  API_INTEGRATION = GITHUB_API_INTEGRATION
  GIT_CREDENTIALS = CICD_METADATA.PUBLIC.GITHUB_PAT;

-- Step 4: Initial fetch
ALTER GIT REPOSITORY CICD_METADATA.PUBLIC.CICD_REPO FETCH;

-- Verify: list files in the repo
LS @CICD_METADATA.PUBLIC.CICD_REPO/branches/main/;
