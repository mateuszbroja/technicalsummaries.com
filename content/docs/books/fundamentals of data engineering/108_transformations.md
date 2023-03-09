---
weight: 8
title: "08: Queries, Modeling, and Transformation"
bookHidden: true
---

# Queries, Modeling, and Transformation

## Query
Queries
A query allows you to retrieve and act on data. It is R from CRUD.

Data definition language (DDL) defines the state of
objects in your database. CREATE, DROP UPDATE.

Data manipulation language add and alter data within
these objects SELECT
INSERT
UPDATE
DELETE
COPY
MERGE

Data control language control access to the
database objects or the data by using SQL commands such as GRANT, DENY, and
REVOKE.

transaction control language (TCL)
supports commands that
control the details of transactions. With TCL, we can define commit checkpoints,
conditions when actions will be rolled back, and more. Two common TCL commands
include COMMIT and ROLLBACK

Life of a Query

1. The database engine compiles the SQL, parsing the code to check for proper
semantics and ensuring that the database objects referenced exist and that the
current user has the appropriate access to these objects.
2. The SQL code is converted into bytecode. This bytecode expresses the steps
that must be executed on the database engine in an efficient, machine-readable
format.
3. The database’s query optimizer analyzes the bytecode to determine how to execute
the query, reordering and refactoring steps to use available resources as
efficiently as possible.
4. The query is executed, and results are produced.

The Query Optimizer attempts
to execute the query in the least expensive manner.


Improving Query Performance

- Optimize your join strategy and schema
prejoin data - often makes sense to
join the data in advance and have queries read from the prejoined version of the
data. relaxing normalization. Create indexes on key8s from joins.

DEF Row Explosion
This occurs when we have a
large number of many-to-many matches

use common table expressions (CTEs)


- Use the explain plan and understand your query’s performance
Usage of key resources such as disk, memory, and network.
• Data loading time versus processing time.
• Query execution time, number of records, the size of the data scanned, and the
quantity of data shuffled.
• Competing queries that might cause resource contention in your database.
• Number of concurrent connections used versus connections available. Oversubscribed
concurrent connections can have negative effects on your users who may
not be able to connect to the database.


Avoid full table scans
query only the data you need. avoid SELECT *.
use pruning to reduce the quantity of data scanned in a query. (In a
column-oriented database, you should select only the columns you need. also clustering and partitioning is popular)
row-oriented databases, pruning usually centers around table indexes

Know how your database handles commits
commit is a change within a database, such as creating, updating, or deleting
a record, table, or other database objects
Many databases support transactions—
i.e., a notion of committing several operations simultaneously in a way that maintains
a consistent state.
The purpose of a transaction is to keep a consistent state of a database
both while it’s active and in the event of a failure. Transactions also handle isolation
when multiple concurrent events might be reading, writing, and deleting from the
same database objects. Without transactions, users would get potentially conflicting
information when querying a database

Does your
database handle writes and updates in an ACID-compliant manner?
Let’s briefly consider three databases to understand the impact of commits (note these
examples are current as of the time of this writing). First, suppose we’re looking at
a PostgreSQL RDBMS and applying ACID transactions. Each transaction consists of
a package of operations that will either fail or succeed as a group. We can also run
analytics queries across many rows; these queries will present a consistent picture of
the database at a point in time.
The disadvantage of the PostgreSQL approach is that it requires row locking (blocking
reads and writes to certain rows), which can degrade performance in various ways.
PostgreSQL is not optimized for large scans or the massive amounts of data appropriate
for large-scale analytics applications.
Next, consider Google BigQuery. It utilizes a point-in-time full table commit model.
When a read query is issued, BigQuery will read from the latest committed snapshot
of the table. Whether the query runs for one second or two hours, it will read only
from that snapshot and will not see any subsequent changes. BigQuery does not lock
the table while I read from it. Instead, subsequent write operations will create new
commits and new snapshots while the query continues to run on the snapshot where
it started.
To prevent the inconsistent state, BigQuery allows only one write operation at a time.
In this sense, BigQuery provides no write concurrency whatsoever. (In the sense that
it can write massive amounts of data in parallel inside a single write query, it is highly
concurrent.) If more than one client attempts to write simultaneously, write queries
are queued in order of arrival. BigQuery’s commit model is similar to the commit
models used by Snowflake, Spark, and others.
Last, let’s consider MongoDB. We refer to MongoDB as a variable-consistency database.
Engineers have various configurable consistency options, both for the database
and at the level of individual queries. MongoDB is celebrated for its extraordinary
scalability and write concurrency but is somewhat notorious for issues that arise
when engineers abuse it.1
For instance, in certain modes, MongoDB supports ultra-high write performance.
However, this comes at a cost: the database will unceremoniously and silently discard
writes if it gets overwhelmed with traffic. This is perfectly suitable for applications
that can stand to lose some data—for example, IoT applications where we simply
want many measurements but don’t care about capturing all measurements. It is not a
great fit for applications that need to capture exact data and statistics.
None of this is to say these are bad databases. They’re all fantastic databases when
they are chosen for appropriate applications and configured correctly. The same goes
for virtually any database technology.


