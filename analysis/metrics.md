# Experimental Metrics — Oracle Database 19c

> **Source of Truth:** Academic Report — *Hệ quản trị cơ sở dữ liệu Oracle: Tablespace, Transaction và Lock*  
> **Scope:** T01–T04  
> **Purpose:** Consolidate, classify, and interpret the experimental measurements recorded during testing.

---

## 1. Overview

The metrics reported in the academic report were primarily collected from the **DBeaver Statistics / execution interface** during the execution of four test cases.

| Test | Topic | Primary Metrics |
| :--- | :--- | :--- |
| **T01** | Tablespace & Quota | Execution time, storage capacity |
| **T02** | Transaction & Savepoint | DML / COMMIT / ROLLBACK time, data state |
| **T03** | Concurrency & Blocking | Execution time, blocking observation, final balance |
| **T04** | Deadlock | UI wait observation, error code |

These measurements are used for **academic validation** of the Oracle mechanisms demonstrated in the report. They are not intended to constitute a production performance benchmark.

---

## 2. Metric Inventory

### 2.1 T01 — Tablespace & Quota

| Operation | Metric | Value | Unit | Evidence |
| :--- | :--- | ---: | :--- | :--- |
| `CREATE TABLESPACE DO_AN_TS` | Execution Time | **1.25** | s | Figure 5.1, p.31 |
| Create Tablespace | Initial Size | **100** | MB | Figure 5.1, p.31 |
| `CREATE TABLE tai_khoan_ngan_hang` | Execution Time | **0.358** | s | Figure 5.2, p.32 |
| Datafile `RESIZE` | Execution Time | **1.031** | s | Figure 5.3, p.32 |
| Datafile `RESIZE` | Capacity | **100 → 200** | MB | Figure 5.3, p.32 |
| `ALTER USER ... QUOTA` | Execution Time | **0.148** | s | Figure 5.4, p.33 |

**Observed State:**
- Tablespace `DO_AN_TS` was created with an initial datafile size of **100 MB**.
- The datafile was resized to **200 MB**.
- User `c##quang` was assigned `QUOTA UNLIMITED` on `DO_AN_TS`.

*The execution times represent the durations displayed by the DBeaver environment during the experiment.*

---

### 2.2 T02 — Transaction & Partial Rollback

| Operation | Metric | Value | Unit | Evidence |
| :--- | :--- | ---: | :--- | :--- |
| Insert account `stt=1` | Execution Time | **1.873** | s | Figure 5.5, p.34 |
| Insert account `stt=1` | Rows Inserted | **1** | row | Figure 5.5, p.34 |
| Account `QUANG_SEC` | Initial Balance | **100,000,000** | VNĐ | Figure 5.5, p.34 |
| `COMMIT` | Execution Time | **0.002** | s | Figure 5.6, p.35 |
| Insert account `stt=2` | Initial Balance | **50,000,000** | VNĐ | Section 5.2.2.2, p.36 |
| Erroneous Update | Deduction | **50,000,000** | VNĐ | Section 5.2.2.2, p.36 |
| `ROLLBACK TO SAVEPOINT` | Execution Time | **0.005** | s | Figure 5.7, p.37 |
| Post-rollback Verification | Restored Balance | **50,000,000** | VNĐ | Figure 5.8, p.37 |

**Observed State:**
1. Account `CHI_SEC` had an initial balance of **50,000,000 VNĐ**.
2. An update operation reduced the balance by **50,000,000 VNĐ**.
3. The transaction was rolled back to the savepoint `truoc_khi_tru_tien`.
4. The verification query showed that the balance had returned to **50,000,000 VNĐ**.

*Execution times for the second account insertion, its commit, the `SAVEPOINT` operation, and the erroneous update were not recorded in the report.*

---

### 2.3 T03 — Concurrency & Row-Level Blocking

| Operation / Event | Metric | Value | Unit | Evidence |
| :--- | :--- | ---: | :--- | :--- |
| Session A `UPDATE stt=1` | Execution Time | **0.006** | s | Figure 5.9, p.38 |
| Session A Update | Modification | **−20,000,000** | VNĐ | Figure 5.9, p.38 |
| Session B Conflicting Update | Modification | **+50,000,000** | VNĐ | Figure 5.10, p.39 |
| Session B Blocking | UI Timer Snapshot | **13** | s | Figure 5.10, p.39 |
| Session B Completion | Total Elapsed Time | **1m 9s** | min/sec | Figure 5.11, p.40 |
| Session B Completion | Updated Rows | **1** | row | Figure 5.11, p.40 |
| Final Verification | Balance | **130,000,000** | VNĐ | Figure 5.12, p.40 |

### Concurrency Calculation
The observed final balance is consistent with the serialized update sequence:

$$100,000,000 - 20,000,000 + 50,000,000 = 130,000,000 	ext{ VNĐ}$$

The experiment therefore provides evidence that, under the tested two-session scenario, Session B's conflicting update did not overwrite Session A's committed modification.

### Important Metric Boundary
The **13s** value is a **client-side DBeaver UI timer snapshot** observed while Session B was waiting.

It must **not** be interpreted as:
- an Oracle lock timeout;
- an Oracle deadlock detection interval;
- internal row-lock acquisition latency;
- database engine wait-event duration.

Likewise, the **1m 9s** value represents the total elapsed time for Session B, including the waiting period and actual execution. It is therefore not an isolated database processing latency measurement.

---

## 3. T04 — Deadlock Detection

