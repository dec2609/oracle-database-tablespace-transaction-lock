# Contribution

## 1. Project-Level Contribution

This document establishes the documented roles and contribution boundaries for the academic project **Oracle Database System: Tablespace, Transaction, and Lock (Consistency, Concurrency)**.

| Member | Documented Responsibility | Assigned Scope | Source | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Nguyễn Minh Quang** | Team Leader; responsible for theoretical analysis of locks, blocking, and deadlock; built concurrency/deadlock scenarios across multiple sessions; participated in testing and evidence collection. | Chapter 4 | Page 49 | Confirmed |
| **Nguyễn Ngọc Quỳnh Chi** | Responsible for the Introduction and Conclusion; defined objectives and practical relevance; reviewed and finalized the report; participated in Oracle 19c testing and supported result consolidation. | Introduction, Conclusion | Pages 49–50 | Confirmed |
| **Nguyễn Ngọc Tuyết Ngân** | Responsible for transaction theory, including Undo/Redo, COMMIT, ROLLBACK, and SAVEPOINT; built and executed transaction-control experiments and recorded recovery results. | Chapter 3 | Page 50 | Confirmed |
| **Nguyễn Đức Thuận** | Consolidated experimental scenarios across Tablespace, Transaction, and Lock; directly participated in Oracle 19c execution; collected experimental results and screenshots; performed analysis against theory; presented Chapter 5. | Chapter 5 | Page 50 | Confirmed |
| **Nguyễn Thị Phương Trâm** | Responsible for Tablespace theory, storage management, and quota; participated in Tablespace creation, Datafile expansion, and storage-allocation verification. | Chapter 2 | Pages 50–51 | Confirmed |
| **Huỳnh Hồng Ánh Tuyết** | Responsible for logical architecture, ACID, and MVCC; supported consistent-read testing and observations of concurrent database behavior. | Chapter 1 | Page 51 | Confirmed |

---

## 2. Test-Case Contribution Matrix

The experimental framework consists of four core test cases documented in Chapter 5.

| Test Case | Member | Documented Role & Tasks | Status | Source |
| :--- | :--- | :--- | :--- | :--- |
| **T01 — Tablespace & Quota** | Nguyễn Thị Phương Trâm | Responsible for Chapter 2; performed Tablespace creation, Datafile expansion, and storage-allocation verification. | Confirmed | Pages 50–51 |
| **T01 — Tablespace & Quota** | Nguyễn Đức Thuận | Consolidated the T01 experimental procedure; participated directly in execution; collected experimental evidence; presented and analyzed Section 5.1. | Confirmed | Pages 30–33, 50 |
| **T02 — Transaction & Savepoint/Rollback** | Nguyễn Ngọc Tuyết Ngân | Responsible for Chapter 3; built and executed transaction-control scenarios; tested recovery behavior and recorded experimental results. | Confirmed | Page 50 |
| **T02 — Transaction & Savepoint/Rollback** | Nguyễn Đức Thuận | Consolidated the Transaction experimental scenario; participated directly in execution; collected experimental evidence; presented and analyzed Section 5.2. | Confirmed | Pages 33–37, 50 |
| **T03 — Concurrency & Blocking** | Nguyễn Minh Quang | Responsible for Chapter 4; built the concurrency scenario; simulated blocking across multiple sessions; participated in result and screenshot collection. | Confirmed | Page 49 |
| **T03 — Concurrency & Blocking** | Huỳnh Hồng Ánh Tuyết | Supported consistent-read verification and observations of concurrent database behavior. | Confirmed | Page 51 |
| **T03 — Concurrency & Blocking** | Nguyễn Đức Thuận | Consolidated the Lock/Concurrency experimental scenario; participated directly in execution; collected DBeaver evidence from Figures 5.9–5.12; consolidated timing metrics in Table 5.1; presented and analyzed Sections 5.3 and 5.5. | Confirmed | Pages 37–40, 43–44, 50 |
| **T04 — Deadlock Detection** | Nguyễn Minh Quang | Responsible for Chapter 4; built the deadlock simulation scenario; simulated cross-session circular dependency; participated in testing and evidence collection. | Confirmed | Page 49 |
| **T04 — Deadlock Detection** | Nguyễn Đức Thuận | Consolidated the Lock/Deadlock experimental scenario; participated directly in execution; collected ORA-00060 evidence from Figures 5.13–5.14; consolidated experimental results; analyzed Sections 5.4 and 5.5. | Confirmed | Pages 41–44, 50 |
| **Cross-Project Support** | Nguyễn Ngọc Quỳnh Chi | Participated in Oracle 19c testing, performed basic SQL queries, and supported experimental result consolidation. | Confirmed | Pages 49–50 |

