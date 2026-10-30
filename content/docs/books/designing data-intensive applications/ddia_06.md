---
weight: 6
title: "06: Partitioning"
bookHidden: false
---

# Partitioning
---

*Clearly, we must break away from the sequential and not limit the computers. We must state definitions and provide for priorities and descriptions of data. We must state relationships, not procedures.*

---

## Overview

> [!NOTE]
> **Partitioning** means breaking a large dataset into smaller subsets called `partitions`. Each piece of data (each record, row, or document) belongs to exactly one partition, and each partition is a small database of its own, although the database may support operations that touch multiple partitions at the same time.

What is called a partition here goes by many names: a `shard` in MongoDB, Elasticsearch, and SolrCloud, a `region` in HBase, a `tablet` in Bigtable, a `vnode` in Cassandra and Riak, and a `vBucket` in Couchbase.

**The main reason for partitioning is `scalability`.** Different partitions can be placed on different nodes in a shared-nothing cluster, so a large dataset can be distributed across many disks, and the query load can be distributed across many processors. Queries that operate on a single partition can be executed independently on each node, so query throughput can be scaled by adding more nodes. Partitioning becomes necessary when the data volume or the query throughput is too much for a single machine.

**Goals of partitioning:**
- Spread the data and the query load evenly across nodes.
- Avoid hot spots, which make partitioning less effective.
- Choose a partitioning scheme that suits the data and the queries.
- Rebalance partitions when nodes are added to or removed from the cluster.

---

### Partitioning and Replication

Partitioning is usually combined with replication, so that copies of each partition are stored on multiple nodes for fault tolerance. Each record belongs to exactly one partition, but it may still be stored on several different nodes. A node may store more than one partition. With leader-follower replication, each node may be the leader for some partitions and a follower for other partitions.

**The choice of partitioning scheme is mostly independent of the choice of replication scheme**, so the two can be considered separately.

---

## Partitioning of Key-Value Data

If the partitioning is unfair, so that some partitions have more data or queries than others, it is called **skewed**. A partition with disproportionately high load is called a **hot spot**.

The simplest approach would be to assign records to nodes randomly. That distributes the data evenly, but there is no way of knowing which node holds a particular item, so every read has to query all nodes in parallel. Two better approaches follow.

---

### Partitioning by Key Range

> [!NOTE]
> **Key range partitioning** assigns a continuous range of keys, from some minimum to some maximum, to each partition, like the volumes of a paper encyclopedia.

- The ranges of keys are not necessarily evenly spaced, because the data may not be evenly distributed. The partition boundaries need to adapt to the data, either chosen manually by an administrator or automatically by the database.
- Within each partition, keys can be kept in sorted order (as in SSTables and LSM-trees). **Range scans are efficient**, and a key can be treated as a concatenated index to fetch several related records in one query.
- This strategy is used by `Bigtable`, its open source equivalent `HBase`, `RethinkDB`, and `MongoDB` before version 2.4.

> [!WARNING]
> **Hot spots with key ranges:** certain access patterns lead to hot spots. If the key is a timestamp, for example in an application that stores sensor measurements, all writes for today end up in the same partition, which is overloaded while the others sit idle. The fix is to use something other than the timestamp as the first element of the key, for example prefixing each timestamp with the sensor name. Then the write load is spread across partitions, but fetching the values of many sensors in a time range requires a separate range query for each sensor name.

---

### Partitioning by Hash of Key

> [!NOTE]
> **Hash partitioning** applies a hash function to each key and assigns each partition a range of hashes. Every key whose hash falls within a partition's range is stored in that partition.

- A good hash function takes skewed data and makes it uniformly distributed. It does not need to be cryptographically strong: `Cassandra` and `MongoDB` use `MD5`, and `Voldemort` uses the Fowler-Noll-Vo function.
- Built-in hash functions of programming languages may not be suitable, because the same key can have a different hash value in different processes (for example, Java's `Object.hashCode()` and Ruby's `Object#hash`).
- The partition boundaries can be evenly spaced or chosen pseudorandomly. The latter is sometimes called `consistent hashing`, but the term is used confusingly, and in the context of databases it is less ambiguous to call this hash partitioning.

**The downside: efficient range queries are lost.** Keys that were once adjacent are now scattered across all the partitions, so their sort order is lost. In MongoDB with hash-based sharding, any range query has to be sent to all partitions. Range queries on the primary key are not supported by Riak, Couchbase, or Voldemort.

