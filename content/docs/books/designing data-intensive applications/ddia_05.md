---
weight: 5
title: "05: Replication"
bookHidden: false
---

# Replication
---

> [!NOTE]
> **Replication** means keeping a copy of the same data on multiple machines that are connected via a network.

**Reasons to replicate data:**
- **Reduce latency** by keeping data geographically close to users.
- **Increase availability** by allowing the system to keep working even if some of its parts have failed.
- **Increase read throughput** by scaling out the number of machines that can serve read queries.

If the data never changed, replication would be easy: copy it to every node once. All the difficulty lies in **handling changes** to replicated data. There are three popular approaches: `single-leader`, `multi-leader`, and `leaderless` replication. This chapter assumes that each node can hold a copy of the entire dataset; partitioning is covered in the next chapter.

---

## Leaders and Followers

Every write to the database needs to be processed by every replica, otherwise the replicas would no longer contain the same data. The most common solution is `leader-based replication` (also known as `active/passive` or `master-slave` replication):

1. One of the replicas is designated the **leader** (`master`, `primary`). Clients must send all writes to the leader, which first writes the new data to its local storage.
2. The other replicas are **followers** (`read replicas`, `slaves`, `secondaries`, `hot standbys`). Whenever the leader writes new data, it also sends the change to all followers as part of a `replication log` or `change stream`. Each follower applies the writes in the same order as they were processed on the leader.
3. Clients can read from the leader or from any follower, but **writes are only accepted on the leader**.

Leader-based replication is built into `PostgreSQL` (since 9.0), `MySQL`, `Oracle Data Guard`, `SQL Server's AlwaysOn Availability Groups`, and nonrelational databases such as `MongoDB`, `RethinkDB`, and `Espresso`. Distributed message brokers such as `Kafka` and `RabbitMQ`'s highly available queues use it as well.

---

### Synchronous Versus Asynchronous Replication

> [!NOTE]
> **Synchronous replication**: the leader waits until the follower confirms that it received the write before reporting success to the client. The follower is guaranteed to have an up-to-date copy of the data, but if it does not respond (because it crashed, or because of a network fault), the write cannot be processed, and the leader must block all writes until the follower is available again.
>
> **Asynchronous replication**: the leader sends the message but does not wait for a response from the follower.

It is impractical for all followers to be synchronous, because any one node outage would bring the whole system to a halt. In practice, **one** follower is synchronous and the others are asynchronous. If the synchronous follower becomes slow or unavailable, an asynchronous follower is made synchronous. This guarantees an up-to-date copy of the data on at least two nodes and is called `semi-synchronous` replication.

Leader-based replication is often configured to be **completely asynchronous**. Then a write is not guaranteed to be durable even if it was confirmed to the client: if the leader fails and is not recoverable, writes that were not yet replicated are lost. The advantage is that the leader can continue processing writes even if all followers have fallen behind.

---

### Setting Up New Followers

Simply copying data files is not enough, because clients keep writing to the database. The process works without downtime:
1. Take a consistent snapshot of the leader's database at some point in time, without locking the entire database. Most databases need this feature for backups anyway.
2. Copy the snapshot to the new follower node.
3. The follower connects to the leader and requests all data changes that happened since the snapshot was taken. This requires that the snapshot is associated with an exact position in the leader's replication log (PostgreSQL calls it the `log sequence number`, MySQL the `binlog coordinates`).
4. When the follower has processed the backlog of changes, it has `caught up` and can continue processing changes as they happen.

---

### Handling Node Outages

- **Follower failure: catch-up recovery.** Each follower keeps a log of the data changes it has received from the leader. After a crash or a network interruption, it knows the last transaction it processed, so it can connect to the leader and request all data changes that occurred since then.
- **Leader failure: failover.** One of the followers needs to be promoted to be the new leader, clients need to send their writes to the new leader, and the other followers need to consume data changes from the new leader. Failover can be manual or automatic:
  1. **Determining that the leader has failed**: there is no foolproof way, so most systems use a timeout. If a node does not respond for some time, for example 30 seconds, it is assumed to be dead.
  2. **Choosing a new leader**: through an election process or by a previously elected controller node. The best candidate is usually the replica with the most up-to-date data changes from the old leader, which minimizes data loss. Getting all nodes to agree on a new leader is a consensus problem.
  3. **Reconfiguring the system to use the new leader**: clients send writes to the new leader, and if the old leader comes back, it must become a follower.