---

## 3. Nguyễn Đức Thuận — Detailed Contribution

Nguyễn Đức Thuận's documented contribution centers on experimental synthesis, execution, evidence collection, metrics consolidation, analysis, and technical reporting.

### 3.1 Experimental Scenario Synthesis
- **Status:** Confirmed
- The report assigns Nguyễn Đức Thuận responsibility for:
  > *"Tổng hợp các kịch bản thực nghiệm liên quan đến Tablespace, Transaction và Lock."*
- This establishes responsibility for consolidating the experimental scenarios used in Chapter 5.
- This should be distinguished from original scenario authorship. The report separately assigns specialized scenario construction to other members, particularly Tablespace, Transaction, and Lock/Deadlock work.
- **Source:** Page 50.

### 3.2 Oracle 19c Execution
- **Status:** Confirmed
- The report explicitly states that Nguyễn Đức Thuận:
  > *"Tham gia trực tiếp vào toàn bộ quá trình thực thi trên Oracle 19c..."*
- Therefore, direct participation in the experimental execution is documented.
- **Source:** Page 50.

### 3.3 Evidence Collection
- **Status:** Confirmed
- The documented responsibility includes:
  > *"...thu thập kết quả, hình ảnh minh họa..."*
- This is reflected in Chapter 5 through the experimental screenshots covering Figures 5.1–5.14.
- **Source:** Page 50; Chapter 5, Pages 30–44.

### 3.4 Metrics Consolidation
- **Status:** Confirmed
- The report documents the consolidation of experimental measurements, particularly the execution and blocking metrics summarized in Table 5.1.
- Examples include:
  - `0.006s` execution time for the T03 Session A update.
  - `13s` blocking wait displayed during the T03 experiment.
  - `1m 9s` total execution time for the blocked T03 Session B update.
  - `ORA-00060` observed during the T04 deadlock experiment.
- These values are treated as experimental observations documented in Chapter 5, rather than evidence of independent authorship of the underlying SQL scenarios.
- **Source:** Pages 37–44.

### 3.5 Experimental Analysis
- **Status:** Confirmed
- The report assigns Nguyễn Đức Thuận responsibility for:
  > *"...phân tích đối chiếu với lý thuyết."*
- This role is reflected in the analysis of experimental behavior and the comparison between observed results and Oracle database mechanisms, including the consolidated evaluation in Table 5.1 and Section 5.5.
- **Source:** Pages 43–44, 50.

### 3.6 Chapter 5 Reporting
- **Status:** Confirmed
- Nguyễn Đức Thuận is explicitly assigned:
  > *"Trình bày Chương 5: Triển khai thực nghiệm và đánh giá."*
- Chapter 5 contains the documented experimental procedures, evidence, measurements, and evaluations for T01–T04.
- **Source:** Page 50.

### 3.7 Theoretical Authorship
- **Status:** Not Evidenced
- The contribution table assigns the main theoretical chapters to other members:
  - Chapter 1 → Huỳnh Hồng Ánh Tuyết
  - Chapter 2 → Nguyễn Thị Phương Trâm
  - Chapter 3 → Nguyễn Ngọc Tuyết Ngân
  - Chapter 4 → Nguyễn Minh Quang