Vacuum dead records
As these old records accumulate
in the database filesystem, they eventually no longer need to be referenced. You
should remove these dead records in a process called vacuuming.
deleting dead database records

Leverage cached query results
results of the query were stored and available
for instant retrieval


Queries on Streaming Data


Basic query patterns on streams


The fast-follower approach


Windows, triggers, emitted statistics, and late-arriving data
Windows are an essential feature in streaming queries and processing. Windows are
small batches that are processed based on dynamic triggers. Windows are generated
dynamically over time in some ways. Let’s look at some common types of windows:
session, fixed-time, and sliding

A session window groups events that occur close together, and filters
out periods of inactivity when no events occur.

Fixed-time windows. A fixed-time (aka tumbling) window features fixed time periods
that run on a fixed schedule and processes all data since the previous window is
closed. This is similar to traditional batch ETL


Sliding windows. Events in a sliding window are bucketed into windows of fixed time
length, where separate windows might overlap

Watermarks. A
watermark (Figure 8-8) is a threshold used by a window to determine whether data in
a window is within the established time interval or whether it’s considered late. If data
arrives that is new to the window but older than the timestamp of the watermark, it is
considered to be late-arriving data.


Combining streams with other data
Conventional table joins.
Enrichment.
Stream-to-stream joining.



## Data Modeling

Data modeling involves deliberately choosing a coherent structure for
data and is a critical step to make data useful for the business.

The
growing popularity of data management (in particular, data governance and data
quality) is pushing the need for coherent business logic.


A data model represents the way data relates to the real world. It reflects how the
data must be structured and standardized to best reflect your organization’s processes,
definitions, workflows, and logic.

When modeling data, it’s critical to focus on translating the model to business
outcomes.

Conceptual
Contains business logic and rules and describes the system’s data, such as schemas,
tables, and fields (names and types). When creating a conceptual model,
it’s often helpful to visualize it in an entity-relationship (ER) diagram, which
is a standard tool for visualizing the relationships among various entities in
your data (orders, customers, products, etc.). For example, an ER diagram might
encode the connections among customer ID, customer name, customer address,
and customer orders. Visualizing entity relationships is highly recommended for
designing a coherent conceptual data model.

Logical
Details how the conceptual model will be implemented in practice by adding
significantly more detail. For example, we would add information on the types of
customer ID, customer names, and custom addresses. In addition, we would map
out primary and foreign keys.
Physical
Defines how the logical model will be implemented in a database system. We
would add specific databases, schemas, and tables to our logical model, including
configuration details.


Another important consideration for data modeling is the grain of the data, which is
the resolution at which data is stored and queried. The grain is typically at the level
of a primary key in a table, such as customer ID, order ID, and product ID; it’s often
accompanied by a date or timestamp for increased fidelity.

In general, you should strive to model your data at the lowest level of grain possible. From here, it’s easy to aggregate this highly granular dataset.


Normalization
Normalization is a database data modeling practice that enforces strict control over
the relationships of tables and columns within a database. The goal of normalization
is to remove the redundancy of data within a database and ensure referential integrity.
Basically, it’s don’t repeat yourself (DRY) applied to data in a database.

