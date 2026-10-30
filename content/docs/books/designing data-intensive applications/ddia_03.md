---
weight: 3
title: "03: Storage and Retrieval"
bookHidden: false
---

# Storage and Retrieval
---

*On the most fundamental level, a database needs to do two things: when you give it some data, it should store the data, and when you ask it again later, it should give the data back to you.*

---

Application developers rarely implement a storage engine, but they need to pick one that suits their workload and tune it. Storage engines optimized for transactional workloads differ a lot from those optimized for analytics.

There are two main families of storage engines used in OLTP databases:
1. **Log-structured**: only ever append to files and delete obsolete files, never update a file that has been written. Examples: `Bitcask`, `SSTables`, `LSM-trees`, `LevelDB`, `RocksDB`, `Cassandra`, `HBase`, `Lucene`. They turn random-access writes into sequential writes, which gives higher write throughput.
2. **Update-in-place (page-oriented)**: treat the disk as a set of fixed-size pages that can be overwritten. `B-trees` are the main example, used in all major relational databases and many nonrelational ones.

---

## Data Structures That Power Your Database

### The Simplest Database (Key-Value Store)

```bash
#!/bin/bash

db_set () {
    echo "$1,$2" >> database
}

db_get () {
    grep "^$1," database | sed -e "s/^$1,//" | tail -n 1  # last occurrence wins
}
```

{{% columns %}}
- **Writes**

  Every call to `db_set` appends a line to the end of the file. Old versions of a value are not overwritten; the newest occurrence is the current value.

  Appending to a file is very efficient, and many real databases internally use such a log.

- **Reads**

  Every call to `db_get` scans the entire file from beginning to end to find occurrences of the key.

  Lookup cost is O(n): doubling the number of records doubles the lookup time.
{{% /columns %}}

> [!NOTE]
> **Log** - an append-only sequence of records. It does not have to be human-readable and may be binary.

To find the value for a key efficiently, the database needs an index.

---

### Indexes

> [!NOTE]
> **Index** - an additional structure derived from the primary data. It acts as a signpost that helps locate the data you want.

Adding and removing indexes does not change the contents of the database, only the performance of queries. Indexes are an important trade-off: **well-chosen indexes speed up reads, but every index slows down writes**, because the index must also be updated on every write. For this reason, databases do not index everything by default, and the developer chooses indexes based on the application's typical query patterns.

---

### Hash Indexes

The simplest indexing strategy for an append-only data file is an **in-memory hash map** in which every key is mapped to the byte offset of its latest value in the file. A lookup uses the hash map to find the offset, seeks to that location, and reads the value. A write appends to the file and updates the offset in the hash map.

**This is simple, but it is a viable approach.** `Bitcask`, the default storage engine in `Riak`, works this way. It offers high-performance reads and writes, provided that all keys fit in the available RAM. A value can be loaded with a single disk seek, or no seek at all if it is already in the filesystem cache.

This approach suits workloads where the **value for each key is updated frequently**, but the number of distinct keys is small enough to keep in memory, for example a counter of how many times each video URL was played.

To avoid running out of disk space, the log is broken into `segments` of a certain size. When a segment reaches that size, it is closed and new writes go to a new segment file.

> [!NOTE]
> **Compaction** - throwing away duplicate keys in the log and keeping only the most recent update for each key. Several segments can be compacted and **merged** together in a background thread while reads and writes continue on the old segment files. Afterwards, requests switch to the new merged segment, and the old files are deleted. Each segment has its own in-memory hash map, and a lookup checks the most recent segment first.

Implementation details that matter in practice:

