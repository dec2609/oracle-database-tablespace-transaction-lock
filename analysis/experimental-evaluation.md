# Experimental Evaluation — Oracle Database 19c

- **Source of Truth:** Academic Report — *Hệ quản trị cơ sở dữ liệu Oracle: Tablespace, Transaction và Lock*
- **Evaluation Scope:** T01–T04, Chapter 5, Sections 5.1–5.5
- **Evaluation Type:** Scenario-based experimental validation
- **Environment:** Oracle Database 19c, Linux, DBeaver

---

## 1. Evaluation Overview

The experimental evaluation assesses four Oracle Database mechanisms through controlled laboratory scenarios:
- **T01:** Tablespace, datafile and user quota management.
- **T02:** Transaction control and partial rollback using `SAVEPOINT`.
- **T03:** Concurrent row updates and row-level blocking.
- **T04:** Circular lock dependency and deadlock detection.

The evaluation focuses on whether the observed database behavior is consistent with the intended mechanism demonstrated by each test case.

Validation results are classified as:

| Status | Meaning |
| :--- | :--- |
| **SUPPORTED** | Experimental evidence directly demonstrates the evaluated behavior. |
| **PARTIALLY SUPPORTED** | The main operation succeeded, but independent verification is incomplete. |
| **INSUFFICIENT EVIDENCE** | Available evidence is insufficient to establish the claim. |
| **NOT SUPPORTED** | The experiment does not support, or contradicts, the claim. |

*The experiments are intended for functional and behavioral validation, not production-grade performance benchmarking.*

---

## 2. Evaluation Methodology

Each test case is evaluated using five dimensions:
1. **Experimental objective** — what behavior the scenario attempts to demonstrate.
2. **Expected behavior** — the database behavior predicted by the tested mechanism.
3. **Observed behavior** — what was actually recorded in the report.
4. **Evidence strength** — whether screenshots, query results, timing records or error messages directly support the observation.
5. **Validation boundary** — what can and cannot reasonably be concluded from the experiment.

This approach prevents execution-time observations from being incorrectly interpreted as internal Oracle performance measurements.

---

## 3. T01 — Tablespace & Quota Evaluation

### 3.1 Objective
T01 evaluates Oracle storage administration through:
- creation of permanent tablespace `DO_AN_TS`;
- creation of a table assigned to that tablespace;
- expansion of the associated datafile from 100M to 200M;
- assignment of `UNLIMITED` quota to user `c##quang`.

The scenario demonstrates the administrative relationship between logical tablespace configuration and physical datafile capacity.

### 3.2 Expected Behavior
The expected sequence is:

```text
CREATE TABLESPACE
       ↓
Datafile allocated at 100M
       ↓
CREATE TABLE ... TABLESPACE DO_AN_TS
       ↓
Datafile RESIZE 100M → 200M
       ↓
ALTER USER ... QUOTA UNLIMITED
```

Each administrative command should complete successfully without an Oracle error.

### 3.3 Observed Behavior
The report records successful execution of all four operations:

| Operation | Observed Time |
| :--- | :--- |
| `CREATE TABLESPACE DO_AN_TS` | 1.25s |
| `CREATE TABLE tai_khoan_ngan_hang` | 0.358s |
| `RESIZE datafile to 200M` | 1.031s |
| `QUOTA UNLIMITED` | 0.148s |

Evidence is provided by Figures 5.1–5.4, Pages 31–33.  
The table creation statement explicitly specifies: `TABLESPACE DO_AN_TS` while the datafile resize changes the configured capacity from `100M → 200M`.

### 3.4 Evaluation
**Validation Status: PARTIALLY SUPPORTED**  
The execution evidence demonstrates that Oracle accepted and successfully processed the tested storage-management commands.

The experiment therefore supports the following conclusions:
- `DO_AN_TS` was successfully created with an initial 100M datafile.
- `tai_khoan_ngan_hang` was created using `DO_AN_TS` in its DDL definition.
- The datafile resize command from 100M to 200M executed successfully.
- The quota command for `c##quang` executed successfully.