Denormalized
No normalization. Nested and redundant data is allowed.
First normal form (1NF)
Each column is unique and has a single value. The table has a unique primary
key.
Second normal form (2NF)
The requirements of 1NF, plus partial dependencies are removed.
Third normal form (3NF)
The requirements of 2NF, plus each table contains only relevant fields related to
its primary key and has no transitive dependencies.

A partial dependency occurs when a subset of fields in
a composite key can be used to determine a nonkey column of the table. A transitive
dependency occurs when a nonkey field depends on another nonkey field.


Additional normal forms exist (up to 6NF in the Boyce-Codd system), but these are
much less common than the first three.

Although denormalization may
seem like an antipattern, it’s common in many OLAP systems that store semistructured
data.

## Techniques for Modeling Batch Analytical Data

The big approaches
you’ll likely encounter are Kimball, Inmon, and Data Vault.

In practice, some of these techniques can be combined. For example, we see some
data teams start with Data Vault and then add a Kimball star schema alongside it.

### Inmon
Cretead in 1989
The goal of the data warehouse
was to separate the source system from the analytical system.

The four critical parts of a data warehouse can be described as follows:
Subject-oriented
The data warehouse focuses on a specific subject area, such as sales or marketing.
Integrated
Data from disparate sources is consolidated and normalized.
Nonvolatile
Data remains unchanged after data is stored in a data warehouse.
Time-variant
Varying time ranges can be queried.

relentless emphasis on ETL

Data from key business source systems is ingested and integrated into a highly
normalized (3NF) data warehouse that often closely resembles the normalization
structure of the source system itself; data is brought in incrementally, starting with
the highest-priority business areas.

The data warehouse represents
a “single source of truth,

modeling data in a data mart is a star schem


source systems -> normalized data warehouse -> data marts

### Kimball

Kimball is very much on the opposite end of
Inmon

Created by Ralph Kimball in the early 1990s, this approach to data modeling
focuses less on normalization, and in some cases accepting denormalization

Whereas Inmon integrates data from across the business in the data warehouse, and
serves department-specific analytics via data marts, the Kimball model is bottom-up,
encouraging you to model and serve department or business analytics in the data
warehouse itself

The Kimball approach effectively makes the data mart the data warehouse
itself. This may enable faster iteration and modeling than Inmon, with the trade-off
of potential looser data integration, data redundancy, and duplication.


In Kimball’s approach, data is modeled with two general types of tables: facts and
dimensions. You can think of a fact table as a table of numbers, and dimension tables
as qualitative data referencing a fact. Dimension tables surround a single fact table in
a relationship called a star schema (Figure 8-14).10 Let’s look at facts, dimensions, and
star schemas.

Fact tables
contains
factual, quantitative, and event-related data. The data in a fact table is immutable
because facts relate to events
Therefore, fact tables don’t change and are append-only.
Fact tables are typically narrow and long, meaning they have not a lot of columns but
a lot of rows that represent events. Fact tables should be at the lowest grain possible.

Queries against a star schema start with the fact table. Each row of a fact table should
represent the grain of the data. Avoid aggregating or deriving data within a fact table.
If you need to perform aggregations or derivations, do so in a downstream query,
data mart table, or view. Finally, fact tables don’t reference other fact tables; they
reference only dimensions.

data types in the
fact table are all numbers (integers and floats); there are no strings


Dimension tables

Dimension tables provide the reference data, attributes, and relational
context for the events stored in fact tables. Dimension tables are smaller than fact tables and take an opposite shape, typically wide and short
When joined to a fact
table, dimensions can describe the events’ what, where, and when. Dimensions are
denormalized, with the possibility of duplicate data

dates are typically stored in a date dimension, allowing you
to reference the date key (DateKey) between the fact and date dimension table


slowly changing dimension (SCD) is necessary to track changes in dimensions
Type 1
Overwrite existing dimension records. This is super simple and means you have
no access to the deleted historical dimension records
Type 2
Keep a full history of dimension records. When a record changes, that specific
record is flagged as changed, and a new dimension record is created that reflects
the current status of the attributes.
Type 3
A Type 3 SCD is similar to a Type 2 SCD, but instead of creating a new row, a
change in a Type 3 SCD creates a new field

