-- ============================================================
-- TEST CASE: T04 - Deadlock Detection
-- Project: Oracle Database 19c - Tablespace, Transaction & Lock
--
-- SOURCE STATUS:
--   Reconstructed from the documented experimental procedure
--   in the original project report.
--
-- IMPORTANT:
--   The SQL statements below represent the documented
--   four-step deadlock sequence.
--
--   Session A and Session B must be executed separately
--   and coordinated in the documented order:
--
--       A1 -> B2 -> A2 -> B1
--
--   This file is a reconstructed reproduction artifact.
--   It is NOT claimed to be the original SQL source file.
--
-- MY CONTRIBUTION:
--   Scenario synthesis / execution participation / evidence
--   collection / metrics analysis / technical reporting.
--
-- ENVIRONMENT:
--   Oracle Database 19c
--   Linux
--   DBeaver
--
-- EXPECTED RESULT:
--   ORA-00060: deadlock detected while waiting for resource
-- ============================================================


-- ============================================================
-- SESSION A - STEP 1
-- ============================================================
-- Source status: EXACT FROM PDF
-- Purpose: Update row 1 and retain the transaction lock.

UPDATE tai_khoan_ngan_hang
SET so_du = so_du - 1
WHERE stt = 1;


-- ============================================================
-- SESSION B - STEP 2
-- ============================================================
-- Source status: EXACT FROM PDF
-- Purpose: Update row 2 and retain the transaction lock.

UPDATE tai_khoan_ngan_hang
SET so_du = so_du + 1
WHERE stt = 2;


-- ============================================================
-- SESSION A - STEP 3
-- ============================================================
-- Source status: EXACT FROM PDF
-- Purpose: Request row 2, which is held by Session B.
-- Expected behavior: BLOCKING / WAITING.

UPDATE tai_khoan_ngan_hang
SET so_du = so_du + 1
WHERE stt = 2;


-- ============================================================
-- SESSION B - STEP 4
-- ============================================================
-- Source status: EXACT FROM PDF
-- Purpose: Request row 1, which is held by Session A.
-- Expected behavior: Circular wait -> ORA-00060.

UPDATE tai_khoan_ngan_hang
SET so_du = so_du + 1
WHERE stt = 1;
