---
weight: 10
title: "10: Batch Processing"
bookHidden: false
---

# Batch Processing
---

## Overview

The book distinguishes three types of systems:

- **Services (online systems)**: wait for a request from a client, handle it as quickly as possible and send a response back. Response time and availability are the main measures of performance.
- **Batch processing systems (offline systems)**: take a large amount of input data, run a _job_ to process it and produce some output. A job often takes minutes to days, and nobody waits for it. Batch jobs are usually scheduled to run periodically, and their main measure of performance is `throughput`.
- **Stream processing systems (near-real-time systems)**: like batch systems, they consume inputs and produce outputs instead of responding to requests, but a stream job operates on events shortly after they happen.

Batch processing is old: punch card tabulating machines, such as the Hollerith machines used in the 1890 US Census, implemented a semi-mechanized form of it. `MapReduce`, published by Google in 2004, made batch processing on large clusters of commodity machines popular, and its ideas still shape modern data systems.

---
## Batch Processing with Unix Tools

A simple log analysis job finds the five most popular pages on a website:

```bash
cat /var/log/nginx/access.log |
  awk '{print $7}' |
  sort             |
  uniq -c          |
  sort -r -n       |
  head -n 5
```

The same job could be written as a small program that keeps a hash table of URLs and counters in memory. The two approaches differ in how they handle large inputs:

- The in-memory hash table works well as long as the number of distinct URLs fits in memory.
- The `sort` utility handles datasets larger than memory: GNU `sort` automatically spills to disk and parallelizes sorting across CPU cores. Sorting-based pipelines therefore scale to large datasets on a single machine, with the disk throughput as the main bottleneck.

### The Unix Philosophy

> [!NOTE]
> **Unix Philosophy**, as described by Doug McIlroy and others in 1978:
>
> 1. Make each program do one thing well.
> 2. Expect the output of every program to become the input to another, as yet unknown, program.
> 3. Design and build software to be tried early, and do not hesitate to throw away clumsy parts.
> 4. Use tools in preference to unskilled help to lighten a programming task.

Several features make Unix tools composable:

- **A uniform interface**: In Unix, the interface is a file, or more precisely a file descriptor, which is an ordered sequence of bytes. By convention, many programs treat this sequence as ASCII text with one record per line. Programs with the same input/output interface can be connected in any combination.
- **Separation of logic and wiring**: Programs read from `stdin` and write to `stdout` by default, and the shell user decides where the input comes from and where the output goes. The program does not need to know or care. This is a form of loose coupling.
- **Transparency and experimentation**: Input files are treated as immutable, so a command can be run repeatedly. The pipeline can be stopped at any point and the output inspected with `less`. The output of one stage can be written to a file and used as the starting point of the next stage, so earlier stages need not be rerun.

The biggest limitation of Unix tools is that they run only on a single machine. That is where tools like Hadoop come in.

---
## MapReduce and Distributed Filesystems

`MapReduce` is somewhat like Unix tools, but distributed across potentially thousands of machines. A MapReduce job, like a Unix process, takes one or more inputs and produces one or more outputs. It does not modify its input and has no side effects other than producing the output. Instead of `stdin` and `stdout`, MapReduce jobs read and write files on a distributed filesystem. In Hadoop's implementation, this is the `Hadoop Distributed File System (HDFS)`, an open source reimplementation of the Google File System (GFS).

### HDFS

**HDFS** is based on the **shared-nothing principle**. It runs a daemon process on each machine, which exposes a network service that allows other nodes to access the files stored on that machine. A central server called the `NameNode` keeps track of which file blocks are stored on which machine. Conceptually, HDFS creates one big filesystem that can use the disk space of all machines running the daemon.

To tolerate machine and disk failures, file blocks are **replicated** on several machines, or protected with an `erasure coding` scheme such as Reed-Solomon codes, which recovers lost data with less storage overhead than full replication. The largest HDFS deployments run on tens of thousands of machines, with hundreds of petabytes of storage.

---
### MapReduce Job Execution

A MapReduce job follows the same pattern as the Unix log analysis example:

1. Read a set of input files and break them up into **records**.
2. Call the **mapper** function to extract a key and value from each input record.
3. Sort all of the key-value pairs by key.
4. Call the **reducer** function to iterate over the sorted key-value pairs. All occurrences of the same key are adjacent after sorting, so they can be combined without keeping a lot of state in memory.

{{% columns %}}
- **Mapper**

  Called once for every input record. Its job is to extract the key and value from the input record. It may generate any number of key-value pairs, including none. It does not keep any state from one input record to the next.