Type 1 is the default behavior of most data warehouses,
and Type 2 is the one we most commonly see used in practice.


Star schema
The star schema represents the data
model of the business.
Unlike highly normalized approaches to data modeling, the
star schema is a fact table surrounded by the necessary dimensions. This results in
fewer joins than other data models, which speeds up query performance. Another
advantage of a star schema is it’s arguably easier for business users to understand and
use.

Because a star schema has one fact table, sometimes you’ll have multiple star schemas
that address different facts of the business.

You should be aware
that this mode is appropriate only for batch data and not for streaming data

### Data Vault

Whereas Kimball and Inmon focus on the structure of business logic in the data
warehouse, the Data Vault offers a different approach to data modeling

1990s

Instead of representing business
logic in facts, dimensions, or highly normalized tables, a Data Vault simply loads data
from source systems directly into a handful of purpose-built tables in an insert-only
manner.

data models need to be agile, flexible, and scalable;
the Data Vault methodology aims to meet this need. The goal of this methodology
is to keep the data as closely aligned to the business as possible, even while the
business’s data evolves.

A Data Vault model consists of three main types of tables: hubs, links, and satellites
(Figure 8-15). In short, a hub stores business keys, a link maintains relationships
among business keys, and a satellite represents a business key’s attributes and context

Please be
aware that the Data Vault model can be used with other data modeling techniques. It’s
not unusual for a Data Vault to be the landing zone for analytical data, after which
it’s separately modeled in a data warehouse, commonly using a star schema
The Data
Vault model also can be adapted for NoSQL and streaming data sources.

### Wide denormalized tables
The strict modeling approaches we’ve described, especially Kimball and Inmon,
were developed when data warehouses were expensive, on premises, and heavily
resource-constrained with tightly coupled compute and storage. While batch data
modeling has traditionally been associated with these strict approaches, more relaxed
approaches are becoming more common.

First, the popularity of the cloud means that storage is
dirt cheap. It’s cheaper to store data than agonize over the optimum way to represent
the data in storage. Second, the popularity of nested data (JSON and similar) means
schemas are flexible in source and analytical systems.

You have the option to rigidly model your data as we’ve described, or you can choose
to throw all of your data into a single wide table. A wide table is just what it sounds
like: a highly denormalized and very wide collection of many fields, typically created
in a columnar database. A field may be a single value or contain nested data. The data
is organized along with one or multiple keys; these keys are closely tied to the grain of
the data.

A wide table can potentially have thousands of columns, whereas fewer than 100
are typical in relational databases
Wide tables are usually sparse; the vast majority
of entries in a given field may be null.

wide schema
in a relational database dramatically slows reading because each row must allocate all
the space specified by the wide schema, and the database must read the contents of
each row in its entirety. On the other hand, a columnar database reads only columns
selected in a query, and reading nulls is essentially free.

Analytics queries on wide tables often run faster than equivalent queries on highly
normalized data requiring many joins. Removing joins can have a huge impact on
scan performance

The biggest criticism is as you blend your data, you lose the business logic in your
analytics. Another downside is the performance of updates to things like an element
in an array, which can be very painful.


We suggest using a wide table when you don’t care about data modeling, or when
you have a lot of data that needs more flexibility than traditional data-modeling rigor
provides. Wide tables also lend themselves to streamin

### Modeling Streaming Data

Because of the unbounded and continuous nature of
streaming data, translating batch techniques like Kimball to a streaming paradigm
is tricky, if not impossible

update a Type-2 slowly changing dimension without bringing your data
warehouse to its knees?

There isn’t (yet) a consensus approach
on streaming data modeling.
traditional batch-oriented data modeling doesn’t apply to
streaming. A few suggested the Data Vault as an option for streaming data modeling.

As you may recall, two main types of streams exist: event streams and CDC

Most
of the time, the shape of the data in these streams is semistructured, such as JSON.
The challenge with modeling streaming data is that the payload’s schema might
change on a whim

anticipate
changes in the source data and keep a flexible schema. This means there’s no rigid
data model in the analytical database.


## Transformations

Transformations manipulate, enhance, and save data for downstream use, increasing
its value in a scalable, reliable, and cost-effective manner.