However, the report does not independently query Oracle data dictionary views such as `DBA_TABLESPACES`, `DBA_DATA_FILES`, or `DBA_TS_QUOTAS`. Therefore, the experiment demonstrates successful administrative command execution, but provides weaker independent verification of the resulting internal database metadata.

### 3.5 Limitations
The experiment does not evaluate:
- behavior when the quota is exceeded;
- actual extent allocation under storage pressure;
- storage exhaustion;
- I/O performance;
- production high availability or zero-downtime behavior.

In particular, `QUOTA UNLIMITED` must not be interpreted as a DoS mitigation mechanism. It is a configuration that removes the configured quota limit for the specified user and tablespace.

---

## 4. T02 — Transaction Integrity & Partial Rollback Evaluation

### 4.1 Objective
T02 evaluates transaction control through:
- `COMMIT`;
- `SAVEPOINT`;
- an intentionally erroneous `UPDATE`;
- `ROLLBACK TO SAVEPOINT`;
- post-rollback state verification.

The main objective is to demonstrate that a transaction can return to a previously established savepoint without discarding the earlier committed state.

### 4.2 Expected Behavior
The expected transaction sequence is:

```text
Insert account 1
      ↓
    COMMIT
      ↓
Insert account 2
      ↓
    COMMIT
      ↓
  SAVEPOINT
      ↓
Erroneous UPDATE
      ↓
ROLLBACK TO SAVEPOINT
      ↓
 Verify account 2
```

The erroneous deduction of 50,000,000 VNĐ should not remain after the rollback to the savepoint.

### 4.3 Observed Behavior
The report records:
- Account `QUANG_SEC` inserted with an initial balance of 100,000,000 VNĐ.
- The first commit completed in 0.002s.
- Account `CHI_SEC` was subsequently inserted with an initial balance of 50,000,000 VNĐ.
- A savepoint named `truoc_khi_tru_tien` was established.
- An update attempted to deduct 50,000,000 VNĐ from account `stt = 2`.
- `ROLLBACK TO SAVEPOINT` completed in 0.005s.
- The subsequent query returned: `STT = 2`, `CHU_TAI_KHOAN = CHI_SEC`, `SO_DU = 50,000,000`.

Evidence is provided by Figures 5.5–5.8, Pages 34–37.

### 4.4 Evaluation
**Validation Status: SUPPORTED**  
The evidence directly demonstrates the intended partial rollback behavior.

The account originally contained:
$$50,000,000 	ext{ VNĐ}$$
An erroneous operation attempted to deduct:
$$50,000,000 	ext{ VNĐ}$$
After `ROLLBACK TO SAVEPOINT truoc_khi_tru_tien;`, the verification query returned:
$$50,000,000 	ext{ VNĐ}$$

This establishes that the erroneous modification did not remain in the resulting transaction state. The experiment therefore supports the use of `SAVEPOINT` and `ROLLBACK TO SAVEPOINT` for partial transaction rollback within the tested scenario.

### 4.5 Interpretation Boundary
The experiment does not constitute a crash-recovery or durability benchmark. Although the successful `COMMIT` demonstrates transaction commit behavior in the tested session, the experiment does not simulate:
- instance failure;
- operating-system failure;
- power loss;
- crash recovery;
- distributed transaction recovery.

Therefore, the results should not be presented as comprehensive proof of every aspect of ACID durability.

### 4.6 Limitations
Execution statistics were not captured for:
- insertion of account `stt = 2`;
- its associated commit;
- `SAVEPOINT`;
- the erroneous update.

Additionally, the report does not capture an intermediate `SELECT` showing the temporary reduced balance before the rollback.

---

## 5. T03 — Concurrency & Row-Level Blocking Evaluation

### 5.1 Objective
T03 evaluates concurrent access to the same database row using two independent sessions. The objective is to demonstrate that when Session A modifies a row without committing, a conflicting modification from Session B is blocked until Session A releases the lock.

### 5.2 Experimental Sequence
The scenario follows:

```text
Initial balance = 100M
        │
        ▼
Session A
−20M, no COMMIT
        │
        │ Row remains locked
        ▼
Session B
+50M
        │
        ▼
     BLOCKED
        │
Session A → COMMIT
        │
        ▼
Session B resumes
        │
        ▼
Final balance = 130M
```