| Issue | Solution |
| ----- | -------- |
| File format | CSV is not the best format. A binary format that first encodes the length of a string in bytes, followed by the raw string, is faster and simpler. |
| Deleting records | Append a special deletion record (`tombstone`). When segments are merged, the tombstone tells the process to discard all previous values for the key. |
| Crash recovery | In-memory hash maps are lost on restart. Rebuilding them by reading every segment is slow, so Bitcask stores a snapshot of each segment's hash map on disk. |
| Partially written records | The database may crash halfway through appending a record. Bitcask files include checksums so that corrupted parts of the log can be detected and ignored. |
| Concurrency control | Writes are appended in strict sequential order, so there is usually only one writer thread. Segments are append-only or immutable, so they can be read concurrently by many threads. |

**Why append-only instead of updating in place?**
- Appending and merging are sequential writes, which are much faster than random writes, especially on magnetic disks and also to some extent on SSDs.
- Concurrency and crash recovery are simpler: a crash cannot leave a file with half of an old value and half of a new one.
- Merging old segments avoids data files becoming fragmented over time.

**Limitations of the hash table index:**
- The hash table must fit in memory. On-disk hash maps are hard to make perform well because they need a lot of random-access I/O.
- Range queries are not efficient. Scanning all keys between `kitty00000` and `kitty99999` requires looking up each key individually.

---

### SSTables and LSM-Trees

A `Sorted String Table` (`SSTable`) is a segment file format in which the key-value pairs are **sorted by key**, and each key appears only once within each merged segment file.

**Advantages over log segments with hash indexes:**
1. **Merging is simple and efficient**, even if the files are bigger than memory. It works like the merge step of mergesort: read the input files side by side and copy the lowest key to the output file. If the same key appears in several segments, the value from the most recent segment wins.
2. **The index can be sparse.** The database no longer needs to keep all keys in memory. One key for every few kilobytes of segment file is enough, because the database can jump to the nearest known offset and scan from there.
3. **Blocks can be compressed.** Records between two sparse index entries can be grouped into a block and compressed before being written to disk, which saves disk space and I/O bandwidth.

**Constructing and maintaining SSTables:**
- When a write comes in, it is added to an in-memory balanced tree (for example a red-black tree or an AVL tree), called the `memtable`.
- When the memtable grows bigger than a threshold (typically a few megabytes), it is written to disk as a new SSTable file. Because the tree already keeps keys sorted, this is efficient. The new file becomes the most recent segment.
- A read first checks the memtable, then the most recent on-disk segment, then the next older segment, and so on.
- From time to time, a background process merges and compacts segment files and discards overwritten or deleted values.
- To survive a crash, every write is also appended to a separate log on disk. Its only purpose is to restore the memtable after a crash, and it is discarded every time the memtable is written out as an SSTable.

This algorithm is used in `LevelDB`, `RocksDB`, `Cassandra`, and `HBase`, all of which were inspired by Google's `Bigtable` paper, which introduced the terms SSTable and memtable. The indexing structure was originally described by Patrick O'Neil and colleagues as the `Log-Structured Merge-Tree` (`LSM-tree`). `Lucene`, the full-text indexing engine used by `Elasticsearch` and `Solr`, uses a similar method to store its term dictionary.

**Performance optimizations:**
- **Bloom filters**: looking up a key that does not exist requires checking the memtable and every segment. A Bloom filter is a memory-efficient structure that can tell for certain that a key does not appear in the database, which saves many unnecessary disk reads.
- **Compaction strategies**: in `size-tiered` compaction (HBase, Cassandra), newer and smaller SSTables are merged into older and larger ones. In `leveled` compaction (LevelDB, RocksDB, Cassandra), the key range is split into smaller SSTables, and older data is moved into separate levels, so compaction can proceed more incrementally and use less disk space.

The basic idea of LSM-trees, keeping a cascade of SSTables that are merged in the background, is simple and effective. It works well even when the dataset is much bigger than memory, supports efficient range queries, and sustains remarkably high write throughput because disk writes are sequential.

---

### B-Trees

`B-trees`, introduced in 1970, are the most widely used indexing structure. Like SSTables, they keep key-value pairs sorted by key, which allows efficient key lookups and range queries. Otherwise, the design is very different.