`Cassandra` achieves a compromise with a `compound primary key` consisting of several columns. Only the first part of the key is hashed to determine the partition, and the other columns are used as a concatenated index for sorting the data in Cassandra's SSTables. A query cannot search for a range of values in the first column, but if it specifies a fixed value for the first column, it can perform an efficient range scan over the other columns. For example, with the key `(user_id, update_timestamp)`, all updates of one user within a time interval can be retrieved efficiently in sorted order.

---

### Skewed Workloads and Relieving Hot Spots

Hashing a key reduces hot spots but cannot avoid them entirely. In the extreme case where all reads and writes are for the same key, all requests still go to the same partition. For example, on a social media site, a celebrity with millions of followers may cause a storm of activity when they post something, and all of it may hit the same key.

Most data systems cannot automatically compensate for such a highly skewed workload, so **it is the responsibility of the application to reduce the skew**:
- A simple technique is to add a random number to the beginning or end of a very hot key. A two-digit decimal random number splits the writes to the key evenly across 100 different keys, which can be distributed to different partitions.
- The cost is extra work for reads: they now have to read the data from all 100 keys and combine it.
- The technique only makes sense for the small number of hot keys, so some bookkeeping is needed to track which keys are being split.

---

## Partitioning and Secondary Indexes

With a key-value data model, partitioning by primary key is enough: the partition can be determined from the key, and read and write requests can be routed to the partition responsible for it.

Secondary indexes complicate things. A secondary index usually does not identify a record uniquely but is a way of searching for occurrences of a particular value, for example all cars that are red. Secondary indexes are the bread and butter of relational databases and common in document databases. Many key-value stores (such as HBase and Voldemort) avoid them because of the added implementation complexity, while search servers such as `Solr` and `Elasticsearch` exist to provide them. The problem is that secondary indexes do not map neatly to partitions.

{{% columns %}}
- **Document-partitioned (local) index**
  - Each partition maintains its own secondary indexes, covering only the documents in that partition.
  - A write (adding, removing, or updating a document) only deals with the partition that contains the document.
  - A read through the secondary index must query all partitions and combine the results (`scatter/gather`), which is expensive and prone to tail latency amplification.
  - Used by `MongoDB`, `Riak`, `Cassandra`, `Elasticsearch`, `SolrCloud`, and `VoltDB`.

- **Term-partitioned (global) index**
  - A global index covers data in all partitions and is itself partitioned, differently from the primary key index. For example, colors starting with the letters a to r are in partition 0, and those starting with s to z in partition 1.
  - The term being looked up determines the partition of the index. The index can be partitioned by the term itself (useful for range scans) or by a hash of the term (more even distribution).
  - A read only needs to query the partition containing the term, so it is more efficient than scatter/gather.
  - A write is slower and more complicated, because a write to a single document may affect multiple partitions of the index.
{{% /columns %}}

Keeping a global index always up to date would require a distributed transaction across all partitions affected by a write, which not all databases support. **In practice, updates to global secondary indexes are often asynchronous**: if the index is read shortly after a write, the change may not be reflected in it yet. For example, `Amazon DynamoDB` states that its global secondary indexes are normally updated within a fraction of a second, but may experience longer propagation delays when there are faults in the infrastructure. Riak's search feature and Oracle's data warehouse also support global term-partitioned indexes.

---

## Rebalancing Partitions

Over time, things change in a database:
- the query throughput increases, so more CPUs are needed,
- the dataset size increases, so more disks and RAM are needed,
- a machine fails, and other machines need to take over its responsibilities.

> [!NOTE]
> **Rebalancing** is the process of moving load from one node in the cluster to another.

**Minimum requirements for rebalancing:**
- After rebalancing, the load (data storage, read and write requests) should be shared fairly between the nodes in the cluster.
- While rebalancing is happening, the database should continue accepting reads and writes.
- No more data than necessary should be moved between nodes, to make rebalancing fast and to minimize the network and disk I/O load.

---

### Strategies for Rebalancing

{{< tabs "rebalancing" >}}
{{% tab "Hash mod N (avoid)" %}}
Assigning a key to node `hash(key) mod N` looks attractive, but **if the number of nodes N changes, most of the keys have to be moved** from one node to another. For example, a key with `hash(key) = 123456` is on node 6 with 10 nodes, on node 3 with 11 nodes, and on node 0 with 12 nodes. Such frequent moves make rebalancing excessively expensive.
{{% /tab %}}
{{% tab "Fixed number of partitions" %}}
Create **many more partitions than there are nodes** and assign several partitions to each node. For example, a cluster of 10 nodes may be split into 1,000 partitions, so each node holds about 100 of them.