- **Reducer**

  Receives the key-value pairs produced by the mappers, collects all the values belonging to the same key, and is called with an iterator over that collection of values. It can produce output records, such as the number of occurrences of the same URL.
{{% /columns %}}

### Distributed Execution of MapReduce

The main difference from Unix pipelines is that MapReduce can parallelize a computation across many machines without the application code handling parallelism explicitly:

- The input is typically a directory in HDFS, and each file or file block is a separate partition processed by a separate map task.
- The MapReduce scheduler tries to run each mapper on one of the machines that stores a replica of the input file. This principle is known as **putting the computation near the data** (data locality), and it saves copying the input over the network.
- The application code, for example JAR files in Java, is copied to the machines that run the tasks.
- The number of map tasks is determined by the number of input file blocks, while the number of reduce tasks is configured by the job author.
- To ensure that all key-value pairs with the same key end up at the same reducer, the framework uses a hash of the key to determine which reduce task should receive a particular pair.

Each map task partitions its output by reducer, based on the hash of the key, and writes a sorted file for each partition to its local disk. When a mapper finishes, the reducers connect to it and download the files of sorted key-value pairs for their partition. This process of partitioning by reducer, sorting and copying data partitions from mappers to reducers is known as the **shuffle**. The reducer merges the sorted files from all mappers, preserving the sort order, and calls the reducer function for each key.

### MapReduce Workflows

The range of problems that a single MapReduce job can solve is limited, so jobs are chained together into **workflows**: the output of one job becomes the input to the next. Hadoop has no special support for this. The first job writes its output to a designated HDFS directory, and the second job reads from the same directory.

A job can start only when all its input jobs have completed successfully. To handle these dependencies, workflow schedulers such as `Oozie`, `Azkaban`, `Luigi`, `Airflow` and `Pinball` were developed. Higher-level tools such as `Pig`, `Hive`, `Cascading`, `Crunch` and `FlumeJava` set up workflows of several MapReduce stages automatically. Recommendation systems built with Hadoop can consist of 50 to 100 MapReduce jobs.

---
## Reduce-Side Joins and Grouping

In batch processing, a join means resolving all occurrences of some association within a dataset, for example joining a log of user activity events with a database of user profiles to find out which pages are popular with which age group.

> [!CAUTION]
> Querying a remote database for every record would be slow, because throughput is limited by network round-trips, and the results would be nondeterministic, because the remote data may change while the job runs. A better approach is to take a copy of the user database, for example with an ETL process, and put it in the same distributed filesystem as the activity events.

### Sort-Merge Joins

1. One set of mappers goes over the activity events and extracts the user ID as the key and the activity event as the value. Another set of mappers goes over the user database and extracts the user ID as the key and the date of birth as the value.
2. The MapReduce framework partitions the mapper output by key and sorts the key-value pairs. All activity events and the user record with the same user ID become adjacent in the reducer input.
3. With a `secondary sort`, the framework arranges the records so that the reducer sees the user record first, followed by the activity events.
4. The reducer is called once for every user ID. It stores the date of birth in a local variable and iterates over the activity events, emitting pairs of viewed URL and viewer age.

The reducer processes all records for one user ID at a time, so it only needs to keep one user record in memory and never makes a request over the network. This algorithm is known as a `sort-merge join`.

> [!NOTE]
> **Bringing related data together in the same place**
>
> Using the key to choose the destination of each key-value pair is like sending a message to an address: the mapper sends messages to the reducers, and all messages with the same key are delivered to the same destination. MapReduce separates the physical network communication, including retries after failures, from the application logic.

### GROUP BY

Grouping records by some key, as in an SQL `GROUP BY` clause, is implemented the same way: the mappers set the grouping key as the key of the key-value pairs, and the partitioning and sorting bring all records with the same key to the same reducer. Common uses are counting records, summing values and picking the top k records per group. `Sessionization`, collating all activity events of a user session to find out the sequence of actions, is another example.

### Handling Skew

If one key has a very large amount of data, for example a celebrity with millions of followers in a social network, all its records end up at a single reducer. These records are called `linchpin objects` or `hot keys`, and they cause `skew`: one reducer has to process significantly more records than the others, and the whole job cannot complete until that reducer finishes.

