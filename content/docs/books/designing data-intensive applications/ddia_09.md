---
weight: 9
title: "09: Consistency and Consensus"
bookHidden: false
---

# Consistency and Consensus
---

*The simplest way of handling faults is to simply let the entire service fail. We need to find ways of tolerating faults.*

---
## Overview

Fault-tolerant systems are best built by using general-purpose **abstractions** with robust guarantees, which can then be relied upon by applications.

{{< hint info >}}
An excellent example of this approach is the **use of transactions**. Transactions allow applications to operate as if there are:
- no crashes (`atomicity`),
- no concurrent database access (`isolation`),
- completely reliable storage devices (`durability`).

Although those real-world issues do occur, application doesn’t need to worry about them.
{{< /hint >}}

---
## Consistency Guarantees

### Eventual Consistency (Weak Guarantee)

Most replicated databases ensure `eventual consistency`, implying that if no new writes are made to the database, all read requests will eventually return the same value, i.e., all replicas will `converge` to the same state. However, this guarantee is weak as it does not specify when the `convergence` will occur, and reads may return inconsistent results till that time.

---
### Stronger Guarantees

Stronger consistency models exist but often trade-off performance or fault-tolerance. One such model is `linearizability`, offering one of the strongest consistency guarantees.

---
### Consistency models

`Linearizablity`: _total order_ of operations: if the system behaves as if there is only a single copy of the data.
`Causality`: Two events are ordered if they are causally related. Causality defines _a partial order_, not a total one (incomparable if they are concurrent).

`Linearizability` is not the only way of preserving `causality`. **Causal consistency is the strongest possible consistency model that does not slow down due to network delays, and remains available in the face of network failures.**


---
## Linearizability

{{< hint warning >}}
**Linearizability** (also known as `atomic consistency`, `strong consistency`, `immediate consistency`, or `external consistency`) is a consistency model that makes a system appear as if there were only one copy of the data, and all operations on it are atomic. This model provides the illusion of a single-node database to clients, maintaining the most recent, up-to-date value.
{{< /hint >}}

It enforces the following:

```sql
read(x) => v
-- Read from a database register x returns value v.
```

```sql
write(x, v) => r
-- Write value v to register x.
-- The response r could be ok or error.
```

```sql
cast(x_old, v_old, v_new) => r
-- An atomic compare-and-set operation.
-- If the value of the register x_equals v_old, it is atomically set to v_new.
-- If x != v_old the register is unchanged and it returns an error.
```

The key property of `linearizability` is that if one client read returns a new value, all subsequent reads must also return the new value. **However, enforcing linearizability can impact performance and reliability: if a node is down, no other nodes can process requests**.

---
### Linearizability vs Serializability

**Serializability** and **Linearizability** are often confused due to their similar implication of sequential order, but they represent different guarantees:

{{< columns >}}
- **Serializability** is an isolation property of transactions, where every transaction may read and write multiple objects. It ensures transactions behave as if they had been executed in some serial order (one after another), but the actual order of transactions can vary.
<--->
- **Linearizability** provides a recency guarantee on individual object reads and writes. It doesn't group operations into transactions, hence doesn't prevent issues like `write skew` unless additional measures are taken.
{{< /columns >}}

A database can offer both serializability and linearizability, known as `strict serializability`.

---
### Applications of Linearizability

- **Locking and leader election**: Coordination services like Apache ZooKeeper and etcd use consensus algorithms to implement linearizable operations in a fault-tolerant way.

- **Constraints and uniqueness guarantees**: For constraints like unique usernames or email addresses, linearizability is needed to ensure that if two entities try to create a user or file with the same name concurrently, one of them will encounter an error.

Linearizability ensures causal order, but unlike causal consistency, it doesn't allow concurrent operations.

---
### Implementing Linearizability and the Cost

While a single data copy is the simplest way to implement linearizability, it's not fault-tolerant. Different replication methods have varying potential for linearizability:

- `Single-leader replication`: Potentially linearizable
- `Consensus algorithms`: Linearizable
- `Multi-leader replication`: Not linearizable
- `Leaderless replication`: Probably not linearizable

In case of network interruptions between datacenters, multi-leader replication allows each data center to operate normally, whereas single-leader replication makes the application unavailable if it requires linearizable reads and writes.

Applications not requiring linearizability can tolerate network problems better as they can process requests independently, even when disconnected from other replicas, enhancing availability.

{{< hint danger >}}
**Linearizability**, though useful, is not commonly implemented in systems and distributed databases because of its performance costs. Many choose to prioritize performance over this type of consistency guarantee, which isn't solely about fault tolerance.

Linearizability is inherently slow, impacting system speed even outside of network faults. There isn't a faster algorithm for linearizability, but weaker consistency models provide a quicker alternative.
{{< /hint >}}

---
### The unhelpful CAP Theorem

{{< hint warning >}}
**CAP theorem** is often misleadingly presented as `Consistency, Availability, Partition tolerance: pick 2 out of 3`. Network partitions are inevitable, so they aren't something you can choose to avoid. Instead, a more accurate phrasing might be `Either Consistent or Available when Partitioned`.
{{< /hint >}}