- The database is broken down into fixed-size **pages** (traditionally 4 KB), and one page is read or written at a time. This corresponds closely to the underlying hardware, where disks are also arranged in fixed-size blocks.
- Each page can be identified by its address, so one page can refer to another, like a pointer but on disk.
- One page is the **root**. A lookup starts there and follows the references for the right key range down to a **leaf page**, which contains the value or a reference to where the value is stored.
- The number of references to child pages in one page is the `branching factor`, typically several hundred.
- **Update**: search for the leaf page that contains the key, change the value in that page, and write the page back to disk.
- **Insert**: find the page whose range contains the new key and add it. If there is not enough free space, the page is **split** into two half-full pages, and the parent page is updated to account for the new subdivision of key ranges.

The algorithm keeps the tree **balanced**: a B-tree with *n* keys always has a depth of O(log *n*). Most databases fit into a B-tree that is three or four levels deep. A four-level tree of 4 KB pages with a branching factor of 500 can store up to 256 TB.

**Making B-trees reliable:**
- The basic write operation **overwrites a page on disk in place**, and the location of the page does not change. This contrasts with LSM-trees, which only append to files and never modify them in place.
- Some operations overwrite several pages, for example a page split. A crash in the middle could leave a corrupted index, such as an orphan page without a parent. To handle this, B-tree implementations include a `write-ahead log` (`WAL`, also known as a `redo log`): an append-only file to which every modification is written before it is applied to the pages of the tree.
- Concurrent access by multiple threads requires careful concurrency control, typically with `latches` (lightweight locks) that protect the tree's data structures.

**B-tree optimizations:**
- Instead of a WAL, some databases (such as `LMDB`) use a `copy-on-write` scheme: a modified page is written to a new location, and new versions of the parent pages point to it. This is also useful for concurrency control.
- Pages can store abbreviated keys, which allows a higher branching factor and fewer levels. This variant is sometimes known as a `B+ tree`.
- Many implementations try to lay out leaf pages in sequential order on disk, which helps range queries. This is hard to maintain as the tree grows, while LSM-trees achieve it naturally during merging.
- Leaf pages can have references to their sibling pages, so keys can be scanned in order without jumping back to parent pages.
- Variants such as `fractal trees` borrow some log-structured ideas to reduce disk seeks.

---

### Comparing B-Trees and LSM-Trees

As a rule of thumb, **LSM-trees are typically faster for writes, whereas B-trees are thought to be faster for reads**. Reads are typically slower on LSM-trees because they have to check several data structures and SSTables at different stages of compaction. Benchmarks are often inconclusive, so the choice should be tested with the actual workload.

| | LSM-trees | B-trees |
| --- | --- | --- |
| **Write amplification** | Usually lower. Data is rewritten during compaction, but writes are sequential. | Every write goes at least twice to disk (WAL and tree page), and a whole page is written even if only a few bytes changed. |
| **Write throughput** | Higher, because SSTable files are written sequentially. This matters especially on magnetic hard drives. | Lower, because pages are overwritten at random locations. |
| **Disk space and compression** | Better compression, smaller files on disk, and less fragmentation because SSTables are periodically rewritten. | Some disk space stays unused because of fragmentation when pages are split. |
| **Response time** | Compaction can interfere with ongoing reads and writes, so high percentiles can be quite high. | More predictable performance. |
| **Behavior at high write rates** | Compaction may fail to keep up with incoming writes, so the number of unmerged segments grows until disk space runs out. This needs explicit monitoring. | Not affected by a background compaction process. |
| **Transactions** | A key may exist in several segments. | Each key exists in exactly one place in the index, which makes strong transactional semantics easier: range locks can be attached directly to the tree. |

> [!NOTE]
> **Write amplification** - one write to the database resulting in multiple writes to disk over the lifetime of the database. It matters especially on SSDs, which can only overwrite blocks a limited number of times before wearing out. In write-heavy applications, the bottleneck may be the rate at which the database can write to disk, so write amplification has a direct performance cost.

