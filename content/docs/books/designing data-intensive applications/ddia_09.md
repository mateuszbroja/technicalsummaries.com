---
weight: 9
title: "09: Consistency and Consensus"
bookHidden: false
---

# Consistency and Consensus
---

*The simplest way of handling faults is to simply let the entire service fail. We need to find ways of tolerating faults.*

---
## Overview

Fault-tolerant systems are best built by using general-purpose **abstractions** with robust guarantees, which can then be relied upon by applications.

> [!NOTE]
> An excellent example of this approach is the **use of transactions**. Transactions allow applications to operate as if there are:
> - no crashes (`atomicity`),
> - no concurrent database access (`isolation`),
> - completely reliable storage devices (`durability`).
>
> Although those real-world issues do occur, application doesn't need to worry about them.

---
## Consistency Guarantees

### Eventual Consistency (Weak Guarantee)

Most replicated databases ensure `eventual consistency`, implying that if no new writes are made to the database, all read requests will eventually return the same value, i.e., all replicas will `converge` to the same state. However, this guarantee is weak as it does not specify when the `convergence` will occur, and reads may return inconsistent results till that time.

---
### Stronger Guarantees

Stronger consistency models exist but often trade-off performance or fault-tolerance. One such model is `linearizability`, offering one of the strongest consistency guarantees.

---
### Consistency models

- `Linearizability`: a _total order_ of operations. The system behaves as if there is only a single copy of the data, so any two operations can be compared.
- `Causality`: two events are ordered if they are causally related. Causality defines _a partial order_, not a total one: two concurrent events are incomparable.

`Linearizability` is not the only way of preserving `causality`. **Causal consistency is the strongest possible consistency model that does not slow down due to network delays, and remains available in the face of network failures.**

---
## Linearizability

> [!WARNING]
> **Linearizability** (also known as `atomic consistency`, `strong consistency`, `immediate consistency`, or `external consistency`) is a consistency model that makes a system appear as if there were only one copy of the data, and all operations on it are atomic. This model provides the illusion of a single-node database to clients, maintaining the most recent, up-to-date value.

In the book, the database is modeled as a set of `registers` (keys), and clients perform these operations:

```text
read(x) => v
  Read the value of register x. The database returns v.

write(x, v) => r
  Set register x to value v. The response r is ok or error.

cas(x, v_old, v_new) => r
  Atomic compare-and-set: if the current value of x equals v_old,
  set it to v_new; otherwise leave x unchanged and return an error.
```

The key property of `linearizability` is a `recency guarantee`: as soon as one read has returned a new value, all subsequent reads, on the same or another client, must also return the new value, until it is overwritten again. **The cost is availability and performance: if a replica is cut off from the leader or from a quorum by a network interruption, it cannot serve linearizable reads or writes, so clients connected to it must wait or get an error.**

---
### Linearizability vs Serializability

**Serializability** and **Linearizability** are often confused due to their similar implication of sequential order, but they represent different guarantees:

{{% columns %}}
- **Serializability** is an isolation property of transactions, where every transaction may read and write multiple objects. It ensures transactions behave as if they had been executed in some serial order (one after another), but the actual order of transactions can vary.

- **Linearizability** provides a recency guarantee on individual object reads and writes. It doesn't group operations into transactions, hence doesn't prevent issues like `write skew` unless additional measures are taken.
{{% /columns %}}

A database can offer both serializability and linearizability, known as `strict serializability`.

---
### Applications of Linearizability

- **Locking and leader election**: Coordination services like Apache ZooKeeper and etcd use consensus algorithms to implement linearizable operations in a fault-tolerant way.

- **Constraints and uniqueness guarantees**: For constraints like unique usernames or email addresses, linearizability is needed to ensure that if two entities try to create a user or file with the same name concurrently, one of them will encounter an error. The same applies to an account balance that must never go negative or a seat that must not be sold twice.

- **Cross-channel timing dependencies**: If a system has an additional communication channel, linearizability prevents race conditions between channels. In the book's example, a web server stores an uploaded photo and then sends a message through a queue to a resizer. If the file storage is not linearizable, the resizer may read an old version of the photo or none at all.