- The `skewed join` method in Pig first runs a sampling job to determine which keys are hot. Records related to a hot key are sent to one of several reducers chosen at random, and the records of the other join input for that key are replicated to all of those reducers.
- The `sharded join` method in Crunch works similarly, but requires the hot keys to be specified explicitly.
- Hive's skewed join requires hot keys to be specified in the table metadata and uses a map-side join for them.
- When grouping records by a hot key, aggregation can be done in two stages: the first stage sends records to random reducers, each of which groups a subset of the records, and the second stage combines these partial results into a single value per key.

---
## Map-Side Joins

Reduce-side joins make no assumptions about the input data, but sorting, copying to reducers and merging are expensive. If you can make certain assumptions about the input, a `map-side join` is faster: there are no reducers and no sorting, and each mapper simply reads one input file block and writes one output file.

{{< tabs "mapside" >}}
{{% tab "Broadcast hash join" %}}
A large dataset is joined with a small dataset that fits entirely in memory on each mapper. Each mapper loads the small dataset into an in-memory hash table, then scans its partition of the large dataset and looks up each record in the hash table. The small input is "broadcast" to all partitions of the large input.

This method is supported by Pig ("replicated join"), Hive ("MapJoin"), Cascading and Crunch, and by data warehouse query engines such as Impala. Instead of a hash table in memory, the small join input can also be stored in a read-only index on the local disk.
{{% /tab %}}
{{% tab "Partitioned hash join" %}}
If both join inputs are partitioned in the same way, using the same key, the same hash function and the same number of partitions, the hash table approach can be applied to each partition independently. Each mapper only needs to load the records of its own partition from the smaller input into its hash table.

In Hive, partitioned hash joins are known as `bucketed map joins`.
{{% /tab %}}
{{% tab "Map-side merge join" %}}
If the input datasets are not only partitioned in the same way but also sorted by the same key, a mapper can read both input files incrementally in order of ascending key and match records with the same key, just as a reducer would. The input is often produced by an earlier MapReduce job that already did the partitioning and sorting.
{{% /tab %}}
{{< /tabs >}}

> [!WARNING]
> The output of a reduce-side join is partitioned and sorted by the join key. The output of a map-side join is partitioned and sorted in the same way as the large input. Map-side joins depend on knowing the physical layout of the datasets, including the partitioning and sort order, which is why this metadata is kept in catalogs such as `HCatalog` and the Hive metastore.

---
## The Output of Batch Workflows

Batch processing is neither transaction processing nor analytics. Its output is often not a report, but some other kind of structure.

### Building Search Indexes

Google's original use of MapReduce was to build indexes for its search engine. A full-text index such as Lucene's is a file in which you can look up a keyword and find the list of document IDs that contain it. Building it is a good fit for MapReduce: the mappers partition the documents, each reducer builds the index for its partition, and the index files are written to the distributed filesystem. Index files are immutable once written. If the indexed documents change, the whole index can be rebuilt periodically, or built incrementally.

### Key-Value Stores as Batch Process Output

Batch processing also builds machine learning systems such as classifiers and recommendation systems. Their output is often a database that the web application queries by key, for example by user ID to get suggested friends.

> [!CAUTION]
> Writing directly from a mapper or reducer to a production database, one record at a time, is a bad idea. It is orders of magnitude slower than normal batch throughput, many tasks writing in parallel can overwhelm the database, and partially completed jobs leave visible side effects, which breaks the all-or-nothing guarantee of MapReduce.

A much better solution is to build a brand-new database inside the batch job and write it as files to the job's output directory. These immutable data files are then loaded in bulk into servers that handle read-only queries. Voldemort, Terrapin, ElephantDB and HBase bulk loading support this. The servers switch atomically from the old files to the new ones, and can switch back if something goes wrong.

### Philosophy of Batch Process Outputs

Batch jobs follow the Unix philosophy: they treat inputs as immutable and avoid side effects. This has several benefits:

- **Human fault tolerance**: If a bug produces wrong output, you can roll back to the previous version of the code and rerun the job, or keep the old output in a different directory. A database with read-write transactions does not offer this: a bug that wrote bad data cannot be fixed by rolling back the code.
- **Minimizing irreversibility**: Easy rollback makes feature development faster, which benefits agile software development.
- **Automatic retries**: If a map or reduce task fails, the framework reschedules it and runs it again on the same input. The output from the failed task is discarded.
- **Reuse of inputs**: The same set of files can serve as input for several different jobs, including monitoring jobs that compare a job's output with the previous run.
- **Separation of logic and wiring**: Jobs separate the processing logic from configuring where inputs come from and outputs go, which allows reusing code across teams.