- Therefore, this repository does not attribute the theoretical authorship of Chapters 1–4 to Nguyễn Đức Thuận.

### 3.8 Infrastructure / OS Setup
- **Status:** Not Evidenced
- The report does not provide evidence attributing Linux installation, Oracle 19c binary deployment, server provisioning, or database-host configuration to Nguyễn Đức Thuận.
- These activities are therefore excluded from his documented contribution.

---

## 4. Other Members

- **Nguyễn Thị Phương Trâm:** Responsible for Chapter 2, covering Oracle Tablespace management. Her documented experimental contribution is primarily associated with T01, including Tablespace creation, Datafile expansion, and storage-allocation verification. (*Source: Pages 50–51*)
- **Nguyễn Ngọc Tuyết Ngân:** Responsible for Chapter 3, covering Transaction management and data integrity. Her documented experimental contribution is primarily associated with T02, including transaction-control scenarios and verification of recovery mechanisms such as SAVEPOINT and ROLLBACK. (*Source: Page 50*)
- **Nguyễn Minh Quang:** Responsible for Chapter 4, covering Lock mechanisms and concurrency control. His documented experimental contribution is primarily associated with T03 and T04, including construction of concurrency/blocking and deadlock scenarios across multiple sessions. (*Source: Page 49*)
- **Huỳnh Hồng Ánh Tuyết:** Responsible for Chapter 1, covering logical architecture, ACID, and MVCC. She also supported experimental observations involving consistent reads and concurrent database behavior. (*Source: Page 51*)
- **Nguyễn Ngọc Quỳnh Chi:** Responsible for the Introduction and Conclusion, as well as report review and finalization. She also participated in Oracle 19c testing, executed basic queries, and supported experimental result consolidation. (*Source: Pages 49–50*)

---

## 5. Contribution Boundaries

### Confirmed Contributions
The report supports the following contribution boundaries:
- Nguyễn Đức Thuận consolidated the experimental scenarios used in Chapter 5.
- Nguyễn Đức Thuận directly participated in Oracle 19c experimental execution.
- Nguyễn Đức Thuận collected experimental results and illustrative evidence.
- Nguyễn Đức Thuận consolidated experimental measurements documented in Chapter 5.
- Nguyễn Đức Thuận performed analysis comparing experimental observations with theoretical mechanisms.
- Nguyễn Đức Thuận presented Chapter 5: Experimental Deployment and Evaluation.
- Nguyễn Thị Phương Trâm was responsible for Tablespace-related theory and experiments.
- Nguyễn Ngọc Tuyết Ngân was responsible for Transaction-related theory and experiments.
- Nguyễn Minh Quang was responsible for Lock/Concurrency/Deadlock theory and scenario construction.
- Nguyễn Ngọc Quỳnh Chi and Huỳnh Hồng Ánh Tuyết provided the documented supporting contributions described in the report.

### Not Confirmed
The report does not establish:
- Which individual physically typed each SQL statement during every collaborative session.
- Which individual initially provisioned the Linux operating system.
- Which individual installed the Oracle 19c binaries.
- Which individual independently authored each SQL statement before the experimental procedures were consolidated.
- Which individual performed every individual execution step when multiple members participated in the same experiment.

### Claims That Must Not Be Made
The repository must not claim that:
- Nguyễn Đức Thuận independently authored all SQL code.
- Nguyễn Đức Thuận independently designed every T01–T04 scenario from scratch.
- Nguyễn Đức Thuận installed, provisioned, or administered the Oracle 19c/Linux environment.
- Nguyễn Đức Thuận authored the theoretical content of Chapters 1–4.
- Nguyễn Đức Thuận single-handedly performed the entire laboratory work.
- Any individual member has exclusive ownership of all experimental SQL.
- The project implemented network architecture, firewall policies, IAM/RBAC, or infrastructure security controls that are not documented in the report.