Linearizability ensures causal order, but unlike causal consistency, it doesn't allow concurrent operations.

---
### Implementing Linearizability and the Cost

While a single data copy is the simplest way to implement linearizability, it's not fault-tolerant. Different replication methods have varying potential for linearizability:

- `Single-leader replication`: potentially linearizable, if reads go to the leader or to synchronously updated followers. A node that wrongly believes it is the leader, or asynchronous failover, can violate it.
- `Consensus algorithms`: linearizable. They include measures to prevent split brain and stale replicas, which is how ZooKeeper and etcd work.
- `Multi-leader replication`: not linearizable, because several nodes process writes concurrently and replicate them asynchronously.
- `Leaderless replication`: probably not linearizable. Even strict quorums (`w + r > n`) can have race conditions under variable network delays, and last write wins based on time-of-day clocks is almost certainly not linearizable.

In case of network interruptions between datacenters, multi-leader replication allows each data center to operate normally, whereas single-leader replication makes the application unavailable if it requires linearizable reads and writes.

Applications not requiring linearizability can tolerate network problems better as they can process requests independently, even when disconnected from other replicas, enhancing availability.

> [!CAUTION]
> **Linearizability**, though useful, is not commonly implemented in systems and distributed databases because of its performance costs. Many choose to prioritize performance over this type of consistency guarantee, which isn't solely about fault tolerance.
>
> Even the RAM of a modern multi-core CPU is not linearizable without memory barriers, because each core has its own cache. Linearizability is slow all the time, not only during network faults. Attiya and Welch proved that the response time of linearizable reads and writes is at least proportional to the uncertainty of delays in the network, so there is no faster algorithm. Weaker consistency models can be much faster.

---
### The unhelpful CAP Theorem

> [!WARNING]
> **CAP theorem** is often misleadingly presented as `Consistency, Availability, Partition tolerance: pick 2 out of 3`. Network partitions are inevitable, so they aren't something you can choose to avoid. Instead, a more accurate phrasing might be `Either Consistent or Available when Partitioned`.

`CAP theorem` has a narrow scope. It only considers one consistency model (`linearizability`) and one kind of fault (`network partitions`). It doesn't take into account network delays, dead nodes, or other trade-offs.

CAP was influential because it encouraged engineers to explore a wider range of designs, but it is of mostly historical interest today and offers little practical value for designing systems.

---
## Ordering Guarantees

**Ordering** keeps coming up throughout the book:

1. `Single-leader replication` uses the leader to determine the order of writes in the replication log.
2. `Serializability` makes transactions behave as if they were executed in some sequential order.
3. `Timestamps` and `clocks` are attempts to decide which of two writes happened later.

One reason ordering matters so much is that it helps preserve `causality`. Examples of causality in earlier chapters:

- In `consistent prefix reads`, an answer must not appear before its question.
- In `snapshot isolation`, a consistent snapshot means consistent with causality: if the snapshot contains an answer, it must also contain the question.
- In the `write skew` example of the on-call doctors, the decision to go off call depends on the observation of who else is on call.

---
### Ordering and Causality

A system that obeys the ordering imposed by causality is `causally consistent`. Linearizability implies causality: any linearizable system preserves causality correctly. Many systems that only need causality, however, do not need the cost of linearizability. To maintain causality, a database must know which version of the data a transaction read, so that it can track causal dependencies across the whole database, similar to the version vectors used for detecting concurrent writes.

---
### Sequence Number Ordering

Tracking all causal dependencies explicitly can be impractical. A better way is to use `sequence numbers` or `timestamps` from a `logical clock`, an algorithm that generates a sequence of numbers to identify operations, typically using counters that increment for every operation.

1. Sequence numbers are compact (a few bytes) and provide a total order: every operation has a unique sequence number, and any two can be compared.
2. They can be generated consistently with causality: if operation A causally happened before B, A gets a lower number than B.
3. In a single-leader database, the leader increments a counter for each operation in the replication log.

Without a single leader, simple methods are not consistent with causality: per-node counters (for example odd and even numbers), physical timestamps and preallocated blocks of sequence numbers all produce numbers whose order can contradict causality.

