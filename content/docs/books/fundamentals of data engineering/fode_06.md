---
weight: 6
title: "06: Storage"
bookHidden: false
---

# Storage
---

Storage is a fundamental component of the data engineering lifecycle and is essential for all its major stages, including ingestion, transformation, and serving. Layers of storage:
{{< columns >}}
**Raw**

- HDD
- SSD     
- RAM
- Networking
- Serialization
- Compression
- CPU

<--->

**Systems**

- HDFS
- RDBMS
- Cache/memory-based storage
- Object storage 
- Streaming storage

<--->

**Abstractions**

- Data lake
- Data platfrom
- Data lakehouse
- Cloud data warehouse

{{< /columns >}}


## Raw Ingredients of Data Storage
---

### Magnetic Disk Drive

`Magnetic disks` store data using a ferromagnetic film that is magnetized by a read/write head. Despite being cheaper than SSDs per gigabyte of stored data, they have limitations such as slower transfer speed, seek time, rotational latency, and lower `input/output operations per second` (IOPS).

`Disk transfer speed`, the rate at which data can be read and written, does not scale in proportion with disk capacity. Data center magnetic drives have a maximum data transfer speed of 200-300 MB/s, meaning it would take over 20 hours to read a 30 TB magnetic drive at a speed of 300 MB/s.

However, they are still used in data centers due to their low storage costs and ability to sustain high transfer rates through `parallelism`.

### Solid-State Drive

`SSDs` store data as charges in flash memory cells, eliminating mechanical components. They can access random data in less than 0.1 ms and support transfer speeds of many gigabytes per second and tens of thousands of IOPS. SSDs are revolutionizing transactional databases, but they are not yet the default option for high-scale analytics data storage due to cost. Commercial SSDs cost nearly 10 times more per capacity than a magnetic drive.

### Random Access Memory

`RAM`, or random access memory, is a high-speed, volatile memory that is mapped into CPU address space and stores the code that CPUs execute and the data that this code directly processes. Data retrieval latency is 1,000 times faster than SSD. However, RAM is significantly more expensive than SSD storage, at roughly $10/GB. Data engineers must always keep in mind the volatility of RAM.

### Networking and CPU

Storage systems are distributed to enhance performance, durability, and availability. Clusters of disks parallelize reads for significant performance scaling. Cloud object storage clusters operate at a much larger scale, with disks distributed across a network and multiple data centers and availability zones.

`Availability zones` in cloud computing provide independent resources to enhance the availability and durability of data. Network device performance and topology are essential for achieving high performance.

### Serialization

Serialization is the process of converting data into a standard format for storage or transmission. Serialization formats, such as XML, JSON, or CSV, provide a standard of data exchange. Databases use row-oriented or columnar serialization. Data engineers should be familiar with popular serialization practices and formats, such as `Apache Parquet` and `Apache Arrow`.

### Compression

`Compression` reduces the size of data, which has three main advantages in storage systems: it takes up less space on disk, increases scan speed, and improves network performance. Disadvantage is increased resource consumption to read or write data due to compression and decompression.

### Caching

`Caching` is the concept of storing frequently or recently accessed data in a fast access layer, while less frequently accessed data is stored in cheaper, slower storage. Most practical data systems rely on many cache layers, ranging from CPU caches to RAM, SSDs, and cloud object storage, each with varying performance characteristics.


| Storage type     | Data fetch latencya | Bandwidth                                     | Price               |
|------------------|---------------------|-----------------------------------------------|---------------------|
| CPU cache        | 1 nanosecond        | 1 TB/s                                        | N/A                 |
| RAM              | 0.1 microseconds    | 100 GB/s                                      | $10/GB              |
| SSD              | 0.1 milliseconds    | 4 GB/s                                        | $0.20/GB            |
| HDD              | 4 milliseconds      | 300 MB/s                                      | $0.03/GB            |
| Object storage   | 100 milliseconds    | 10 GB/s                                       | $0.02/GB per month  |
| Archival storage | 12 hours            | Same as object storage once data is available | $0.004/GB per month |



## Data Storage Systems
---

Storage systems are an abstraction level above raw storage components such as magnetic disks.

### Single Machine Versus Distributed Storage

`Distributed storage` is used to store, retrieve, and process data faster and at a larger scale by coordinating the activities of multiple servers while providing redundancy. It is common in architectures that require scalability and redundancy for large amounts of data, such as object storage, Apache Spark, and cloud data warehouses.

Distributed systems pose a challenge for storage and query accuracy because data is spread across multiple servers. Two common consistency patterns are:

- `Eventual consistency` is a trade-off in large-scale, distributed systems that allows for scaling horizontally to process data in high volumes.
- `Strong consistency`, on the other hand, ensures that writes to any node are first distributed with a consensus and that any reads against the database return consistent values.

`BASE`:
- Basically available: Consistency is not guaranteed, but the database will make a best effort to provide consistent data most of the time.

- Soft-state: The state of the transaction is not well defined, and it's unclear whether it is committed or uncommitted.

- Eventual consistency

### File Storage

File Storage is a finite-length stream of bytes that can be appended to and accessed randomly. File storage systems organize files into a directory tree, with metadata containing information about the entities within each directory. Object storage, on the other hand, supports only finite length. When working with file storage paradigms, it is important to be cautious with state and use ephemeral environments as much as possible. Types:

- `Local disk storage`
- `Network-attached storage (NAS)`
- `Storage area network (SAN)`
- `Cloud filesystem services`


### Block Storage

Block storage is the raw storage provided by SSDs and magnetic disks, and is the standard for virtual machines in the cloud. Blocks are the smallest addressable unit of data on a disk, and transactional databases often rely on direct access to block storage for high random access performance.

`RAID (redundant array of independent disks)` is a technology that uses multiple disks to improve data durability, performance, and capacity. It makes an array of disks appear as a single block device to the operating system.


### Object Storage

Object storage is a type of storage that contains files of different types and sizes. Many cloud data warehouses and data lakes are built on top of object storage (google Cloud Storage, S3). Cloud object storage is easy to manage and considered one of the first "serverless" services. An object store is a key-value store for immutable data objects.


Object storage:
- is `immutable`,
- support extremely performant parallel,
- stores save data in several availability zones,
- separating compute and storage (ephemeral clusters),
- excellent performance for large batch reads and batch writes,
- gold standard of storage for data lakes,
- may be eventually consistent or strongly consistent (after a new version of an object was written under the same key, the object store might sometimes return the old version of the object).


### Cache and Memory-Based Storage Systems

RAM provides fast access and transfer speeds, but is susceptible to data loss in case of power outage. RAM-based storage is mostly used for caching, not for data retention.

### The Hadoop Distributed File System

`Hadoop` breaks files into blocks managed by the NameNode, which maintains metadata and block location. Blocks are replicated to increase durability and availability. Hadoop combines compute and storage resources, using MapReduce for in-place data processing, but other processing models are now more widely used. HDFS remains widely used in various applications and organizations.

### Streaming Storage

Streaming data requires different storage considerations than nonstreaming data. Distributed streaming frameworks like Apache Kafka support long-duration data retention and allow for replaying of stored data.

## Data Storage Abstractions
---

Data engineering storage abstractions are key to organizing and querying data, and are built on top of data storage systems. Key considerations for storage abstractions include:
- purpose,
- update patterns,
- cost,
- and separating storage and compute.

### Data Warehouse

Data warehouses are a standard OLAP data architecture.

```
Evolution:
1. data warehouses atop conventional transactional databases
2. row-based MPP systems
3. columnar MPP systems
4. cloud data warehouses and data platforms
```

Cloud data warehouses handle large amounts of text and complex JSON data, but they cannot manage unstructured data like images, video, and audio. They can be combined with object storage to create a complete data lake solution.

### Data Lake

Data lakes were initially built on Hadoop systems for cheap storage of raw, unprocessed data. However, the trend has shifted towards separating compute and storage and using cloud object storage for long-term retention. Importance of unctionality like schema management and update capabilities, leading to the concept of the data lakehouse.

### Data Lakehouse

`The data lakehouse` combines features of data warehouses and data lakes by storing data in object storage and offering robust table and schema support, incremental update and delete management, and table history and rollback. A lakehouse system is a metadata and file-management layer. Examples: Databricks.


### Stream-to-Batch Storage Architecture

The stream-to-batch storage architecture writes data to multiple consumers, including real-time processing systems and batch storage for long-term retention and queries. Examples: AWS Kinesis Firehose and BigQuery.

## Big Ideas and Trends in Storage
---

### Evolution of lookups

`Indexes` are crucial for fast record lookup in RDBMSs. They are used for primary and foreign keys and can also be applied to other columns for specific applications. However, analytics-oriented storage systems are evolving away from indexes.

Early data warehouses used `row-oriented` RDBMSs. `Columnar-oriented' allows scanning only necessary columns, resulting in faster data access and compression. Columnar databases used to have poor join performance, leading data engineers to denormalize data (today it's not that valid anymore).

`Partitioning` is making a table into multiple subtables based on a field, such as time.

`Clustering` in a columnar database sorts data by one or a few fields, colocating similar values for improved performance

### Data Catalog
A data catalog is a centralized metadata store for all data across an organization. It integrates with various systems and abstractions, allowing users to view their data, queries, and storage.

### Data sharing

`Data sharing` enables organizations and individuals to share specific data with carefully defined permissions.

### Schema

Schema provides information about data structure and organization, even for non-relational data such as images. Two schema patterns exist: schema on write and schema on read. Schema on write enforces data standards, while schema on read allows flexibility in writing data. The former requires a schema metastore, while the latter is best implemented with file formats like Parquet or JSON instead of CSV.

### Separation of Compute from Storage

The separation of compute from storage is now a standard pattern in the cloud era, motivated by scalability and data durability. Hybrid approaches that combine colocation and separation are commonly used, such as multitier caching and hybrid object storage. Apache Spark relies on in-memory storage and distributed filesystems, but separating compute and storage in the cloud allows for renting large quantities of memory and releasing it when the job is done.

### Data retention

Data engineers should consider data retention when deciding what data to keep and for how long

### Single-Tenant Versus Multitenant Storage

Single-tenant architecture dedicates resources to each group of tenants, while multitenant architecture shares resources among groups. Single-tenant storage isolates each tenant's data, such as storing each customer's data in their own database. Multitenant storage allows multiple tenants to reside in the same database, sharing the same schemas or tables.