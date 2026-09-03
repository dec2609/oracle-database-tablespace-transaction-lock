# Test Plan — Oracle Database 19c

## 1. Test Plan Overview
This Test Plan defines the experimental validation strategy for the Oracle Database 19c mechanisms documented in the academic report *Hệ quản trị cơ sở dữ liệu Oracle — Tablespace, Transaction và Lock (Consistency, Concurrency)*.

The primary objective is to experimentally validate four core database mechanisms documented in the report:
- **Logical Storage Management:** Tablespace abstraction, datafile mapping, dynamic capacity resizing, and user quota allocation.
- **Transaction Control & Error Recovery:** Transaction persistence through `COMMIT` and partial transaction rollback through `SAVEPOINT` and `ROLLBACK TO SAVEPOINT`.
- **Multi-User Concurrency Control:** Row-level locking and transaction blocking under concurrent update conditions.
- **Deadlock Detection:** Detection of circular lock dependencies and generation of the `ORA-00060` error.

The experimental relationship documented in the laboratory is:

```text
Tablespace
    ↓
Database Objects (Table & Rows)
    ↓
Transactions (DML)
    ↓
Row-Level Locking
    ↓
Blocking / Deadlock
```

*This plan represents an academic experimental validation suite executed in a controlled laboratory environment. It is not a production performance benchmark.*

---

## 2. Experimental Scope

| Test Case | Domain | Main Mechanism | Session Model | Primary Validation |
| :--- | :--- | :--- | :--- | :--- |
| **T01** | Storage Management | Tablespace / Datafile / Quota | Single Session | Storage allocation, datafile expansion, quota assignment |
| **T02** | Transaction Integrity | COMMIT / SAVEPOINT / ROLLBACK TO SAVEPOINT | Single Session | Transaction persistence and partial state reversal |
| **T03** | Concurrency Control | Row-Level Locking | Two Sessions | Blocking behavior and serialized execution |
| **T04** | Deadlock Detection | Circular Lock Dependency | Two Sessions | Deadlock detection and ORA-00060 |

---

## 3. Test Case Inventory

### 3.1 T01 — Tablespace & Quota Validation
- **Title:** Thực nghiệm quản trị Tablespace (Tablespace Management Experiment)
- **Source Section:** Chapter 5, Section 5.1
- **Report Pages:** Pages 30–33
- **Objective:** Validate creation of a permanent tablespace, table provisioning within that tablespace, expansion of the physical datafile, and assignment of a user storage quota.
- **Scenario:** Create permanent tablespace `DO_AN_TS` mapped to a 100M datafile; create table `tai_khoan_ngan_hang` in `DO_AN_TS`; resize the datafile from 100M to 200M; grant `QUOTA UNLIMITED` on `DO_AN_TS` to user `c##quang`.
- **Session Requirement:** Single session.
- **Expected Result:** Tablespace creation succeeds; the table is created in `DO_AN_TS`; the datafile is resized to 200M without error; the quota assignment succeeds.
- **Observed Result:** Tablespace creation completed in 1.25s; table creation completed in 0.358s; datafile resize completed in 1.031s; quota assignment completed in 0.148s.
- **Evidence:** Figure 5.1, Figure 5.2, Figure 5.3, Figure 5.4.
- **Limitations:** No verification queries against `DBA_TABLESPACES`, `DBA_DATA_FILES`, or `DBA_TS_QUOTAS` are documented.

