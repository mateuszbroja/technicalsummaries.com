---
weight: 6
title: "06: Partitioning"
bookHidden: false
---

# Partitioning
---

*Clearly, we must break away from the sequential and not limit the computers. We must state definitions and provide for priorities and descriptions of data. We must state relationships, not procedures.*

## Overview

{{< hint warning >}}
**Replication** involves breaking data into `partitions` or `sharding`. Each partition functions as a standalone database. The division is not `logical` but `physical`.
{{< /hint >}}

**Partitioning** is mainly for `scalability`, allowing query load distribution across multiple processors, thereby improving `throughput` by adding more nodes. It becomes necessary when data volume makes single-machine storage and processing unfeasible.

**Principles of partitioning:**
- Balance data and query load across machines.
- Prevent hot spots by distributing load evenly.
- Use an appropriate partitioning scheme.
- Rebalance partitions when modifying cluster nodes.

---
### Partitioning and Replication

While each record exclusively belongs to one partition, it can be stored across several nodes for fault tolerance. Additionally, a single node may house multiple partitions.

Importantly, **partitioning strategies and replication methodologies are mostly independent**, facilitating their separate consideration.

---
## Partitioning Methods

A straightforward approach is random record assignment to nodes, but it has a major disadvantage: there's no way to predict on which node a particular item resides, necessitating parallel querying on all nodes. Because of that, we are using different methods.

### Key Range Partitioning

{{< hint warning >}}
**Key Range Partitioning** keys are sorted and assigned to a partition that owns all keys from a specified minimum to maximum.
{{< /hint >}}

This method facilitates efficient range queries, but may risk `hot spots` if keys in the sorted order are accessed frequently.

Partitions can be dynamically re-balanced by splitting the range into two sub-ranges when a partition becomes too large.

### Hash Partitioning

{{< hint warning >}}
**Hash partitioning** involves applying a hash function to each key, with a partition owning a range of hashes.
{{< /hint >}}

A downside is the loss of efficient range queries, as keys once adjacent become scattered across all partitions. Consequently, any range query must be sent to all partitions. But it can distribute load more evenly.

`MongoDB` uses `MD5` and `Cassandra` uses `Murmur3`. Each partition can be assigned a range of hashes, with boundaries evenly spaced or chosen pseudo-randomly (`consistent hashing`).

---

### Skewed Workloads and Relieving Hot Spots

Partitioning aims to evenly distribute data and query load across nodes.

{{< hint warning >}}
An uneven partition is referred to as **skewed**, making partitioning less effective. A partition with disproportionately high load is a **hot spot**.
{{< /hint >}}

`Hot spots` cannot be completely avoided, especially when there's a high volume of writes targeting the same key.

The application is responsible for reducing skew. One basic technique involves appending or prepending a random number to the key. Although splitting writes across different keys can help, it results in extra work for reads, which now have to combine data from these various keys.

---
## Partitioning and Secondary Indexes

In key-value data models, partitioning by the primary key facilitates efficient routing of read/write requests.

However, when dealing with secondary indexes, the situation gets complex:
- Unlike primary keys, secondary indexes do not provide a unique identifier for records.
- It's crucial to handle mapping to ensure efficient data distribution and retrieval.

---

### Document-Partitioned Indexes

- Secondary indexes are stored in the same partition as the primary key and value (`local index`).
- Only a single partition needs to be updated on write.
- A read of the secondary index requires a scatter/gather across all partitions.
- Efficient writes but inefficient reads.

`MongoDB`, `Riak`, `Cassandra`, `Elasticsearch`, `SolrCloud`, and `VoltDB` utilize document-partitioned secondary indexes.

---

### Term-Partitioned Indexes

- Secondary indexes are partitioned separately, using the indexed values (`global index`).
- An entry in the secondary index may include records from all partitions of the primary key.
- When a document is written, several partitions of the secondary index need to be updated.
- A read can be served from a single partition.
- Efficient reads but slower and more complex writes.

---

## Re-balancing Partitions

{{< hint warning >}}
**Rebalancing** in a database refers to the process of redistributing data and requests from one node to another within a cluster. This is typically done to **accommodate changes in query throughput, dataset size, or to address the failure of a machine**. 
{{< /hint >}}

Strategies of rebalancing include:

1. **`Hash mod n`**: Not advisable as changing the number of nodes results in most keys being moved.
2. **Fixed number of partitions**: More partitions than nodes are created, and several partitions are assigned to each node. As nodes are added, partitions are reassigned.
3. **Dynamic partitioning**: Number of partitions adapts to the total data volume. As the dataset grows, more partitions are created.
4. **Partitioning proportionally to nodes**: Fixed number of partitions per node, keeps size of each partition fairly stable.

---

### Automatic vs Manual Rebalancing

- Automatic rebalancing can cause operational load and impact performance.
- Manual rebalancing allows for more operational control.

---

## Request Routing

When datasets are partitioned across multiple nodes and machines, the question arises: how does a client know which node to connect to, especially as partition assignments to nodes change due to rebalancing?

This problem, known as service discovery, is not limited to databases but affects any network-accessible software aiming for high availability.

**Several request routing approaches exist:**
1. Clients may contact any node.
2. Clients' requests are first routed through a routing tier.
3. Clients are made aware of partitioning and assignment of partitions to nodes.

Regardless of the method, one challenge persists: how does the entity making the routing decision (a node, routing tier, or the client) keep updated about changes in partition assignments to nodes? Many distributed systems utilize a separate coordination service like `ZooKeeper` to maintain cluster metadata.

{{< hint info >}}
`ZooKeeper` acts as a centralized service for maintaining configuration information, naming, and providing distributed synchronization. Each node registers itself with `ZooKeeper`, which then holds the authoritative mapping of partitions to nodes.

**Key aspects of `ZooKeeper`:**
- Other components, like the routing tier or the partitioning-aware client, can subscribe to `ZooKeeper` for changes.

- When there's a change in partition ownership, or when a node is added or removed, ZooKeeper notifies the subscribers.

- This ensures the routing information is always up-to-date, aiding efficient request routing.
{{< /hint >}}

---

### Parallel Query Execution

Most NoSQL distributed datastores primarily support simple queries involving single key read or write operations. This level of access meets the requirements of many use cases. However, more complex query patterns and advanced data manipulation operations may necessitate additional features and capabilities beyond basic key-based access. This can be provide by `MPP`.

{{< hint warning >}}
`Massively parallel processing` (`MPP`) relational database products support sophisticated types of queries that run across multiple nodes.
{{< /hint >}}