> [!CAUTION]
> **Failover is fraught with things that can go wrong:**
> - With asynchronous replication, the new leader may not have received all writes from the old leader. If the former leader rejoins, those writes are usually discarded, which may violate clients' durability expectations.
> - Discarding writes is especially dangerous if other storage systems are coordinated with the database. In one GitHub incident, an out-of-date MySQL follower was promoted and reused autoincrementing primary keys that the old leader had already assigned. These keys were also used in a Redis store, so some private data was disclosed to the wrong users.
> - Two nodes may both believe that they are the leader (`split brain`). If both accept writes and there is no process for resolving conflicts, data is likely to be lost or corrupted. Some systems shut down one node when two leaders are detected, but a carelessly designed mechanism can shut down both.
> - Choosing the timeout is hard. A longer timeout means a longer recovery time. A shorter timeout risks unnecessary failovers, for example during a load spike, which can make the situation worse.
>
> For these reasons, some operations teams prefer to perform failovers manually.

---

### Implementation of Replication Logs

{{< tabs "replication" >}}
{{% tab "Statement-based" %}}
The leader logs every write request (`INSERT`, `UPDATE`, `DELETE` statement) and sends it to its followers, which parse and execute it as if it had been received from a client.

**Problems:**
- Nondeterministic functions such as `NOW()` or `RAND()` generate a different value on each replica.
- Statements that use an autoincrementing column or depend on existing data (`UPDATE ... WHERE <condition>`) must be executed in exactly the same order on each replica, which limits concurrently executing transactions.
- Statements with side effects (triggers, stored procedures, user-defined functions) may cause different effects on each replica.

The leader can replace nondeterministic calls with fixed values, but there are so many edge cases that other methods are generally preferred. MySQL before version 5.1 used statement-based replication. VoltDB uses it and requires transactions to be deterministic.
{{% /tab %}}
{{% tab "Write-ahead log shipping" %}}
Storage engines already maintain an append-only log of every write: the log segments of an LSM-tree, or the write-ahead log of a B-tree. The same log can be sent to the followers, which build an exact copy of the leader's data structures. PostgreSQL and Oracle use this method.

**Problem:** the log describes the data on a very low level, such as which bytes were changed in which disk blocks. Replication is therefore closely coupled to the storage engine. If the storage format changes between database versions, the leader and followers usually cannot run different versions, which makes zero-downtime upgrades impossible.
{{% /tab %}}
{{% tab "Logical (row-based) log" %}}
A different log format is used for replication than for the storage engine, which decouples the replication log from the storage engine internals. A logical log for a relational database is a sequence of records describing writes at the granularity of a row:
- for an inserted row, the new values of all columns,
- for a deleted row, enough information to identify it, typically the primary key,
- for an updated row, enough information to identify it and the new values of the changed columns.

A transaction that modifies several rows generates several log records followed by a commit record. MySQL's binlog works this way when configured for row-based replication. A logical log can be kept backward compatible, so leader and followers can run different versions, and it is easier for external applications to parse, for example to send the contents of a database to a data warehouse. This technique is called `change data capture`.
{{% /tab %}}
{{% tab "Trigger-based" %}}
Sometimes more flexibility is needed: replicating only a subset of the data, replicating from one kind of database to another, or applying custom conflict resolution logic. Then replication can be moved up to the application layer.

A `trigger` registers custom application code that is executed automatically when a data change occurs. It can log the change into a separate table, from which an external process reads and replicates it. Oracle's `Databus` and Postgres's `Bucardo` work like this.

Trigger-based replication typically has greater overhead than built-in replication and is more prone to bugs, but its flexibility can be useful.
{{% /tab %}}
{{< /tabs >}}

---

## Problems with Replication Lag

In **read-scaling** architectures, read capacity is increased by adding more followers. This only realistically works with asynchronous replication: if all followers were synchronous, a single node failure or network outage would make the entire system unavailable for writing.

When an application reads from an asynchronous follower, it may see outdated information. Running the same query on the leader and on a follower at the same time can give different results, because not all writes have been reflected in the follower. This inconsistency is temporary: if writes stop for a while, the followers eventually catch up.

