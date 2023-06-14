---
weight: 3
title: "03: Storage and Retrieval"
bookHidden: false
---

# Storage and Retrieval
---

*On the most fundamental level, a database needs to do two things: when you give it some data, it should store the data, and when you ask it again later, it should give the data back to you.*

---
## Data Structures That Power OLTP Databases

There are two main families of storage engines commonly used in OLTP:
1. **Log-structured**: More recent invention, only allows appending to files and deleting obsolete files. Examples include `Bitcask`, `SSTables`, `LSM-trees`, `LevelDB`, `Cassandra`, `HBase`, `Lucene`. Log-structured storage engines optimize writes by converting random-access writes into sequential writes, resulting in higher write throughput.

2. Update-in-place (**page-oriented**): Treats the disk as fixed-size pages that can be overwritten. `B-trees` are a common example used in relational and nonrelational databases.

---
### Simplest database (key-value store)

```bash
#!/bin/bash

db_set () {
	echo "$1,$2" >> database
}

db_get () {
	grep "^$1," database | sed -e "s/^$1,//" | tail -n 1 # last occurrence
}
```

{{< columns >}}
**Writes**

Every call to `db_set` appends to the end of the file, preserving previous versions of the value (log).

Appending to a file is efficient, since append to a log is the simplest way to writing something to db.

<--->

**Reads**

Every call to `db_get` scans the entire database file from beginning to end in order to find occurrences of the key.

The performance of lookups is poor, with a time complexity of O(n). As the number of records in the database increases, the lookup time also increases proportionally.
{{< /columns >}}


{{< hint warning >}}
**Log** - append-only sequence of records.
{{< /hint >}}

To efficiently retrieve the value of a specific key in the database, an index is required.

---
## Indexes

{{< hint warning >}}
**Indexes** - additional structures (metadata) derived from the primary data that help in locating specific data efficiently. They act as signposts and improve the performance of queries.
{{< /hint >}}

Adding and removing indexes has no impact on the contents of the database, but it affects query performance. Indexes provide a trade-off, speeding up read queries while slowing down writes due to the need for index updates during data writes.

---
### Hash indexes

The simplest indexing strategy is to use an in-memory hash map where each key is mapped to a byte offset in the data file. This allows quick lookup of values by seeking to the corresponding offset in the file. When new key-value pairs are appended to the file, the hash map is updated to reflect the new offsets.

**Simple, but it is a effective solution**. `Bitcask`, the default storage engine in `Riak`, uses a similar approach, requiring that all the keys fit in the available RAM

If you keep a hash map in the RAM, it is well suited to situations where the **value for each key is updated frequently**, but the overall number of distinct keys is smaller (to fit into memory). To avoid running out of space, we can segment the logs and use `compaction`.

{{< hint warning >}}
**Compaction** - involves discarding duplicate keys in the log and retaining only the most recent update for each key.
{{< /hint >}}

Issues with implementing a log-structured engine with hash indexes include:

| Issue                     | Description                                                                                                                                                             |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| File format               | Use a binary format that includes the length of a string in bytes (CSV not preferable).                                                                                                      |
| Crash recovery            | In-memory hash maps are lost if the database is restarted, requiring a rebuild of the index.                                                                            |
| Partially written records | The database may crash during the process of appending a record to the log, leading to incomplete or corrupt data.                                                      |
| Concurrency control       | While writes are typically sequential with a single writer thread, multiple threads can read concurrently from immutable data file segments.                            |
| Memory limitations        | The hash table must fit in memory, making it challenging to handle a large number of keys.                                                                             |
| Inefficient range queries | Scanning over a range of keys requires individual lookups in the hash maps, making range queries less efficient.                                                       |

---
### SSTables and LSM-Trees

The Sorted String Table (`SSTable`) is a storage engine where key-value pairs are sorted by key. It enables index-free lookup, eliminating the need to keep an index of all keys in memory. The idea of using `SSTables` in storage engines is seen in systems like `Cassandra` and `HBase`, which were inspired by Google's Bigtable paper.

