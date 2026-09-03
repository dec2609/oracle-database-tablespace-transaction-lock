# Oracle Database 19c — Tablespace, Transaction & Lock

**Academic Database Project** — Experimental study of Tablespace, Transaction, Concurrency & Lock mechanisms in Oracle Database 19c.

---

## Overview

This project investigates how Oracle Database 19c manages storage allocation, transaction control, concurrent access, row-level blocking, and deadlock detection through four controlled experimental scenarios.

The repository is structured as a scenario-level functional and behavioral evaluation, using SQL execution results, timing observations, screenshots, and experimental analysis as evidence. The academic report serves as the Source of Truth for the project's implementation, observations, measurements, and conclusions.

---

## Project Objectives

- Examine tablespace and datafile management in Oracle Database 19c.
- Demonstrate transaction control using `COMMIT`, `SAVEPOINT`, and partial `ROLLBACK`.
- Observe concurrent transactions and row-level blocking between database sessions.
- Reproduce a deadlock scenario and observe Oracle's `ORA-00060` response.

---

## Experimental Scope

| Test | Topic | Main Objective | Result |
| :--- | :--- | :--- | :--- |
| **T01** | Tablespace & Quota | Create and manage tablespace, datafile, and user quota | **Partially Supported** |
| **T02** | Transaction & Savepoint | Verify partial rollback to a savepoint | **Supported** |
| **T03** | Concurrency & Blocking | Observe row-level blocking between two sessions | **Supported** |
| **T04** | Deadlock Detection | Reproduce circular waiting and observe Oracle's response | **Supported** |

### T01 — Tablespace & Quota
The experiment creates the `DO_AN_TS` tablespace, creates a table within the tablespace, resizes its datafile from 100 MB to 200 MB, and configures an unlimited quota for the test user.
The experiment successfully demonstrates the intended storage-management operations. However, independent validation through dictionary views such as `DBA_TABLESPACES`, `DBA_DATA_FILES`, and `DBA_TS_QUOTAS` was not captured in the experiment, so the evidence is classified as **Partially Supported**.

### T02 — Transaction & Partial Rollback
The experiment creates account records, commits them, establishes a savepoint, performs an erroneous balance update, and uses `ROLLBACK TO SAVEPOINT`.
The affected account balance is restored from the erroneous state back to 50,000,000 VNĐ, demonstrating the intended partial rollback behavior.

### T03 — Concurrency & Row-Level Blocking
Two database sessions concurrently access the same account row.
Session A performs an update and remains uncommitted. Session B attempts to update the same row and becomes blocked until Session A commits.
After both transactions complete, the final balance is:
$$130,000,000 	ext{ VNĐ}$$
This experiment demonstrates row-level blocking in the tested two-session scenario.

### T04 — Deadlock Detection
Two sessions acquire locks in an incompatible order:
$$	ext{Session A} \longrightarrow 	ext{locks Row 1} \longrightarrow 	ext{waits for Row 2}$$
$$	ext{Session B} \longrightarrow 	ext{locks Row 2} \longrightarrow 	ext{waits for Row 1}$$

This creates a circular wait condition. Oracle detects the conflict and returns:
```text
ORA-00060: deadlock detected while waiting for resource
```
The experiment confirms deadlock detection and the corresponding Oracle error response for the tested scenario.

---

## Key Findings

- **Storage Management:** A dedicated tablespace `DO_AN_TS` was created with an initial datafile size of 100 MB, successfully resized to 200 MB, and user quota configuration was applied.
- **Transaction Control:** `COMMIT` finalized transactions, `SAVEPOINT` established rollback checkpoints, and `ROLLBACK TO SAVEPOINT` restored the tested account balance to 50,000,000 VNĐ without discarding prior committed operations.
- **Concurrency:** Two sessions accessing the same row produced observable blocking. The blocked transaction resumed after the blocking transaction committed, yielding an expected serialized final balance of 130,000,000 VNĐ.
- **Deadlock:** A circular wait condition was successfully reproduced, and Oracle returned `ORA-00060`, terminating one conflicting statement.

---

## Repository Structure

