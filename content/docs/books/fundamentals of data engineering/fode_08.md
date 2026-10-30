---
weight: 8
title: "08: Queries, Modeling, and Transformation"
bookHidden: false
---

# Queries, Modeling, and Transformation
---

This chapter covers the stage where data starts creating value: querying it, modeling it to reflect the business, and transforming it into forms that downstream users can consume.

## Queries
---

A `query` lets you retrieve and act on data. In `CRUD` terms, querying usually means the `R` (read), but SQL covers much more than reading.

**Data definition language (DDL)** defines the state of objects in the database, such as databases, schemas, tables, and views: `CREATE`, `ALTER`, `DROP`.

**Data manipulation language (DML)** adds and alters data within those objects: `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `COPY`, `MERGE`.

**Data control language (DCL)** controls access to database objects and data: `GRANT`, `DENY`, `REVOKE`.

**Transaction control language (TCL)** controls the details of transactions: `COMMIT`, `ROLLBACK`.

### The Life of a Query

1. The database engine parses the SQL and validates its syntax and semantics, for example that referenced tables exist and the user has access.
2. The SQL is converted to bytecode that the engine can execute.
3. The `query optimizer` analyzes the bytecode and decides how to run it efficiently: join order, which indexes to use, and how much data to scan.
4. The query executes and the engine returns the results.

### Improving Query Performance

- **Optimize join strategy and schema**: Pre-join frequently combined data, relax normalization to reduce the number of joins, and create indexes on join keys. Simplify complex queries with `common table expressions (CTEs)` instead of deeply nested subqueries.
- **Use the explain plan**: `EXPLAIN` shows how the optimizer will run a query and helps find bottlenecks. Also monitor resource usage: disk, memory, network, load time, rows scanned, and data spilled to disk.
- **Avoid full table scans**: Query only the columns and rows you need; avoid `SELECT *` in production. Use `pruning`: clustering and partitioning in column-oriented databases, indexes in row-oriented ones.
- **Know how your database handles commits**: see below.
- **Vacuum dead records**: Updates and deletes leave behind dead records that take space and slow queries. Vacuuming removes them; some databases do it automatically, others need manual runs.
- **Leverage cached query results**: Many cloud OLAP databases cache results, so a repeated query can return instantly at no extra cost.

> [!NOTE]
> **Row explosion** happens when a join matches many rows on both sides (many-to-many), producing far more output rows than either input. It can make a query run for a very long time or fail.

### Commits

A commit is a change within a database: creating, updating, or deleting a record, table, or other object. Transactions keep the database consistent during and after failures, and isolation prevents concurrent reads, writes, and deletes from producing conflicting results. ACID compliance is a key factor when evaluating a database's commit model.

- **PostgreSQL** uses row locking, which gives strong consistency but can hurt performance under heavy concurrent writes.
- **Google BigQuery** uses a point-in-time full-table commit model: reads see a consistent snapshot, but write concurrency is limited.
- **MongoDB** offers configurable consistency; in some configurations it can discard writes when overwhelmed with traffic.

### Queries on Streaming Data

Streaming data is constantly in flight, so querying it requires different patterns.

- **Fast-follower approach**: An analytics database follows a production database through `CDC` and serves queries with only a slight lag, without loading the production system.
- **Kappa architecture**: The stream storage is the primary storage and transport layer. Data is retained for a long time and can be replayed, so the same system serves both real-time and historical queries.

**Windows, triggers, emitted statistics, and late-arriving data**

A `window` is a small batch processed according to dynamic triggers. Common window types:

- `Session window`: groups events that occur close together and closes after a period of inactivity, for example per user.
- `Fixed-time (tumbling) window`: fixed, non-overlapping periods, such as every 20 seconds.
- `Sliding window`: fixed-length windows that overlap, for example 60-second windows starting every 30 seconds.

A `watermark` is a threshold that a window uses to decide whether data falls within its time interval or counts as late. Late data needs an explicit policy: drop it, or reprocess and update earlier results.

**Combining streams with other data**

- **Conventional table joins**: join stream outputs with tables in a database.
- **Enrichment**: add data to each event, for example product details looked up from an in-memory cache or API.
- **Stream-to-stream joining**: join two streams, typically by buffering both within a time window so that related events can find each other.

## Data Modeling
---

A `data model` represents the way data relates to the real world. It reflects how data must be structured and standardized to best reflect the organization's processes, definitions, workflows, and logic. Data modeling lost importance during the big data era, when schemaless data lakes became popular; the resulting `data swamps` showed that modeling still matters.

Modeling usually moves from abstract to concrete:

- `Conceptual model`: business logic and rules and the system's data, such as schemas, tables, and fields. Often visualized in an entity-relationship (ER) diagram.
- `Logical model`: how the conceptual model will be implemented in practice, adding detail such as data types and primary and foreign keys.
- `Physical model`: how the logical model will be implemented in a specific database system, including databases, schemas, tables, and configuration details.

> [!NOTE]
> **The grain of data** is the resolution at which data is stored and queried, for example one row per order or one row per customer per day. Model data at the lowest grain possible: aggregating a granular dataset is easy, while recovering detail that was aggregated away is impossible.

### Normalization

> [!NOTE]
> **Normalization** is a database data modeling practice that enforces strict control over the relationships of tables and columns. It removes redundancy and ensures referential integrity, applying the `don't repeat yourself (DRY)` principle to data.

