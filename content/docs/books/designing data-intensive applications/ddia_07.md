---
weight: 7
title: "07: Transactions"
bookHidden: false
---

# Transactions
---

*Some authors have claimed that general two-phase commit is too expensive to support, because of the performance or availability problems that it brings. We believe it is better to have application programmers deal with performance problems due to overuse of transactions as bottlenecks arise, rather than always coding around the lack of transactions.*

~ `James Corbett et al., Spanner: Google's Globally-Distributed Database (2012)`

---
## Overview

Real-world reads and writes are complex. Things can go wrong half-way through for a lot of reasons (DB hardware/software failure, application failure, network interrupt, concurrency issues, race conditions, etc.). **A transaction** is a way for an application to group a set of reads/writes into a logical unit. Either the whole unit succeeds (`commit`), or it fails (`abort` and `rollback`) and the application can safely retry it. Transactions are not a law of nature: they were created to simplify the programming model, so that the application does not have to deal with partial failures and concurrency issues itself.


> [!NOTE]
> **History of Transactions**
> - The concept of transactions in databases was introduced with the creation of **IBM System R**, the first SQL database, in 1975. Many databases follow similar principles.
> - In the late 2000s, nonrelational (NoSQL) databases gained popularity, focusing on features like replication and partitioning. However, transactions were often neglected or redefined with much weaker guarantees.
> - The term **ACID** was coined in 1983 by Theo Härder and Andreas Reuter to establish precise terminology for fault-tolerance mechanisms in databases.

---
## ACID and BASE

> [!CAUTION]
> **To remember**
>
> `ACID` or `BASE` compliant does not provide clear and standardized guarantees. It is important to carefully understand the specific properties and trade-offs offered by a system before relying on these terms as indicators of its behavior.

**ACID** (`Atomicity`, `Consistency`, `Isolation`, `Durability`) and **BASE** (`Basically Available`, `Soft state`, `Eventual consistency`) are the two common sets of properties for database transactions.

* **Atomicity**: Enables aborting a transaction on error, discarding all writes from that transaction. It's not about `concurrency` but `abortability`.
* **Consistency**: Application-specific invariants about the data must always hold true, for example that credits and debits across all accounts are balanced. It is a property of the application rather than of the database: the database can check some constraints, such as foreign keys, but the application defines what valid data is.
* **Isolation**: Concurrently executing transactions are isolated from each other. The textbook definition is `serializability`: the result is the same as if the transactions had run one after another. In practice, many databases use weaker isolation levels.
* **Durability**: Data that a transaction has committed will not be lost, even after a hardware fault or database crash. A single-node database writes the data to nonvolatile storage, usually with a write-ahead log, and a replicated database copies it to some number of nodes. Perfect durability does not exist: disks fail, SSDs can corrupt data, and correlated faults can destroy all replicas.


{{% columns %}}
- `BASE` is a vague term for systems that do not meet the ACID criteria. About the only sensible definition is "not ACID": it says very little about what such a system guarantees.

- `ACID` implementations also differ between databases, and the meaning of isolation in particular is ambiguous. The philosophy of ACID databases is to abandon a transaction entirely rather than leave it half-finished when atomicity, isolation or durability would be violated.
{{% /columns %}}

In relational databases, a transaction is typically defined as the set of operations executed between a `BEGIN TRANSACTION` and `COMMIT` statement. This grouping ensures that all operations within the transaction are treated atomically, consistently, and isolated from concurrent operations. **However, many nonrelational databases do not provide a built-in way to explicitly group operations into transactions.**

---
## Single-Object and Multi-Object Operations

Atomicity and isolation apply to single objects as well as to groups of objects:

- **Single-object writes**: Storage engines almost universally provide atomicity (via a log for crash recovery) and isolation (via a lock on each object) for a single object on one node. Some also offer atomic operations such as increment and compare-and-set. These are useful but are not transactions in the usual sense.
- **Multi-object transactions**: Needed when several pieces of data must be kept in sync, for example a foreign key reference between two tables, a denormalized document that must be updated together with its source, or a secondary index that must stay consistent with the data. Many distributed datastores abandoned multi-object transactions because they are hard to implement across partitions.

> [!NOTE]
> **Handling errors and aborts**
>
> Retrying an aborted transaction is a simple and effective error-handling mechanism, but it is not perfect:
>
> - If the transaction succeeded but the network failed while the server acknowledged the commit, retrying performs it twice, unless the application has its own deduplication.
> - If the error is caused by overload, retrying makes the problem worse. Limit the number of retries and use exponential backoff.
> - Retrying only makes sense after transient errors, such as a deadlock or a network interruption, not after a permanent error such as a constraint violation.
> - If the transaction has side effects outside the database, such as sending an email, the side effects may happen even if the transaction aborts.