`CAP theorem` has a narrow scope. It only considers one consistency model (`linearizability`) and one kind of fault (`network partitions`). It doesn't take into account network delays, dead nodes, or other trade-offs.

While CAP has been historically influential, it's of mostly historical interest today and offers little practical value for designing systems. It only considers one consistency model (`linearizability`) and one kind of fault (`network partitions`).

---
## Causality and Ordering

**Ordering** is vital in distributed systems:
1. `Single-leader replication` uses a leader to establish write orders, ensuring data consistency.
2. `Serializability` makes transactions behave as if executed sequentially.
3. `Timestamps` and `clocks` help introduce order, including determining the sequence of operations.

There are several reasons why ordering keeps coming up, and one of the reasons is that it helps preserve causality.

---
### Sequence Number Ordering

To maintain `causality` in distributed systems, operations need to be ordered. This is achieved using sequence numbers or timestamps. 

1. Sequence numbers promise that if operation A causally happens before B, it occurs before B in the total order.
2. Sequence numbers and timestamps are compact and provide a total order of operations.
3. The source of these numbers can be a logical clock, generating a sequence typically using incrementing counters.
4. In absence of a single leader, generating sequence numbers for operations is complex.

Though `Lamport timestamps` define a causality-consistent total order, they're not sufficient for all distributed system problems. For instance, implementing uniqueness constraints requires knowledge of when an order is finalized.

Causal consistency preserves the ordering required by causality and is used in consistent prefix reads, snapshot isolation, and preventing write skew.

---
### Total Order Broadcast

Total order broadcast is a protocol for exchanging messages among nodes. It ensures:

1. `Reliable delivery`: If a message is delivered to one node, it is delivered to all.
2. `Totally ordered delivery`: Messages are delivered to all nodes in the same order.

These properties hold even if nodes or networks are faulty. Services like `ZooKeeper` and `etcd` use this for consensus. It is vital for database replication, helping maintain consistency among replicas.

---
## Consensus

{{< hint warning >}}
**Consensus** in distributed computing appears simple: getting multiple nodes to agree on something. However, it's not easy to solve and has led to many broken systems.
{{< /hint >}}

Several scenarios demand consensus among nodes:

{{< tabs "consensus" >}}
{{< tab "Leader election" >}}

**Leader election**: Nodes must agree on who is the leader in leader-based replication systems.

{{< /tab >}}
{{< tab "Atomic commit" >}}

**Atomic commit**: In a database supporting multi-node or partition-spanning transactions, nodes must agree on a transaction's outcome for maintaining atomicity. This type of consensus is known as the atomic commit problem.

`Two-phase commit (2PC)` is a consensus algorithm used for `atomic commit` in distributed databases, ensuring either all nodes commit or all abort. It introduces a coordinator to manage transactions. Note that 2PC is distinct from two-phase locking (2PL), which provides serializable isolation.

{{< /tab >}}
{{< /tabs >}}


{{< hint danger >}}
**The Impossibility of Consensus**

The `Fischer`, `Lynch`, and `Paterson` (`FLP`) result states there's no fail-proof consensus algorithm in the event of a node crash. Despite this, consensus is usually attainable in practical distributed systems.
{{< /hint >}}

To maintain consistency in a distributed system, a consensus algorithm must satisfy these properties:

1. **Uniform agreement**: No two nodes make different decisions.
2. **Integrity**: No node makes a decision twice.
3. **Validity**: If a node decides on value v, then v was proposed by some node.
4. **Termination**: Every node that doesn't crash eventually decides on some value.

---
## Distributed Transactions in Practice

**Distributed transactions**, particularly those implemented with `two-phase commit`, have a **controversial reputation**. They are appreciated for providing significant safety guarantees that would be challenging to achieve otherwise. **However, they are also criticized for causing operational issues, impacting performance negatively, and overpromising their capabilities.** 

Many cloud services opt not to implement distributed transactions due to the operational difficulties they present. For instance, distributed transactions in `MySQL` have been reported to be more than 10 times slower than single-node transactions. 

---
## Zookeeper

{{< hint warning >}}
**ZooKeeper** is a vital tool in distributed systems, acting as a coordination and configuration service. It implements a **consensus algorithm**, enabling it to manage small, frequently replicated amounts of data that can entirely fit in memory. The consensus protocol guarantees `linearizability` and `atomicity` of operations even in the event of node failure or network interruptions.
{{< /hint >}}

Key features that make these services valuable for distributed systems include:
- **Linearizable atomic operations**
- **Total ordering of operations**
- **Failure detection**
- **Change notifications**

While only the linearizable atomic operations really require consensus, the combination of these features makes ZooKeeper an invaluable tool for distributed coordination.

`ZooKeeper` can efficiently allocate work to nodes, helping in leader election and assignment of partitioned resources to nodes. It can also support service discovery, assisting services to discover leaders or primaries. It is often used to manage slow-changing data and is not meant for storing rapid, runtime state of an application.

Importantly, not every system necessarily requires consensus. In cases where global consensus is not utilized, such as in **leaderless and multi-leader replication systems**, we may need to adapt to data with branching and merging version histories instead of striving for linearizability. `ZooKeeper` offers a way of outsourcing some of the work of coordinating nodes, making it an indispensable tool in the distributed systems landscape.

