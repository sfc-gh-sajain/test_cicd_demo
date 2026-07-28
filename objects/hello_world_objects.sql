-- ============================================================================
-- Approach 4: CREATE OR ALTER — Desired State Definition
-- ============================================================================
-- One file. No version numbers. Describes what SHOULD exist.
-- Safe to run 100 times — idempotent, data-preserving.
--
-- Reuses: CICD_METADATA.PUBLIC.CICD_REPO (from Approach 2)
-- ============================================================================

-- Desired state of the HELLO_WORLD table
-- Edit this file to change the schema. Re-run to apply. No migration file needed.
CREATE OR ALTER TABLE HELLO_WORLD_DB.DEMO_SCHEMA.HELLO_WORLD (
    FIRST_NAME  VARCHAR(100),
    LAST_NAME   VARCHAR(100),
    EMAIL       VARCHAR(255),
    PHONE       VARCHAR(20),
    COUNTRY     VARCHAR(20)
);