### 3.2 T02 — Transaction Integrity & Partial Rollback
- **Title:** Thực nghiệm kiểm soát TRANSACTION và tính toàn vẹn (Transaction Control & Integrity Experiment)
- **Source Section:** Chapter 5, Section 5.2
- **Report Pages:** Pages 33–37
- **Objective:** Validate transaction persistence through `COMMIT` and partial transaction rollback through `SAVEPOINT` and `ROLLBACK TO SAVEPOINT`.
- **Scenario:** Insert account record `stt = 1` and commit; insert account record `stt = 2` and commit; create savepoint `truoc_khi_tru_tien`; execute an update deducting 50,000,000 from account 2; execute `ROLLBACK TO SAVEPOINT`; query account 2 to verify the balance.
- **Session Requirement:** Single session.
- **Expected Result:** Previously committed data remains persisted, while the update performed after the savepoint is reverted without rolling back the previously committed records.
- **Observed Result:** The insert for `stt = 1` completed in 1.873s; `COMMIT` executed in 0.002s; `ROLLBACK TO SAVEPOINT` executed in 0.005s; the query confirmed that account `stt = 2` (`CHI_SEC`) remained at 50,000,000.
- **Evidence:** Figure 5.5, Figure 5.6, Figure 5.7, Figure 5.8.
- **Limitations:** Execution statistics were not captured for the intermediate insert and commit commands for account record `stt = 2`.

### 3.3 T03 — Concurrency & Row-Level Blocking
- **Title:** Thực nghiệm xử lý đồng thời (Concurrency) và hiện tượng chờ khóa (Blocking)
- **Source Section:** Chapter 5, Sections 5.3 and 5.5
- **Report Pages:** Pages 37–40, 43–44
- **Objective:** Validate row-level locking behavior and observe transaction blocking when two concurrent sessions attempt conflicting updates on the same row.
- **Scenario:** Session A updates row `stt = 1` by deducting 20,000,000 without committing; Session B attempts to update the same row by adding 50,000,000; Session B enters a blocking wait; Session A commits; Session B subsequently completes its update; the final balance is queried.
- **Session Requirement:** Two independent database sessions (Session A and Session B).
- **Expected Result:** Session B is blocked while Session A's transaction remains uncommitted. After Session A commits, Session B resumes and completes its update. The final balance should reflect the sequential calculation:
$$100,000,000 - 20,000,000 + 50,000,000 = 130,000,000$$
- **Observed Result:** Session A executed its update in 0.006s; Session B displayed an active `Execute query - 13s` waiting state; Session B completed with a total elapsed time of 1m 9s; the final query returned 130,000,000.
- **Evidence:** Figure 5.9, Figure 5.10, Figure 5.11, Figure 5.12, Table 5.1.
- **Limitations:** No queries against dynamic lock-monitoring views such as `V$LOCK` or `V$SESSION_BLOCKERS` were captured. Timing also includes manual coordination between the two sessions.

### 3.4 T04 — Deadlock Detection
- **Title:** Thực nghiệm hiện tượng Deadlock (Khóa chết)
- **Source Section:** Chapter 5, Sections 5.4 and 5.5
- **Report Pages:** Pages 41–44
- **Objective:** Validate Oracle's detection of a circular lock dependency created by two concurrent sessions.
- **Scenario:** Session A updates row 1; Session B updates row 2; Session A attempts to update row 2 and becomes blocked; Session B attempts to update row 1, creating a circular dependency.
- **Session Requirement:** Two independent database sessions (Session A and Session B).
- **Expected Result:** The circular lock dependency is detected and Oracle returns error `ORA-00060`.
- **Observed Result:** The cross-update sequence resulted in deadlock detection, and the affected session received:
```text
SQL Error [60] [61000]:
ORA-00060: deadlock detected while waiting for resource
```
- **Evidence:** Figure 5.13, Figure 5.14, Table 5.1.
- **Limitations:** Post-deadlock session states, cleanup statements, and verification queries were not documented.

---

## 4. Preconditions and Environment
- **Database Management System:** Oracle Database 19c Enterprise Edition.
- **Operating System:** Linux host environment, based on the documented physical storage path `/u01/app/oracle/oradata/ORCL/...`.
- **Client Interface:** DBeaver.
- **Required Tablespace:** `DO_AN_TS`.
- **Required Table:** `tai_khoan_ngan_hang`.
- **Target User:** `c##quang` *(Note: The report references user `c##quang` in the quota assignment command, but the initial user creation command is not confirmed in the report).*