---
## Race Conditions

Concurrency control in databases introduces various kinds of race conditions:

- **Dirty read**: Transaction B reads Transaction A's uncommitted writes.
- **Dirty writes**: Transaction B overwrites Transaction A's uncommitted writes.
- **Read skew (nonrepeatable reads)**: A transaction sees different parts of the database at different points in time, for example one account balance before and another after a concurrent transfer.
- **Lost updates**: Two transactions concurrently perform a read-modify-write cycle on the same value, and one overwrites the other's write without incorporating its change, for example two concurrent counter increments.
- **Write skew**: A transaction reads something, makes a decision based on that value and writes the decision, but by the time the write commits, the premise of the decision is no longer true. The two transactions may update different objects.
- **Phantom reads**: A write in one transaction changes the result of a search query in another transaction. Write skew is often caused by a phantom: the first transaction checks that no rows match a condition, and a concurrent transaction inserts a matching row.

Implementing these fault-tolerant mechanisms is complex and may affect system performance. Despite the challenges of concurrency control, databases strive to provide `transaction isolation` to hide these issues. Nevertheless, achieving serializable isolation often comes with a performance cost, leading many systems to opt for weaker isolation levels that can handle some, but not all, concurrency issues.

---

### Preventing Lost Updates

Lost updates can occur during concurrent read-modify-write cycles. Several strategies can prevent this:

- **Atomic Write Operations**: Databases like MongoDB and Redis offer atomic operations to perform local modifications, eliminating the need for read-modify-write cycles.
- **Explicit Locking**: The application explicitly locks the objects it plans to update, for example with `SELECT ... FOR UPDATE`, which takes an exclusive lock on the returned rows.
- **Automatic Detection of Lost Updates**: Transactions execute in parallel. If the transaction manager detects a lost update, it aborts the transaction and forces it to retry the read-modify-write cycle. PostgreSQL's repeatable read, Oracle's serializable and SQL Server's snapshot isolation levels do this, while MySQL/InnoDB's repeatable read does not.
- **Compare-and-set**: Updates are made only if the current value matches the previously read value.
- **Conflict Resolution and Replication**: In multi-leader or leaderless replication systems, locks and compare-and-set do not apply, because there is no single up-to-date copy. Concurrent writes create multiple versions (siblings) of a value, which application code or special data structures resolve and merge later. Commutative atomic operations, such as incrementing a counter, work well in this setting. Last write wins (LWW) is prone to lost updates.

---

### Write Skew and Phantoms

The book's example is a hospital on-call system. At least one doctor must be on call. Two doctors, Alice and Bob, both feel unwell and request leave at the same time. Each transaction checks that at least two doctors are on call, sees that the condition holds, and removes its own doctor. Both transactions commit, and nobody is on call.

Write skew is a generalization of the lost update problem: two transactions read the same objects and then update some of them, possibly different ones. Other examples include a meeting room booking system that must prevent double bookings, a multiplayer game where two players move to the same position, claiming a username, and preventing double-spending of money.

Options for preventing write skew are limited:

- Atomic single-object operations do not help, because several objects are involved.
- Automatic lost-update detection in snapshot isolation does not catch it.
- Most databases cannot express constraints that span several objects, although triggers or materialized views can sometimes help.
- If serializable isolation is not available, the next best option is to explicitly lock the rows the transaction depends on.

> [!NOTE]
> **Materializing conflicts**
>
> When the problem is a phantom, there is no existing row to lock. One workaround is to create the rows artificially, for example a table of all possible room and time slot combinations, which transactions can lock with `SELECT ... FOR UPDATE`. This is error-prone and leaks a concurrency control mechanism into the data model, so serializable isolation is preferable.

---

## Isolation Levels

Concurrency issues only arise when one transaction reads data that is concurrently modified by another transaction, or when two transactions simultaneously modify the same data. Isolation levels define how these situations are handled.


| | Read Committed | Snapshot Isolation | Serializable |
| --- | --- | --- | --- |
| **Race conditions prevented** | Dirty read, Dirty Write | All of Read Committed, plus: Read skew. Lost updates only in implementations that detect them automatically | All of the above, plus: Lost updates, Write skew, Phantoms |
| **Implementation** | Row-level locks for writes, serving old values for reads when writes are in progress | Row-level locks for writes, Multi-Version Concurrency Control (MVCC) for reads | Actual serial execution (stored procedures, active dataset in memory), Two-phase locking ("2PL"), Serializable Snapshot Isolation ("SSI") |

---

### Read Committed

Read committed is a guarantee in database systems that:

1. **Prevents dirty reads**: You will only see data that has been committed when reading from the database. Writes by a transaction become visible to others only when that transaction commits.
2. **Prevents dirty writes**: You will only overwrite data that has been committed when writing to the database. This is usually prevented by delaying the second write until the first write's transaction has committed or aborted.

Most databases prevent dirty writes with row-level locks that hold until the transaction commits or aborts. For each object written, the database remembers both the old committed value and the new value set by the write lock-holding transaction. During the transaction, any other transactions reading the object get the old value.

---
### Snapshot Isolation and Repeatable Read

Read committed still allows read skew. Long-running reads such as backups and analytic queries cannot tolerate seeing the database in an inconsistent state.

- **Nonrepeatable read**: Also known as _read skew_, occurs when a transaction sees one part of the database before and another part after a concurrent transaction committed.
- **Snapshot isolation**: Each transaction reads from a consistent snapshot of the database: it sees all the data that was committed at the start of the transaction, and nothing committed later. It is implemented with write locks to prevent dirty writes and `multi-version concurrency control (MVCC)`, which keeps several committed versions of an object side by side. The key principle is that readers never block writers, and writers never block readers.
- **Repeatable read**: The SQL standard defines this level differently, and the naming is confusing. PostgreSQL and MySQL call their snapshot isolation level "repeatable read", Oracle calls it "serializable", and the guarantees actually provided differ between databases.

In both, snapshot isolation and repeatable read, handling indexes in a multi-version database can be challenging. One approach is to let the index point to all versions of an object and filter out non-visible object versions during an index query.

---
### Serializability

> [!WARNING]
> **Serializability**, the strongest isolation level, ensures that the outcome of executing transactions in parallel is the same as if they were executed one at a time. Techniques for achieving this include `executing transactions in serial order`, `two-phase locking`, and `serializable snapshot isolation`.

Weak isolation levels protect against some of those anomalies but leave you, the application developer, to handle others manually (e.g., using `explicit locking`). Only serializable isolation protects against all of these issues.

{{< tabs "Serializability" >}}
{{% tab "Actual Serial Execution" %}}
The simplest way to avoid concurrency problems is to remove concurrency: execute one transaction at a time, in serial order, on a single thread. `VoltDB`/`H-Store`, `Redis` and `Datomic` use this approach. It became feasible around 2007 because RAM became cheap enough to keep the whole active dataset in memory, and because OLTP transactions are usually short.

Constraints of serial execution:

- Every transaction must be small and fast, because one slow transaction stalls all others.
- Interactive multi-statement transactions would spend most of their time waiting for the network, so the whole transaction code must be submitted in advance as a `stored procedure`.
- The active dataset must fit in memory.
- Write throughput is limited to a single CPU core, unless the data can be partitioned so that each transaction touches only one partition. Cross-partition transactions are much slower.
{{% /tab %}}
{{% tab "Two-Phase Locking (2PL)" %}}
For around 30 years, `two-phase locking` was the only widely used algorithm for serializability. Several transactions may read the same object concurrently, but as soon as anyone wants to write it, exclusive access is required: writers block readers and readers block writers. Locks are held until the transaction commits or aborts.

- The lock has a `shared mode` for readers and an `exclusive mode` for writers.
- Deadlocks are detected automatically, and one of the transactions is aborted and must be retried.
- To prevent phantoms, 2PL needs `predicate locks` on all objects matching a search condition, including objects that do not exist yet. Most databases approximate them with `index-range locks`.

The big downside is performance: throughput is much lower and latency at high percentiles is very unstable, because a single slow transaction can make many others wait.
{{% /tab %}}
{{% tab "Serializable Snapshot Isolation (SSI)" %}}
`SSI`, first described in 2008, provides full serializability with only a small performance penalty compared to snapshot isolation. It is used in PostgreSQL (since 9.1) and FoundationDB.

2PL is a `pessimistic` concurrency control mechanism: it waits until a situation is safe. Serial execution is pessimistic to the extreme. SSI is `optimistic`: transactions continue without blocking, and at commit time the database checks whether isolation was violated. If it was, the transaction is aborted and retried.

SSI builds on snapshot isolation and adds an algorithm to detect serialization conflicts among writes:

- **Detecting stale MVCC reads**: the database tracks when a transaction ignores another transaction's uncommitted write, and aborts the reading transaction at commit time if that write has committed in the meantime.
- **Detecting writes that affect prior reads**: the database records which transactions have read which data, and notifies them when a later write affects it.

Readers do not block writers, so query latency is predictable, and read-only queries can run on a consistent snapshot without locks. Performance depends on the abort rate, so SSI works best when read-write transactions are short.
{{% /tab %}}
{{< /tabs >}}
