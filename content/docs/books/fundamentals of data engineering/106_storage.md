---
weight: 6
title: "06: Storage"
bookHidden: true
---

# Storage

Storage is the cornerstone of the data engineering lifecycle and underlies its major stages—ingestion, transformation, and serving.

To understand storage, we’re going to start by studying the raw ingredients that
compose storage systems, including hard drives, solid state drives, and system memory.

Layers of storage:

![[Pasted image 20230304094056.png]]


In practice, we don’t directly access system memory or hard disks. These physical storage components exist inside servers and clusters that can ingest and retrieve data using various access paradigms.

When building data pipelines, engineers choose the appropriate abstractions for storing their data as it moves through the ingestion, transformation, and serving stages.


## Raw Ingredients of Data Storage

Though current managed services potentially free data engineers from the complexities of managing servers, data engineers still need to be aware of underlying components’ essential characteristics, performance considerations, durability, and costs.


In most data architectures, data frequently passes through magnetic storage, SSDs, and memory as it works its way through the various processing phases of a data pipeline.

Let’s look at some of the raw ingredients of data storage: disk drives, memory, networking and CPU, serialization, compression, and caching.

### Magnetic Disk Drive

Magnetic disks utilize spinning platters coated with a ferromagnetic film

This film is magnetized by a read/write head during write operations to physically encode binary data.

The read/write head detects the magnetic field and outputs a bitstream during read operations. Magnetic disk drives have been around for ages. They still form the backbone of bulk data storage systems because they are significantly cheaper than SSDs per gigabyte of stored data.


IBM developed magnetic disk drive technology in the 1950s. Since then, magnetic disk capacities have grown steadily. The first commercial magnetic disk drive, the IBM 350, had a capacity of 3.75 megabytes. As of this writing, magnetic drives storing 20 TB are commercially available.


disk transfer speed, the rate at which data can be read and written, does not scale in proportion with disk capacity.

Disk capacity scales with areal density (gigabits stored per square inch), whereas transfer speed scales with linear density (bits per inch). This means that if disk capacity grows by a factor of 4, transfer speed increases by only a factor of 2. Consequently, current data center drives support maximum data transfer speeds of 200–300 MB/s. To frame this another way, it takes more than 20 hours to read the entire contents of a 30 TB magnetic drive, assuming a transfer speed of 300 MB/s.

A second major limitation is seek time. To access data, the drive must physically relocate the read/write heads to the appropriate track on the disk.


Third, in order to find a particular piece of data on the disk, the disk controller must wait for that data to rotate under the read/write heads. This leads to rotational latency.

A fourth limitation is input/output operations per second (IOPS), critical for transactional databases. A magnetic drive ranges from 50 to 500 IOPS.

magnetic drives remotely competitive with SSDs for random access lookups. SSDs can deliver data with significantly lower latency, higher IOPS, and higher transfer speeds, partially because there is no physically rotating disk or magnetic head to wait for.

As mentioned earlier, magnetic disks are still prized in data centers for their low datastorage costs. In addition, magnetic drives can sustain extraordinarily high transfer rates through parallelism. This is the critical idea behind cloud object storage: data can be distributed across thousands of disks in clusters. Data-transfer rates go up dramatically by reading from numerous disks simultaneously, limited primarily by network performance rather than disk transfer rate. Thus, network components and CPUs are also key raw ingredients in storage systems, and we will return to these topics shortly.


### Solid-State Drive

Solid-state drives (SSDs) store data as charges in flash memory cells. SSDs eliminate the mechanical components of magnetic drives; the data is read by purely electronic means. SSDs can look up random data in less than 0.1 ms (100 microseconds)

In addition, SSDs can scale both data-transfer speeds and IOPS by slicing storage into partitions with numerous storage controllers running in parallel. Commercial SSDs can support transfer speeds of many gigabytes per second and tens of thousands of IOPS.

SSDs have revolutionized transactional databases and are the accepted standard for commercial deployments of OLTP systems. SSDs allow relational databases such as PostgreSQL, MySQL, and SQL Server to handle thousands of transactions per second.

However, SSDs are not currently the default option for high-scale analytics data storage. Again, this comes down to cost. Commercial SSDs typically cost 20–30 cents (USD) per gigabyte of capacity, nearly 10 times the cost per capacity of a magnetic drive. Thus, object storage on magnetic disks has emerged as the leading option for large-scale data storage in data lakes and cloud data warehouses.

SSDs still play a significant role in OLAP systems. Some OLAP databases leverage SSD caching to support high-performance queries on frequently accessed data. As low-latency OLAP becomes more popular, we expect SSD usage in these systems to follow suit.

