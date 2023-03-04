# Data Generation in Source Systems

Before you get raw data, you must understand where the data exists, how it is generated, and its characteristics and quirks. Remember that, source systems are generally outside the control of the data engineer.

Things to have in mind:
- **Security:** is data encrypted, access over public internet or VPN, keys token secured, do you trust the source system.
- **Management:** who manages the data, what is the data quality, what is the schema, regulations.
- **DataOps:** automation, observability, incident response.
- **Architecture:** reliability, durability, availability.
- **Software engineering:** networking, authentication, access patterns, orchestration.


<div class="page"/>

## Files and Unstructured Data
A file is a sequence of bytes, typically stored on a disk. These files have their quirks and can be:
- structured (Excel, CSV),
- semi-structured (JSON, XML, CSV),
- unstructured (TXT, CSV).

In structured there are also very popular formats for data processing (especially big data):
- Parquet,
- ORC,
- Avro.

---
## APIs

APIs are a standard exchanging data in the cloud, for SaaS platforms, and between internal company systems.

**REST**
- a currently the dominant API paradigm,
- stands for representational state transfer,
- stipulates basic properties of interactions,
- is built around HTTP verbs, such as GET and PUT.

One of the principal ideas of REST is that interactions are stateless; each REST call is independent. REST calls can change the system’s state, but these changes are global, applying to the full system rather than a current session.

Pros of using as a data source:
- data providers frequently supply client libraries in various languages,
- client libraries handle critical details such as authentication and map fundamental methods into accessible classes,
- various services and open source libraries have emerged to interact with APIs and manage data synchronization.

**GraphQL**

GraphQL was created at Facebook as a query language for application data and an alternative to generic REST APIs. Whereas REST APIs generally restrict your queries to a specific data model, GraphQL opens up the possibility of retrieving multiple data models in a single request. This allows for more flexible and expressive queries than with REST. GraphQL is built around JSON and returns data in a shape resembling the JSON query.


**Webhooks**

Webhooks are a simple event-based data-transmission pattern.

The data source can be an application backend, a web page, or a mobile app. When specified events happen in the source system, this triggers a call to an HTTP endpoint hosted by the data consumer. Notice that the connection goes from the source system to the data sink, the opposite of typical APIs. For this reason, webhooks are often called **`reverse APIs`**.

**RPC and gRPC**

A remote procedure call (RPC) is commonly used in distributed computing. It allows you to run a procedure on a remote system.

Many Google services, such as Google Ads and GCP, offer gRPC APIs. gRPC is built around the Protocol Buffers open data serialization standard, also developed by Google. Like GraphQL, gRPC imposes much more specific technical standards than REST.

## Application Databases (OLTP Systems)

An application database stores the state of an application. Often referred to as transactional databases. OLTP databases work well as application backends when thousands or even millions of users might be interacting with the application simultaneously, updating and writing data concurrently. OLTP systems are less suited to use cases driven by analytics at scale, where a single query must scan a vast amount of data.

Example: database that stores account balances for bank accounts. As customer transactions
and payments happen, the application updates bank account balances.

OLTP database:
- reads and writes individual data records at a high rate
- supports low latency (can SELECT or UPDATE a row in less that a millisecond)
- supports high concurrency (can handle thousands of reads and writes per second)

Often, small companies run analytics directly on an OLTP. This pattern works in the short term but is ultimately not scalable.

**ACID**

```
A: atomicity - entire transaction should run with updates to both account balances or fail without updating either account balance. That is, the whole operation should happen as a transaction.
C: consistency - any database read will return the last written version of the retrieved item.
I: isolation - if two updates are in flight concurrently for the same thing, the end database state will be consistent with the sequential execution of these updates in the order they were submitted.
D: durability - committed data will never be lost, even in the event of power loss.
```

Note that ACID characteristics are not required to support application backends, and relaxing these constraints can be a considerable boon to performance and scale. However, ACID characteristics guarantee that the database will maintain a consistent picture of the world, dramatically simplifying the app developer’s task. All engineers (data or otherwise) must understand operating with and without ACID. For instance, to improve performance, some distributed databases use relaxed consistency constraints, such as eventual consistency, to improve performance.

---
## Online Analytical Processing System (OLAP)

In contrast to an OLTP system, an online analytical processing (OLAP) system is built to run large analytics queries and is typically inefficient at handling lookups of individual records. Any query typically involves scanning a minimal data block, often 100 MB or more in size. Trying to look up thousands of individual items per second in such a system will bring it to its knees unless it is combined with a caching layer designed for this use case.

---
## Change Data Capture

Change data capture (CDC) is a method for extracting each change event (insert, update, delete) that occurs in a database. CDC is frequently leveraged to replicate between databases in near real time or create an event stream for downstream processing. CDC is handled differently depending on the database technology. Relational databases often generate an event log stored directly on the database server that can be processed to create a stream. (See “Database Logs” on page 161.) Many cloud NoSQL databases can send a log or event stream to a target storage location.