> [!NOTE]
> **Lamport timestamps**
>
> A `Lamport timestamp` is a pair `(counter, node ID)`. Every node keeps a counter of the operations it has processed. Every node and every client tracks the maximum counter value it has seen so far and includes it in every request. When a node receives a request or response with a maximum counter value greater than its own, it immediately increases its counter to that maximum. Timestamps are compared by counter first and by node ID when the counters are equal. This gives a total order that is consistent with causality.

Lamport timestamps are not sufficient for everything. To enforce a uniqueness constraint such as a unique username, a node must know that no other node is concurrently creating the same username with a lower timestamp. A total order of operations only emerges after all operations have been collected, so the node would have to check with every other node, which fails as soon as one node is unreachable. The node needs to know when the order is finalized.

---
### Total Order Broadcast

> [!WARNING]
> **Total order broadcast** (also called `atomic broadcast`) is a protocol for exchanging messages between nodes. It requires two safety properties to hold, even if nodes or the network are faulty:
>
> 1. `Reliable delivery`: no messages are lost. If a message is delivered to one node, it is delivered to all nodes.
> 2. `Totally ordered delivery`: messages are delivered to every node in the same order.

Consensus services such as `ZooKeeper` and `etcd` implement total order broadcast. It is exactly what database replication needs: if every replica processes the same writes in the same order, the replicas stay consistent with each other (`state machine replication`). It can also implement serializable transactions and a lock service that provides fencing tokens. The order is fixed at the time the messages are delivered: a node cannot insert a message into an earlier position.

- **Linearizable storage from total order broadcast**: to claim a username, append a message to the log that tentatively claims it, read the log, and wait for your message to be delivered back. If the first claim for that username in the log is yours, commit it; otherwise abort. Because all nodes deliver messages in the same order, they all agree on which claim came first. This makes writes linearizable. Reads can be made linearizable by sequencing them through the log too, or by waiting until the replica has caught up with the latest log position.
- **Total order broadcast from linearizable storage**: a linearizable register with an atomic increment-and-get operation can attach a sequence number to every message, and recipients deliver messages consecutively by sequence number.

> [!CAUTION]
> Linearizable compare-and-set (or increment-and-get) registers and total order broadcast are both equivalent to consensus. Solving one of them solves the others.

---
## Consensus

> [!WARNING]
> **Consensus** in distributed computing appears simple: getting multiple nodes to agree on something. However, it's not easy to solve and has led to many broken systems.

Several scenarios demand consensus among nodes:

{{< tabs "consensus" >}}
{{% tab "Leader election" %}}

**Leader election**: In a database with single-leader replication, all nodes must agree on which node is the leader. Without consensus, a network fault can lead to `split brain`, where two nodes both believe they are the leader, which often causes data loss.

{{% /tab %}}
{{% tab "Atomic commit" %}}

**Atomic commit**: In a database that supports transactions spanning several nodes or partitions, a transaction may fail on some nodes and succeed on others. To keep the transaction atomic, all nodes must agree on its outcome: either all of them commit, or all of them abort.

{{% /tab %}}
{{< /tabs >}}

> [!CAUTION]
> **The Impossibility of Consensus**
>
> The `Fischer, Lynch and Paterson (FLP)` result proves that no algorithm can always reach consensus if there is a risk that a node may crash. The proof assumes the `asynchronous system model`, in which an algorithm cannot use any clocks or timeouts. If the algorithm may use timeouts to suspect crashed nodes, or random numbers, consensus becomes solvable, and distributed systems usually achieve it in practice.

---
### Atomic Commit and Two-Phase Commit (2PC)

On a single node, atomic commit is implemented by the storage engine: the transaction is committed at the moment the commit record is durably written to disk. When several nodes are involved, it is not enough to send a commit request to all of them, because some may commit while others fail.

`Two-phase commit (2PC)` achieves atomic transaction commit across several nodes. It uses a `coordinator` (transaction manager), and the database nodes are called `participants`:

1. The application gets a globally unique transaction ID from the coordinator and starts a single-node transaction on each participant with that ID.
2. When the application is ready to commit, the coordinator sends a `prepare` request to every participant.
3. A participant that answers "yes" makes sure it can definitely commit under all circumstances, including after a crash: it writes all transaction data to disk and checks constraints. By voting yes, it gives up the right to abort.
4. The coordinator collects the answers and makes a definitive decision: commit only if all participants voted yes. It writes the decision to its transaction log on disk. This moment is the `commit point`.
5. The coordinator sends the commit or abort request to all participants. If a request fails, the coordinator retries forever until it succeeds.

> [!NOTE]
> 2PC contains two "points of no return": a participant that votes yes promises to commit if asked, and a decision of the coordinator is irrevocable. These promises make the commit atomic. Note that 2PC (atomic commit) has nothing to do with `two-phase locking (2PL)`, which provides serializable isolation.

**Coordinator failure.** If the coordinator crashes after participants voted yes but before they received the decision, the participants are `in doubt` (uncertain). They cannot commit or abort on their own, because that might contradict the decision of the coordinator. They must wait until the coordinator recovers and reads the decision from its log. This is why 2PC is called a `blocking` atomic commit protocol.

`Three-phase commit (3PC)` is nonblocking in theory, but it assumes bounded network delay and response times. In a network with unbounded delays, it cannot guarantee atomicity, so 2PC remains in use despite the coordinator problem.

---
## Distributed Transactions in Practice

**Distributed transactions**, particularly those implemented with `two-phase commit`, have a **controversial reputation**. They are appreciated for providing significant safety guarantees that would be challenging to achieve otherwise. **However, they are also criticized for causing operational issues, impacting performance negatively, and overpromising their capabilities.**

Many cloud services opt not to implement distributed transactions due to the operational difficulties they present. For instance, distributed transactions in `MySQL` have been reported to be more than 10 times slower than single-node transactions. Much of the cost comes from the additional disk forcing (`fsync`) needed for crash recovery and the additional network round-trips.

There are two quite different types of distributed transactions:

- **Database-internal distributed transactions**: all participating nodes run the same database software, as in VoltDB and MySQL Cluster's NDB storage engine. They can use any protocol and optimizations, and often work quite well.
- **Heterogeneous distributed transactions**: the participants are two or more different technologies, for example two databases from different vendors, or a database and a message broker.

`Exactly-once message processing` is one use of heterogeneous transactions: acknowledging a message from a queue and writing the result of processing it to a database can be committed atomically, so the message is effectively processed exactly once even if it was retried.

> [!NOTE]
> **XA transactions**
>
> `X/Open XA` (eXtended Architecture), introduced in 1991, is a standard for two-phase commit across heterogeneous technologies. It is a C API for interfacing with a transaction coordinator, supported by many relational databases and message brokers. In the Java world, it is implemented through the `Java Transaction API (JTA)`. The coordinator is usually a library loaded into the same process as the application, so if the application process crashes, the coordinator goes with it.

> [!CAUTION]
> **Holding locks while in doubt**
>
> An in-doubt transaction keeps holding its row-level locks, so other transactions cannot modify those rows, and possibly cannot read them either, until the coordinator recovers. If the coordinator's log is lost, transactions may remain in doubt forever (`orphaned`), and an administrator must manually decide whether to commit or roll back each one. Many XA implementations have an emergency escape hatch called `heuristic decisions`, which lets a participant decide unilaterally, at the risk of breaking atomicity.

Limitations of distributed transactions:

- A coordinator that is not replicated is a single point of failure for the whole system.
- An application server with a coordinator is no longer stateless, because the coordinator logs are part of the durable system state.
- XA has to be compatible with a wide range of systems, so it is a lowest common denominator: it cannot detect deadlocks across systems and does not work with SSI.
- 2PC requires all participants to respond, so any failing part makes the whole transaction fail. Distributed transactions tend to `amplify failures`.

---
## Fault-Tolerant Consensus

In a consensus problem, one or more nodes `propose` values, and the consensus algorithm `decides` on one of those values. Uniform agreement and integrity define the core idea, validity rules out trivial solutions, and termination formalizes fault tolerance: a consensus algorithm cannot simply sit around and do nothing forever. 2PC does not satisfy termination, because it waits for the coordinator to recover.