B-trees are very ingrained in the architecture of databases and provide consistently good performance for many workloads, so they are unlikely to go away. In new datastores, log-structured indexes are becoming increasingly popular.

---

### Other Indexing Structures

**Secondary indexes** are crucial for performing joins efficiently. In relational databases, many secondary indexes can be created on the same table with the `CREATE INDEX` command. The main difference from a primary key index is that **secondary keys are not unique**: many rows can have the same key. This is solved either by making each value in the index a list of matching row identifiers or by making each key unique by appending a row identifier to it. Both B-trees and log-structured indexes can be used as secondary indexes.

**Storing values within the index:**
- `Heap file`: the index stores a reference to the row, and the rows themselves are stored in an unordered heap file. Several secondary indexes can refer to the same row without duplicating data. If an updated value no longer fits in its place, it is moved, and either all indexes are updated or a forwarding pointer is left behind.
- `Clustered index`: the indexed row is stored directly within the index. In MySQL's `InnoDB`, the primary key is always a clustered index, and secondary indexes refer to the primary key. In SQL Server, one clustered index per table can be specified.
- `Covering index` (`index with included columns`): a compromise that stores some of a table's columns within the index, so some queries can be answered using the index alone.

Clustered and covering indexes speed up reads, but they need additional storage and add overhead on writes. Duplicating data also requires extra effort to keep transactional guarantees.

**Multi-column indexes:**
- `Concatenated index`: combines several fields into one key by appending one column to another, like an old-fashioned phone book sorted by (last name, first name). It is useless for finding all people with a particular first name.
- `Multi-dimensional indexes`: needed for queries over several columns at once, for example finding all restaurants within a rectangular map area by latitude and longitude. A standard B-tree or LSM-tree cannot answer this efficiently. Specialized spatial indexes such as `R-trees` are used, for example in `PostGIS`. The same approach helps with queries such as all weather observations in a date range with a temperature range.

**Full-text search and fuzzy indexes:**
- Full-text search engines can expand a search to synonyms, ignore grammatical variations of words, and search for words near each other.
- `Lucene` can search text for words within a certain edit distance (for example, one letter added, removed, or replaced). Its in-memory index is a finite state automaton over the characters in the keys, similar to a trie, which can be turned into a `Levenshtein automaton`.

---

### Keeping Everything in Memory

As RAM becomes cheaper, keeping entire datasets in memory becomes feasible, potentially distributed across several machines.
- Some in-memory key-value stores, such as `Memcached`, are intended for caching only, and losing data on restart is acceptable.
- Others aim for durability with battery-powered RAM, a log of changes on disk, periodic snapshots, or replication to other machines. Examples: `VoltDB`, `MemSQL`, `Oracle TimesTen` (relational), `RAMCloud` (key-value), and `Redis` and `Couchbase`, which provide weak durability by writing to disk asynchronously.

> [!WARNING]
> **In-memory databases are not faster because they avoid reading from disk.** A disk-based engine may never read from disk if there is enough memory, because the operating system caches recently used disk blocks. They are faster because they avoid the overhead of encoding in-memory data structures into a form that can be written to disk.

In-memory databases can also offer data models that are difficult to implement with disk-based indexes, such as the priority queues and sets of Redis. The `anti-caching` approach extends the in-memory design to datasets larger than memory by evicting the least recently used data to disk and loading it back when it is accessed.

---

## Transaction Processing or Analytics?

> [!NOTE]
> **Transaction** - a group of reads and writes that form a logical unit. Transaction processing does not necessarily mean ACID properties. It means allowing clients to make low-latency reads and writes, as opposed to batch processing jobs that run periodically. This access pattern became known as `online transaction processing` (`OLTP`).

Analytic queries scan over a huge number of records, read only a few columns per record, and calculate aggregate statistics such as counts, sums, or averages. This access pattern is called `online analytic processing` (`OLAP`).