| Operation / Event | Metric | Value | Unit | Evidence |
| :--- | :--- | :--- | :--- | :--- |
| Preceding Statement | Execution Time | **0.01** | s | Figure 5.13, p.42 |
| Session A Suspended State | UI Timer Snapshot | **13** | s | Figure 5.13, p.42 |
| Deadlock Exception | Error Code | **ORA-00060** | code | Figure 5.14, p.42 |
| Deadlock Exception | Error Message | `deadlock detected while waiting for resource` | text | Figure 5.14, p.42 |

The tested deadlock sequence follows the circular dependency:

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

The report confirms the occurrence of Oracle's deadlock error:
```text
SQL Error [60] [61000]:
ORA-00060: deadlock detected while waiting for resource
```

### Important Metric Boundary
The **0.01s** value belongs to a preceding statement shown in the DBeaver Statistics tab. It is **not** the time Oracle required to detect the deadlock.

Similarly, the **13s** UI timer is only an observed client-side waiting snapshot. The report does not provide an Oracle-internal deadlock detection latency.

---

## 4. Consolidated Metrics

| Test | Metric | Value | Classification | Interpretation |
| :--- | :--- | :--- | :--- | :--- |
| **T01** | Tablespace creation | 1.25s | Execution | DBeaver-reported SQL duration |
| **T01** | Table creation | 0.358s | Execution | DBeaver-reported SQL duration |
| **T01** | Datafile resize | 1.031s | Execution | DBeaver-reported SQL duration |
| **T01** | Quota assignment | 0.148s | Execution | DBeaver-reported SQL duration |
| **T02** | Insert account 1 | 1.873s | Execution | DBeaver-reported SQL duration |
| **T02** | Commit | 0.002s | Execution | DBeaver-reported transaction duration |
| **T02** | Rollback to savepoint | 0.005s | Execution | DBeaver-reported rollback duration |
| **T03** | Session A update | 0.006s | Execution | DBeaver-reported SQL duration |
| **T03** | Session B blocking | 13s | Observation | Client UI timer snapshot |
| **T03** | Session B completion | 1m 9s | Total elapsed | Includes waiting + execution |
| **T03** | Final balance | 130M VNĐ | Validation | Final serialized state |
| **T04** | Preceding statement | 0.01s | Execution | Prior statement duration |
| **T04** | Waiting observation | 13s | Observation | Client UI timer snapshot |
| **T04** | Deadlock | ORA-00060 | Fault | Oracle deadlock error |

---

## 5. Metrics Not Captured

The report does not provide measurements for:
- `V$LOCK`, `V$LOCKED_OBJECT`, `V$SESSION_BLOCKERS`, or other dynamic lock views;
- Oracle wait-event durations such as `enq: TX - row lock contention`;
- CPU utilization;
- RAM / SGA / PGA utilization;
- buffer cache statistics;
- disk I/O latency or IOPS;
- transaction throughput (TPS);
- scalability under increasing concurrency;
- repeated trials;
- mean, median, or standard deviation;
- p50, p95, or p99 latency;
- execution time of the second account insertion and commit in T02;
- execution time of the initial T04 Session A/B updates.

Consequently, the available metrics support **behavioral validation**, but not statistical performance benchmarking.

---

## 6. Interpretation Boundaries

### What the Metrics Support
The collected measurements support the following conclusions within the experimental scope:
- Oracle successfully executed the tested tablespace and datafile management operations.
- The transaction scenario demonstrated partial rollback to a savepoint and restoration of the expected account state.
- The concurrency scenario demonstrated blocking between two sessions attempting conflicting updates on the same row.
- The final T03 balance was consistent with the expected serialized update sequence.
- The deadlock scenario produced Oracle error `ORA-00060`.

### What the Metrics Do Not Support
The measurements do **not** establish:
- production-grade database performance;
- generalized Oracle throughput or scalability;
- internal Oracle lock acquisition latency;
- Oracle's internal deadlock detection interval;
- physical disk synchronization latency;
- database-wide performance characteristics;
- statistical reliability across repeated trials.

In particular:
> **13s ≠ Oracle timeout / deadlock detection latency**  
> **0.01s ≠ deadlock detection latency**  
> **1m 9s ≠ pure database execution latency**  

*These values must remain classified according to the evidence actually available in the report.*

---

## 7. Experimental Validity

The metrics have several limitations that affect their interpretation:
1. **Single-Trial Measurements:** The report does not document repeated executions, so the recorded execution times cannot be treated as statistically stable estimates.
2. **Client-Side Timing:** Most execution times originate from the DBeaver interface rather than Oracle's internal performance instrumentation.
3. **Manual Session Coordination:** T03 and T04 require coordination between two independent sessions. Therefore, observed elapsed time can include operator-induced waiting.
4. **Limited Concurrency Scope:** Only two sessions are used. No scalability behavior under larger concurrent workloads is measured.
5. **Limited Internal Observability:** No Oracle dynamic performance views or wait-event measurements are documented.

For these reasons, the metrics should be used primarily to **validate the expected database behavior demonstrated by each scenario**, rather than to rank or benchmark Oracle performance.

---

## 8. Final Metric Summary

The experimental dataset contains a small but sufficient set of measurements for validating the four scenarios:

```text
T01 → Storage Management
      1.25s | 0.358s | 1.031s | 0.148s

T02 → Transaction / Savepoint
      1.873s | 0.002s | 0.005s
      50M VNĐ restored

T03 → Concurrency / Blocking
      0.006s | 13s observation | 1m 9s total
      130M VNĐ final balance

T04 → Deadlock
      13s observation | ORA-00060
```

Overall, the collected metrics provide **direct evidence of execution, state changes, blocking behavior, and deadlock occurrence** in the tested Oracle Database 19c environment.

However, the dataset is intentionally treated as **scenario-level experimental evidence**, not as a statistically rigorous database performance benchmark.