> [!NOTE]
> **Eventual consistency** - if no new writes are made, all replicas eventually converge to the same state. "Eventually" is deliberately vague: there is no limit to how far a replica can fall behind. Under normal operation, the `replication lag` may be only a fraction of a second, but when the system operates near capacity or there is a network problem, it can increase to several seconds or even minutes.

Three guarantees help with the problems caused by replication lag:

{{% columns %}}
- **Reading your own writes**

  `Read-after-write consistency` (`read-your-writes`) guarantees that users always see any updates they submitted themselves after reloading the page. It makes no promises about other users' updates.

- **Monotonic reads**

  If a user makes several reads in sequence, they will not see time go backward: they never read older data after having previously read newer data. It is a weaker guarantee than strong consistency but stronger than eventual consistency.

- **Consistent prefix reads**

  If a sequence of writes happens in a certain order, anyone reading those writes sees them appear in the same order. Otherwise, an observer could see the answer to a question before the question itself.
{{% /columns %}}

**How to implement read-after-write consistency:**
- Read data that the user may have modified from the leader, and everything else from a follower. For example, a user's own profile is always read from the leader, and other users' profiles from followers.
- If most things are editable by the user, track the time of the last update and read from the leader for one minute afterwards, or monitor the replication lag and avoid followers that are more than one minute behind.
- The client can remember the timestamp of its most recent write (a logical timestamp or the actual system clock), and the system makes sure that the replica serving the read reflects updates at least until that timestamp.
- If replicas are distributed across datacenters, any request that needs the leader must be routed to the datacenter that contains it.
- **Cross-device consistency** adds problems: a user may write on a desktop and read on a phone. The timestamp of the last update must then be centralized, and requests from all devices may need to be routed to the same datacenter.

**How to implement monotonic reads:** make sure that each user always reads from the same replica, for example by choosing the replica based on a hash of the user ID. If that replica fails, the user's queries need to be rerouted.

**How to implement consistent prefix reads:** this is a particular problem in partitioned databases, where different partitions operate independently and there is no global ordering of writes. One solution is to write causally related data to the same partition, but in some applications that cannot be done efficiently.

> [!WARNING]
> **Solutions for replication lag:** if replication lag of several minutes would cause a bad user experience, the system should be designed to provide a stronger guarantee. Pretending that replication is synchronous when it is in fact asynchronous is a recipe for problems. Handling this in application code is complex and easy to get wrong, which is why database `transactions` exist. Many distributed databases abandoned transactions, claiming they are too expensive, but that is an overly simplistic view.

---

## Multi-Leader Replication

Leader-based replication has one major downside: there is only one leader, and all writes must go through it. If the client cannot connect to the leader, it cannot write. `Multi-leader replication` (`master-master`, `active/active`) allows more than one node to accept writes. Each leader simultaneously acts as a follower to the other leaders.

### Use Cases for Multi-Leader Replication

- **Multi-datacenter operation**: there is a leader in each datacenter, and each datacenter's leader replicates its changes to the leaders in other datacenters.
- **Clients with offline operation**: an application that must keep working while disconnected from the internet, such as calendar apps on a mobile phone, a laptop, and other devices. Every device has a local database that acts as a leader, and replication is asynchronous with a lag of hours or even days. `CouchDB` is designed for this mode of operation.
- **Collaborative editing**: applications such as Google Docs allow several people to edit a document at the same time. To guarantee there are no editing conflicts, the document would have to be locked; for faster collaboration, the unit of change is made very small (for example, a single keystroke) and locking is avoided, which brings all the challenges of multi-leader replication.

{{% columns %}}
- **Single-leader in multiple datacenters**
  - Every write goes over the internet to the leader's datacenter, which adds significant latency.
  - If the leader's datacenter fails, failover can promote a follower in another datacenter.
  - Traffic between datacenters goes over the public internet, which is less reliable than the local network, so a synchronous setup is very sensitive to problems with this link.

- **Multi-leader in multiple datacenters**
  - Every write is processed in the local datacenter and replicated asynchronously, so inter-datacenter delay is hidden from users.
  - Each datacenter keeps operating independently, and replication catches up when a failed datacenter comes back online.
  - A temporary network interruption does not prevent writes from being processed.
{{% /columns %}}