| Property | OLTP (transaction processing) | OLAP (analytic systems) |
| -------- | ----------------------------- | ----------------------- |
| **Main read pattern** | Small number of records per query, fetched by key | Aggregate over a large number of records |
| **Main write pattern** | Random-access, low-latency writes from user input | Bulk import (ETL) or event stream |
| **Primarily used by** | End user or customer, via a web application | Internal analyst, for decision support |
| **What data represents** | Latest state of data (current point in time) | History of events that happened over time |
| **Dataset size** | Gigabytes to terabytes | Terabytes to petabytes |
| **Typical bottleneck** | Disk seek time | Disk bandwidth |

---

### Data Warehousing

> [!NOTE]
> **Data warehouse** - a separate database that analysts can query to their heart's content without affecting OLTP operations. It contains a read-only copy of the data from all the various OLTP systems in the company.

OLTP systems are expected to be highly available and to process transactions with low latency, so database administrators are reluctant to let analysts run expensive ad hoc queries on them. Data is extracted from the OLTP databases (with periodic data dumps or a continuous stream of updates), transformed into an analysis-friendly schema, cleaned up, and loaded into the warehouse. This process is called `Extract-Transform-Load` (`ETL`).

The data model of a warehouse is usually relational, because SQL is generally a good fit for analytic queries. On the surface, a data warehouse and a relational OLTP database look similar, but their internals are optimized for very different query patterns.
- Commercial warehouse vendors: `Teradata`, `Vertica`, `SAP HANA`, `ParAccel`. `Amazon Redshift` is a hosted version of ParAccel.
- Open source SQL-on-Hadoop projects: `Apache Hive`, `Spark SQL`, `Cloudera Impala`, `Facebook Presto`, `Apache Tajo`, `Apache Drill`.

---

### Stars and Snowflakes: Schemas for Analytics

Many data warehouses use a `star schema` (also known as `dimensional modeling`):
- At the center is a **fact table**. Each row represents an event that occurred at a particular time, such as a customer's purchase of a product. Facts are captured as individual events, which gives maximum flexibility for later analysis. The fact table can become extremely large: big enterprises have tens of petabytes of transaction history.
- Some columns in the fact table are attributes, such as the price. Other columns are foreign key references to **dimension tables**, which represent the *who*, *what*, *where*, *when*, *how*, and *why* of the event, for example the product, the store, or the date.
- Even date and time are often represented as dimension tables, so that additional information such as public holidays can be encoded.

A `snowflake schema` is a variation in which dimensions are further broken down into subdimensions, for example a separate table for brands referenced by the products table. Snowflake schemas are more normalized, but star schemas are often preferred because they are simpler for analysts to work with.

Tables in a typical data warehouse are very **wide**: fact tables often have over 100 columns, sometimes several hundred.

---

## Column-Oriented Storage

A typical analytic query accesses only 4 or 5 columns of a fact table with more than 100 columns. In a row-oriented storage engine, all values of a row are stored next to each other, so the engine has to load every row from disk, parse it, and filter out the columns it does not need. With trillions of rows, this takes a long time.

The idea of **column-oriented storage** is simple: do not store all the values from one row together, but store all the values from each **column** together in a separate file. A query reads and parses only the columns it uses. Column storage relies on every column file containing the rows **in the same order**: the 23rd entry in each column file belongs to the 23rd row. `Parquet` is a columnar storage format, based on Google's Dremel, that also supports a document data model.

> [!CAUTION]
> **Column families are not column-oriented storage.** `Cassandra` and `HBase` have a concept of column families inherited from Bigtable, but within each column family they store all columns of a row together, along with a row key, and they do not use column compression. The Bigtable model is still mostly row-oriented.

---

### Column Compression

Column-oriented storage often lends itself very well to compression, because the sequence of values in a column is often repetitive.

