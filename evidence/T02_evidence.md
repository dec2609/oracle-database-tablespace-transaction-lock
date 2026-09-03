# T02 — Transaction, COMMIT & Partial Rollback Validation

## Objective
Validate the documented transaction-management procedures in Oracle Database 19c, focusing on:
- `INSERT` and transaction initialization.
- `COMMIT` for permanently committing a transaction.
- `SAVEPOINT` for establishing a partial rollback point.
- `ROLLBACK TO SAVEPOINT` for reversing changes made after the savepoint.
- Verification of the final data state after rollback.

The experiment demonstrates the documented behavior of transaction control within the `tai_khoan_ngan_hang` table.

## Environment
- **Database:** Oracle Database 19c
- **Operating System:** Linux
- **Client / Tool:** DBeaver

## Experimental Procedure

### Scenario 1 — Initialize Data and Commit
The first scenario inserts a new bank account into the database:

```sql
INSERT INTO tai_khoan_ngan_hang
    (stt, chu_tai_khoan, so_du)
VALUES
    (1, 'QUANG_SEC', 100000000);
```
- **Updated Rows:** 1
- **Execute time:** 1.873s

The transaction is then committed:

```sql
COMMIT;
```
- **Updated Rows:** 0
- **Execute time:** 0.002s

This establishes the initial account data for the subsequent transaction experiment.

### Scenario 2 — SAVEPOINT and Partial Rollback
A second account is created:

```sql
INSERT INTO tai_khoan_ngan_hang
    (stt, chu_tai_khoan, so_du)
VALUES
    (2, 'CHI_SEC', 50000000);
```

The transaction is committed:

```sql
COMMIT;
```

A savepoint is then established before the subsequent balance modification:

```sql
SAVEPOINT truoc_khi_tru_tien;
```

The experiment performs the documented balance update:

```sql
UPDATE tai_khoan_ngan_hang
SET so_du = so_du - 50000000
WHERE stt = 2;
```

The change is then rolled back to the previously established savepoint:

```sql
ROLLBACK TO SAVEPOINT truoc_khi_tru_tien;
```
- **Updated Rows:** 0
- **Execute time:** 0.005s

Finally, the account is queried to verify the resulting balance:

```sql
SELECT *
FROM tai_khoan_ngan_hang
WHERE stt = 2;
```
- **STT:** 2
- **CHU_TAI_KHOAN:** CHI_SEC
- **SO_DU:** 50,000,000

## Observed Results

| Operation | Result | Execution Time | Evidence |
| :--- | :--- | :--- | :--- |
| **INSERT — stt = 1** | Updated Rows: 1 | 1.873s | Figure 5.5 |
| **COMMIT — stt = 1** | Updated Rows: 0 | 0.002s | Figure 5.6 |
| **INSERT — stt = 2** | No execution metric documented | Not evidenced | Text, p. 36 |
| **COMMIT — stt = 2** | No execution metric documented | Not evidenced | Text, p. 36 |
| **SAVEPOINT truoc_khi_tru_tien** | Executed as part of the documented script | Not independently measured | Figure 5.7 |
| **UPDATE — stt = 2** | Executed before rollback | Not independently measured | Figure 5.7 |
| **ROLLBACK TO SAVEPOINT** | Updated Rows: 0 | 0.005s | Figure 5.7 |
| **Final SELECT — stt = 2** | Balance returned as 50,000,000 | Not measured | Figure 5.8 |

### Recorded Execution Times
The report provides the following DBeaver execution timestamps:

- **INSERT (stt = 1):**
  - Start: Thu Mar 26 13:23:05 ICT 2026
  - Finish: Thu Mar 26 13:23:07 ICT 2026
- **COMMIT (stt = 1):**
  - Start: Thu Mar 26 13:23:51 ICT 2026
  - Finish: Thu Mar 26 13:23:51 ICT 2026
- **ROLLBACK TO SAVEPOINT:**
  - Start: Sat Apr 11 12:46:42 ICT 2026
  - Finish: Sat Apr 11 12:46:42 ICT 2026

*No execution time is assigned to operations for which the report does not provide an independent Statistics measurement.*

## Evidence

- **Figure 5.5 — INSERT**
  - *Type:* Direct evidence
  - *Description:* Direct evidence of the first INSERT operation. The figure shows the SQL statement and DBeaver Statistics indicating Updated Rows: 1, Execute time: 1.873s. This confirms the documented insertion of the `QUANG_SEC` account.