The big downside is that **the same data may be concurrently modified in two different datacenters**, and those write conflicts must be resolved. Multi-leader replication is often retrofitted onto databases, so features like autoincrementing keys, triggers, and integrity constraints can have surprising interactions. It is often considered dangerous territory that should be avoided if possible.

---

### Handling Write Conflicts

In a single-leader database, the second writer either blocks or aborts. In a multi-leader setup, both writes succeed locally, and the conflict is detected asynchronously at some later point, when it may be too late to ask the user to resolve it. Making conflict detection synchronous would lose the main advantage of multi-leader replication.

- **Conflict avoidance**: the simplest strategy is to ensure that all writes for a particular record go through the same leader. For example, all requests from one user are routed to the same datacenter. This breaks down when the designated leader has to change, for example because of a datacenter failure or because the user moved.
- **Converging toward a consistent state**: in a multi-leader configuration there is no defined ordering of writes, but all replicas must arrive at the same final value. Ways to achieve convergent conflict resolution:
  - give each write a unique ID (a timestamp, a long random number, a UUID, or a hash of the key and value), pick the write with the highest ID as the winner, and throw away the others. If a timestamp is used, this is `last write wins` (`LWW`). It is popular but **prone to data loss**,
  - give each replica a unique ID and let writes from the higher-numbered replica win. This also implies data loss,
  - merge the values, for example by ordering them alphabetically and concatenating them,
  - record the conflict in an explicit data structure that preserves all information, and resolve it later in application code, for example by prompting the user.
- **Custom conflict resolution logic** written in application code:
  - **On write**: as soon as the database detects a conflict in the log of replicated changes, it calls a conflict handler. The handler usually runs in a background process and cannot prompt the user. `Bucardo` works like this.
  - **On read**: all conflicting writes are stored. The next time the data is read, the multiple versions are returned to the application, which may prompt the user or resolve the conflict automatically and write the result back. `CouchDB` works like this.

Conflict resolution usually applies at the level of an individual row or document, not an entire transaction. Research into **automatic conflict resolution** includes `conflict-free replicated datatypes` (`CRDTs`, used in Riak 2.0), `mergeable persistent data structures` (which track history explicitly, similar to Git), and `operational transformation` (the algorithm behind collaborative editors such as Etherpad and Google Docs).

> [!NOTE]
> **What is a conflict?** Some conflicts are obvious, such as two writes concurrently modifying the same field of the same record to different values. Others are subtle: a meeting room booking system must ensure that each room is booked by only one group at a time. If two bookings for the same room are created on two different leaders, a conflict occurs even though the records are different.

---

### Multi-Leader Replication Topologies

A `replication topology` describes the communication paths along which writes are propagated from one node to another.

- **All-to-all**: every leader sends its writes to every other leader. This is the most general topology.
- **Circular**: each node receives writes from one node and forwards those writes, plus its own, to one other node. MySQL supports only this topology by default.
- **Star**: one designated root node forwards writes to all other nodes. It can be generalized to a tree.

In circular and star topologies, a write may pass through several nodes. To prevent infinite replication loops, each node has a unique identifier, and each write is tagged with the identifiers of all the nodes it has passed through. **If just one node fails, it can interrupt the flow of replication messages** between other nodes until it is fixed or the topology is reconfigured manually.

All-to-all topologies have better fault tolerance, but some network links may be faster than others, so some replication messages may **overtake** others. For example, an update may arrive at a replica before the insert of the row it updates. This is a problem of causality, similar to consistent prefix reads. Timestamps are not sufficient to order these events correctly, because clocks cannot be trusted to be in sync. `Version vectors` can be used instead, but conflict detection is poorly implemented in many multi-leader replication systems.

---

## Leaderless Replication

Some data storage systems abandon the concept of a leader and allow **any replica to accept writes from clients directly**. This idea was largely forgotten during the dominance of relational databases and became fashionable again after Amazon used it for its in-house `Dynamo` system. `Riak`, `Cassandra`, and `Voldemort` are open source datastores with leaderless replication models inspired by Dynamo, so this kind of database is also known as **Dynamo-style**.

In some leaderless implementations, the client sends its writes directly to several replicas. In others, a `coordinator node` does this on behalf of the client, but unlike a leader, it does not enforce a particular ordering of writes.

---

### Writing to the Database When a Node Is Down