### 5.3 Observed Behavior
Session A executed:
```sql
UPDATE tai_khoan_ngan_hang
SET so_du = so_du - 20000000
WHERE stt = 1;
```
The operation completed in 0.006s.

Session B subsequently attempted:
```sql
UPDATE tai_khoan_ngan_hang
SET so_du = so_du + 50000000
WHERE stt = 1;
```
The client displayed `Execute query - 13s`, indicating that the statement remained suspended while the conflicting transaction was active.

After Session A committed, Session B completed its update. The report records a total elapsed duration of 1m 9s for Session B, including waiting time and execution. The final verification returned: `QUANG_SEC`, `SO_DU = 130,000,000 VNĐ`.

Evidence is provided by Figures 5.9–5.12 and Table 5.1.

### 5.4 Evaluation
**Validation Status: SUPPORTED**  
The observed interaction directly demonstrates blocking between two sessions attempting conflicting modifications of the same row.

The final state is consistent with the serialized update sequence:
$$100,000,000 - 20,000,000 + 50,000,000 = 130,000,000 	ext{ VNĐ}$$

The evidence therefore supports the conclusion that, for this specific two-session scenario, the conflicting update was not allowed to overwrite Session A's uncommitted modification concurrently. This provides experimental evidence for row-level concurrency control and the prevention of the specific Lost Update scenario tested.

### 5.5 Critical Timing Boundary
The recorded 13s must be treated only as a client-side DBeaver UI timer snapshot. It does not establish:
- Oracle lock timeout;
- Oracle deadlock timeout;
- internal lock acquisition latency;
- Oracle wait-event duration.

Likewise, the 1m 9s value represents total elapsed time from execution to completion and includes waiting/coordination. It should not be interpreted as pure database engine execution latency.

### 5.6 Limitations
The experiment uses only two concurrent sessions. No measurements were collected from:
- `V$LOCK`;
- `V$LOCKED_OBJECT`;
- `V$SESSION`;
- `V$SESSION_WAIT`;
- Oracle wait-event instrumentation.

Consequently, the experiment demonstrates the externally visible blocking behavior but does not provide internal lock/wait telemetry.

---

## 6. T04 — Deadlock Detection Evaluation

### 6.1 Objective
T04 evaluates Oracle's response to a circular dependency between two concurrent sessions. The scenario deliberately creates the following dependency:

```text
Session A → locks Row 1
Session B → locks Row 2

Session A → waits for Row 2
Session B → waits for Row 1

             ↓
       Circular Wait
             ↓
        ORA-00060
```

### 6.2 Experimental Sequence
- **Step 1 — Session A:**
  ```sql
  UPDATE tai_khoan_ngan_hang
  SET so_du = so_du - 1
  WHERE stt = 1;
  ```
  Session A holds the resource associated with row 1.

- **Step 2 — Session B:**
  ```sql
  UPDATE tai_khoan_ngan_hang
  SET so_du = so_du + 1
  WHERE stt = 2;
  ```
  Session B holds the resource associated with row 2.

- **Step 3 — Session A:** Session A attempts to modify row 2 and becomes blocked.
- **Step 4 — Session B:** Session B attempts to modify row 1, completing the circular dependency.

### 6.3 Observed Behavior
During the waiting state, Figure 5.13 displays a client-side: `Execute query - 13s`.  
After Session B executes the conflicting statement, Oracle returns:
```text
SQL Error [60] [61000]:
ORA-00060: deadlock detected while waiting for resource
```
The error is captured in Figure 5.14, with additional comparison in Table 5.1, Pages 41–44.

### 6.4 Evaluation
**Validation Status: SUPPORTED**  
The experiment successfully established a circular wait between two sessions and produced the expected Oracle deadlock error.

The evidence directly supports:
- existence of a circular resource dependency in the tested scenario;
- detection of the deadlock condition by Oracle;
- return of the `ORA-00060` exception;
- termination of the affected statement as part of breaking the deadlock.

The result demonstrates that the database did not remain indefinitely blocked after the circular dependency was established.

### 6.5 Critical Timing Boundary
The report does not provide an internal measurement of Oracle's deadlock detection latency.

