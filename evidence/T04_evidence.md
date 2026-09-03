# T04 — Deadlock Detection

## Objective
Validate the documented behavior of Oracle Database 19c when two concurrent sessions hold row-level locks on different rows and subsequently attempt to access each other's locked rows.  
The experiment focuses on circular waiting, deadlock detection, and Oracle's `ORA-00060` response.

## Environment
- **Database:** Oracle Database 19c
- **Operating System:** Linux
- **Client / Tool:** DBeaver
- **Concurrent Sessions:** Two concurrent database sessions (Session A and Session B)

## Experimental Procedure

### Session A — Step 1
Session A executes:

```sql
UPDATE tai_khoan_ngan_hang
SET so_du = so_du - 1
WHERE stt = 1;
```
The statement updates row `stt = 1` and retains the corresponding transaction lock.

### Session B — Step 2
Session B executes:

```sql
UPDATE tai_khoan_ngan_hang
SET so_du = so_du + 1
WHERE stt = 2;
```
The statement updates row `stt = 2` and retains the corresponding transaction lock.

### Session A — Step 3
Session A then executes:

```sql
UPDATE tai_khoan_ngan_hang
SET so_du = so_du + 1
WHERE stt = 2;
```
Because Session B is holding the lock associated with row `stt = 2`, Session A enters a waiting/blocking state.

### Session B — Step 4
While Session A is waiting, Session B executes:

```sql
UPDATE tai_khoan_ngan_hang
SET so_du = so_du + 1
WHERE stt = 1;
```
Session B requests the row currently held by Session A, creating a circular wait between the two sessions.  
Oracle subsequently returns:

```text
SQL Error [60] [61000]:
ORA-00060: deadlock detected while waiting for resource
```

## Observed Results

| Operation | Result | Time / Metric | Evidence |
| :--- | :--- | :--- | :--- |
| **Session A — Step 1** | Row 1 updated | Not independently measured | Experimental procedure |
| **Session B — Step 2** | Row 2 updated | Not independently measured | Experimental procedure |
| **Session A — Step 3** | Query enters waiting/blocking state | 13s shown in UI | Figure 5.13 |
| **Session B — Step 4** | Deadlock error returned | ORA-00060 | Figure 5.14 |

### Additional Evidence Recorded in Figure 5.13
- **Rows:** 1
- **Execute time:** 0.01s for the preceding statement shown in the Statistics interface
- **UI timer:** `Execute query - 13s`
- **Start time:** Sat Apr 11 13:38:29 ICT 2026
- **Finish time:** Sat Apr 11 13:38:29 ICT 2026

The `0.01s` value belongs to the preceding statement displayed in the DBeaver Statistics interface. It is not the duration of the blocked operation.  
The `13s` value is treated as a client-side UI waiting/elapsed observation at the moment of capture. It is not interpreted as Oracle's internal deadlock-detection interval.

## Evidence

- **Figure 5.13**
  - **Type:** Direct evidence of the blocking state.
  - **Observed state:** Session A is waiting while attempting to access row `stt = 2`.
  - **UI display:** `Execute query - 13s`.
  - **Additional metric:** A preceding statement is shown with an execution time of 0.01s.
  - **Classification:** DIRECT EVIDENCE.
- **Figure 5.14**
  - **Type:** Direct evidence of the deadlock error.
  - **Observed result:** Oracle returns `SQL Error [60] [61000]: ORA-00060: deadlock detected while waiting for resource`.
  - **Classification:** DIRECT EVIDENCE.
- **Table 5.1**
  - **Type:** Supporting evidence for the reported concurrency/deadlock scenario.
  - **Observed result:** The documented scenario results in the reported deadlock error.
  - **Classification:** DIRECT EVIDENCE for the reported observation; INTERPRETATION for mechanism-level explanation.

## Interpretation
Within this experimental scenario, Session A holds the lock associated with row 1 while Session B holds the lock associated with row 2.  
The subsequent requests create the following dependency:

```text
Session A → holds Row 1 → requests Row 2
Session B → holds Row 2 → requests Row 1
                         ↓
                   Circular Wait
                         ↓
                     ORA-00060
```

The observed `ORA-00060` confirms that Oracle detected the documented deadlock condition in this two-session scenario.  
The result demonstrates deadlock detection for the specific circular-wait configuration tested in the experiment.

## Source Boundary

### Confirmed
- Session A's update of row `stt = 1` is documented in the PDF.
- Session B's update of row `stt = 2` is documented in the PDF.
- Session A's subsequent request for row `stt = 2` is documented.
- Session A is directly evidenced in a waiting/blocking state.
- Session B's subsequent request for row `stt = 1` is documented.
- Oracle's `ORA-00060` error is directly evidenced.
- The `13s` UI observation is documented in Figure 5.13.
- The `0.01s` preceding-statement metric is documented in Figure 5.13.

### Not Confirmed
- Independent execution metrics for the initial Session A update.
- Independent execution metrics for the initial Session B update.
- The exact internal duration required by Oracle to detect the deadlock.
- Any post-error `COMMIT` or `ROLLBACK`.
- A final `SELECT` verifying the account balances after the deadlock.
- Oracle internal lock or wait-event statistics.

### Must Not Assume
- The `13s` UI observation must not be described as Oracle's deadlock-detection interval.
- The `0.01s` metric must not be attributed to the blocked operation or deadlock detection.
- No internal Oracle timing should be inferred from the DBeaver UI measurements.
- The experiment must not be generalized into a guarantee against all concurrency anomalies or production deadlock scenarios.
- Additional cleanup, `COMMIT`, `ROLLBACK`, or verification statements must not be added to the documented experiment.

## Contribution Boundary
According to the project contribution table:

- **Nguyễn Minh Quang:**
  - Chapter 4 — Lock and concurrency mechanisms.
  - Analysis of Lock, Blocking and Deadlock.
  - Construction of concurrency/deadlock scenarios.
  - Execution/testing across multiple sessions.
  - Collection of installation and testing evidence.
- **Nguyễn Đức Thuận:**
  - Experimental scenario synthesis.
  - Participation in Oracle 19c execution.
  - Evidence collection.
  - Metrics collection.
  - Experimental analysis.
  - Chapter 5 experimental reporting.

*The repository therefore does not claim Nguyễn Đức Thuận as the original designer of the deadlock scenario or as the environment administrator.*
