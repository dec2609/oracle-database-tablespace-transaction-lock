-- ============================================================
-- TEST CASE: T02 - Transaction & Rollback Validation
-- Project: Oracle Database 19c - Tablespace, Transaction & Lock
--
-- SOURCE:
--   Reconstructed from the documented experimental procedure
--   in the original project report, Chapter 5, pp. 33-37.
--
-- SOURCE STATUS:
--   SQL statements are transcribed from the original report.
--   This file is a reconstructed reproduction artifact and
--   is NOT claimed to be the original SQL source file used
--   by the team.
--
-- MY CONTRIBUTION:
--   Scenario synthesis / execution coordination / evidence
--   collection / metrics analysis / technical reporting.
--
-- ENVIRONMENT:
--   Oracle Database 19c
--   Linux
--   DBeaver
-- ============================================================


-- ============================================================
-- SCENARIO 1
-- Initialize account data and commit transaction
-- ============================================================

-- Insert initial account record
INSERT INTO tai_khoan_ngan_hang
    (stt, chu_tai_khoan, so_du)
VALUES
    (1, 'QUANG_SEC', 100000000);

-- Commit the transaction
COMMIT;


-- ============================================================
-- SCENARIO 2
-- SAVEPOINT and partial transaction rollback
-- ============================================================

-- Insert second account record
INSERT INTO tai_khoan_ngan_hang
    (stt, chu_tai_khoan, so_du)
VALUES
    (2, 'CHI_SEC', 50000000);

-- Commit initial account creation
COMMIT;

-- Create a savepoint before the transaction operation
SAVEPOINT truoc_khi_tru_tien;

-- Execute the documented update operation
UPDATE tai_khoan_ngan_hang
SET so_du = so_du - 50000000
WHERE stt = 2;

-- Roll back only to the previously created savepoint
ROLLBACK TO SAVEPOINT truoc_khi_tru_tien;

-- Verify the account balance after rollback
SELECT *
FROM tai_khoan_ngan_hang
WHERE stt = 2;