Normal forms are cumulative:

- `Denormalized`: no normalization; nested and redundant data is allowed.
- `1NF`: each column is unique and holds a single value; the table has a unique primary key.
- `2NF`: 1NF plus removal of partial dependencies, where a column depends on only part of a composite key.
- `3NF`: 2NF plus no transitive dependencies, where a non-key column depends on another non-key column.

Further normal forms exist, up to 6NF, but they are rare in business practice. Denormalization is common in OLAP systems and with semistructured data.

## Techniques for Modeling Batch Analytical Data
---

### Inmon

Bill Inmon, the father of the data warehouse, created his approach in 1989. He defined a data warehouse as `subject-oriented`, `integrated`, `nonvolatile`, and `time-variant` in support of management decisions. Data from source systems is ingested through ETL and integrated into a highly normalized (3NF) warehouse, which serves as the `single source of truth`. Department-specific data marts are built downstream, often modeled as star schemas.

```text
sources -> ETL -> normalized data warehouse -> data marts -> reports and analysis
```

### Kimball

Ralph Kimball's approach, popularized in the 1990s, focuses less on normalization and accepts denormalization. It is bottom-up: department- and business-specific analytics are modeled directly in the warehouse, which effectively becomes the collection of data marts. **Data is modeled with fact and dimension tables in a star schema.**

`Fact tables` contain factual, quantitative, event-related data. They are immutable, append-only, typically narrow and long, and should be at the lowest grain possible. Queries start from the fact table, and aggregations or derivations should happen downstream. Fact tables reference dimensions, not other fact tables.

`Dimension tables` provide reference data, attributes, and relational context for the events in fact tables. They are smaller and wider than fact tables and denormalized, so duplicate data is allowed. Dates are typically stored in a separate date dimension, referenced through a date key.

`Slowly changing dimensions (SCD)` track changes in dimensions over time:

- `Type 1`: overwrite existing records; no history is kept.
- `Type 2`: keep the full history; a change creates a new record with validity dates or a current flag. This is the most common type.
- `Type 3`: instead of a new row, a change creates a new field, such as a column with the previous value.

The `star schema` is a model of the business: a fact table surrounded by the dimensions it needs. It needs fewer joins than a highly normalized model, which speeds up queries, and it keeps business logic close to the data. A warehouse usually contains several star schemas, with dimensions shared across them (`conformed dimensions`).

### Data Vault

`Data Vault` was created by Dan Linstedt in the 1990s. It separates the structural aspects of source data from its attributes. Data is loaded directly from source systems into purpose-built tables in an insert-only manner, without applying business logic during loading.

- `Hubs` store unique business keys, the core business concepts.
- `Links` store relationships between hubs.
- `Satellites` store the attributes and context of hubs and links, with history.

The goal is a model that stays closely aligned with the business as it evolves. Data Vault can be combined with other techniques, for example star schemas built on top of it for querying, and it can be adapted to NoSQL and streaming sources.

### Wide Denormalized Tables

Cheap cloud storage, columnar databases, and nested data (such as JSON) made very wide, highly denormalized tables common. A wide table collects many fields, often hundreds, into one table organized around one or more keys, closely tied to the grain of the data. Columnar storage reads only the columns a query needs, and nulls cost little.

Queries on wide tables often run faster than on highly normalized data because they avoid joins. The biggest criticism is that, as data is blended together, the business logic of the model gets lost in the analytics.

### Modeling Streaming Data

Traditional batch modeling techniques do not translate well to streaming data, which is unbounded and continuous. There is no consensus approach yet; the Data Vault has been suggested as one option. **Streaming data comes mainly as event streams or CDC**, usually semistructured, such as JSON. Because source schemas can change at any time, the analytical database should have a flexible schema that accommodates new fields.

## Transformations
---

A `transformation` manipulates, enhances, and saves data for downstream use, increasing its value in a scalable, reliable, and cost-effective way. Unlike a one-off query, a transformation persists its results so that other processes can consume them. Orchestration is critical: many transformations are chained together and must run in the right order.

### Batch Transformations

Batch transformations run on discrete chunks of data, on a fixed schedule or when a threshold is reached.

**Distributed joins** break a logical join into many smaller node joins that run on individual servers:

- `Broadcast join`: used when one table is small enough to fit on a single node. The small table is sent (broadcast) to every node and joined with each part of the large table, which avoids shuffling the large table.
- `Shuffle hash join`: used when neither table fits on one node. Both tables are repartitioned by a hash of the join key so matching rows end up on the same node. This is more resource intensive.