- **Figure 5.6 — COMMIT**
  - *Type:* Direct evidence
  - *Description:* Direct evidence of the first COMMIT operation. The figure shows Updated Rows: 0, Execute time: 0.002s. This confirms successful execution of the transaction commit documented in the report.
- **Figure 5.7 — SAVEPOINT / UPDATE / ROLLBACK**
  - *Type:* Direct evidence
  - *Description:* Direct evidence of the transaction recovery procedure. The DBeaver script contains the sequence `SAVEPOINT -> UPDATE -> ROLLBACK TO SAVEPOINT`. Statistics records Execute time: 0.005s, Updated Rows: 0.
- **Figure 5.8 — Final Verification**
  - *Type:* Direct evidence
  - *Description:* Direct evidence of the final data state. The query `SELECT * FROM tai_khoan_ngan_hang WHERE stt = 2;` returns `STT = 2`, `CHU_TAI_KHOAN = CHI_SEC`, `SO_DU = 50,000,000`.

## Interpretation
The experiment demonstrates a partial transaction rollback using a savepoint:

```
Create CHI_SEC
       ↓
     COMMIT
       ↓
   SAVEPOINT
       ↓
UPDATE balance - 50,000,000
       ↓
ROLLBACK TO SAVEPOINT
       ↓
Balance remains 50,000,000
```

The final query shows that the balance of `CHI_SEC` remains at 50,000,000 after the rollback. Within this experimental scenario, the change made after the savepoint was successfully reversed while the previously committed account state remained available.

The result is consistent with the purpose of `ROLLBACK TO SAVEPOINT` documented in the report: restoring the transaction state to a previously established savepoint rather than treating the entire transaction as a single rollback operation.

## Source Boundary

### Confirmed
The following information is directly documented in the original report:
- `INSERT` for `QUANG_SEC`.
- `COMMIT` following the first insertion.
- `INSERT` for `CHI_SEC`.
- `COMMIT` following the second insertion.
- `SAVEPOINT truoc_khi_tru_tien`.
- `UPDATE` reducing the balance of account `stt = 2`.
- `ROLLBACK TO SAVEPOINT truoc_khi_tru_tien`.
- Final `SELECT` verification.
- Execution times of:
  - `INSERT (stt = 1)`: 1.873s
  - `COMMIT (stt = 1)`: 0.002s
  - `ROLLBACK TO SAVEPOINT`: 0.005s
- Final balance of `CHI_SEC`: 50,000,000.

### Not Confirmed
The report does not provide independent Statistics measurements for:
- `INSERT (stt = 2)`.
- `COMMIT (stt = 2)`.
- `SAVEPOINT`.
- The `UPDATE` operation before rollback.
- The final `SELECT`.
- The report also does not provide a separate intermediate query showing the balance immediately after the `UPDATE` and before the rollback.

### Must Not Assume
- Do not invent execution times for operations without Statistics evidence.
- Do not add cleanup commands such as `DELETE` or `DROP TABLE`.
- Do not add additional `COMMIT` statements that are not documented.
- Do not claim that Nguyễn Đức Thuận was the original author of the Transaction scenario.
- Do not claim that the experiment proves transaction behavior under every possible production workload.
- Do not infer undocumented database configuration or environment details.

## Contribution Boundary
According to the project's contribution table:

- **Nguyễn Ngọc Tuyết Ngân:**
  - Chapter 3 — Transaction management and data integrity.
  - Analysis of Undo, Redo, COMMIT, ROLLBACK, and SAVEPOINT.
  - Building and running transaction-control scenarios.
  - Testing data recovery behavior.
  - Recording experimental results and illustrative evidence.
- **Nguyễn Đức Thuận:**
  - Experimental scenario synthesis.
  - Participation in Oracle 19c execution.
  - Evidence collection.
  - Metrics collection.
  - Experimental analysis.
  - Chapter 5 — Experimental implementation and evaluation.
  - Comparison of experimental results with theoretical concepts.

*The repository therefore does not claim Nguyễn Đức Thuận as the sole designer or original author of the Transaction experiment. Environment/server setup is not attributed to Nguyễn Đức Thuận because the report does not provide evidence supporting that claim.*

## Reproduction Notes
This artifact is intended to support later reproduction of the documented experiment on an Oracle Database 19c environment.

The SQL should be treated as a reconstruction of the documented experimental procedure rather than as the original source file used by the team.

Any future re-execution should record its own:
- Execution time.
- Observed result.
- DBeaver/Oracle evidence.
- Environment information.

*These reproduction results must remain distinguishable from the original measurements documented in the academic report.*