In a leaderless configuration, failover does not exist. The client sends a write to all replicas in parallel and considers it successful if enough replicas acknowledge it. Reads are also sent to several nodes in parallel, and **version numbers** determine which value is newer.

When an unavailable node comes back online, it has to catch up on the writes it missed:
- **Read repair**: when a client reads from several nodes in parallel, it can detect stale responses and write the newer value back to the stale replica. This works well for values that are read frequently.
- **Anti-entropy process**: a background process constantly looks for differences in the data between replicas and copies missing data. Unlike the replication log in leader-based replication, it does not copy writes in any particular order, and there may be a significant delay before data is copied.

Without an anti-entropy process, values that are rarely read may be missing from some replicas, which reduces durability.

---

### Quorums for Reading and Writing

> [!NOTE]
> **Quorum condition**: with `n` replicas, every write must be confirmed by `w` nodes, and every read must query at least `r` nodes. As long as **`w + r > n`**, at least one of the `r` nodes read from must be up to date, so the read is expected to return the latest value. Reads and writes that obey these `r` and `w` values are called `quorum` reads and writes.

- In Dynamo-style databases, `n`, `w`, and `r` are typically configurable. A common choice is an odd `n` (typically 3 or 5) with `w = r = (n + 1) / 2`, rounded up.
- A workload with few writes and many reads may benefit from `w = n` and `r = 1`. This makes reads faster, but a single failed node makes all writes fail.
- The quorum condition allows the system to tolerate unavailable nodes: with `n = 3, w = 2, r = 2`, one unavailable node can be tolerated, and with `n = 5, w = 3, r = 3`, two.
- If fewer than `w` or `r` nodes are available, writes or reads return an error.

---

### Limitations of Quorum Consistency

Even with `w + r > n`, there are likely to be edge cases where stale values are returned:
- If a **sloppy quorum** is used, the `w` writes may end up on different nodes than the `r` reads, so there is no longer a guaranteed overlap.
- If **two writes occur concurrently**, it is not clear which one happened first. The only safe solution is to merge the concurrent writes. If a winner is picked based on a timestamp (LWW), writes can be lost because of clock skew.
- If a **write happens concurrently with a read**, the write may be reflected on only some of the replicas, and it is undetermined whether the read returns the old or the new value.
- If a write **succeeded on some replicas but failed on others** and overall succeeded on fewer than `w` replicas, it is not rolled back on the replicas where it succeeded. Subsequent reads may or may not return the value from that write.
- If a node carrying a new value fails and its data is **restored from a replica carrying an old value**, the number of replicas storing the new value may fall below `w`.
- Even when everything works correctly, there are edge cases related to timing.

Dynamo-style databases are generally optimized for use cases that can tolerate eventual consistency. The parameters `w` and `r` adjust the probability of stale values being read, but they are not absolute guarantees. Stronger guarantees such as reading your writes, monotonic reads, or consistent prefix reads generally require transactions or consensus.

**Monitoring staleness** is harder than in leader-based replication. With leader-based replication, the replication lag can be computed by subtracting a follower's position in the replication log from the leader's position. In a leaderless system, there is no fixed order in which writes are applied, and if only read repair is used, there is no limit to how old a value might be.

---

### Sloppy Quorums and Hinted Handoff

In a large cluster, a client may be able to connect to some database nodes during a network interruption, but not to the nodes that it needs to assemble a quorum for a particular value. The database designer then faces a trade-off:
- return errors to all requests for which a quorum of `w` or `r` nodes cannot be reached, or
- accept writes anyway and write them to some nodes that are reachable but are not among the `n` nodes on which the value usually lives.

The second option is a `sloppy quorum`: writes and reads still require `w` and `r` successful responses, but those may include nodes outside the designated `n` "home" nodes. When the network interruption is fixed, the writes that a node temporarily accepted on behalf of another node are sent to the appropriate home nodes. This is called `hinted handoff`.

Sloppy quorums are particularly useful for **increasing write availability**. However, even with `w + r > n`, a read is not guaranteed to see the latest value, because it may have been written to nodes outside of `n`. A sloppy quorum is therefore only an assurance of durability, not a quorum in the traditional sense. Sloppy quorums are optional in all common Dynamo implementations: enabled by default in Riak and disabled by default in Cassandra and Voldemort.