Unlike Unix tools, Hadoop tools do not need to parse untyped text: they can use structured file formats such as `Avro` and `Parquet`, which provide efficient schema-based encoding and allow the schema to evolve over time.

---
## Comparing Hadoop to Distributed Databases

Massively parallel processing (MPP) databases, such as Teradata and Gamma, already implemented parallel join algorithms more than ten years before MapReduce. The biggest difference is that MPP databases focus on parallel execution of analytic SQL queries, while the combination of MapReduce and a distributed filesystem provides something much more like a general-purpose operating system that can run arbitrary programs.

| | **Hadoop (MapReduce + HDFS)** | **MPP Databases** |
| --- | --- | --- |
| **Storage** | Any data can be dumped into HDFS in any format, and interpreted later | Data must be carefully modeled and imported into the database's proprietary storage format |
| **Data interpretation** | Consumer's responsibility (`schema-on-read`) | Schema defined up front (`schema-on-write`) |
| **Processing model** | Arbitrary code; SQL is one of many options | Monolithic, tightly integrated SQL engine |
| **Faults** | A failed task is retried; output of each task is written to disk | A failing node usually aborts the whole query, and data is kept in memory where possible |

### Diversity of Storage

Collecting data in its raw form and worrying about schema design later is sometimes called the `sushi principle`: "raw data is better". It allows data to be collected quickly into a `data lake`. The interpretation of the data becomes the consumer's problem, and different teams can transform the same raw data into different forms for their own purposes.

### Diversity of Processing Models

MPP databases are monolithic: the storage layout, query planner, scheduling and execution are tuned together for SQL queries. Many types of processing, such as machine learning, recommendation systems and full-text search, cannot be expressed sensibly in SQL. Hadoop lets you run arbitrary code on the same data. Over time, other processing models have been built on top of the same cluster and HDFS storage, such as `HBase` for random-access OLTP and `Impala` for MPP-style SQL queries.

### Designing for Frequent Faults

> [!NOTE]
> **Why MapReduce writes everything to disk**
>
> MapReduce tolerates the failure of a map or reduce task by retrying it at the granularity of an individual task, and it writes data eagerly to disk. The reason is Google's environment: batch jobs share machines with production services, and a low-priority MapReduce task can be terminated (`preempted`) at any time to make room for a higher-priority process. At Google, a MapReduce task that runs for an hour has an approximately 5% risk of being terminated. Overcommitting resources this way gives better utilization and efficiency. In environments where tasks are not terminated so frequently, the design decisions of MapReduce make less sense.

---
## Beyond MapReduce

MapReduce is only one of many possible programming models for distributed systems. It is robust: it can process large quantities of data on an unreliable multi-tenant system with frequent task terminations. Implementing complex processing jobs directly with the raw MapReduce APIs is hard, though, and its execution model has performance problems.

### Materialization of Intermediate State

Every MapReduce job is independent from every other job. When the output of one job is used only as the input to another job maintained by the same team, the files on the distributed filesystem are just `intermediate state`. Writing it out to files is called `materialization`. Unix pipes, in contrast, stream the output of one command incrementally to the input of the next. Fully materializing intermediate state has downsides:

- A job can start only when all tasks of the preceding jobs have completed, so a few straggler tasks slow down the whole workflow.
- Mappers are often redundant: they just read back the file written by a reducer and prepare it for the next stage of partitioning and sorting.
- Intermediate state in a distributed filesystem is replicated across several nodes, which is overkill for temporary data.

### Dataflow Engines

`Spark`, `Tez` and `Flink` are `dataflow engines`. They handle an entire workflow as one job, rather than breaking it up into independent subjobs. Like MapReduce, they repeatedly call a user-defined function to process one record at a time on a single thread, and they parallelize work by partitioning inputs. Unlike MapReduce, these functions, called `operators`, can be assembled flexibly. Operators can be connected in several ways:

- Repartition and sort records by key, like the shuffle stage of MapReduce, which enables sort-merge joins and grouping.
- Repartition records without sorting, which is enough for partitioned hash joins.
- Broadcast the same output to all partitions of the join operator, for broadcast hash joins.

Advantages over the MapReduce model:

- Expensive work such as sorting is performed only where it is actually required.
- There are no unnecessary map tasks.
- The scheduler knows all joins and data dependencies of the workflow, so it can place tasks near the data they consume.
- Intermediate state is usually kept in memory or written to local disk, which requires less I/O than writing to HDFS.
- Operators can start executing as soon as their input is ready.
- Existing Java Virtual Machine (JVM) processes can be reused, which reduces startup overhead.