- When a node is added, it steals a few partitions from every existing node until partitions are fairly distributed again. When a node is removed, the reverse happens.
- Only entire partitions are moved between nodes. The number of partitions and the assignment of keys to partitions do not change; only the assignment of partitions to nodes changes. The old assignment is used for reads and writes while the transfer is in progress.
- More powerful nodes can be assigned more partitions.
- Used in `Riak`, `Elasticsearch`, `Couchbase`, and `Voldemort`.
- The number of partitions is usually fixed when the database is first set up and not changed afterwards. It must be high enough to accommodate future growth, but each partition has management overhead. If partitions are very large, rebalancing and recovery from node failures become expensive; if they are too small, they incur too much overhead.
{{% /tab %}}
{{% tab "Dynamic partitioning" %}}
With key range partitioning, a fixed number of partitions with fixed boundaries would be very inconvenient, because wrong boundaries could leave all the data in one partition. Databases such as `HBase` and `RethinkDB` therefore create partitions dynamically:

- When a partition grows beyond a configured size (on HBase, the default is 10 GB), it is **split** into two partitions, so that approximately half of the data ends up on each side.
- If lots of data is deleted and a partition shrinks below a threshold, it can be **merged** with an adjacent partition. This is similar to what happens at the top level of a B-tree.
- After a split, one of the halves can be transferred to another node to balance the load.
- **The number of partitions adapts to the total data volume**, so the overhead stays small when there is little data.
- **Caveat**: an empty database starts with a single partition, so all writes are processed by a single node until the first split. HBase and MongoDB allow an initial set of partitions to be configured on an empty database (`pre-splitting`).
- Dynamic partitioning is suitable for key range partitioned data and also for hash-partitioned data. MongoDB since version 2.4 supports both key-range and hash partitioning and splits partitions dynamically in either case.
{{% /tab %}}
{{% tab "Partitioning proportionally to nodes" %}}
`Cassandra` and `Ketama` make **the number of partitions proportional to the number of nodes**: there is a fixed number of partitions per node (256 by default in Cassandra).

- While the number of nodes stays unchanged, the size of each partition grows proportionally to the dataset size.
- When the number of nodes increases, the partitions become smaller again.
- Larger data volumes generally require a larger number of nodes, so this approach also keeps the size of each partition fairly stable.
- When a new node joins the cluster, it randomly chooses a fixed number of existing partitions to split and takes ownership of one half of each split partition. Randomization can produce unfair splits, but averaged over a larger number of partitions, the new node ends up with a fair share of the load.
- Picking partition boundaries randomly requires hash-based partitioning, and this approach corresponds most closely to the original definition of consistent hashing.
{{% /tab %}}
{{< /tabs >}}

---

### Automatic Versus Manual Rebalancing

There is a gradient between fully automatic rebalancing (the system decides when to move partitions without administrator interaction) and fully manual rebalancing (an administrator explicitly configures the assignment of partitions to nodes). For example, `Couchbase`, `Riak`, and `Voldemort` generate a suggested partition assignment automatically, but an administrator has to commit it before it takes effect.

- Fully automated rebalancing is convenient but unpredictable. Rebalancing is an expensive operation that reroutes requests and moves a large amount of data, so it can overload the network or the nodes and harm the performance of other requests while it is in progress.
- **Automation combined with automatic failure detection can be dangerous.** If one node is overloaded and temporarily slow to respond, the other nodes may conclude that it is dead and rebalance the cluster to move load away from it. This puts additional load on the overloaded node, the other nodes, and the network, and can cause a cascading failure.
- It can therefore be good to have a human in the loop for rebalancing. It is slower than a fully automatic process, but it helps prevent operational surprises.

---

## Request Routing

When a dataset is partitioned across multiple nodes, a client that wants to make a request needs to know which node to connect to. As partitions are rebalanced, the assignment of partitions to nodes changes. This is an instance of a more general problem called **service discovery**, which is not limited to databases: any software that is accessible over a network has this problem, especially if it aims for high availability.