**Multi-datacenter operation:** leaderless replication is suitable for multi-datacenter operation, because it is designed to tolerate conflicting concurrent writes, network interruptions, and latency spikes. Cassandra and Voldemort count `n` across all datacenters, and each write is sent to all replicas, but the client usually waits only for a quorum of nodes within its local datacenter. Riak keeps all communication between clients and database nodes local to one datacenter, and cross-datacenter replication happens asynchronously in the background.

---

### Detecting Concurrent Writes

Dynamo-style databases allow several clients to concurrently write to the same key, so conflicts occur even with strict quorums. Events may also arrive in a different order at different nodes because of variable network delays and partial failures. To become eventually consistent, the replicas should converge toward the same value.

**Last write wins (LWW):** each replica stores only the most recent value and lets older values be overwritten and discarded. A timestamp is attached to each write, and the biggest timestamp is picked as the most recent. LWW achieves eventual convergence at the cost of durability: if there are several concurrent writes to the same key, only one survives, even if all were reported as successful to the client. LWW is the only supported conflict resolution method in Cassandra. **The only safe way to use a database with LWW is to ensure that a key is written only once and thereafter treated as immutable**, for example by using a UUID as the key for every write.

> [!NOTE]
> **The happens-before relationship and concurrency:** an operation A `happens before` an operation B if B knows about A, depends on A, or builds upon A in some way. Two operations are `concurrent` if neither happens before the other, that is, if neither knows about the other. The exact time does not matter: two operations may be concurrent even if they happen at different physical times, as long as they are unaware of each other.

**Capturing the happens-before relationship** on a single replica:
- The server maintains a version number for every key and increments it every time the key is written.
- When a client reads a key, the server returns all values that have not been overwritten, together with the latest version number. A client must read a key before writing it.
- When a client writes a key, it must include the version number from the prior read and merge together all values that it received in that read.
- When the server receives a write with a particular version number, it can overwrite all values with that version number or below, because it knows they have been merged into the new value. It must keep all values with a higher version number, because those values are concurrent with the incoming write.

**Merging concurrently written values:** the concurrent values, called `siblings`, must be merged by the client. For a shopping cart, a reasonable approach is to take the union of the items. To support item removal, a deletion is recorded with a marker (`tombstone`), because removing the item from one sibling would make it reappear after the union. Riak's datatypes based on CRDTs can merge siblings automatically.

**Version vectors:** with multiple replicas and no leader, a version number is needed **per replica as well as per key**. Each replica increments its own version number when processing a write and keeps track of the version numbers it has seen from each of the other replicas. The collection of version numbers from all the replicas is called a `version vector`. It is sent to the client when values are read and sent back to the database when a value is written, which allows the database to distinguish between overwrites and concurrent writes. Riak uses a variant called `dotted version vectors`. A version vector is sometimes called a vector clock, but strictly speaking they are not the same thing.

---

## Summary

- Replication serves several purposes: **high availability** (keeping the system running when one machine, or a whole datacenter, goes down), **disconnected operation** (allowing an application to continue working during a network interruption), **latency** (placing data geographically close to users), and **scalability** (handling a higher volume of reads than a single machine could).
- The three main approaches:
  - **Single-leader replication**: clients send all writes to a single node, which sends a stream of data change events to the other replicas. Reads can be performed on any replica, but reads from followers might be stale. It is popular because it is fairly easy to understand and there is no conflict resolution to worry about.
  - **Multi-leader replication**: clients send each write to one of several leader nodes, any of which can accept writes. The leaders send streams of data change events to each other and to any follower nodes. It is more robust in the presence of faulty nodes, network interruptions, and latency spikes, at the cost of being harder to reason about and providing only very weak consistency guarantees.
  - **Leaderless replication**: clients send each write to several nodes and read from several nodes in parallel to detect and correct nodes with stale data. Like multi-leader replication, it is robust but weakly consistent.
- Replication can be synchronous or asynchronous, which has a profound effect on system behavior when there is a fault.
- Consistency models help decide how an application should behave under replication lag: **read-after-write consistency**, **monotonic reads**, and **consistent prefix reads**.
- Multi-leader and leaderless approaches allow concurrent writes, so conflicts can occur. Databases can use the happens-before relationship and version vectors to determine whether one operation happened before another or whether they were concurrent, and then merge the concurrent updates.