### Account Records
- **T02:** Record `stt = 1` (`QUANG_SEC`) and record `stt = 2` (`CHI_SEC`).
- **T03:** Existing record `stt = 1` with balance 100,000,000.
- **T04:** Existing records `stt = 1` and `stt = 2`.

### Session Architecture
- **T01:** Single database session.
- **T02:** Single database session.
- **T03:** Two independent concurrent database sessions.
- **T04:** Two independent concurrent database sessions.

---

## 5. Test Data and Database Objects

| Item | Identifier / Parameter | Documented Value | Source |
| :--- | :--- | :--- | :--- |
| **Tablespace** | Tablespace Identifier | DO_AN_TS | Page 30 |
| **Datafile** | Physical File Mapping | `/u01/app/oracle/oradata/ORCL/do_an_ts_01.dbf` | Page 30 |
| **Initial Datafile Size** | Storage Allocation | 100M | Page 30 |
| **Resized Datafile Size** | Storage Expansion | 200M | Page 32 |
| **Business Table** | Schema Object | tai_khoan_ngan_hang | Page 31 |
| **Table Schema** | Column Definitions | `stt NUMBER PRIMARY KEY, chu_tai_khoan VARCHAR2(50), so_du NUMBER` | Page 31 |
| **Target User** | User Grantee | c##quang | Page 32 |
| **Quota** | Tablespace Quota | UNLIMITED | Page 32 |
| **Account 1** | Seed Data | `stt = 1`, QUANG_SEC, 100000000 | Page 33 |
| **Account 2** | Seed Data | `stt = 2`, CHI_SEC, 50000000 | Page 36 |
| **Savepoint** | Transaction Checkpoint | truoc_khi_tru_tien | Page 36 |

### Documented Transaction DML Values

| Test Case | Operation | Value |
| :--- | :--- | :--- |
| **T02** | Update stt = 2 | -50,000,000 |
| **T03 — Session A** | Update stt = 1 | -20,000,000 |
| **T03 — Session B** | Update stt = 1 | +50,000,000 |
| **T04 — Session A Step 1** | Update stt = 1 | -1 |
| **T04 — Session B Step 2** | Update stt = 2 | +1 |
| **T04 — Session A Step 3** | Update stt = 2 | +1 |
| **T04 — Session B Step 4** | Update stt = 1 | +1 |

### Observed Oracle Error
```text
SQL Error [60] [61000]:
ORA-00060: deadlock detected while waiting for resource
```

---

## 6. Execution Strategy

### 6.1 Overall Execution Order
The experimental sequence follows the dependency documented in Chapter 5:

```text
T01 (Storage Setup)
        ↓
T02 (Transaction Controls)
        ↓
T03 (Concurrency / Blocking)
        ↓
T04 (Deadlock)
```
- **T01** establishes the tablespace and database table.
- **T02** establishes the account records and validates transaction control.
- **T03** uses the existing account record to demonstrate concurrent blocking.
- **T04** uses two existing records to create a circular lock dependency.

### 6.2 T01 Execution Procedure
1. Execute `CREATE TABLESPACE DO_AN_TS` using the documented datafile path and initial size 100M.
2. Execute `CREATE TABLE tai_khoan_ngan_hang (...) TABLESPACE DO_AN_TS`.
3. Execute the documented `ALTER DATABASE DATAFILE ... RESIZE 200M` command.
4. Execute `ALTER USER c##quang QUOTA UNLIMITED ON DO_AN_TS`.

### 6.3 T02 Execution Procedure
1. Insert record `stt = 1` (`QUANG_SEC`, balance 100000000) and execute `COMMIT`.
2. Insert record `stt = 2` (`CHI_SEC`, balance 50000000) and execute `COMMIT`.
3. Create savepoint `truoc_khi_tru_tien`.
4. Execute the documented update deducting 50,000,000 from `stt = 2`.
5. Execute `ROLLBACK TO SAVEPOINT truoc_khi_tru_tien`.
6. Execute the documented `SELECT` query for `stt = 2`.
7. Verify that the balance remains 50,000,000.