**Request routing approaches:**
1. Clients may contact any node, for example via a round-robin load balancer. If that node owns the partition, it handles the request directly; otherwise, it forwards the request to the appropriate node, receives the reply, and passes it to the client.
2. Clients send all requests to a **routing tier** first, which determines the node that should handle each request and forwards it. The routing tier does not handle any requests itself; it only acts as a partition-aware load balancer.
3. Clients are **aware of the partitioning** and the assignment of partitions to nodes, so they connect directly to the appropriate node without any intermediary.

In all cases, the key problem is how the component making the routing decision (a node, the routing tier, or the client) learns about changes in the assignment of partitions to nodes. All participants must agree, otherwise requests are sent to the wrong nodes. Protocols for achieving consensus in a distributed system are hard to implement correctly.

> [!NOTE]
> **Coordination with ZooKeeper**
>
> Many distributed data systems rely on a separate coordination service such as `ZooKeeper` to keep track of cluster metadata:
> - Each node registers itself in ZooKeeper, and ZooKeeper maintains the authoritative mapping of partitions to nodes.
> - Other actors, such as the routing tier or a partition-aware client, can subscribe to this information in ZooKeeper.
> - Whenever a partition changes ownership, or a node is added or removed, ZooKeeper notifies the routing tier so that it can keep its routing information up to date.
>
> `LinkedIn's Espresso` uses `Helix` for cluster management, which in turn relies on ZooKeeper. `HBase`, `SolrCloud`, and `Kafka` also use ZooKeeper to track partition assignment. `MongoDB` has a similar architecture but relies on its own `config server` implementation and `mongos` daemons as the routing tier.

`Cassandra` and `Riak` take a different approach: they use a `gossip protocol` among the nodes to disseminate any changes in cluster state. Requests can be sent to any node, and that node forwards them to the appropriate node for the requested partition (approach 1). This puts more complexity in the database nodes but avoids the dependency on an external coordination service. `Couchbase` does not rebalance automatically, which simplifies the design; it is normally configured with a routing tier called `moxi`, which learns about routing changes from the cluster nodes.

When using a routing tier or sending requests to a random node, clients still need to find the IP addresses to connect to. These change much less often than the assignment of partitions to nodes, so it is often sufficient to use DNS.

---

### Parallel Query Execution

So far the chapter has focused on very simple queries that read or write a single key, plus scatter/gather queries in the case of document-partitioned secondary indexes. This is about the level of access supported by most NoSQL distributed datastores.

> [!NOTE]
> `Massively parallel processing` (`MPP`) relational database products, often used for analytics, are much more sophisticated in the types of queries they support. A typical data warehouse query contains several join, filtering, grouping, and aggregation operations. The MPP query optimizer breaks this complex query into a number of execution stages and partitions, many of which can be executed in parallel on different nodes of the database cluster. Queries that involve scanning large parts of the dataset particularly benefit from such parallel execution.

---

## Summary

- Partitioning is necessary when there is so much data that storing and processing it on a single machine is no longer feasible. The goal is to spread the data and query load evenly across multiple machines and avoid hot spots.
- Two main approaches to partitioning:
  - **Key range partitioning**: keys are sorted, and a partition owns all the keys from some minimum up to some maximum. Range queries are efficient, but there is a risk of hot spots if the application often accesses keys that are close together in the sorted order. Partitions are typically rebalanced dynamically by splitting a range into two subranges when a partition gets too big.
  - **Hash partitioning**: a hash function is applied to each key, and a partition owns a range of hashes. Range queries become inefficient, but the load may be distributed more evenly. It is common to create a fixed number of partitions in advance, assign several to each node, and move entire partitions when nodes are added or removed. Dynamic partitioning can also be used.
- Hybrid approaches are possible, for example a compound key that uses one part of the key to identify the partition and another part for the sort order.
- Secondary indexes also need to be partitioned:
  - **Document-partitioned indexes** (local indexes) store the secondary index in the same partition as the primary key and value. A write updates only a single partition, but a read of the secondary index requires a scatter/gather across all partitions.
  - **Term-partitioned indexes** (global indexes) partition the secondary index separately, using the indexed values. A read can be served from a single partition, but a write may need to update several partitions of the index.
- Request routing ranges from simple partition-aware load balancing to sophisticated parallel query execution engines.
- By design, every partition operates mostly independently, which is what allows a partitioned database to scale to multiple machines. Operations that need to write to several partitions can be difficult to reason about: what happens if the write to one partition succeeds but another fails?