### Random Access Memory

We commonly use the terms random access memory (RAM) and memory interchangeably RAM has several specific characteristics:

It is attached to a CPU and mapped into CPU address space.
• It stores the code that CPUs execute and the data that this code directly processes.
• It is volatile, while magnetic drives and SSDs are nonvolatile. Though they may
occasionally fail and corrupt or lose data, drives generally retain data when
powered off. RAM loses data in less than a second when it is unpowered.
• It offers significantly higher transfer speeds and faster retrieval times than SSD
storage. DDR5 memory—the latest widely used standard for RAM—offers data
retrieval latency on the order of 100 ns, roughly 1,000 times faster than SSD. A
typical CPU can support 100 GB/s bandwidth to attached memory and millions
of IOPS. (Statistics vary dramatically depending on the number of memory
channels and other configuration details.)
• It is significantly more expensive than SSD storage, at roughly $10/GB (at the
time of this writing).
• It is limited in the amount of RAM attached to an individual CPU and memory
controller. This adds further to complexity and cost. High-memory servers typically
utilize many interconnected CPUs on one board, each with a block of
attached RAM.
• It is still significantly slower than CPU cache, a type of memory located directly
on the CPU die or in the same package. Cache stores frequently and recently
accessed data for ultrafast retrieval during processing. CPU designs incorporate
several layers of cache of varying size and performance characteristics.

When we talk about system memory, we almost always mean dynamic RAM, a high-density, low-cost form of memory

Dynamic RAM stores data as charges in capacitors. These capacitors leak over time, so the data must be frequently refreshed (read and rewritten) to prevent data loss. The hardware memory controller handles these technical details; data engineers simply need to worry about bandwidth and retrieval latency characteristics. Other forms of memory, such as static RAM, are used in specialized applications such as CPU caches.

RAM is used in various storage and processing systems and can be used for caching, data processing, or indexes. Several databases treat RAM as a primary storage layer, allowing ultra-fast read and write performance. In these applications, data engineers must always keep in mind the volatility of RAM. Even if data stored in memory is replicated across a cluster, a power outage that brings down several nodes could cause data loss. Architectures intended to durably store data may use battery backups and automatically dump all data to disk in the event of power loss.


### Networking and CPU

Increasingly, storage systems are distributed to enhance performance, durability, and
availability.

We mentioned specifically that individual magnetic disks offer relatively
low-transfer performance, but a cluster of disks parallelizes reads for significant performance
scaling
While storage standards such as redundant arrays of independent
disks (RAID) parallelize on a single server, cloud object storage clusters operate at
a much larger scale, with disks distributed across a network and even multiple data
centers and availability zones.

Availability zones are a standard cloud construct consisting of compute environments
with independent power, water, and other resources. Multizonal storage enhances
both the availability and durability of data.

CPUs handle the details of servicing requests, aggregating reads, and distributing
writes. Storage becomes a web application with an API, backend service components,
and load balancing. Network device performance and network topology are key
factors in realizing high performance.


### Serialization

The decisions around serialization will inform how well queries perform
across a network, CPU overhead, query latency, and more

Designing a data lake, for example, involves choosing a base storage system (e.g., Amazon S3) and standards for
serialization that balance interoperability with performance considerations

What is serialization, exactly? Data stored in system memory by software is generally
not in a format suitable for storage on disk or transmission over a network. Serialization
is the process of flattening and packing data into a standard format that a reader
will be able to decode. Serialization formats provide a standard of data exchange. We
might encode data in a row-based manner as an XML, JSON, or CSV file and pass
it to another user who can then decode it using a standard library. A serialization
algorithm has logic for handling types, imposes rules on data structure, and allows
exchange between programming languages and CPUs. The serialization algorithm
also has rules for handling exceptions. For instance, Python objects can contain cyclic
references; the serialization algorithm might throw an error or limit nesting depth on
encountering a cycle.

Low-level database storage is also a form of serialization. Row-oriented relational
databases organize data as rows on disk to support speedy lookups and in-place
updates. Columnar databases organize data into column files to optimize for highly
efficient compression and support fast scans of large data volumes. Each serialization
choice comes with a set of trade-offs, and data engineers tune these choices to
optimize performance to requirements.


We suggest that data engineers become familiar with common
serialization practices and formats, especially the most popular current formats (e.g.,
Apache Parquet), hybrid serialization (e.g., Apache Hudi), and in-memory serialization
(e.g., Apache Arrow).

### Compression

