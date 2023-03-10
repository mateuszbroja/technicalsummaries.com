---
weight: 8
title: "08: Queries, Modeling, and Transformation"
bookHidden: false
---

# Queries, Modeling, and Transformation


Data governance tips:
- Keep credentials secure and avoid storing them in code.
- Use data lineage tools are invaluable for tracking the transformation of data.
- Consider implementing `Master Data Management (MDM)` to improve data accuracy and consistency.

## Query
---
A query allows you to retrieve and act on data (`R` from `CRUD`).

**Data definition language (DDL)** defines the state of objects in your database. `CREATE`, `DROP`, `UPDATE`.

**Data manipulation language (DML)** adds and alters data using: `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `COPY`, `MERGE`.

**Data control language (DCL)** controls access to database objects and data with SQL commands: `GRANT`, `DENY`, `REVOKE`.

**Transaction Control Language (TCL)** allows control over transaction, it includes commands like `COMMIT` and `ROLLBACK`.

**Life of a Query:**
- Parse and validate SQL code.
- Convert SQL to bytecode.
- Optimize bytecode for efficient execution.
- Execute the query and produce results.

**Improving Query Performance:**
- Pre-join data to reduce query processing time.
- Relax normalization to reduce the number of joins required.
- Create indexes on keys used in joins.
- Use `EXPLAIN` to understand how query is run.
- Avoid full table scan (avoid `SELECT *`)
- Use pruning (in column-oriented use clustering and partitioning; in row-oriented use indexes)
- Vacuuming to remove dead records that are no longer needed and are taking up space in the database file system.
- Leverage cached query results, so that results of a query that have been previously executed and stored can be retrieved instantly.

{{< hint info >}} **Row explosion** happens when there are numerous many-to-many matches. {{< /hint >}}

When working with commits in a database, it's important to consider the following:

- Commits involve creating, updating, or deleting database objects.
- Transactions can help maintain a consistent state in the database during and after a failure.
- Isolation is important for concurrent read, write, and delete operations to avoid conflicting information.
- ACID compliance is a key factor to consider when evaluating a database's commit model.
- Different databases handle commits differently. PostgreSQL uses row locking, which can impact performance. Google BigQuery uses a point-in-time full table commit model with limited write concurrency. MongoDB offers configurable consistency options but may discard writes when overwhelmed with traffic.


### Basic query patterns on streams

- The fast-follower approach.
- `Session`, `fixed-time (tumbling)`, and `sliding windows` are common types of windows.
- `Watermarks` are used to determine whether data in a window is within the established time interval or whether it's considered late.
- Combining streams with other data can be done through conventional table joins, enrichment, or stream-to-stream joining.


## Data Modeling
---

Data modeling includes three stages:
- `Conceptual model`: describes the system's data and business logic, often visualized in an entity-relationship diagram.
- `Logical model`: details how the conceptual model will be implemented, adding more detail such as information on types of data and primary and foreign keys.
- `Physical model`: defines how the logical model will be implemented in a database system, including specific databases, schemas, tables, and configuration details.

{{< hint info >}} **The grain of data** is the level of details at which data is stored. Modeling data at the lowest level of grain possible enables easy aggregation of highly granular datasets. {{< /hint >}}

{{< hint info >}} **Normalization** removes data redundancy and ensures referential integrity in a database by enforcing strict control over table and column relationships. It's a way of applying the `don't repeat yourself (DRY) principle` to data. {{< /hint >}}

**Forms:**
- `1NF`: Columns are unique and have a single value. Table has a unique primary key.
- `2NF`: Meets 1NF and partial dependencies are removed.
- `3NF`: Meets 2NF and has no transitive dependencies.

Additional normal forms exist up to 6NF, but are less common. `Denormalization` is common in many OLAP systems with semi-structured data.

## Techniques for Modeling Batch Analytical Data

### Inmon
Data warehouse created in 1989 to separate source system from analytical system. 4 critical parts: `subject-oriented`, `integrated`, `nonvolatile`, and `time-variant`. Emphasis on ETL to ingest and integrate data from source systems into highly normalized data warehouse. Serves as `single source of truth`. Data modeling in data marts typically uses star schema.

```source -> normalized DWH -> data marts```

### Kimball

`Kimball` is a data modeling approach that focuses less on normalization and allows denormalization. It is bottom-up, encouraging department-specific analytics in the data warehouse itself. **Data is modeled with fact and dimension tables in a star schema.**