`SSTables` are often used in `LSM-trees`, where a cascade of `SSTables` is merged in the background. This approach allows for high write throughput as disk writes are sequential.

---
### B-Trees

`B-trees` are widely used indexing structures that keep key-value pairs sorted by key, allowing for efficient lookups and range queries. They organize the database into fixed-size blocks or pages, with one designated as the root. Updates and additions are performed by searching for the relevant leaf page, modifying the value, and updating the parent page if necessary.

`B-trees` maintain balance, ensuring a logarithmic depth. Write operations involve overwriting pages on disk, and careful concurrency control is needed for multi-threaded access. A write-ahead log (WAL) is often used for crash recovery.

| LSM-trees       | B-trees     |
|-----------------|-------------|
| Faster writes   | Faster reads |
| Higher throughput | Strong semantics |
| Lower write amplification | Predictable performance |
| Better compression  | Lock-based isolation |
| Impact from compaction | Attached locks |
| Disk space requirements | Key-based locks |
| Configuration impact | |


`B-trees` and `log-structured indexes` are both popular storage engines with their own advantages. `B-trees` offer consistent performance and are widely used, while log-structured indexes provide higher write throughput and better compression. The choice depends on the use case and should be tested empirically.

---
### Other Indexing Structures

**Secondary indexes** are crucial for efficient joins and improved query performance in databases. In relational databases, you can create multiple secondary indexes on a table using the `CREATE INDEX` command.

- `R-Trees`: Geospatial indexes (e.g., `PostGIS`)
- `Fuzzy indexes`: Full-text search (e.g., `Lucene`, `ElasticSearch`)
- Storing indexes:
	- `Heap Files`: Index key maps to pointer in heap file
	- `Clustered Index`: Data stored directly in the index (e.g., `MySQL`'s `InnoDB`)
	- `Covering Index`: Data split between index and heap files
	- `Concatenated Index`: Indexing on multiple columns by concatenating keys

---
## Transaction Processing or Analytics?

|   | OLTP (Transaction Processing) | OLAP (Analytics)               |
|-----------|-----------------------------|-------------------------------|
| **Use**       | Handling high volumes of user-facing requests | Analyzing large amounts of data |
| **Access**    | Small number of records accessed | Large number of records scanned |
| **Indexing**  | Relies on indexes | Less reliant on indexes |
| **Bottleneck** | Disk seek time | Disk bandwidth |
| **Query**     | Key-based queries | Scanning large numbers of rows |
| **Updates**   | Frequent and concurrent updates | Fewer queries, but more demanding |
| **Purpose**   | Low latency and high throughput | Fast query performance and data analysis |
| **Examples**  | Online shopping, banking, e-commerce applications | Business intelligence, data warehousing |
| **Technologies** | `MySQL`, `LevelDB`, `Cassandra`, `HBase`, `Lucene` | `Hive`, `Presto`, `Spark`, `Redshift` |

{{< hint warning >}}
**Transaction** - group of reads and writes that form a logical unit, this pattern became known as online transaction processing (OLTP).

{{< /hint >}}

{{< hint warning >}}
**Data warehouse** - separate database that analysts can query to their heart's content without affecting OLTP operations.
{{< /hint >}}

Data warehouses follow a **star schema**, where facts are captured as individual events, providing flexibility for analysis. The **fact table** can grow to be very large. **Dimensions** in data warehouses represent various attributes related to the event, such as `who`, `what`, `where`, `when`, `how`, and `why`.

---
### Column-Oriented Storage

- Column-oriented storage improves query performance by efficiently retrieving relevant columns.
- It reduces storage requirements through effective compression techniques.
- Bitmap encoding and indexing are well-suited for various query types in column-oriented storage.
- Vectorized processing optimizes CPU utilization.
- `LSM trees` are commonly used for indexes in column-oriented storage.
- Writes can be slower due to the lack of in-place updates and the need to rewrite column files.

`Cassandra` and `HBase` utilize column families inherited from Bigtable.

{{< hint warning >}}
Materialized aggregates, such as materialized views and **data cubes**, enhance query performance but require additional maintenance during writes.
{{< /hint >}}