### Fault Tolerance in Dataflow Engines

Because dataflow engines avoid writing intermediate state to HDFS, they need a different approach to fault tolerance: if a machine fails and its intermediate state is lost, the engine recomputes it from data that is still available, such as a prior intermediary stage or the original input. To do this, the framework tracks how each piece of data was computed. Spark uses the `resilient distributed dataset (RDD)` abstraction to track the ancestry of data, and Flink checkpoints operator state.

> [!WARNING]
> Recomputation works well only if the operators are `deterministic`. If an operator produces different output on a second run, downstream operators may have to be killed and rerun too. Sources of nondeterminism include the iteration order of hash tables, random numbers without a fixed seed, the system clock and external data sources. If the intermediate data is much smaller than the source data, or the computation is very CPU-intensive, materializing it to files can be cheaper than recomputing it.

Dataflow engines still need some materialization: a sort operation must consume its entire input before producing any output, and the final output of the job is usually written durably to the distributed filesystem.

---
## Graphs and Iterative Processing

Many graph algorithms, such as `PageRank`, are iterative: they repeat a step until some condition is met, for example until no edges remain to be followed or the results converge. This can be implemented with MapReduce, but it is very inefficient, because MapReduce reads the entire input dataset and produces a completely new output dataset in each iteration, even if only a small part of the graph changed.

> [!NOTE]
> **The Pregel processing model**
>
> The `bulk synchronous parallel (BSP)` model of computation, popularized by Google's `Pregel` paper, optimizes batch processing of graphs. It is implemented by `Apache Giraph`, Spark's `GraphX` API and Flink's `Gelly` API. In each iteration, a function is called for each vertex, which receives all the messages sent to that vertex in the previous iteration. A vertex can send messages to other vertices, typically along the edges of the graph. A vertex remembers its state in memory from one iteration to the next, so the function only needs to process new incoming messages.

- **Fault tolerance**: Messages are batched, and the framework waits for all messages of one iteration to be delivered before the next iteration starts. Fault tolerance is achieved by periodically checkpointing the state of all vertices at the end of an iteration. If a node fails, the whole computation rolls back to the last checkpoint.
- **Parallel execution**: A vertex does not need to know on which physical machine it is executing. The framework partitions the graph, usually by vertex ID, without trying to group related vertices together. As a result, graph algorithms often have a lot of cross-machine communication overhead, and intermediate state can be larger than the original graph.

If a graph fits in memory on a single computer, a single-machine algorithm will probably outperform a distributed batch process. Even a graph larger than memory can be processed efficiently on one machine using disks, as frameworks such as `GraphChi` do. Distributed approaches are necessary only when the graph is too big for a single machine.

---
## High-Level APIs and Languages

Higher-level languages and APIs such as `Hive`, `Pig`, `Cascading` and `Crunch` became popular because programming MapReduce jobs by hand is laborious. Spark and Flink also include their own high-level dataflow APIs, often inspired by `FlumeJava`. These APIs use relational-style building blocks such as joining datasets on the value of a field, grouping tuples by key, filtering and aggregating.

- **The move toward declarative query languages**: When joins are specified as relational operators instead of written as code, the framework can analyze the properties of the join inputs and decide which join algorithm suits the task best. Hive, Spark and Flink have cost-based query optimizers that can also change the order of joins to minimize intermediate state. Batch processing frameworks start to look more like MPP databases and achieve comparable performance, for example through column-oriented storage and `vectorized execution`, while keeping the flexibility of running arbitrary code and reading data in arbitrary formats.
- **Specialization for different domains**: Reusable implementations of common processing patterns are emerging. Statistical and numerical algorithms for machine learning are available in `Mahout` for MapReduce, Spark and Flink, and in `MADlib` inside MPP databases. Spatial algorithms such as `k-nearest neighbors` and approximate search for genome analysis are other examples.

---
## Summary

- Unix tools such as `awk`, `grep` and `sort` share a philosophy that carries over to MapReduce and dataflow engines: immutable inputs, outputs that become the input to another program, and small tools that each do one thing well.
- The two main problems of distributed batch processing frameworks are `partitioning`, which brings related data together, and `fault tolerance`, which in MapReduce relies on materialized intermediate state and in dataflow engines on recomputation.
- Join algorithms include sort-merge joins, broadcast hash joins and partitioned hash joins.
- A batch job reads bounded, immutable input and produces derived output without side effects, which makes it safe to retry tasks and to rerun jobs after fixing bugs.
