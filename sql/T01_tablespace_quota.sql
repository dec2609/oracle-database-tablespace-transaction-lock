-- ============================================================
-- T01 - TABLESPACE & QUOTA VALIDATION
-- Project: Oracle Database 19c - Tablespace, Transaction & Lock
--
-- SOURCE STATUS:
--   Reconstructed from the documented experimental procedure
--   in the original academic report (Chapter 5, pp. 30-33).
--
-- IMPORTANT:
--   This file is a reconstruction of the documented experiment.
--   It is NOT claimed to be the original SQL source file used
--   by the team.
--
-- ENVIRONMENT:
--   Oracle Database 19c
--   Linux
--   DBeaver
--
-- CONTRIBUTION:
--   Scenario synthesis / execution coordination /
--   evidence collection / metrics analysis / reporting.
--
-- ENVIRONMENT SETUP:
--   Per the project contribution record, the Oracle/Linux
--   laboratory environment was not set up by Nguyễn Đức Thuận.
-- ============================================================


-- ============================================================
-- STEP 1 — CREATE PERMANENT TABLESPACE
-- SOURCE: Exact SQL documented in the original report.
-- ============================================================

CREATE TABLESPACE DO_AN_TS
DATAFILE '/u01/app/oracle/oradata/ORCL/do_an_ts_01.dbf'
SIZE 100M;


-- Observed result:
--   Status: PASS
--   Execute time: 1.25s
--   Evidence: Figure 5.1


-- ============================================================
-- STEP 2 — CREATE BUSINESS TABLE
-- SOURCE: Exact SQL documented in the original report.
-- ============================================================

CREATE TABLE tai_khoan_ngan_hang (
    stt NUMBER PRIMARY KEY,
    chu_tai_khoan VARCHAR2(50),
    so_du NUMBER
)
TABLESPACE DO_AN_TS;


-- Observed result:
--   Status: PASS
--   Execute time: 0.358s
--   Evidence: Figure 5.2


-- ============================================================
-- STEP 3 — RESIZE DATAFILE
-- SOURCE: Exact SQL documented in the original report.
-- ============================================================

ALTER DATABASE DATAFILE
'/u01/app/oracle/oradata/ORCL/do_an_ts_01.dbf'
RESIZE 200M;


-- Observed result:
--   Status: PASS
--   Execute time: 1.031s
--   Evidence: Figure 5.3


-- ============================================================
-- STEP 4 — ASSIGN USER QUOTA
-- SOURCE: Exact SQL documented in the original report.
-- ============================================================

ALTER USER c##quang
QUOTA UNLIMITED ON DO_AN_TS;


-- Observed result:
--   Status: PASS
--   Execute time: 0.148s
--   Evidence: Figure 5.4