### 6.4 T03 Multi-Session Procedure
1. **Session A:** Execute the documented update deducting 20,000,000 from `stt = 1`. Do not commit.
2. **Session B:** Execute the documented update adding 50,000,000 to `stt = 1`.
3. **Observation:** Record the blocking state displayed by the client interface.
4. **Session A:** Execute `COMMIT`.
5. **Session B:** Observe completion of the waiting statement.
6. **Verification:** Execute the documented `SELECT` query and verify the final balance of 130,000,000.

### 6.5 T04 Multi-Session Procedure
The documented execution order is:

```text
Step 1 — Session A
    Update row 1
    Lock remains uncommitted
          ↓
Step 2 — Session B
    Update row 2
    Lock remains uncommitted
          ↓
Step 3 — Session A
    Attempt update row 2
    Session A waits
          ↓
Step 4 — Session B
    Attempt update row 1
    Circular dependency formed
          ↓
Oracle detects deadlock
          ↓
ORA-00060
```
1. **Session A:** Update row `stt = 1` by -1. Do not commit.
2. **Session B:** Update row `stt = 2` by +1. Do not commit.
3. **Session A:** Attempt to update row `stt = 2` by +1. Session A enters a waiting state.
4. **Session B:** Attempt to update row `stt = 1` by +1.
5. **Observation:** Record the resulting deadlock error `ORA-00060`.

---

## 7. Expected Results and Pass Criteria

### 7.1 T01
**PASS when:**
- `CREATE TABLESPACE DO_AN_TS` succeeds.
- `CREATE TABLE tai_khoan_ngan_hang` succeeds in `DO_AN_TS`.
- Datafile resize to 200M completes without error.
- Quota assignment to `c##quang` completes without error.

### 7.2 T02
**PASS when:**
- Previously committed account data remains available.
- `ROLLBACK TO SAVEPOINT` completes successfully.
- The post-rollback query returns 50,000,000 for `CHI_SEC`.

### 7.3 T03
**PASS when:**
- Session B enters a blocking state while attempting to update the row being modified by Session A.
- Session B resumes after Session A commits.
- The final query returns 130,000,000.

### 7.4 T04
**PASS when:**
- The documented cross-session sequence produces a circular lock dependency.
- Oracle detects the deadlock condition.
- The affected session receives `ORA-00060: deadlock detected while waiting for resource`.

---

## 8. Evidence Mapping

| Test Case | Evidence | Report Page | What the Evidence Documents |
| :--- | :--- | :--- | :--- |
| **T01** | Figure 5.1 | 31 | `CREATE TABLESPACE DO_AN_TS` execution log (1.25s) |
| **T01** | Figure 5.2 | 32 | `CREATE TABLE tai_khoan_ngan_hang` execution log (0.358s) |
| **T01** | Figure 5.3 | 32 | Datafile resize execution log (1.031s) |
| **T01** | Figure 5.4 | 33 | `ALTER USER ... QUOTA UNLIMITED` execution log (0.148s) |
| **T02** | Figure 5.5 | 34 | Insert execution log for `QUANG_SEC` (1.873s) |
| **T02** | Figure 5.6 | 35 | `COMMIT` execution log (0.002s) |
| **T02** | Figure 5.7 | 37 | `ROLLBACK TO SAVEPOINT` execution log (0.005s) |
| **T02** | Figure 5.8 | 37 | Results Grid showing `CHI_SEC` balance 50,000,000 |
| **T03** | Figure 5.9 | 38 | Session A update execution (0.006s) |
| **T03** | Figure 5.10 | 39 | DBeaver UI showing `Execute query - 13s` during blocking |
| **T03** | Figure 5.11 | 40 | Session B completion (1m 9s total elapsed time) |
| **T03** | Figure 5.12 | 40 | Final balance 130,000,000 |
| **T03 & T04** | Table 5.1 | 43–44 | Analytical synthesis of experimental observations |
| **T04** | Figure 5.13 | 42 | Query suspension during cross-resource dependency |
| **T04** | Figure 5.14 | 42 | `ORA-00060` error returned by Oracle |

