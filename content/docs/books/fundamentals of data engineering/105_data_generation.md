---
weight: 5
title: "05: Data Generation in Source Systems"
---

# Data Generation in Source Systems
---

Understanding the location, generation process, and unique properties of data is critical before working with raw data. It's important to keep in mind that source systems are typically beyond the control of data engineers.

Things to have in mind:
- **Security:** is data encrypted, access over public internet or VPN, keys token secured, do you trust the source system.
- **Management:** who manages the data, what is the data quality, what is the schema, regulations.
- **DataOps:** automation, observability, incident response.
- **Architecture:** reliability, durability, availability.
- **Software engineering:** networking, authentication, access patterns, orchestration.

## Data sources
---

### Files and Unstructured Data
A file is a sequence of bytes, typically stored on a disk. These files have their quirks and can be:
- structured (Excel, CSV),
- semi-structured (JSON, XML, CSV),
- unstructured (TXT, CSV).

In structured there are also very popular formats for data processing (especially big data):
- `Parquet`,
- ORC,
- Avro.


### APIs

APIs are a standard exchanging data in the cloud, for SaaS platforms, and between internal company systems.

**REST**
- dominant API paradigm,
- stands for representational state transfer,
- stipulates basic properties of interactions,
- is built around HTTP verbs, such as GET and PUT.

REST interactions are stateless and each call is independent, meaning changes apply to the full system, not just the current session. Other paradigms:
- GraphQL
- Webhooks
- RPC


### Application Databases (OLTP Systems)

An application database, also known as a transactional database or OLTP database, stores the state of an application and is suitable for application backends with high concurrency. However, it is not well-suited for analytics at scale where a single query needs to scan a large amount of data. Often, small companies run analytics directly on an OLTP. This pattern works in the short term but is ultimately not scalable. Characteristics:
- reads and writes individual data records at a high rate
- supports low latency (can SELECT or UPDATE a row in less that a millisecond)
- supports high concurrency (can handle thousands of reads and writes per second)


**ACID**


```
A: atomicity - entire transaction should run with updates to both account balances or fail without updating either account balance. That is, the whole operation should happen as a transaction.

C: consistency - any database read will return the last written version of the retrieved item.

I: isolation - if two updates are in flight concurrently for the same thing, the end database state will be consistent with the sequential execution of these updates in the order they were submitted.

D: durability - committed data will never be lost, even in the event of power loss.
```


ACID not required for app backends, but they guarantee consistency. Relaxing these constraints can improve performance and scale, but all engineers must understand the implications of operating with and without ACID. Some distributed databases use eventual consistency to improve performance.


### Online Analytical Processing System (OLAP)

OLAP systems are designed to handle large analytics queries but are not efficient in handling lookups of individual records. Such systems typically involve scanning large data blocks of at least 100 MB in size for each query. Trying to perform thousands of individual lookups per second can overload the system unless combined with a caching layer specifically designed for this purpose.

---
## Important terms
---

### Change Data Capture

Change data capture (CDC) extracts each change event (insert, update, delete) that occurs in a database. CDC is used to replicate between databases in near real time or create an event stream for downstream processing. CDC is handled differently depending on the database technology, with relational databases often generating an event log that can be processed, while many cloud NoSQL databases can send a log or event stream to a target storage location.

### Logs

Database logs are essential in data engineering, particularly for change data capture (CDC) to generate event streams from database changes. They capture events and metadata such as the user or system responsible for the event, the details of the event, and the timestamp.

Logs have different encodings. Binary-encoded logs are efficient in terms of space and I/O, while semi-structured logs are portable and machine-readable. Plain-text logs store console output and are the least efficient.

### CRUD

```
C: create
R: read
U: update
D: delete
```

CRUD is a common pattern used in programming and represents the four basic operations of persistent storage: Create, Read, Update, and Delete. It's widely used in APIs and databases for storing and retrieving data. We can use snapshot-based extraction to get data from a database where CRUD operations are applied or event extraction with CDC for near real-time analytics.


### Insert-Only

The insert-only pattern stores history directly in a table by inserting new records with a timestamp instead of updating existing ones. This makes it useful if the application needs access to historical data. To retrieve the current customer address using this pattern, you would look up the latest record under the customer ID. However, tables can grow quite large, and record lookups may be expensive for large datasets.

Disadvantages of the insert-only pattern:
- tables can grow quite large,
- record lookups incur extra overhead,
- this lookup operation is expensive to run.


## Database considerations
---

**Database management system (DBMS)**: consists of a storage engine, query optimizer, disaster recovery, and other key components for managing the database system.

**Lookups**: How does the database find and retrieve data? Indexes can help speed up lookups, but not all databases have indexes.

**Query optimizer**: Does the database utilize an optimizer? What are its characteristics?

**Scaling and distribution**: does the database scale with demand? What scaling strategy does it deploy? Does it scale horizontally (more database nodes) or vertically (more resources on a single machine)?

**Modeling patterns**: what modeling patterns work best with the database (e.g., data normalization or wide tables)?

**CRUD**: How is data queried, created, updated, and deleted in the database? Every type of database handles CRUD operations differently.