- **Bitmap encoding**: a column often has few distinct values compared to the number of rows (for example, a retailer may have billions of sales transactions but only 100,000 distinct products). Each distinct value gets a bitmap with one bit per row. Sparse bitmaps can be further **run-length encoded**, which makes them remarkably compact.
- Bitmap indexes are well suited to common warehouse queries: `WHERE product_sk IN (30, 68, 69)` becomes a bitwise OR of three bitmaps, and conditions on two different columns become a bitwise AND.

**Memory bandwidth and vectorized processing:** besides the bandwidth for getting data from disk into memory, the bandwidth from main memory into the CPU cache matters, as do branch mispredictions and bubbles in the CPU instruction pipeline. Column storage is good for CPU cycles: a chunk of compressed column data that fits in the L1 cache can be iterated through in a tight loop without function calls. Operators such as bitwise AND and OR can work directly on chunks of compressed column data. This technique is known as `vectorized processing`.

---

### Sort Order in Column Storage

The order of rows does not necessarily matter, so the rows can be sorted, and the database administrator can choose the columns to sort by based on common queries.
- The columns cannot be sorted independently: an entire row must be sorted at a time, otherwise it is impossible to know which values belong together.
- If queries often target date ranges, the date is a good first sort key. A second sort key determines the order of rows that have the same value in the first column.
- Sorting helps compression: the first sort column, with long runs of repeated values, compresses extremely well with run-length encoding.
- **Several different sort orders**: the data must be replicated to several machines anyway, so each replica can store it sorted in a different way. The query engine then picks the version that best fits the query. This idea was introduced in `C-Store` and adopted by `Vertica`. It differs from multiple secondary indexes in a row-oriented store, because column stores have no pointers to data elsewhere, only columns containing values.

---

### Writing to Column-Oriented Storage

Column storage, compression, and sorting make reads faster but writes more difficult.
- **In-place updates** like those of B-trees are not possible with compressed columns. Inserting a row in the middle of a sorted table would most likely require rewriting all the column files.
- The solution is the **LSM-tree** approach: all writes first go to an in-memory store, where they are added to a sorted structure. When enough writes have accumulated, they are merged with the column files on disk and written to new files in bulk. `Vertica` does this.
- Queries need to examine both the column data on disk and the recent writes in memory and combine the two, but the query optimizer hides this distinction from the user.

---

### Aggregation: Data Cubes and Materialized Views

Data warehouse queries often involve aggregate functions such as `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX`. If the same aggregates are used by many queries, they can be cached.

> [!NOTE]
> **Materialized view** - an actual copy of the query results written to disk. A virtual view is just a shortcut for writing queries.

When the underlying data changes, a materialized view needs to be updated. This makes writes more expensive, which is why materialized views are not often used in OLTP databases. In read-heavy data warehouses, they can make more sense.

A `data cube` (`OLAP cube`) is a common special case: a grid of aggregates grouped by different dimensions, for example the total sales per date and per product. Each dimension can then be summarized further.
- **Advantage**: certain queries become very fast because they have effectively been precomputed.
- **Disadvantage**: a data cube does not have the flexibility of querying the raw data. For example, the share of sales from items that cost more than $100 cannot be calculated, because price is not one of the dimensions. Most warehouses therefore keep as much raw data as possible and use aggregates only as a performance boost for certain queries.

---

## Summary

- **OLTP systems** are typically user-facing and see a huge volume of requests. Each query touches a small number of records, which are found by key using an index. **Disk seek time** is often the bottleneck.
- **Data warehouses and analytic systems** handle fewer queries, but each query is very demanding and scans millions of records. **Disk bandwidth** is often the bottleneck, and column-oriented storage is an increasingly popular solution.
- On the OLTP side, there are two main schools of storage engines:
  - **Log-structured**: only append to files and delete obsolete files (Bitcask, SSTables, LSM-trees, LevelDB, Cassandra, HBase, Lucene).
  - **Update-in-place**: treat the disk as a set of fixed-size pages that can be overwritten (B-trees).
- In analytic workloads, the important factor is encoding data very compactly to minimize the amount of data the query needs to read from disk.