---

## 9. Available Metrics

| Test Case | Operation / Event | Metric | Value | Classification | Evidence |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T01** | Create Tablespace | Execution Time | 1.25s | SQL execution duration | Figure 5.1, Page 31 |
| **T01** | Create Table | Execution Time | 0.358s | SQL execution duration | Figure 5.2, Page 32 |
| **T01** | Resize Datafile | Execution Time | 1.031s | SQL execution duration | Figure 5.3, Page 32 |
| **T01** | Grant User Quota | Execution Time | 0.148s | SQL execution duration | Figure 5.4, Page 33 |
| **T02** | Insert stt=1 | Execution Time | 1.873s | SQL execution duration | Figure 5.5, Page 34 |
| **T02** | Commit | Execution Time | 0.002s | SQL execution duration | Figure 5.6, Page 35 |
| **T02** | Rollback to Savepoint | Execution Time | 0.005s | SQL execution duration | Figure 5.7, Page 37 |
| **T03** | Session A Update | Execution Time | 0.006s | SQL execution duration | Figure 5.9, Page 38 |
| **T03** | Session B Blocking | UI Timer Snapshot | 13s | Client-side elapsed display | Figure 5.10, Page 39 |
| **T03** | Session B Completion | Total Elapsed Duration | 1m 9s | Includes waiting/manual coordination | Figure 5.11, Page 40 |
| **T04** | Preceding Statement | Execution Time | 0.01s | Execution duration of preceding statement | Figure 5.13, Page 42 |
| **T04** | Deadlock Waiting | UI Timer Snapshot | 13s | Client-side elapsed display | Figure 5.13, Page 42 |
| **T04** | Deadlock Exception | Oracle Error Code | ORA-00060 | Database error code | Figure 5.14, Page 42 |

*Metric interpretation rule:*
- The `13s` value in T03 and T04 is a client-side UI timer snapshot. It is not an Oracle lock timeout value and must not be interpreted as the internal deadlock detection interval.
- The `0.01s` value documented for T04 belongs to the preceding statement execution and must not be interpreted as deadlock detection latency.

---

## 10. Multi-Session Requirements

### 10.1 T03 Concurrency Architecture
Sessions Required: 2 independent database connections.

- **Session A:**
  1. Update row `stt = 1`.
  2. Keep the transaction uncommitted.
  3. Commit after Session B enters the waiting state.
- **Session B:**
  1. Attempt to update row `stt = 1`.
  2. Observe the blocking state.
  3. Observe completion after Session A commits.

**Blocking Point:**  
The blocking condition occurs when Session B attempts to modify the row currently held by Session A's uncommitted transaction.

### 10.2 T04 Deadlock Architecture
Sessions Required: 2 independent database connections.  
Required execution order:
$$	ext{A1} \longrightarrow 	ext{B2} \longrightarrow 	ext{A2} \longrightarrow 	ext{B1}$$

**Lock Dependency:**
- **A1:** Session A updates row 1.
- **B2:** Session B updates row 2.
- **A2:** Session A attempts row 2 and waits.
- **B1:** Session B attempts row 1, creating the circular dependency.

The resulting dependency can be represented as:
$$	ext{Session A} \longrightarrow 	ext{waits for} \longrightarrow 	ext{Session B}$$
$$	ext{Session B} \longrightarrow 	ext{waits for} \longrightarrow 	ext{Session A}$$

**Resolution:**  
The documented result is that Oracle detects the circular dependency and returns:
```text
ORA-00060: deadlock detected while waiting for resource
```

---