**Consistency**: Is the database fully consistent, or does it support a relaxed consistency model (e.g., eventual consistency)? Does the database support optional consistency modes for reads and writes (e.g., strongly consistent reads)?


## Relational databases
---

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


## Non-relational databases: NoSQL
---

NoSQL, which stands for not only SQL, refers to a whole class of databases that abandon the relational paradigm. NoSQL describes a universe of “new school” databases, alternatives to relational databases.

Dropping relational constraints can improve:
- performance
- scalability,
- schema flexibility.

NoSQL databases also typically abandon various RDBMS characteristics:
- strong consistency,
- joins,
- a fixed schema.


### Key-value stores
Retrieves records using a key that uniquely identifies each record. Works like dictionary in Python (hash map).

Key-value stores encompass several NoSQL database types - for example, document stores and wide column databases. One of the most popular implementation is in-memory key-value database.

In-memory key-value databases:
- for caching session data for web and mobile applications
- ultra-fast lookup
- high concurrency
- temporary storage


### Document stores
Document store is a specialized key-value store and a nested object; we can usually think of each document as a JSON object. Documents are stored in collections and retrieved by key.

| Relational database | Document store          |
|---------------------|-------------------------|
| table               | collection              |
| row                 | document, items, entity |

Document store:
- doesn't support JOINs (data cannot be easily normalized). Ideally, all related data can be stored in the same document
- doesn't enforce schema or types
- not ACID compliant
- generally must run a full scan to extract all data from a collection (you can set up an index to speed up the process)


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


### Wide-column

- stores massive amounts of data (petabytes of data),
- high transaction rates (millions of requests per second),
- extremely low latency (sub-10ms latency),
- can scale to extreme.
- rapid scans of massive amounts of data,
- do not support complex queries,
- only a single index (the row key) for lookups,
- which means that engineers must generally extract data and send it to a secondary analytics system to run complex queries to deal with these limitations.

### Graph databases
- store data with a mathematical graph structure (as a set of nodes and edges),
- are a good fit when you want to analyze the connectivity between elements.
- example: Neo4j

### Search
A search database is use to search your data’s complex and straightforward semantic and structural characteristics. Search databases are popular for fast search and retrieval. Queries can be optimized and sped up with the use of indexes. Examples are Elasticsearch, Apache Solr.

Use cases exist for a search database:
- text search (involves searching a body of text for keywords or phrases, matching on exact, fuzzy, or semantically similar matches),
- log analysis (Log analysis is typically used for anomaly detection, real-time monitoring, security analytics, and operational analytics).

### Time series
A time series is a series of values organized by time. Any events that are recorded over time—either regularly or sporadically—are time-series data. Example is Apache Druid. The schema for a time series typically contains a timestamp and a small set of fields.

A time-series database:
- optimized for retrieving and statistical processing of time-series data.
- address the needs of growing, high-velocity data volumes from IoT, event and application logs, etc.
- utilize memory buffering to support fast writes and reads.
- suitable for operational analytics
- joins are not common, though some quasi time-series databases such as Apache Druid support joins.


## Message Queues and Event-Streaming Platforms
---

A message is data transmitted between systems through a queue, while a stream is an append-only log of event records. Streams are used for long-term storage of event data and support complex operations such as aggregations and rewinding to specific points in time. Messages are typically removed from the queue after being delivered to a consumer.

Reasons why streams have become popular:
1. They enable events to trigger work in the application and feed near real-time analytics.
2. They are used in various ways, including routing messages between microservices and ingesting millions of events per second of event data from web, mobile, and IoT applications.

A message queue is a publish-subscribe mechanism for asynchronous data transmission between discrete systems. Typically, data is sent as small, individual messages, often in kilobytes. The data is published to a message queue and delivered to one or more subscribers. After receiving the message, the subscriber acknowledges receipt, which removes it from the queue.

```json
{
	"Key":"Order # 3245",
	"Value":"SKU 123, purchase price of $3100",
	"Timestamp":"2023-02-03 06:01:00"
}
```

Critical characteristics of an event-streaming platform include `topics`, `stream partitions`, and `fault tolerance and resilience`. Topics are collections of related events, stream partitions allow for parallelism and higher throughput, and fault tolerance ensures the stream remains accessible even if a node goes down.

{{< hint info >}} *Hotspotting* - a disproportionate number of messages delivered to one partition. {{< /hint >}}

### Message ordering and delivery
The order in which messages are created, sent, and received can significantly impact downstream subscribers. Message queues use FIFO (first in, first out) order, but messages may be delivered out of order in distributed systems. Don't assume that messages will be delivered in order unless guaranteed by the message queue technology, and design for out-of-order message delivery.


### Delivery frequency

Messages can be sent in different ways depending on the guarantees required by the use case:

- `Exactly once`: The message is delivered once to the subscriber, ensuring that there is no duplicate processing. After the subscriber acknowledges the message, the message disappears and won't be delivered again.
- `At least once`: The message can be consumed by multiple subscribers or by the same subscriber more than once, ensuring that the message is processed at least once. However, this may result in duplicate processing.

Ideally, systems should be `idempotent`. In an idempotent system, the outcome of processing a message once is identical to the outcome of processing it multiple times.

### Scalability

The most popular message queues utilized in event-driven applications are horizontally scalable, running across multiple servers.

