---
weight: 10
title: "10: Batch Processing"
bookHidden: false
---

# Batch Processing
---

- **Service (online)**: waits for a request, sends a response back
- **Batch processing system (offline)**: takes a large amount of input data, runs a _job_ to process it, and produces some output.
- **Stream processing systems (near-real-time)**: a stream processor consumes input and produces outputs. A stream job operates on events shortly after they happen.

In batch jobs you might not care so much about response time, but rather throughput.

---
## Batch processing with Unix tools

Simple log analysis job to get the five most popular pages on your site:

```bash
cat /var/log/nginx/access.log |
  awk '{print $7}' |
  sort             |
  uniq -c          |
  sort -r -n       |
  head -n 5        |
```

Unix tools offer a versatile framework for tasks like log analysis. Key features include:

- **Efficiency**: Unix commands handle large datasets and parallelize sorting without the need for custom programs.
- **Standardized Data Interface**: Unix uses files (or file descriptors), treated as ASCII text, for smooth data transmission between programs.
- **Flexibility**: Programs designed to use `stdin` and `stdout` enable users to control data sources and destinations.
- **Transparency**: This user control and the visible flow of data contribute to Unix's success and widespread use.

{{< hint info >}}
**Unix Philosophy**

1. Make each program do one thing well
2. Expect output to become input
3. Design and build to be tried early and iterate
4. Use tools to lighten a programming task
{{< /hint >}}

---
## MapReduce and distributed file systems

`MapReduce` jobs, akin to Unix processes, don't modify inputs and produce outputs without side effects. Unlike Unix that uses `stdin` and `stdout`, `MapReduce` jobs interact with data via Hadoop's `Distributed File System (HDFS)`.

These jobs read and write files on this distributed filesystem, which scales to cater for large datasets across numerous machines. MapReduce is more appropriate for larger jobs.

---
### HDFS

**HDFS**, grounded on the **shared-nothing principle**, comprises a daemon process on each machine, offering network service for other nodes to access files on it.

The `NameNode`, a central server, keeps track of file block distribution across machines. **Data redundancy is ensured through replication**, creating multiple copies across machines.

---
### How MapReduce Works

MapReduce operates by breaking down tasks into a series of operations that follow a certain order:

1. Read a set of input files and break them up into individual **records**.
2. Call the **mapper** function for each record to extract a key and value.
3. Sort all of the key-value pairs by their keys.
4. Call the **reducer** function to iterate over the sorted key-value pairs.

The **mapper** function is invoked once for every input record, with its primary responsibility being the extraction of the key and value from the record. 

The **reducer**, on the other hand, handles the key-value pairs produced by the mappers. It aggregates all values belonging to the same key, and then calls the reducer function with an iterator over that collection of values. This flow ensures the processing of large datasets in a distributed filesystem like HDFS.

`The MapReduce scheduler` aims to run each mapper on a machine holding a replica of the input file, a principle known as **data locality**. The reduce side computation is also partitioned. While the number of map tasks is determined by input file blocks, the number of reduce tasks is configured by the job author. A hash of the key ensures all key-value pairs with the same key land in the same reducer. 

Given that datasets can be too large for single-machine sorting, sorting is performed in stages. Upon a mapper finishing its task, the MapReduce scheduler notifies reducers to fetch output files from that mapper. This process of partitioning by reducer, sorting, and transferring data partitions from mappers to reducers is known as **shuffle**. 

`MapReduce` jobs can be strung together into **workflows** where one job's output serves as the next job's input.

---
### MapReduce vs MPP Databases

|      | **MapReduce**  | **MPP Databases** |
|------------- |-------------| -----|
| **Data Import** | Arbitrary data dump allowed in HDFS | Upfront data modeling & import into proprietary storage needed |
| **Data Interpretation** | Consumer's responsibility | Producer standardizes format |
| **Query Execution** | Tolerates node/task failure, eager disk writing | Aborts query if node fails, prefers in-memory storage |
| **Handling Large Jobs** | More suitable, designed for frequent task termination | Less suitable, prefers to keep data in memory |

---
### Materialization of Intermediate State in MapReduce

- `MapReduce's` intermediate state is fully materialized, represented by files.
- Jobs need to finish before the next starts, unlike Unix pipes.
- There's redundancy as mappers often read whole input files again.
- This approach can be slow and inefficient.

---
## Beyond MapReduce

MapReduce, while robust and capable of handling large data quantities, has limitations leading to the emergence of higher-level models like `Pig`, `Hive`, `Cascading`, and `Crunch`. Its approach of fully materializing state leads to issues like:

- Starting `MapReduce` jobs only after completion of preceding jobs.
- Redundancy in mappers.
- Overkill replication of files across nodes for temporary data.

To address these, new batch computation engines like `Spark`, `Tez`, and `Flink` have been developed. They handle entire workflows as one job (dataflow engines) and allow assembling functions called operators flexibly.

These new engines avoid writing intermediate state to `HDFS` and instead recompute lost data if a machine fails. Ancestry data tracking is used in Spark through `resilient distributed datasets (RDDs)`, and `Flink` checkpoints operator state for fault tolerance. **While this approach complicates fault tolerance, it may not always be necessary, leading to overall efficiency gains.**

---
### Graphs and Iterative Processing

In batch processing for applications like machine learning, `Bulk Synchronous Parallel (BSP) `optimizes graph processing.

Implemented in `Apache Giraph`, `Spark's GraphX API`, and `Flink's Gelly API`, `BSP` allows state retention and message passing between vertices, and ensures fault tolerance through periodic state checkpointing. However, it can induce high cross-machine communication overhead. Single-machine algorithms are efficient for smaller graphs, but for larger graphs, distributed approaches like `Pregel` are necessary.