A consensus algorithm must satisfy these properties:

1. **Uniform agreement**: No two nodes make different decisions.
2. **Integrity**: No node makes a decision twice.
3. **Validity**: If a node decides on value v, then v was proposed by some node.
4. **Termination**: Every node that doesn't crash eventually decides on some value.

Termination is subject to the assumption that fewer than half of the nodes are crashed or unreachable. Any consensus algorithm requires at least a majority of nodes to function correctly to ensure termination. The safety properties (agreement, integrity and validity) are always met, even if a majority of nodes fail.

### Consensus Algorithms and Total Order Broadcast

The best-known fault-tolerant consensus algorithms are `Viewstamped Replication (VSR)`, `Paxos`, `Raft` and `Zab`. Most of them actually decide on a sequence of values, which makes them total order broadcast algorithms: total order broadcast is equivalent to repeated rounds of consensus, one per message. VSR, Raft and Zab implement total order broadcast directly; Paxos does it in the optimization known as `Multi-Paxos`.

### Epoch Numbering and Quorums

Consensus protocols use a leader internally, but they do not guarantee that the leader is unique. Instead, they guarantee that within each `epoch` (called a `ballot number` in Paxos, `view number` in VSR and `term number` in Raft), the leader is unique.

1. When the current leader is thought to be dead, the nodes vote to elect a new leader. The election gets an incremented epoch number, so epoch numbers are totally ordered and monotonically increasing.
2. If two leaders from different epochs conflict, the leader with the higher epoch number wins.
3. Before a leader decides anything, it collects votes from a quorum of nodes for its proposal. A node votes for a proposal only if it is not aware of a leader with a higher epoch.

There are two rounds of voting: once to choose a leader, and a second time to vote on the leader's proposal. The two quorums must overlap: if a vote on a proposal succeeds, at least one of the nodes that voted for it must also have taken part in the most recent leader election. This looks similar to 2PC, but the leader is elected rather than fixed, and a quorum of nodes is enough instead of every participant.

### Limitations of Consensus

- The voting process on proposals is a kind of synchronous replication, which costs performance.
- Consensus systems require a strict majority to operate: at least three nodes to tolerate one failure, or five nodes to tolerate two. A network partition can block the minority side.
- Most consensus algorithms assume a fixed set of nodes. Dynamic membership extensions exist but are much less well understood.
- Consensus systems rely on timeouts to detect failed nodes. In environments with highly variable network delays, nodes often falsely believe the leader has failed, and frequent elections can make the system spend more time choosing a leader than doing useful work.

---
## Membership and Coordination Services: ZooKeeper

> [!WARNING]
> **ZooKeeper** is a vital tool in distributed systems, acting as a coordination and configuration service. It implements a **consensus algorithm**, enabling it to hold small amounts of data that fit entirely in memory (it still writes them to disk for durability) and replicate them to all nodes. The consensus protocol guarantees `linearizability` and `atomicity` of operations even in the event of node failure or network interruptions.

Key features that make these services valuable for distributed systems include:
- **Linearizable atomic operations**
- **Total ordering of operations**
- **Failure detection**
- **Change notifications**

While only the linearizable atomic operations really require consensus, the combination of these features makes ZooKeeper an invaluable tool for distributed coordination.

`ZooKeeper` can efficiently allocate work to nodes, helping in leader election and assignment of partitioned resources to nodes. It can also support service discovery, assisting services to discover leaders or primaries. It is often used to manage slow-changing data and is not meant for storing rapid, runtime state of an application.

ZooKeeper and similar services can also serve as `membership services`, which determine which nodes are currently active and live members of a cluster. A failure detector combined with consensus lets the nodes agree on which nodes should be considered alive, even if a node is wrongly declared dead.

Importantly, not every system necessarily requires consensus. In cases where global consensus is not utilized, such as in **leaderless and multi-leader replication systems**, we may need to adapt to data with branching and merging version histories instead of striving for linearizability. `ZooKeeper` offers a way of outsourcing some of the work of coordinating nodes, making it an indispensable tool in the distributed systems landscape.