`Fact tables` contain immutable factual, quantitative, and event-related data, which are typically narrow and long, and should be at the lowest grain possible. Queries start with the fact table and aggregations or derivations should be done downstream. Fact tables don't reference other fact tables, only dimensions.

`Dimension tables` provide reference data, attributes, and relational context for fact tables, are smaller and wider than fact tables, and are denormalized with the possibility of duplicate data. Dates are typically stored in a separate date dimension table to be referenced with a date key between the fact and date dimension table.


`SCD (Slowly Changing Dimension)` is used to track changes in dimensions over time. Types:
- `Type 1 SCD`: overwrites existing records and does not retain any historical data.
- `Type 2 SCD`: keeps a full history of records, flagging changes and creating new records as necessary. Most common type.
- `Type 3 SCD`: creates a new field instead of a new row when a change occurs.

`The star schema` is a data model of the business that is less normalized than other approaches. It consists of a fact table surrounded by dimensions, resulting in fewer joins and faster query performance. It is not suitable for streaming data, only batch data.

### Data Vault

`The Data Vault` approach to data modeling offers a different approach to Kimball and Inmon. Data is loaded directly from source systems into purpose-built tables in an insert-only manner. The model consists of hubs, links, and satellites, and aims to keep the data closely aligned with the business as it evolves. The Data Vault can be used alongside other modeling techniques and can be adapted for NoSQL and streaming data sources.

### Wide denormalized tables

A wide table approach to data modeling is becoming more common due to the popularity of the cloud and nested data. Wide tables are highly denormalized, very wide, and contain many fields. They are organized along with one or multiple keys, closely tied to the grain of the data.

While queries on wide tables run faster than highly normalized data, the biggest criticism is losing the business logic in analytics. Wide tables work well for streaming data.

### Modeling Streaming Data

Modeling streaming data is challenging because of its unbounded and continuous nature, and traditional batch-oriented data modeling techniques don't apply.

There isn't a consensus approach yet, but the Data Vault has been suggested as an option. **Streaming data comes in two main types: event streams and CDC**, and the data is often semistructured, such as JSON. The challenge with modeling streaming data is that the schema can change frequently, so the analytical database needs to have a flexible schema to accommodate these changes.

## Transformations
---

Transformations enhance and save data for downstream use, increasing its value in a scalable and reliable way. Orchestration is critical to transformations, combining many operations for consumption by downstream processes.

### Batch Transformations

Batch transformations run on discrete chunks of data. Examples:
- Distributed joins break a logical join into smaller node joins.
- Broadcast join is used when one table is much larger than the other and can be distributed across nodes while the small table can fit on a single node.
- Shuffle hash join is used when neither table can fit on a single node and requires shuffling and hashing the data.
- **ETL**, **ELT**, and data pipelines.
- SQL and code-based transformation tools - engineers sometimes use Python and Spark for transformations that could be done more easily and efficiently in SQL.


### Update patterns
- truncate and reload,
- insert only,
- delete,
- upsert/merge - originally designed for row-based databases. BigQuery supports the upsert/merge pattern for streaming new records into a table, along with materialized views for efficient deduplication in near real-time.

### MapReduce and Spark
Top tips for coding in native Spark:
- Filter data early and often.
- Use the core Spark API and try to rely on well-maintained public libraries. Good Spark code is declarative.
- Use User-Defined Functions (UDFs) carefully.
- Consider using SQL in combination with Spark.


`MapReduce` is a batch data processing pattern in Hadoop, consisting of map tasks that read individual data blocks, followed by a shuffle that redistributes data, and a reduce step that aggregates data on each node. It was the defining batch data transformation pattern of the big data era.

`Post-MapReduce processing` still uses map, shuffle, and reduce, but allows for in-memory caching to speed up processing tasks. Frameworks like Spark and BigQuery treat data as a distributed set in memory, with disk used as a secondary storage layer.


## Materialized Views, Federation, and Query Virtualization
---

Views are database objects that allow selecting from other tables as if they were a table. They can serve a security role and provide a current deduplicated picture of data or present common data access patterns. However, they don't do any precomputation, which can be a disadvantage compared to `materialized views`.


`Federated queries` allow an OLAP database to select from an external data source. `Data virtualization `doesn't store data internally and `query pushdown` offloads computation from the virtualization layer to the source database for better performance and reducing the amount of data that must push across the network.