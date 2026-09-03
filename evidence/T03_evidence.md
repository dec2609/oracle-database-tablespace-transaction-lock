# T03 — Concurrency & Row-Level Lock / Blocking

## Objective

Validate the documented behavior of Oracle Database 19c when two concurrent sessions attempt to update the same database row.

The experiment focuses on row-level locking, blocking, lock release through `COMMIT`, and the resulting data consistency.

## Environment

- **Database:** Oracle Database 19c
- **Operating System:** Linux
- **Client / Tool:** DBeaver
- **Concurrent Sessions:** Two concurrent database sessions (Session A and Session B)

## Experimental Procedure

### Session A
Session A executes:

```sql
UPDATE tai_khoan_ngan_hang
SET so_du = so_du - 20000000
WHERE stt = 1;
```
The statement updates one row and remains uncommitted.

### Session B
Session B executes:

```sql
UPDATE tai_khoan_ngan_hang
SET so_du = so_du + 50000000
WHERE stt = 1;
```
Because Session A has not released its lock, Session B enters a waiting/blocking state.

### Lock Release
Session A executes:

```sql
COMMIT;
```
*Note: This statement is reconstructed from the textual procedure in the report because no standalone screenshot of the COMMIT statement is preserved in the T03 evidence.*

After the lock is released, Session B continues execution and completes.

### Verification
The final state is checked using:

```sql
SELECT * FROM tai_khoan_ngan_hang;
```
The documented result is:
- **STT:** 1
- **CHU_TAI_KHOAN:** QUANG_SEC
- **SO_DU:** 130,000,000

## Observed Results

| Operation | Result | Time | Evidence |
| :--- | :--- | :--- | :--- |
| **Session A UPDATE** | Updated Rows: 1 | 0.006s | Figure 5.9 |
| **Session B UPDATE — blocking** | Query enters waiting state | 13s shown in UI | Figure 5.10 |
| **Session A COMMIT** | Lock released | Not independently measured | Textual procedure |
| **Session B UPDATE — completed** | Updated Rows: 1 | 1m 9s total | Figure 5.11 |
| **Final SELECT** | Balance = 130,000,000 | No Statistics metric | Figure 5.12 |

## Evidence

- **Figure 5.9**
  - *Type:* Direct evidence of Session A's UPDATE.
  - *Metrics:* Updated Rows: 1, Execute time: 0.006s.
- **Figure 5.10**
  - *Type:* Direct evidence of Session B entering a waiting/blocking state.
  - *UI display:* `Execute query - 13s`.
- **Figure 5.11**
  - *Type:* Direct evidence of Session B completing after the lock is released.
  - *Metrics:* Updated Rows: 1, Execute time: 1m 9s, Start: 13:39:47, Finish: 13:40:56.
- **Figure 5.12**
  - *Type:* Direct evidence of the final data state.
  - *Data:* The account `QUANG_SEC` has `SO_DU = 130,000,000`.

## Interpretation

Within this experimental scenario, the second update could not immediately modify the same row while Session A retained its uncommitted lock. After Session A committed, Session B was able to continue and complete successfully.

The final balance of 130,000,000 is consistent with the documented sequence:

```
100,000,000
      ↓
-20,000,000  (Session A)
      ↓
 80,000,000
      ↓
+50,000,000  (Session B)
      ↓
130,000,000
```

## Source Boundary

### Confirmed
- Session A UPDATE is documented in the PDF.
- Session B UPDATE is documented in the PDF.
- Blocking is directly evidenced.
- Session A COMMIT is documented through the textual procedure.
- Session B eventually completes successfully.
- Final balance is directly shown as 130,000,000.
- Execution metrics of 0.006s, 13s and 1m 9s are documented.

### Not Confirmed
- A standalone Statistics screenshot for Session A's COMMIT.
- A Statistics measurement for the final SELECT.
- Whether Session B performed a separate COMMIT afterward.

### Must Not Assume
- 1m 9s must not be described as pure SQL execution time.
- 13s must not be presented as the exact total lock duration.
- The experiment must not be generalized into a production-level guarantee against all concurrency anomalies.
- Additional COMMIT, cleanup, or verification SQL must not be inserted into the original experiment.

## Contribution Boundary

According to the project contribution table:

- **Nguyễn Minh Quang:**
  - Chapter 4 — Lock and concurrency mechanisms.
  - Concurrency scenario construction.
  - Blocking/deadlock simulation.
- **Nguyễn Đức Thuận:**
  - Experimental scenario synthesis.
  - Participation in execution.
  - Evidence and metrics collection.
  - Experimental analysis.
  - Chapter 5 reporting.

*The repository therefore does not claim Nguyễn Đức Thuận as the original author of the concurrency scenario or as the environment administrator.*