---

## 6. Contribution Model

The documented workflow separates theoretical ownership, scenario-specific construction, experimental integration, execution, analysis, and reporting:

```text
THEORETICAL DOMAIN LEADS
│
├── Chapter 1 — Architecture, ACID & MVCC
│   └── Huỳnh Hồng Ánh Tuyết
│
├── Chapter 2 — Tablespace & Quota
│   └── Nguyễn Thị Phương Trâm
│
├── Chapter 3 — Transactions, Undo/Redo & Savepoints
│   └── Nguyễn Ngọc Tuyết Ngân
│
└── Chapter 4 — Locking, Concurrency & Deadlock
    └── Nguyễn Minh Quang
                    │
                    ▼
SCENARIO & EXPERIMENTAL WORK
│
├── T01 — Tablespace & Quota
│   └── Module lead + Nguyễn Đức Thuận
│
├── T02 — Transaction & Savepoint/Rollback
│   └── Module lead + Nguyễn Đức Thuận
│
├── T03 — Concurrency & Blocking
│   └── Module lead + Nguyễn Đức Thuận
│
└── T04 — Deadlock Detection
    └── Module lead + Nguyễn Đức Thuận
                    │
                    ▼
EXPERIMENTAL INTEGRATION
│
├── Scenario synthesis
│   └── Nguyễn Đức Thuận
│
├── Oracle 19c execution
│   └── Team members according to documented roles
│
├── Evidence & metrics consolidation
│   └── Nguyễn Đức Thuận
│
└── Supporting testing
    ├── Nguyễn Ngọc Quỳnh Chi
    └── Huỳnh Hồng Ánh Tuyết
                    │
                    ▼
EVALUATION & DOCUMENTATION
│
├── Experimental analysis
│   └── Nguyễn Đức Thuận
│
├── Chapter 5
│   └── Nguyễn Đức Thuận
│
└── Final review & report consistency
    └── Nguyễn Ngọc Quỳnh Chi
```

*This contribution model distinguishes between specialized theoretical/scenario ownership and cross-module experimental synthesis and reporting.*

---

## 7. Evidence Sources

| Claim / Responsibility | Report Section | Page(s) | Evidence Strength |
| :--- | :--- | :--- | :--- |
| **Module-specific member assignments** | Appendix — Group Work Allocation | 49–51 | High |
| **Tablespace creation, Datafile expansion, and quota verification** | Section 5.1, Figures 5.1–5.4 | 30–33 | High |
| **Transaction, Savepoint, and Rollback experiments** | Section 5.2, Figures 5.5–5.8 | 33–37 | High |
| **Row-level locking and blocking behavior** | Section 5.3, Figures 5.9–5.12 | 37–40 | High |
| **T03 execution and blocking metrics** | Table 5.1 | 43–44 | High |
| **Deadlock detection and ORA-00060** | Section 5.4, Figures 5.13–5.14 | 41–42 | High |
| **Consolidated experimental evaluation** | Section 5.5, Table 5.1 | 43–44 | High |
| **Nguyễn Đức Thuận's Chapter 5 and experimental responsibilities** | Appendix — Group Work Allocation | 50 | High |

---

## Contribution Scope Summary

The project follows a collaborative experimental model rather than assigning all implementation ownership to a single contributor.

Nguyễn Đức Thuận's documented role is best characterized as:
> **Experimental Integration & Evaluation — Oracle 19c**

with responsibility spanning:
$$	ext{Scenario Synthesis} \longrightarrow 	ext{Experimental Execution} \longrightarrow 	ext{Evidence Collection} \longrightarrow 	ext{Metrics Consolidation} \longrightarrow 	ext{Technical Analysis} \longrightarrow 	ext{Chapter 5 Reporting}$$

while the specialized theoretical and scenario-design responsibilities remain attributed to their respective module leads according to the documented group allocation.