Compression is another critical component of storage engineering. On a basic level,
compression makes data smaller, but compression algorithms interact with other
details of storage systems in complex ways.

Highly efficient compression has three main advantages in storage systems. First,
the data is smaller and thus takes up less space on the disk. Second, compression
increases the practical scan speed per disk. With a 10:1 compression ratio, we go from
scanning 200 MB/s per magnetic disk to an effective rate of 2 GB/s per disk.

The third advantage is in network performance. Given that a network connection
between an Amazon EC2 instance and S3 provides 10 gigabits per second (Gbps) of
bandwidth, a 10:1 compression ratio increases effective network bandwidth to 100
Gbps.

Compression also comes with disadvantages. Compressing and decompressing data
entails extra time and resource consumption to read or write data.

### Caching

The core idea of caching
is to store frequently or recently accessed data in a fast access layer. The faster
the cache, the higher the cost and the less storage space available. Less frequently
accessed data is stored in cheaper, slower storage. Caches are critical for data serving,
processing, and transformation.

As we analyze storage systems, it is helpful to put every type of storage we utilize
inside a cache hierarchy (Table 6-1). Most practical data systems rely on many cache
layers assembled from storage with varying performance characteristics. This starts
inside CPUs; processors may deploy up to four cache tiers. We move down the
hierarchy to RAM and SSDs. Cloud object storage is a lower tier that supports
long-term data retention and durability while allowing for data serving and dynamic
data movement in pipelines.

A heuristic cache hierarchy displaying storage types with approximate pricing and
performance characteristics

| Storage type     | Data fetch latencya | Bandwidth                                     | Price               |
|------------------|---------------------|-----------------------------------------------|---------------------|
| CPU cache        | 1 nanosecond        | 1 TB/s                                        | N/A                 |
| RAM              | 0.1 microseconds    | 100 GB/s                                      | $10/GB              |
| SSD              | 0.1 milliseconds    | 4 GB/s                                        | $0.20/GB            |
| HDD              | 4 milliseconds      | 300 MB/s                                      | $0.03/GB            |
| Object storage   | 100 milliseconds    | 10 GB/s                                       | $0.02/GB per month  |
| Archival storage | 12 hours            | Same as object storage once data is available | $0.004/GB per month |


We can think of archival storage as a reverse cache. Archival storage provides inferior
access characteristics for low costs. Archival storage is generally used for data backups
and to meet data-retention compliance requirements. In typical scenarios, this
data will be accessed only in an emergency (e.g., data in a database might be lost and
need to be recovered, or a company might need to look back at historical data for
legal discovery).


## Data Storage Systems

Storage systems exist at a level of abstraction above raw ingredients. For example,
magnetic disks are a raw storage ingredient, while major cloud object storage
platforms and HDFS are storage systems that utilize magnetic disks.

### Single Machine Versus Distributed Storage

As data storage and access patterns become more complex and outgrow the usefulness
of a single server, distributing data to more than one server becomes necessary.
Data can be stored on multiple servers, known as distributed storage.

![[Pasted image 20230304100631.png]]

Distributed storage coordinates the activities of multiple servers to store, retrieve,
and process data faster and at a larger scale, all while providing redundancy in case
a server becomes unavailable. Distributed storage is common in architectures where
you want built-in redundancy and scalability for large amounts of data. For example,
object storage, Apache Spark, and cloud data warehouses rely on distributed storage
architectures.
Data engineers must always be aware of the consistency paradigms of the distributed
systems


### Eventual Versus Strong Consistency

A challenge with distributed systems is that your data is spread across multiple
servers. How does this system keep the data consistent? Unfortunately, distributed
systems pose a dilemma for storage and query accuracy. It takes time to replicate
changes across the nodes of a system; often a balance exists between getting current
data and getting “sorta” current data in a distributed database. Let’s look at two
common consistency patterns in distributed systems: eventual and strong.


We’ve covered ACID compliance throughout this book, starting in Chapter 5.
Another acronym is BASE, which stands for basically available, soft-state, eventual consistency. Think of it as the opposite of ACID. BASE is the basis of eventual consistency.

Basically available
Consistency is not guaranteed, but database reads and writes are made on a
best-effort basis, meaning consistent data is available most of the time.

Soft-state
The state of the transaction is fuzzy, and it’s uncertain whether the transaction is
committed or uncommitted.
Eventual consistency
At some point, reading data will return consistent values.

If reading data in an eventually consistent system is unreliable, why use it? Eventual
consistency is a common trade-off in large-scale, distributed systems. If you want
to scale horizontally (across multiple nodes) to process data in high volumes, then
eventually, consistency is often the price you’ll pay. Eventual consistency allows you
to retrieve data quickly without verifying that you have the latest version across all
nodes.


