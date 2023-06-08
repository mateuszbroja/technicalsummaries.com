---
weight: 7
title: "07: Transactions"
bookHidden: false
---

# Transactions
---

*Some authors have claimed that general two-phase commit is too expensive to support, because of the performance or availability problems that it brings. We believe it is better to have application programmers deal with performance problems due to overuse of transactions as bottlenecks arise, rather than always coding around the lack of transactions.*

~ `James Corbett et al., Spanner: Google’s Globally-Distributed Database (2012)`

---
## Overview

Real-world reads and writes are complex. Things can go wrong half-way through for a lot of reasons (DB hardware/software failure, application failure, network interrupt, concurrency issues, race conditions, etc.).

{{< hint warning >}}
**A transaction** is a way for an application to group a set of reads/writes into a logical unit. Either the whole unit succeeds (`commit`), or fails and can be retried (`abort` + `rollback`.
{{< /hint >}}

{{< hint info >}}
**History of Transactions**
- The concept of transactions in databases was introduced with the creation of **IBM System R**, the first SQL database, in 1975. Many databases follow similar principles.
- In the late 2000s, nonrelational (NoSQL) databases gained popularity, focusing on features like replication and partitioning. However, transactions were often neglected or redefined with much weaker guarantees.
- The term **ACID** was coined in 1983 by Theo Härder and Andreas Reuter to establish precise terminology for fault-tolerance mechanisms in databases.
{{< /hint >}}

---
## ACID and BASE

{{< hint warning >}}
`ACID` or `BASE` compliant does not provide clear and standardized guarantees. It is important to carefully understand the specific properties and trade-offs offered by a system before relying on these terms as indicators of its behavior.
{{< /hint >}}

**ACID** (`Atomicity`, `Consistency`, `Isolation`, `Durability`) and **BASE** (`Basically Available`, `Soft state`, `Eventual consistency`) are the two common sets of properties for database transactions. 

* **Atomicity**: Enables aborting a transaction on error, discarding all writes from that transaction. It's not about `concurrency` but `abortability`.
* **Consistency**: Data-model-specific invariants must always hold true. **It's a property of the application not really of the database**.
* **Isolation**: Ensures that concurrently executing transactions are isolated from each other, providing a result as if they had run serially.
* **Durability**: Guarantees that committed data will not be lost, even if there's a hardware fault or database crash. This is achieved through writing to nonvolatile storage or replication to some number of nodes. 


{{< columns >}}
`BASE` provides weaker guarantees and is often offered by systems that are not ACID-compliant. Implementations for atomicity and isolation can be via a log for crash recovery and a lock on each object, respectively.

<--->

`ACID` compliance, despite being subjected to potential compromises, is crucial for maintaining database integrity, especially when handling multi-object operations. The philosophy behind ACID databases is to abandon a transaction entirely rather than leaving it half-finished in case of possible violations of atomicity, isolation, or durability.
{{< /columns >}}

In relational databases, a transaction is typically defined as the set of operations executed between a `BEGIN TRANSACTION` and `COMMIT` statement. This grouping ensures that all operations within the transaction are treated atomically, consistently, and isolated from concurrent operations. **However, many nonrelational databases do not provide a built-in way to explicitly group operations into transactions.**

---
## Weak Isolation Levels

Concurrency issues only arise when one transaction reads data that is concurrently modified by another transaction, or when two transactions simultaneously modify the same data. Isolation levels define how these situations are handled.

|                           | Read Committed                                                                       | Snapshot Isolation                                                             | Serializable                                                                                                                                                                      |
| ------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Also known as             |                                                                                      | Repeatable read (PostgreSQL, MySQL), Serializable (Oracle)                     |                                                                                                                                                                                   |
| Race conditions prevented | Dirty read, Dirty Write                                                              | All of Read Committed, plus: Read skew, Lost updates                           | All of Snapshot Isolation, plus: Write skew                                                                                                                                       |
| Implementation            | Row-level locks for writes, serving old values for reads when writes are in progress | Row-level locks for writes, Multi-Version Concurrency Control (MVCC) for reads | Transactions executed in serial order (often using stored procedures, only possible when data fits in memory), Two-phase locking ("2PL"), Serializable Snapshot Isolation ("SSI") |


---
## Kinds of Race Conditions and Isolation Levels

Concurrency control in databases introduces various kinds of race conditions, which can be mitigated using different isolation levels:

- **Dirty read**: Transaction B reads Transaction A's uncommitted writes.
- **Dirty writes**: Transaction B overwrites Transaction A's uncommitted writes.
- **Read skew (nonrepeatable reads)**: A single transaction reads different data at different points in time.
- **Lost updates**: Transaction B overwrites Transaction A's committed writes. This happens due to concurrent read-update-write cycles and can be prevented by row-level read locks (`SELECT FOR UPDATE`).
- **Write skew**: Transaction A's write operation is based on a premise that is no longer true at the time of writing.
- **Phantom reads**: Transaction A's write operation is based on a search condition that is no longer true at the time of writing.

Implementing these fault-tolerant mechanisms is complex and may affect system performance. Despite the challenges of concurrency control, databases strive to provide `transaction isolation` to hide these issues. Nevertheless, achieving serializable isolation often comes with a performance cost, leading many systems to opt for weaker isolation levels that can handle some, but not all, concurrency issues.

---
### Read Committed

Read committed is a guarantee in database systems that:

1. **Prevents dirty reads**: You will only see data that has been committed when reading from the database. Writes by a transaction become visible to others only when that transaction commits.
2. **Prevents dirty writes**: You will only overwrite data that has been committed when writing to the database. This is usually prevented by delaying the second write until the first write's transaction has committed or aborted.

Most databases prevent dirty writes with row-level locks that hold until the transaction commits or aborts. For each object written, the database remembers both the old committed value and the new value set by the write lock-holding transaction. During the transaction, any other transactions reading the object get the old value.

---
### Snapshot Isolation and Repeatable Read

Snapshot Isolation and Repeatable Read are mechanisms in database systems to manage temporal inconsistencies due to concurrent reads and writes:

- **Nonrepeatable read**: Also known as _read skew_, occurs when you read inconsistent results from the database while committing a change.
- **Snapshot isolation**: Each transaction reads from a consistent snapshot of the database, mitigating the issues of nonrepeatable reads. It's implemented using write locks to prevent dirty writes and multi-version concurrency control (MVCC) to maintain different committed versions of an object.
- **Repeatable read**: This is a variant of snapshot isolation where the same snapshot is used for an entire transaction. 

In both, snapshot isolation and repeatable read, handling indexes in a multi-version database can be challenging. One approach is to let the index point to all versions of an object and filter out non-visible object versions during an index query.

---
### Preventing Lost Updates

Lost updates can occur during concurrent read-modify-write cycles. Several strategies can prevent this:

- **Atomic Write Operations**: Databases like MongoDB and Redis offer atomic operations to perform local modifications, eliminating the need for read-modify-write cycles.
- **Explicit Locking**: Applications can explicitly lock objects they plan to update.
- **Automatic Detection of Lost Updates**: Transactions execute in parallel. If a lost update is detected, the transaction is aborted, forcing a retry of the read-modify-write cycle.
- **Compare-and-set**: Updates are made only if the current value matches the previously read value.
- **Conflict Resolution and Replication**: In multi-leader or leaderless replication systems, concurrent writes create multiple versions of a value. These versions are later resolved and merged.

---
### Write Skew and Phantoms

Write skew happens when two transactions read the same objects, then update some of those objects, leading to inconsistency (like both doctors going off call). Preventing write skew requires true serializable isolation or explicit locking.

---
### Serializability

Serializability, the strongest isolation level, ensures that the outcome of executing transactions in parallel is the same as if they were executed one at a time. Techniques for achieving this include executing transactions in serial order, two-phase locking, and serializable snapshot isolation.

---
### Actual Serial Execution

Actual serial execution, adopted by `VoltDB`/`H-Store`, `Redis`, and `Datomic`, is the simplest way to avoid concurrency problems by executing one transaction at a time. However, to improve efficiency, these systems require the entire transaction code to be submitted as a stored procedure.

---
### Two-Phase Locking (2PL)

Two-phase locking allows concurrent read of an object but requires exclusive access for write operations. This method protects against race conditions but has limitations due to possible deadlocks and slow transaction throughput at high percentiles.

---
### Serializable Snapshot Isolation (SSI)

`SSI` ensures full serializability with better performance than snapshot isolation. It uses optimistic concurrency control, meaning transactions continue unless a conflict occurs. It's more efficient than pessimistic concurrency control methods, provided transaction contention is low. Compared to other methods, `SSI` avoids blocking transactions and can utilize multiple CPU cores. However, its performance depends on the abort rate and it requires short read-write transactions.