**ETL, ELT, and data pipelines**: Classic ETL transforms data before it reaches the warehouse. ELT loads raw data first and transforms it inside the warehouse. Data pipelines combine both patterns as needed.

**SQL and code-based transformation tools**: SQL is a powerful, declarative transformation language. Engineers sometimes build transformations in Python and Spark that would be simpler and more efficient in SQL; choose the tool that fits the task.

**Update patterns**

- `Truncate and reload`: delete everything and regenerate it from scratch.
- `Insert only`: insert new records without changing old ones; a view or query keeps the current state.
- `Delete`: hard deletes remove records permanently; soft deletes mark them as deleted. Deletes are expensive in columnar systems.
- `Upsert/merge`: update matching records and insert new ones. The pattern was designed for row-based databases; in columnar systems it can be costly, because changes often require rewriting whole files.

> [!NOTE]
> BigQuery lets you stream-insert new records into a table and offers specialized materialized views that present an efficient, near real-time deduplicated view of that data.

**Schema updates**: Data changes over time, and columnar cloud databases make adding, removing, and renaming columns much easier than in the past. Semistructured columns, such as JSON fields, let you absorb new attributes without schema changes.

**Data wrangling**: Takes messy, malformed data and turns it into useful, clean data. It is often heavy, undifferentiated work; wrangling tools with visual interfaces can speed it up.

**Business logic and derived data**: Transformations frequently encode business logic, for example how revenue or profit is calculated. Derived data is data computed from other data stored in the system. Keep business logic consistent across reports, for example through a metrics or semantic layer.

**Master data management (MDM)**: Creates consistent entity records, called `golden records`, for customers, products, locations, and other core entities across systems.

### MapReduce and Spark

`MapReduce` was the defining batch transformation pattern of the big data era. Map tasks read individual data blocks, a shuffle redistributes the results across the cluster, and a reduce step aggregates data on each node. Every step writes to disk, which makes it slow.

`Post-MapReduce` frameworks still use map, shuffle, and reduce, but cache data in memory. Spark, BigQuery, and similar engines treat data as a distributed set that lives in memory, with disk as a secondary storage layer.

Tips for writing native Spark code:

- Filter data early and often.
- Rely on the core Spark API and well-maintained public libraries. Good Spark code is largely declarative.
- Be careful with user-defined functions (UDFs), especially in Python, because they can be slow.
- Consider mixing in SQL where it simplifies the logic.

## Materialized Views, Federation, and Query Virtualization
---

A `view` is a database object that you can select from as if it were a table. It is only a stored query and does no precomputation. Views can serve a security role, present a current deduplicated picture of the data, or capture common access patterns.

A `materialized view` precomputes and stores the result of the view's query, so reads are fast. Some databases refresh materialized views incrementally, and newer systems support `composable materialized views` that select from other materialized views.

`Federated queries` let an OLAP database select from external data sources, such as object storage or other databases, without ingesting the data first.

`Data virtualization` is a query engine that does not store data internally. It reads data from external sources at query time; Trino and Presto are examples. `Query pushdown` offloads as much computation as possible to the source database, which improves performance and reduces the amount of data sent across the network.

## Streaming Transformations and Processing
---

**Transformations versus processing**: A streaming query runs continuously to present a current view of the data. A streaming transformation prepares data for downstream consumption, for example by enriching IoT events with metadata before they reach the next stream.

**Streaming DAGs**: Several streams can be combined, split, and enriched in a directed graph of processing steps, with each step reading from and writing to topics.

{{% columns %}}
- **Micro-batch**

  Splits the stream into very small batches, measured in seconds or less, and processes each with batch tools. Spark Streaming is the classic example. Simple to adopt when you already run batch jobs.

- **True streaming**

  Processes one event at a time as it arrives, as in Flink or Beam. Lower latency, at the cost of more operational complexity.
{{% /columns %}}

The right choice depends on the latency the business really needs, the team's skills, and the cost.

## Whom You'll Work With
---

- **Upstream stakeholders**: the owners of the source systems and data. Work with them on data definitions and give them advance notice when your queries or transformations might affect their systems.
- **Downstream stakeholders**: analysts, data scientists, ML engineers, and the business. Make sure your models and transformations are correct and performant, and that they reflect how the business actually works.

## Undercurrents
---

- **Security**: Queries and transformations combine data in new ways, so apply access controls at the table, row, and column level. Keep credentials secure, out of code, and in a secrets manager.
- **Data management**: Define business terms and metrics consistently. Data lineage tools are invaluable for tracking how data is transformed. Consider `master data management (MDM)` to improve the accuracy and consistency of core entities. Respect privacy, for example by masking or hashing sensitive fields.
- **DataOps**: Monitor both the data (quality, freshness, schema) and the systems (query performance, cost, failures).
- **Data architecture**: Design models and transformations that fit the business and can evolve, with clear trade-offs between batch and streaming.
- **Orchestration**: Transformations depend on each other and on ingestion; an orchestrator manages these dependencies and schedules.
- **Software engineering**: Write readable, tested transformation code, use version control, and prefer declarative SQL where it fits.