Therefore:
$$	ext{13s} 
eq 	ext{deadlock detection interval}$$
The 13s value is only a client-side UI observation. Similarly, the 0.01s value visible in Figure 5.13 belongs to the execution statistics of a preceding statement. It is not a measurement of the deadlock detection process.

### 6.6 Limitations
The report does not document:
- post-error transaction cleanup;
- complete `ROLLBACK` or `COMMIT` state after the exception;
- Oracle lock-monitoring views;
- deadlock trace-file analysis;
- application-level deadlock retry mechanisms.

---

## 7. Cross-Test Synthesis

The four test cases form a progressive experimental chain:

```text
T01 — Storage Provisioning
 │
 │ Tablespace / Datafile / Quota
 ▼
T02 — Transaction State Management
 │
 │ INSERT / COMMIT / SAVEPOINT / ROLLBACK
 ▼
T03 — Concurrent Access Control
 │
 │ Row Contention / Blocking / Commit
 ▼
T04 — Circular Dependency Handling
 │
 │ Deadlock / ORA-00060
 ▼
Oracle Transaction & Concurrency Behavior
```

This progression moves from database resource provisioning toward increasingly complex transaction and concurrency scenarios:
- **T01:** Establishes the storage environment required by subsequent operations.
- **T02:** Demonstrates controlled transaction state modification and partial rollback.
- **T03:** Introduces multiple concurrent sessions and demonstrates blocking caused by conflicting row modifications.
- **T04:** Extends the concurrency scenario by introducing a circular dependency that results in deadlock detection.

Together, the tests demonstrate several fundamental Oracle operational mechanisms within the scope of the laboratory environment. They do not, however, cover the full Oracle enterprise architecture.

---

## 8. Evaluation Matrix

| Test | Mechanism Evaluated | Observed Result | Evidence | Status |
| :--- | :--- | :--- | :--- | :--- |
| **T01** | Tablespace / Datafile / Quota | DDL operations completed; datafile configured 100M → 200M; quota configured | Figures 5.1–5.4 | **PARTIALLY SUPPORTED** |
| **T02** | Transaction / Savepoint | Rollback restored account balance to 50M | Figures 5.5–5.8 | **SUPPORTED** |
| **T03** | Row-level blocking | Session B blocked until Session A committed; final balance 130M | Figures 5.9–5.12, Table 5.1 | **SUPPORTED** |
| **T04** | Deadlock detection | Circular wait produced ORA-00060 | Figures 5.13–5.14, Table 5.1 | **SUPPORTED** |

*The only partially supported test is T01 because the report does not independently verify the resulting storage metadata through Oracle data dictionary queries.*

---

## 9. Claim Boundary Matrix

| Evaluated Claim | Result | Evidence | Boundary |
| :--- | :--- | :--- | :--- |
| Permanent tablespace can be created | **SUPPORTED** | Figure 5.1 | Successful DDL execution demonstrated |
| Table can be assigned to DO_AN_TS | **SUPPORTED** | Figure 5.2 | DDL explicitly specifies the tablespace |
| Datafile can be resized 100M → 200M | **SUPPORTED** | Figure 5.3 | Resize command completed successfully |
| User quota can be configured as UNLIMITED | **SUPPORTED** | Figure 5.4 | Configuration statement completed successfully |
| SAVEPOINT enables partial rollback | **SUPPORTED** | Figures 5.7–5.8 | Post-rollback state confirms restoration |
| Conflicting row updates cause blocking | **SUPPORTED** | Figures 5.9–5.10 | Two-session blocking directly observed |
| Session B resumes after Session A commits | **SUPPORTED** | Figure 5.11 | Update subsequently completed |
| Final T03 state reflects serialized updates | **SUPPORTED** | Figure 5.12 | Final balance = 130M |
| Specific Lost Update scenario is prevented | **SUPPORTED** | Figures 5.9–5.12 | Valid only for tested two-session scenario |
| Oracle detects circular lock dependency | **SUPPORTED** | Figure 5.14 | ORA-00060 observed |
| Oracle returns ORA-00060 for tested deadlock | **SUPPORTED** | Figure 5.14 | Exact error captured |
| 13s is Oracle lock timeout | **NOT SUPPORTED** | Figure 5.10 | Client UI timer only |
| 13s is Oracle deadlock detection interval | **NOT SUPPORTED** | Figure 5.13 | No internal Oracle timing measurement |
| 0.01s is deadlock detection latency | **NOT SUPPORTED** | Figure 5.13 | Belongs to preceding statement |
| 1m 9s is pure database execution latency | **NOT SUPPORTED** | Figure 5.11 | Includes waiting/coordination |
| Experiment is a production benchmark | **NOT SUPPORTED** | Chapter 5 | No repeated trials/load testing |
| Experiment validates high availability | **NOT SUPPORTED** | Chapter 5 | No failover/crash/RAC testing |
| Experiment validates all Oracle isolation levels | **NOT SUPPORTED** | Chapter 5 | Only the tested concurrency scenario is evaluated |

