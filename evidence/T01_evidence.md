# T01 — Tablespace & Quota Validation

## 1. Objective
Validate the documented experimental procedures involving:
- Permanent Tablespace creation
- Business table allocation to the Tablespace
- Datafile resizing
- User quota configuration

The experiment was conducted in an Oracle Database 19c laboratory environment.

## 2. Environment

| Item | Documented Environment |
| :--- | :--- |
| **Database** | Oracle Database 19c |
| **Operating System** | Linux |
| **Client / Tool** | DBeaver |
| **Tablespace** | DO_AN_TS |
| **Datafile** | do_an_ts_01.dbf |
| **Target User** | c##quang |

*Note: The Oracle/Linux laboratory environment was not established by Nguyễn Đức Thuận.*

## 3. Experimental Procedure

### Step 1 — Create Tablespace
A permanent Tablespace named `DO_AN_TS` was created with an initial Datafile size of 100 MB.

```sql
CREATE TABLESPACE DO_AN_TS
DATAFILE '/u01/app/oracle/oradata/ORCL/do_an_ts_01.dbf'
SIZE 100M;
```
- **Observed:** Successful execution.
- **Execution time:** 1.25s
- **Evidence:** Figure 5.1.

### Step 2 — Create Business Table
The `tai_khoan_ngan_hang` table was created and assigned to the `DO_AN_TS` Tablespace.

```sql
CREATE TABLE tai_khoan_ngan_hang (
    stt NUMBER PRIMARY KEY,
    chu_tai_khoan VARCHAR2(50),
    so_du NUMBER
)
TABLESPACE DO_AN_TS;
```
- **Observed:** Successful execution.
- **Execution time:** 0.358s
- **Evidence:** Figure 5.2.

### Step 3 — Resize Datafile
The Datafile associated with `DO_AN_TS` was resized to 200 MB.

```sql
ALTER DATABASE DATAFILE
'/u01/app/oracle/oradata/ORCL/do_an_ts_01.dbf'
RESIZE 200M;
```
- **Observed:** Successful execution.
- **Execution time:** 1.031s
- **Evidence:** Figure 5.3.

*The report documents successful execution of the resize operation. This repository does not interpret the result as evidence of zero-downtime or high-availability behavior.*

### Step 4 — Configure User Quota
An unlimited quota was assigned to user `c##quang` on `DO_AN_TS`.

```sql
ALTER USER c##quang
QUOTA UNLIMITED ON DO_AN_TS;
```
- **Observed:** Successful execution.
- **Execution time:** 0.148s
- **Evidence:** Figure 5.4.

## 4. Results & Metrics

| Operation | Result | Execution Time | Evidence |
| :--- | :--- | :--- | :--- |
| Create Tablespace DO_AN_TS | PASS | 1.25s | Figure 5.1 |
| Create tai_khoan_ngan_hang | PASS | 0.358s | Figure 5.2 |
| Resize Datafile to 200M | PASS | 1.031s | Figure 5.3 |
| Assign QUOTA UNLIMITED | PASS | 0.148s | Figure 5.4 |

### DBeaver Execution Timestamps
The report additionally records the following execution timestamps:

| Operation | Start | Finish |
| :--- | :--- | :--- |
| Create Tablespace | Wed Mar 25 17:18:08 ICT 2026 | Wed Mar 25 17:18:10 ICT 2026 |
| Create Table | Thu Mar 26 13:20:56 ICT 2026 | Thu Mar 26 13:20:56 ICT 2026 |
| Resize Datafile | Sat Apr 11 12:34:49 ICT 2026 | Sat Apr 11 12:34:50 ICT 2026 |
| Quota Unlimited | Sat Apr 11 12:35:14 ICT 2026 | Sat Apr 11 12:35:14 ICT 2026 |

*The execution times above are retained as reported experimental metrics and are not independently recalculated.*

## 5. Evidence

- **Figure 5.1**
  - *Type:* Direct evidence
  - *Description:* Demonstrates successful execution of the `CREATE TABLESPACE` operation and the associated execution metric.
- **Figure 5.2**
  - *Type:* Direct evidence
  - *Description:* Demonstrates successful creation of the `tai_khoan_ngan_hang` table on `DO_AN_TS`.
- **Figure 5.3**
  - *Type:* Direct evidence
  - *Description:* Demonstrates successful execution of the Datafile resize operation.
- **Figure 5.4**
  - *Type:* Direct evidence
  - *Description:* Demonstrates successful execution of the quota configuration for `c##quang`.

## 6. Contribution
According to the project's contribution record, Nguyễn Đức Thuận's relevant responsibilities included:
- Synthesizing the experimental scenarios covering Tablespace, Transaction and Lock.
- Participating in the experimental execution process.
- Collecting experimental results and visual evidence.
- Extracting execution metrics.
- Analyzing experimental results against the theoretical material.
- Presenting Chapter 5: Experimental Implementation and Evaluation.

*The Oracle/Linux laboratory environment setup is not attributed to Nguyễn Đức Thuận. The Tablespace theoretical module and the documented hands-on Tablespace/Datafile/Quota work were also assigned to Nguyễn Thị Phương Trâm. Therefore, this repository describes Thuận's role as scenario synthesis, coordination/participation, evidence and metrics collection, analysis, and reporting, rather than environment provisioning or sole ownership of the Tablespace module.*

## 7. Source Boundary

### Confirmed
The original report directly documents:
- Creation of `DO_AN_TS`.
- Creation of `tai_khoan_ngan_hang` on `DO_AN_TS`.
- Resizing the Datafile to 200 MB.
- Assignment of `QUOTA UNLIMITED` to `c##quang`.
- The reported execution metrics.
- Figures 5.1–5.4 as experimental evidence.
- The contribution boundaries described above.

### Not Confirmed
The report does not establish:
- How user `c##quang` was originally created.
- Actual Datafile space consumption after table creation.
- Quota configuration for users other than `c##quang`.
- Detailed Oracle installation procedures.
- Detailed Linux configuration or administration procedures.

### Must Not Assume
This artifact must not be interpreted as evidence that:
- Nguyễn Đức Thuận installed or configured Oracle/Linux.
- Nguyễn Đức Thuận was the DBA or system administrator.
- `QUOTA UNLIMITED` was implemented as an anti-DoS control.
- Datafile resizing demonstrated zero-downtime or high availability.
- The reconstructed SQL file is the original source code used by the team.

## 8. Reproduction Status
- **Status:** Documented / Reconstructed
- The SQL commands in this directory are reconstructed from the experimental procedure documented in the original academic report. They are not presented as the original source files used during the team's experiment.
- A future reproduction run may independently execute these procedures on an Oracle 19c laboratory environment and record new evidence and metrics separately.
