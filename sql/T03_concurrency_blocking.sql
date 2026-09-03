-- ============================================================
-- TEST CASE: T03 - Concurrency & Row-Level Lock / Blocking
-- Project: Oracle Database 19c - Tablespace, Transaction & Lock
--
-- SOURCE STATUS:
--   Reconstructed from the documented experimental procedure
--   in the original project report.
--
-- IMPORTANT:
--   The COMMIT statement in Session A is reconstructed from
--   the textual procedure because no standalone screenshot
--   of that COMMIT statement is preserved in the report.
--
--   The UPDATE statements and SELECT statement are exact SQL
--   documented in the original PDF.
--
-- MY CONTRIBUTION:
--   Scenario synthesis / execution coordination / evidence
--   collection / metrics analysis / technical reporting.
--
-- ENVIRONMENT:
--   Oracle Database 19c
--   Linux
--   DBeaver
--
-- NOTE:
--   This file is a reconstructed reproduction artifact.
--   It is NOT claimed to be the original SQL source file.
-- ============================================================


-- ============================================================
-- SESSION A
-- ============================================================
-- Source status: EXACT FROM PDF
-- Purpose: Update row 1 and retain the lock before COMMIT.

UPDATE tai_khoan_ngan_hang
SET so_du = so_du - 20000000
WHERE stt = 1;


-- ============================================================
-- SESSION B
-- ============================================================
-- Source status: EXACT FROM PDF
-- Expected documented behavior:
--   The statement waits because Session A has not released
--   its lock on row stt = 1.

UPDATE tai_khoan_ngan_hang
SET so_du = so_du + 50000000
WHERE stt = 1;


-- ============================================================
-- SESSION A - RELEASE LOCK
-- ============================================================
-- Source status: RECONSTRUCTED FROM TEXT DESCRIPTION
--
-- The report documents that Session A executes COMMIT to
-- release the lock. No standalone SQL screenshot is preserved
-- for this statement in the T03 evidence.
--
-- DO NOT interpret this as an exact transcription of an
-- original SQL source file.

COMMIT;


-- ============================================================
-- VERIFICATION
-- ============================================================
-- Source status: EXACT FROM PDF
-- Purpose: Verify the final account balance after both
-- sessions have completed.

SELECT *
FROM tai_khoan_ngan_hang;