**Logs**
Database logs are extremely useful in data engineering, especially for CDC to generate event streams from database changes. Batch logs are often written continuously to a file.

All logs track events and event metadata. At a minimum, a log should capture:
- Who: The human, system, or service account associated with the event (e.g., a web browser user agent or a user ID)
- What happened: The event and related metadata
- When: The timestamp of the event

Logs are encoded in a few ways:
- Binary-encoded logs: These encode data in a custom compact format for space efficiency and fast I/O. Database logs are a standard example.
- Semi-structured logs: as text in an object serialization format (JSON). Semi-structured logs are machine-readable and portable. However, they are much less efficient than binary logs.
- Plain-text (unstructured) logs: These essentially store the console output from software.

---
## CRUD

```yaml
C: create
R: read
U: update
D: delete
```

CRUD is a transactional pattern commonly used in programming and represents the four basic operations of persistent storage. CRUD is the most common pattern for storing application state in a database.

CRUD is a widely used pattern in software applications, and you’ll commonly find CRUD used in APIs and databases. For example, a web application will make heavy use of CRUD for RESTful HTTP requests and storing and retrieving data from a database. As with any database, we can use snapshot-based extraction to get data from a database where our application applies CRUD operations. On the other hand, event extraction with CDC gives us a complete history of operations and potentially allows for near real-time analytics.

---
## Insert-Only

The insert-only pattern retains history directly in a table containing data. Rather than updating records, new records get inserted with a timestamp indicating when they were created Following a CRUD pattern, you would simply update the record if the customer changed their address. With the insert-only pattern, a new address record is inserted with the same customer ID. To read the current customer address by customer ID, you would look up the latest record under that ID. In a sense, the insert-only pattern maintains a database log directly in the table itself, making it especially useful if the application needs access to history.

Insert-only has a couple of disadvantages:
- tables can grow quite large, especially if data frequently changes, since each change is inserted into the table.
- record lookups incur extra overhead because looking up the current state involves running MAX (created_timestamp). If hundreds or thousands of records are under a single ID, this lookup operation is expensive to run.


<div class="page"/>

## Database characteristics

**Database management system (DBMS)**: consists of a storage engine, query optimizer, disaster recovery, and other key components for managing the database system.

**Lookups**: How does the database find and retrieve data? Indexes can help speed up lookups, but not all databases have indexes.

**Query optimizer**: Does the database utilize an optimizer? What are its characteristics?

**Scaling and distribution**: does the database scale with demand? What scaling strategy does it deploy? Does it scale horizontally (more database nodes) or vertically (more resources on a single machine)?

**Modeling patterns**: what modeling patterns work best with the database (e.g., data normalization or wide tables)?

**CRUD**: How is data queried, created, updated, and deleted in the database? Every type of database handles CRUD operations differently.

**Consistency**: Is the database fully consistent, or does it support a relaxed consistency model (e.g., eventual consistency)? Does the database support optional consistency modes for reads and writes (e.g., strongly consistent reads)?

---
## Relational databases

Ideal for storing rapidly changing application state. The challenge for data engineers is to determine how to capture state information over time.

Data is stored in tables. Table has:
- relations (rows)
- fields (columns)
- schema (a sequence of columns with assigned static types such as string, integer, or float)
- primary key (unique field for each row in the table)
- foreign keys
- index (typically by a primary key)

**`Normalization`** is a strategy for ensuring that data in records is not duplicated in multiple places, thus avoiding the need to update states in multiple locations at once and preventing inconsistencies.

RDBMS systems have:
- ACID compliance,
- have normalized schema,
- support for high transaction rates

Ideal for storing rapidly changing application state. The challenge for data engineers is to determine how to capture state information over time.

---
## Non-relational databases: NoSQL

NoSQL, which stands for not only SQL, refers to a whole class of databases that abandon the relational paradigm. NoSQL describes a universe of “new school” databases, alternatives to relational databases.

Dropping relational constraints can improve:
- performance
- scalability,
- schema flexibility.

NoSQL databases also typically abandon various RDBMS characteristics:
- strong consistency,
- joins,
- a fixed schema.

---
## NoSQL database types

Database types:
- key-value,
- document,
- wide-column,
- graph, search,
- time series.

---
**Key-value stores**
Retrieves records using a key that uniquely identifies each record. Works like dictionary in Python (hash map).

Key-value stores encompass several NoSQL database types - for example, document stores and wide column databases. One of the most popular implementation is in-memory key-value database.

In-memory key-value databases:
- for caching session data for web and mobile applications
- ultra-fast lookup
- high concurrency
- temporary storage


Examples: TODO

---
**Document stores**
Document store is a specialized key-value store and a nested object; we can usually think of each document as a JSON object. Documents are stored in collections and retrieved by key.

```
Table -> Collection
Row -> Document, items, entity
```