---

## 10. Threats to Experimental Validity

Several factors constrain the generalizability of the results:

### 10.1 Single-Run Measurements
The recorded execution times are individual observations. The experiment does not report repeated trials, averages, standard deviations, or percentile distributions. Therefore, these values should not be interpreted as statistically representative performance characteristics.

### 10.2 Client-Side Timing
Most timing observations originate from DBeaver's execution interface. This means that measured elapsed time may include factors outside the Oracle database engine itself.

### 10.3 Manual Concurrency Coordination
T03 and T04 require deliberate coordination between Session A and Session B. Consequently, observed waiting durations can be affected by human interaction and cannot be isolated as database-internal latency.

### 10.4 Limited Concurrency Scale
The experiments use two sessions only. No workload was generated to evaluate behavior under:
- tens of concurrent sessions;
- hundreds of concurrent sessions;
- sustained transaction load;
- increasing contention levels.

### 10.5 Limited Internal Observability
The report does not document the use of Oracle dynamic performance views or wait-event instrumentation. Therefore, conclusions are based primarily on externally observable database behavior.

---

## 11. Overall Experimental Assessment

The experimental results provide sufficient evidence to validate the principal behaviors targeted by T02, T03 and T04, while T01 is classified as partially supported because its resulting database metadata was not independently queried.

The strongest evidence is provided by direct state and error observations:
- **T02:** $50,000,000 	ext{ VNĐ}$ restored after `ROLLBACK TO SAVEPOINT`
- **T03:** Session B blocked $ightarrow$ Session A `COMMIT` $ightarrow$ Session B completed $ightarrow$ Final balance = $130,000,000 	ext{ VNĐ}$
- **T04:** Circular dependency $ightarrow$ `ORA-00060`

These observations demonstrate that the tested Oracle environment behaved consistently with the intended transaction and concurrency scenarios. However, the experiment should be interpreted as a functional laboratory validation, not as a performance or production-readiness assessment.

In particular, the following values must remain strictly bounded:
- `13s` $ightarrow$ Client-side waiting observation
- `0.01s` $ightarrow$ Preceding SQL statement execution time
- `1m 9s` $ightarrow$ Total elapsed duration including waiting/coordination

*None of these values provides a direct measurement of Oracle's internal lock timeout, deadlock detection latency, or pure database execution performance.*

---

## 12. Final Conclusion

The experimental evaluation successfully demonstrates the intended Oracle Database 19c mechanisms within the defined laboratory scenarios:
- **T01** demonstrates successful storage-management operations involving tablespaces, datafiles and user quota configuration, with partial validation due to the absence of independent metadata queries.
- **T02** demonstrates partial transaction rollback through `SAVEPOINT` and `ROLLBACK TO SAVEPOINT`, with the expected account state restored.
- **T03** demonstrates blocking between conflicting concurrent row updates and subsequent completion after lock release, producing the expected final balance of 130,000,000 VNĐ.
- **T04** demonstrates circular lock dependency and Oracle's deadlock response through the observed `ORA-00060` error.

The combined evidence is sufficient to establish the behavioral correctness of the tested scenarios, while remaining insufficient to claim production-scale performance, system-wide concurrency guarantees, high availability, crash recovery, or internal Oracle timing characteristics.

> **Appropriate interpretation:** Scenario-level validation of Oracle storage, transaction, locking and deadlock mechanisms — not a production performance benchmark.