The opposite of eventual consistency is strong consistency. With strong consistency,
the distributed database ensures that writes to any node are first distributed with a
consensus and that any reads against the database return consistent values. You’ll use
strong consistency when you can tolerate higher query latency and require correct
data every time you read from the database.

Generally, data engineers make decisions about consistency in three places. First, the
database technology itself sets the stage for a certain level of consistency. Second,
configuration parameters for the database will have an impact on consistency. Third,
databases often support some consistency configuration at an individual query level.
For example, DynamoDB supports eventually consistent reads and strongly consistent
reads. Strongly consistent reads are slower and consume more resources, so it is
best to use them sparingly, but they are available when consistency is required.

gathered requirements from your
stakeholders and choose your technologies appropriately.


## File Storage

We deal with files every day, but the notion of a file is somewhat subtle. A file is a
data entity with specific read, write, and reference characteristics used by software
and operating systems.

We define a file to have the following characteristics:
Finite length
A file is a finite-length stream of bytes.

Append operations
We can append bytes to the file up to the limits of the host storage system.
Random access
We can read from any location in the file or write updates to any location.


Object storage behaves much like file storage but with key differences. While we set
the stage for object storage by discussing file storage first, object storage is arguably
much more important for the type of data engineering you’ll do today. We will
forward-reference the object storage discussion extensively over the next few pages.

File storage systems organize files into a directory tree. The directory reference for a
file might look like this:
/Users/matthewhousley/output.txt

The filesystem stores each directory as metadata about the files
and directories that it contains. This metadata consists of the name of each entity,
relevant permission details, and a pointer to the actual entity. To find a file on disk,
the operating system looks at the metadata at each hierarchy level and follows the
pointer to the next subdirectory entity until finally reaching the file itself.


Note that other file-like data entities generally don’t necessarily have all these properties.
For example, objects in object storage support only the first characteristic, finite
length, but are still extremely us


In cases where file storage paradigms are necessary for a pipeline, be careful with
state and try to use ephemeral environments as much as possible. Even if you must
process files on a server with an attached disk, use object storage for intermediate
storage between processing steps.

### Local disk storage

The most familiar type of file storage is an operating system–managed filesystem
on a local disk partition of SSD or magnetic disk.

New Technology File System
(NTFS) and ext4 are popular filesystems on Windows and Linux, respectively

The
operating system handles the details of storing directory entities, files, and metadata.
Filesystems are designed to write data to allow for easy recovery in the event of power
loss during a write, though any unwritten data will still be lost.

Local filesystems generally support full read after write consistency; reading immediately
after a write will return the written data. Operating systems also employ various
locking strategies to manage concurrent writing attempts to a file.

### Network-attached storage

Network-attached storage (NAS) systems provide a file storage system to clients over
a network. NAS is a prevalent solution for servers; they quite often ship with built-in
dedicated NAS interface hardware. While there are performance penalties to accessing
the filesystem over a network, significant advantages to storage virtualization
also exist, including redundancy and reliability, fine-grained control of resources,
storage pooling across multiple disks for large virtual volumes, and file sharing across
multiple machines. Engineers should be aware of the consistency model provided by
their NAS solution, especially when multiple clients will potentially access the same
data.
A popular alternative to NAS is a storage area network (SAN), but SAN systems
provide block-level access without the filesystem abstraction.


### Cloud filesystem services

Cloud filesystem services provide a fully managed filesystem for use with multiple
cloud VMs and applications, potentially including clients outside the cloud environment.

Cloud filesystems should not be confused with standard storage attached
to VMs—generally, block storage with a filesystem managed by the VM operating
system. Cloud filesystems behave much like NAS solutions, but the details of networking,
managing disk clusters, failures, and configuration are fully handled by the
cloud vendor.
For example, Amazon Elastic File System (EFS) is an extremely popular example of
a cloud filesystem service. Storage is exposed through the NFS 4 protocol, which
is also used by NAS systems. EFS provides automatic scaling and pay-per-storage
pricing with no advanced storage reservation required. The service also provides local
read-after-write consistency (when reading from the machine that performed the
write). It also offers open-after-close consistency across the full filesystem. In other
words, once an application closes a file, subsequent readers will see changes saved to
the closed file.


## Block Storage

Fundamentally, block storage is the type of raw storage provided by SSDs and magnetic
disks. In the cloud, virtualized block storage is the standard for VMs. These
block storage abstractions allow fine control of storage size, scalability, and data
durability beyond that offered by raw disks.