Document store:
- doesn't support JOINs (data cannot be easily normalized). Ideally, all related data can be stored in the same document
- doesn't enforce schema or types
- not ACID compliant
- generally must run a full scan to extract all data from a collection (you can set up an index to speed up the process)


Example:
- `users`: collection
- `id`: key

```json
{
  "users": [
    {
      "id": 1234,
      "name": {
        "first": "Joe",
        "last": "Reis"
      },
      "favorite_bands": [
        "AC/DC",
        "Slayer",
        "WuTang Clan",
        "Action Bronson"
      ]
    },
    {
      "id": 1235,
      "name": {
        "first": "Matt",
        "last": "Housley"
      },
      "favorite_bands": [
        "Dave Matthews Band",
        "Creed",
        "Nickelback"
      ]
    }
  ]
}
```

Examples:

---
**Wide-column**
Wide-column database:
- stores massive amounts of data (petabytes of data),
- high transaction rates (millions of requests per second),
- extremely low latency (sub-10ms latency),
- can scale to extreme.

It also:
- rapid scans of massive amounts of data,
- do not support complex queries,
- only a single index (the row key) for lookups,
- which means that engineers must generally extract data and send it to a secondary analytics system to run complex queries to deal with these limitations.

Example:

---
**Graph databases**
Graph databases:
- store data with a mathematical graph structure (as a set of nodes and edges),
- are a good fit when you want to analyze the connectivity between elements.


Example:
- Neo4j

---
**Search**
A search database is use to search your data’s complex and straightforward semantic and structural characteristics. Search databases are popular for fast search and retrieval. Queries can be optimized and sped up with the use of indexes.

Use cases exist for a search database:
- text search (involves searching a body of text for keywords or phrases, matching on exact, fuzzy, or semantically similar matches),
- log analysis (Log analysis is typically used for anomaly detection, real-time monitoring, security analytics, and operational analytics).

Examples:
- Elasticsearch
- Apache Solr

---
**Time series**
A time series is a series of values organized by time. Any events that are recorded over time—either regularly or sporadically—are time-series data.

The schema for a time series typically contains a timestamp and a small set of fields.

A time-series database:
- optimized for retrieving and statistical processing of time-series data.
- address the needs of growing, high-velocity data volumes from IoT, event and application logs, etc.
- utilize memory buffering to support fast writes and reads.
- suitable for operational analytics
- joins are not common, though some quasi time-series databases such as Apache Druid support joins.

Example:
- Apache Druid

<div class="page"/>

## Message Queues and Event-Streaming Platforms

A message is raw data communicated across two or more systems. A message is typically sent through a message queue from a publisher to a consumer, and once the message is delivered, it is removed from the queue.

Stream is an append-only log of event records. You’ll use streams when you care about what happened over many events. Because of the append-only nature of streams, records in a stream are persisted over a long retention window—often weeks or months—allowing for complex operations on records such as aggregations on multiple records or the ability to rewind to a point in time within the stream.

It becomes popular because:
- events can both trigger work in the application and feed near real-time analytics
- are used in numerous ways, from routing messages between microservices ingesting millions of events per second of event data from web, mobile, and IoT applications.

A message queue is a mechanism to asynchronously send data (usually as smal individual messages, in the kilobytes) between discrete systems using a publish and subscribe model. Data is published to a message queue and is delivered to one or more subscribers. The subscriber acknowledges receipt of the message, removing it from the queue.

Example of a message:
```json
{
	"Key":"Order # 12345",
	"Value":"SKU 123, purchase price of $100",
	"Timestamp":"2023-01-02 06:01:00"
}
```

Critical characteristics of an event-streaming platform:
- topics: collection of related events
- stream partitions: are subdivisions of a stream into multiple streams. Having multiple streams allows for parallelism and higher throughput. Messages are distributed across partitions by partition key.
- fault tolerance and resilience: if a node goes down, another node replaces it, and the stream is still accessible.

**`Hotspotting`** - a disproportionate number of messages delivered to one partition.

Some things to keep in mind with message queues are frequency of delivery, message ordering, and scalability.

**Message ordering and delivery**
The order in which messages are created, sent, and received can significantly impact downstream subscribers.

Message queues often apply a fuzzy notion of order and first in, first out (**`FIFO`**). Strict FIFO means that if message A is ingested before message B, message A will always be delivered before message B. In practice, messages might be published and received out of order, especially in highly distributed message systems.

In general, don’t assume that your messages will be delivered in order unless your message queue technology guarantees it. You typically need to design for out-of-order message delivery.


**Delivery frequency**
Messages can be sent:
- exactly once (after the subscriber acknowledges the message, the message disappears and won’t be delivered again),
- or at least once (can be consumed by multiple subscribers or by the same subscriber more than once).

Ideally, systems should be **`idempotent`**. In an idempotent system, the outcome of processing a message once is identical to the outcome of processing it multiple times.

**Scalability**

The most popular message queues utilized in event-driven applications are horizontally scalable, running across multiple servers.