A query retrieves the data from various
sources based on filtering and join logic. A transformation persists the results for
consumption by additional transformations or queries. These results may be stored
ephemerally or permanently.


Transformations critically rely on one of the major undercurrents in this book:
orchestration. Orchestration combines many discrete operations, such as intermediate
transformations, that store data temporarily or permanently for consumption by
downstream transformations or serving. Increasingly, transformation pipelines span
not only multiple tables and datasets but also multiple systems.

### Batch Transformations

Batch transformations run on discrete chunks of data
Distributed joins break a logical join (the
join defined by the query logic) into much smaller node joins that run on individual
servers in the cluste

Broadcast join. A broadcast join is generally asymmetric, with one large table distributed
across nodes and one small table that can easily fit on a single node

Shuffle hash join. If neither table is small enough to fit on a single node, the query
engine will use a shuffle hash join

ETL, ELT, and data pipelines

SQL and code-based transformation tools often see engineers doing things in Python and
Spark that could be more easily and efficiently done in SQL

1. How difficult is it to code the transformation in SQL?
2. How readable and maintainable will the resulting SQL code be?
3. Should some of the transformation code be pushed into a custom library for
future reuse across the organization?


A few top-level things to keep in mind when coding in native Spark:
1. Filter early and often.
2. Rely heavily on the core Spark API, and learn to understand the Spark native way
of doing things. Try to rely on well-maintained public libraries if the native Spark
API doesn’t support your use case. Good Spark code is substantially declarative.
3. Be careful with UDFs.
4. Consider intermixing SQL.


Update patterns
Truncate and reload
Insert only.
Delete
Upsert/merge The upsert/merge pattern was originally designed for rowbased
databases. BigQuery allows us to stream insert new records into a table, and
then supports specialized materialized views that present an efficient, near real-time
deduplicated table view

Schema updates stores raw JSON in a field while storing
frequently accessed data in adjacent flattened fields

Data wrangling Data wrangling takes messy, malformed data and turns it into useful, clean data. This
is generally a batch transformation process

MapReduce A simple MapReduce job consists of a collection of map tasks that read individual
data blocks scattered across the nodes, followed by a shuffle that redistributes result
data across the cluster and a reduce step that aggregates data on each node
processing
pattern of Hadoop
MapReduce was the defining batch data transformation pattern of the big data era

Post-
MapReduce processing does not truly discard MapReduce; it still includes the elements
of map, shuffle, and reduce, but it relaxes the constraints of MapReduce to
allow for in-memory caching.18 Recall that RAM is much faster than SSD and HDDs
in transfer speed and seek time. Persisting even a tiny amount of judiciously chosen
data in memory can dramatically speed up specific data processing tasks and utterly
crush the performance of MapReduce.

For example, Spark, BigQuery, and various other data processing frameworks were
designed around in-memory processing. These frameworks treat data as a distributed
set that resides in memory. If data overflows available memory, this causes a spill to
disk. The disk is treated as a second-class data-storage layer for processing, though it
is still highly valuable


## Materialized Views, Federation, and Query Virtualization

First, let’s review views to set the stage for materialized views. A view is a database
object that we can select from just like any other table. In practice, a view is just a
query that references other tables. When we select from a view, that database creates
a new query that combines the view subquery with our query. The query optimizer
then optimizes and runs the full query.
views can serve a security role.
view might be used to provide a current deduplicated picture of data.
views can be used to present common data access patterns

A
potential disadvantage of (nonmaterialized) views is that they don’t do any precomputation

Federated queries
Federated queries are a database feature that allows an OLAP database to select from
an external data source,

Data virtualization is closely related to federated queries, but this typically entails a
data processing and query system that doesn’t store data internally
query pushdown aims to move as much work as possible to the source databases
This serves two purposes: first, it offloads computation from the
virtualization layer, taking advantage of the query performance of the source. Second,
it potentially reduces the quantity of data that must push across the network, a critical
bottleneck for virtualization performance.


Keep credentials hidden; avoid copying and pasting passwords, access tokens, or
other credentials into code or unencrypted files.
As we transform data,
data lineage tools become invaluable.
critical to ensure that the data
you’re using is free of defects and represents ground truth. If MDM is an option at
your company, pursue its implementation.