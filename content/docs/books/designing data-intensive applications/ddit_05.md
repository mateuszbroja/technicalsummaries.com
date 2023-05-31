---
weight: 5
title: "05: Replication"
bookHidden: false
---

# Replication
---

{{< hint warning >}}
**Replication** means keeping a copy of the same data on multiple machines that are connected via a network.
{{< /hint >}}

Reasons why you might want to replicate data:
- Increase `read throughput`
- `Fault tolerance`/`high availability` (system works even if some of it's parts have failed)
- Reduced `latency`, e.g. regional data centers
- `Scalability` - being able to handle a higher volume of reads than a single machine could handle, by performing reads on replicas.

---
## Handling changes to replicated data

The challenge with replication is how to deal with writes (changes) because every node will have to process every write. Popular algorithms for replicating changes between nodes: `single-leader`, `multi-leader`, and `leaderless` replication.

`MySQL`, `SQL Server's AlwaysOn Availability Groups`, `MongoDB`, `RethinkDB`, `Kafka` and `RabbitMQ` are examples of these kind of databases.

---
### How to create leaders and followers

1. **Leader Selection**:
   - One replica is designated as the leader/master/primary.
   - Writes are directed to the leader node.
2. **Follower Replication**:
   - Other replicas are followers/read replicas/slaves/secondaries.
   - The leader sends data changes to followers via replication logs or change streams.
3. **Read and Write Operations**:
   - Reads can be performed on both the leader and followers.
   - Writes are only accepted on the leader.

{{< tabs "replication" >}}
{{< tab "Adding New Followers" >}}
- Sync a snapshot from the leader to the new follower.
- Request all updates that occurred since the snapshot.
{{< /tab >}}
{{< tab "Replication Formats" >}}
- `Statement-based replication`: Replicate data using evaluated SQL statements on each node.
- `Write-ahead log replication`: Sync LSM-trees and B-trees directly using a replication log.
- `Logical replication`: Use an engine-agnostic data structure to represent records for replication.
- `Trigger-based replication`: Custom replication schemes using triggers for handling conflicts.
{{< /tab >}}
{{< /tabs >}}

---
### Database Leadership Types

- **Single-leader**: Standard DB model. Writes to leader, distributes to followers. Followers handle reads. Leader failure prompts consensus for replacement.
- **Multi-leader**: Large-scale DB model. Writes to any leader (typically per data center). Followers handle reads. More robust, but consistency is weak.
- **Leaderless**: Exotic DB model (e.g., Cassandra, Dynamo, CRDTs). Reads/writes to multiple nodes. Each value versioned; outdated versions updated on detection.

---
### Synchronous vs. asynchronous

{{< hint warning >}}
**Asynchronous Replication**: The leader sends a message, not waiting for the follower's response.
**Synchronous Replication**: Guarantees up-to-date and consistent data on the follower. If the follower doesn't respond, the write can't proceed.
{{< /hint >}}

The former prioritizes **performance**, while the latter ensures **durability**. In practice, a hybrid model (one synchronous follower, several asynchronous) balances durability and performance.

Synchronous replication for all followers is impractical. Typically, _one_ follower is synchronous, while the others are asynchronous.

{{< hint warning >}}
**Eventual consistency** signifies that replicas eventually reach the same state for a record, popularized by NoSQL projects, but also present in asynchronously replicated relational databases.
{{< /hint >}}

{{< hint warning >}}
**Concurrency** implies multiple clients writing to a DB oblivious of each other's operations. For concurrency definition, the exact time is irrelevant. Two operations are concurrent if they're both unaware of each other, irrespective of the actual occurrence time.
{{< /hint >}}

When an application reads from an asynchronous follower, it might see outdated data, resulting in inconsistencies. Running identical queries on a leader and a follower could yield different results due to unreflected writes in the follower. However, given no further writes and enough time, followers catch up to the leader, hence "eventual" consistency.

*Eventually* is non-specific; there's no limit to a replica's lag. Under normal conditions, replication lag might be barely noticeable but can drastically increase under system stress or network issues, leading to noticeable inconsistencies.

---
### Node Outage Management

- **Catch-up Recovery**: Request all updates from the leader since the snapshot.
- **Failover**: On leader failure, nodes elect a new leader, typically the one with the most current data.

---
## Replication lag

**Replication lag** can lead to inconsistent reads. Guarantees to mitigate this include:

- **Read-After-Write Consistency**: Clients should read the same version of data they wrote.
- **Monotonic Reads**: Clients should never see older versions of data once seen.
- **Consistent Prefix Reads**: Local ordering is critical for certain data types (e.g., messages and responses).

Replication is crucial not only for handling node failures but also for scalability and latency.

In **read-scaling**, adding followers increases read-only request handling capacity. This mainly works with asynchronous replication due to the higher likelihood of node failures with increased nodes, making a fully synchronous configuration unreliable.

Asynchronous replication can cause database inconsistencies (_eventual consistency_) due to lag, which can vary from fractions of a second to several minutes.

**Conflict resolution** strategies are necessary for concurrent client writes, such as:
- **Last Write Wins**: Simple to implement, may cause data loss.

---
### Replication Logs Implementation

- **Statement-based Replication**: Leader logs and sends every statement (`INSERT`, `UPDATE`, `DELETE`) to followers.
- **Write-ahead Log (WAL) Shipping**: Append-only log of all writes sent to followers. Used in PostgreSQL and Oracle.
- **Logical (Row-based) Log Replication**: Sequence of records describing row-level writes.
- **Trigger-based Replication**: Moves replication to the application layer in some situations.

---
### Consistency Models under Replication Lag

Certain consistency models help determine application behavior during replication lag:

{{< columns >}}
**Reading Your Own Writes**: _Read-after-write consistency_ or _read-your-writes consistency_ ensures users will always see their own updates upon page reload.

<--->

**Monotonic Reads**: Prevents the scenario of users witnessing data _moving backward in time_. Once users see data at a point in time, they should never see it from an earlier point.

<--->
**Consistent Prefix Reads**: Ensures that a sequence of writes viewed by a reader appears in the same order as written. This helps users see data in a causally logical order, such as a question and its corresponding reply.

{{< /columns >}}