## 11. Known Limitations
- **Missing Intermediate Statistics:** Execution statistics for inserting and committing account record `stt = 2` in T02 were not captured.
- **Missing T04 Initial Statistics:** Execution statistics for the initial T04 update statements were not captured in the report screenshots.
- **Absence of Dynamic Lock Queries:** The report does not document explicit queries against `V$LOCK`, `V$SESSION`, `V$LOCKED_OBJECT`, or `V$SESSION_BLOCKERS`.
- **Absence of Teardown / Cleanup:** No `DROP TABLE`, `DROP TABLESPACE`, or equivalent cleanup procedure is documented.
- **User Provisioning:** The initial `CREATE USER c##quang` command is not documented.
- **UI Timer vs. Database Timing:** The `13s` value represents a client-side UI timer snapshot and is not an Oracle timeout parameter.
- **Manual Interaction Latency:** The `1m 9s` total duration in T03 includes manual coordination between sessions and therefore cannot be treated as a pure database execution-time benchmark.
- **Host Administration Scope:** Linux host provisioning, OS configuration, and Oracle 19c binary installation are outside the documented experimental scope.
- **Post-Deadlock State:** The report does not document the subsequent transaction state or cleanup actions after the `ORA-00060` error.

---

## 12. Source Boundaries

### 12.1 Confirmed
The following information is directly documented in the source material:
- SQL operations documented across T01–T04.
- Tablespace `DO_AN_TS`.
- Table `tai_khoan_ngan_hang`.
- User `c##quang` as the target of the quota command.
- Recorded execution values: `1.25s`, `0.358s`, `1.031s`, `0.148s`, `1.873s`, `0.002s`, `0.005s`, `0.006s`, `1m 9s`, `0.01s`.
- UI timer snapshots of `13s`.
- Final T03 balance of 130,000,000.
- T02 restored balance of 50,000,000.
- Exact Oracle error:
```text
SQL Error [60] [61000]:
ORA-00060: deadlock detected while waiting for resource
```
- Documented division of work:
  - **Nguyễn Minh Quang** — Chapter 4, Concurrency/Deadlock design.
  - **Nguyễn Thị Phương Trâm** — Chapter 2, Tablespace/Quota.
  - **Nguyễn Ngọc Tuyết Ngân** — Chapter 3, Transaction/Savepoint.
  - **Nguyễn Đức Thuận** — Chapter 5, Scenario Synthesis, Execution Participation, Evidence Collection, Metrics Analysis & Reporting.

### 12.2 Not Confirmed
The following information is not confirmed by the documented experimental evidence:
- SQL commands used to create users.
- Password configuration or initial privilege grants.
- Verification queries against `DBA_TABLESPACES`, `DBA_DATA_FILES`, or `DBA_TS_QUOTAS`.
- Post-deadlock verification queries.
- Post-deadlock `COMMIT` or `ROLLBACK` actions.
- Underlying hardware specifications.
- CPU or memory allocation.
- Kernel parameters.
- Exact individual keystrokes or command ownership during collaborative execution.

### 12.3 Must Not Assume
The following claims must not be introduced into subsequent analysis without independent evidence:
- `QUOTA UNLIMITED` is a Denial-of-Service or storage-exhaustion security control.
- `13s` represents an Oracle internal lock timeout or deadlock detection interval.
- `0.01s` represents deadlock detection latency.
- The recorded timings constitute a production-grade concurrency benchmark.
- The experiment demonstrates production high availability.
- Undocumented cleanup scripts were executed.
- Nguyễn Đức Thuận authored all SQL statements.
- Nguyễn Đức Thuận configured the Linux host or installed the Oracle engine.
- Network security controls, firewall rules, IAM/RBAC architecture, or RMAN backup infrastructure exist within the project.

---

## 13. Traceability Rule for Downstream Analysis
All subsequent analysis files should use this Test Plan as the primary experimental reference:

```text
test-plan.md
    ↓
metrics.md
    ↓
experimental-evaluation.md
    ↓
Repository Audit
```

When a metric, observation, or technical claim is not supported by this Test Plan or the original report evidence, it must be explicitly marked as:
- **CONFIRMED**
- **NOT CONFIRMED**
- **INTERPRETATION**
- **MUST NOT ASSUME**

*No undocumented experimental result should be presented as an observed fact.*