```text
oracle-database-tablespace-transaction-lock/
│
├── README.md
├── CONTRIBUTION.md
│
├── report/
│   └── academic-report.pdf
│
├── sql/
│   ├── T01-tablespace-quota.sql
│   ├── T02-transaction-savepoint.sql
│   ├── T03-concurrency-lock.sql
│   └── T04-deadlock.sql
│
├── evidence/
│   ├── T01-evidence.md
│   ├── T02-evidence.md
│   ├── T03-evidence.md
│   └── T04-evidence.md
│
├── analysis/
│   ├── test-plan.md
│   ├── metrics.md
│   └── experimental-evaluation.md
│
└── .gitignore
```

---

## Project Workflow

The repository follows an evidence-driven workflow:

```text
Academic Report
      │
      ▼
SQL Test Scenarios
      │
      ├── T01
      ├── T02
      ├── T03
      └── T04
      │
      ▼
Evidence (Screenshots & Logs)
      │
      ▼
Metrics & Experimental Evaluation
      │
      ▼
Final Findings
```

*The SQL scripts provide the experimental procedures, while the evidence and analysis files document what was observed and evaluate the evidentiary strength supporting each conclusion.*

---

## Reproduction

### Requirements
- Oracle Database 19c
- SQL client capable of executing Oracle SQL (e.g., DBeaver)
- Appropriate privileges for tablespace, datafile, table, and user-quota operations
- Two concurrent database sessions for concurrency and deadlock experiments

### Execution Order
Execute the test cases sequentially:
$$	ext{T01} \longrightarrow 	ext{T02} \longrightarrow 	ext{T03} \longrightarrow 	ext{T04}$$

1. **T01:** Execute `sql/T01-tablespace-quota.sql` (covers tablespace creation, table creation, datafile resizing, and quota configuration).
2. **T02:** Execute `sql/T02-transaction-savepoint.sql` (demonstrates transaction commits, savepoints, and partial rollback).
3. **T03:** Execute `sql/T03-concurrency-lock.sql` across two database sessions to observe row-level blocking.
4. **T04:** Execute `sql/T04-deadlock.sql` across two database sessions following the documented cross-update sequence to reproduce circular waiting.

> *Note:* Exact execution behavior and timing may vary depending on the Oracle environment, client software, host performance, and session coordination.

---

## Evidence & Analysis Reference

### Evidence Documents
| Test | Evidence File |
| :--- | :--- |
| **T01** | `evidence/T01-evidence.md` |
| **T02** | `evidence/T02-evidence.md` |
| **T03** | `evidence/T03-evidence.md` |
| **T04** | `evidence/T04-evidence.md` |

### Detailed Analysis Files
- **Test Plan:** `analysis/test-plan.md` — Experimental parameters, preconditions, and execution procedures.
- **Experimental Metrics:** `analysis/metrics.md` — Execution times and quantitative observations recorded during testing.
- **Experimental Evaluation:** `analysis/experimental-evaluation.md` — Evidentiary classification and interpretation boundaries.

---

## Important Limitations

This project is a controlled academic experiment and **not** a production-scale database benchmark. The experiments do not establish:
- General database performance under high concurrency workloads.
- Production scalability or throughput (TPS).
- System resource utilization (CPU, RAM, SGA/PGA, disk I/O latency, or IOPS).
- Statistical latency distributions (p50, p95, p99).
- Deadlock detection latency at the internal Oracle engine level.
- Crash-recovery or power-failure durability behavior.
- Comprehensive isolation-level anomaly testing.
- Production high-availability or zero-downtime guarantees.

*Client-side UI timing observations (such as timer snapshots in DBeaver) must not be interpreted as Oracle internal engine wait times or timeout parameters.*

---

## Academic Contribution

This repository organizes the project into four traceable layers:
$$	ext{Implementation} \longrightarrow 	ext{SQL Scripts} \longrightarrow 	ext{Evidence} \longrightarrow 	ext{Experimental Evaluation}$$

For complete details on group work allocation, module responsibilities, and contribution boundaries, see [CONTRIBUTION.md](CONTRIBUTION.md).

---

## Conclusion

The project demonstrates four fundamental Oracle Database 19c behaviors through controlled experiments:
1. Tablespace and datafile management
2. Transaction control and partial rollback
3. Concurrent access and row-level blocking
4. Deadlock detection

The strongest conclusions are those directly supported by the captured experimental evidence. Where independent instrumentation or repeated measurements were not available, the repository explicitly limits the scope of its claims rather than treating observations as general performance guarantees.
