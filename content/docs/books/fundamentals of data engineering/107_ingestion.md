---
weight: 7
title: "07: Ingestion"
bookHidden: true
---

# Ingestion

Data ingestion involves moving data from one location to another, specifically from source systems to storage. This differs from data integration, which involves merging data from various sources into a single dataset. It is important to note that data ingestion is distinct from internal ingestion within a system, such as when data is copied between tables or temporarily cached in a stream. These processes are considered part of the broader data transformation process. A data pipeline encompasses the architecture, systems, and processes used to move data through the various stages of the data engineering lifecycle.

## Key Engineering Considerations for the Ingestion Phase

Consider use case and data reusability.
Determine data destination and update frequency.
Estimate data volume and ensure format compatibility.
Assess data quality and post-processing requirements.
Consider potential data-quality risks.
Determine if streaming data requires in-flight processing.

## Factors when designing your ingestion architecture:

### Bounded versus unbounded

Unbounded data is data as it exists in reality, as events happen,
either sporadically or continuously, ongoing and flowing. Bounded data is a convenient
way of bucketing data across some sort of boundary, such as time.

Business processes have long imposed artificial bounds on data by cutting discrete
batches.

### Frequency

Ingestion processes can be batch,
micro-batch, or real-time.

Ingestion frequencies vary dramatically from slow to fast
On the
faster side, a CDC system could retrieve new log updates from a source database once
a minute. Even faster, a system might continuously ingest events from IoT sensors
and process these within seconds. 

We note that “real-time” ingestion patterns are becoming increasingly common.
ML models are typically trained on a
batch basis, although continuous online training is becoming more prevalent

Rarely
do data engineers have the option to build a purely near real-time pipeline with no
batch components.

While this data can be written directly into a
database, a streaming ingestion platform such as Amazon Kinesis or Apache Kafka
is a better fit for the application.

While this data can be written directly into a
database, a streaming ingestion platform such as Amazon Kinesis or Apache Kafka
is a better fit for the application.

streaming architectures generally coexist with
batch processing.

### Synchronous versus asynchronous

With synchronous ingestion, the source, ingestion, and destination have complex
dependencies and are tightly coupled.

A, B, and C directly dependent upon one
another. If process A fails, processes B and C cannot start; common in older ETL systems,

With asynchronous ingestion, dependencies can now operate at the level of individual
events, much as they would in a software backend built from microservices
Individual events become available in storage as soon as they are ingested
individually.
each stage of the asynchronous pipeline can process data items as they become
available in parallel across


### Serialization and deserialization

Moving data from source to destination involves serialization and deserialization. As
a reminder, serialization means encoding the data from a source and preparing data
structures for transmission and intermediate storage stages.

ensure that your destination can deserialize the data it receives.

### Throughput and scalability

In theory, your ingestion should never be a bottleneck In practice, ingestion bottlenecks
are pretty standard.

Data throughput and system scalability become critical as
your data volumes grow and requirements change. Design your systems to scale and
shrink to flexibly match the desired data throughput.

handle bursty data ingestion
Built-in buffering
is required to collect events during rate spikes to prevent data from getting lost.
Whenever possible, use managed services that handle the throughput scaling for you.

### Reliability and durability

Reliability
entails high uptime and proper failover for ingestion systems. Durability entails
making sure that data isn’t lost or corrupted.

Some data sources (e.g., IoT devices and caches) may not retain data if it is not
correctly ingested. Once lost, it is gone for good.

Our advice is to evaluate the risks and build an appropriate level of redundancy and
self-healing based on the impact and cost of losing data.
Continually
evaluate the trade-offs and costs of reliability and durability.


### Payload

A payload is the dataset you’re ingesting and has characteristics such as kind, shape,
size, schema and data types, and metadata.

`Kind` consists of type and format. Data has a type—tabular,
image, video, text, etc. The type directly influences the data format or the way it
is expressed in bytes, names, and file extensions.

`shape` describes its dimensions. Examples: Tabular, Semistructured JSON, Unstructured text, Images.

`Size` describes the number of bytes of a payload, which could be compressed or split into chunks.

`Schema and data types`. schema describes the fields and types of data
within those fields. great engineering challenge is understanding
the underlying schema.

Detecting and handling upstream and downstream schema changes Changes in schema
frequently occur in source systems and are often well out of data engineers’ control.
Examples of schema changes include the following:
• Adding a new column
• Changing a column type
• Creating a new table
• Renaming a column

It’s becoming increasingly common for ingestion tools to automate the detection of
schema changes and even auto-update target tables. Engineers must still implement strategies to respond to changes automatically and
alert on changes that cannot be accommodated automatically.
Schema registries. In streaming data, every message has a schema, and these schemas
may evolve between producers and consumers. A schema registry is a metadata
repository used to maintain schema and data type integrity in the face of constantly
changing schemas. Schema registries can also track schema versions and history. It
describes the data model for messages, allowing consistent serialization and deserialization
between producers and consumers.


`Metadata` 
payload often contains
metadata
Metadata can be as critical as the data itself. One of the significant limitations of
the early approach to the data lake—or data swamp, which could become a data
superfund site—was a complete lack of attention to metadata.



### Push versus pull versus poll patterns

push strategy (Figure 7-7) involves a source system sending data to
a target, while a pull strategy (Figure 7-8) entails a target reading data directly from
a source. lines between these strategies are
blurry.
Another pattern related to pulling is polling for data (Figure 7-9). Polling involves
periodically checking a data source for any changes. When changes are detected, the
destination pulls the data as it would in a regular pull situation.

## Batch Ingestion Considerations

Time-based or Size-based

`Time-interval batch ingestion `is widespread in traditional business ETL for data warehousing.
This pattern is often used to process data once a day, overnight during
off-hours, to provide daily reporting, but other frequencies can also be used.

`Size-based batch ingestion` is quite common when data is moved from
a streaming-based system into object storage; ultimately, you must cut the data into
discrete blocks for future processing in a data lake.


Snapshot or Differential Extraction

capture full snapshots of a source system
or differential (sometimes called incremental) updates. While differential updates are ideal for minimizing
network traffic and target storage usage, full snapshot reads remain extremely common
because of their simplicity.

File-Based Export and Ingestion

Data is quite often moved between databases and systems using files. We consider file-based export to be a push-based ingestion pattern. File-based ingestion has several potential advantages over a direct database connection
approach. It is often undesirable to allow direct access to backend systems
for security reasons. With file-based ingestion, export processes are run on the
data-source side, giving source system engineers complete control over what data
gets exported and how the data is preprocessed. Once files are done, they can be
provided to the target system in various ways. Common file-exchange methods are
object storage, secure file transfer protocol (SFTP), electronic data interchange (EDI),
or secure copy (SCP).


ETL Versus ELT


Inserts, Updates, and Batch Size

Batch-oriented systems often perform poorly when users attempt to perform many
small-batch operations rather than a smaller number of large operations. the limits
and characteristics of your tools.


Data Migration

Migrating data to a new database or environment is not usually trivial, and data needs
to be moved in bulk.
File or object storage is often an excellent intermediate stage for
transferring data.


## Message and Stream Ingestion Considerations


Schema Evolution

Schema evolution is common when handling event data; fields may be added or
removed, or value types might change
use schema registry to version your schema changes
Next, a dead-letter queue (described
in “Error Handling and Dead-Letter Queues” on page 249) can help you investigate
issues with events that are not properly handled.

Late-Arriving Data

because of internet
latency issues.
occur. To handle late-arriving data, you need to set a cutoff time for when
late-arriving data will no longer be processed.


Ordering and Multiple Delivery

Streaming platforms are generally built out of distributed systems, which can cause
some complications. Specifically, messages may be delivered out of order and more
than once (at-least-once delivery).

Replay

Replay allows readers to request a range of messages from the history, allowing you
to rewind your event history to a particular point in time. Replay is a key capability
in many streaming ingestion platforms and is particularly useful when you need
to reingest and reprocess data for a specific time range. For example, RabbitMQ
typically deletes messages after all subscribers consume them. Kafka, Kinesis, and
Pub/Sub all support event retention and replay.

Time to Live

maximum message
retention time, also known as the time to live (TTL)
Find the right balance of TTL impact on our data pipeline. An extremely short TTL
(milliseconds or seconds) might cause most messages to disappear before processing.
A very long TTL (several weeks or months) will create a backlog of many unprocessed
messages, resulting in long wait time


Message Size

ensure that the streaming framework
in question can handle the maximum expected message size (Kafka max is 20 MB)

Error Handling and Dead-Letter Queues

Events that cannot be ingested need to be rerouted and stored in
a separate location called a dead-letter queue
A dead-letter queue segregates problematic events from events that can be accepted
by the consumer

Consumer Pull and Push

A consumer subscribing to a topic can get events in two ways: push and pull.
Kafka and Kinesis
support only pull subscriptions. Subscribers read messages from a topic and confirm
when they have been processed.
Pull subscriptions are the default choice for most data engineering applications, but
you may want to consider push capabilities for specialized applications.

Location

It is often desirable to integrate streaming across several locations for enhanced
redundancy 

a general rule,
the closer your ingestion is to where data originates, the better your bandwidth and
latency



## Ways to Ingest Data


Direct Database Connection

Data can be pulled from databases for ingestion by querying and reading over a network
connection. Most commonly, this connection is made using ODBC or JDBC.

ODBC uses a driver hosted by a client accessing the database to translate commands
issued to the standard ODBC API into commands issued to the database. The database
returns query results over the wire, where the driver receives them and translates
them back into a standard form to be read by the client
JDBC and ODBC are used extensively for data ingestion from relational databases,
returning to the general concept of direct database connections.

JDBC and ODBC were long the gold standards for data ingestion from databases, but
these connection standards are beginning to show their age for many data engineering
applications. These connection standards struggle with nested data, and they send
data as rows.
This means that native nested data must be reencoded as string data to
Ways to Ingest Data | 251
be sent over the wire, and columns from columnar databases must be reserialized as
rows.

many databases now
support native file export that bypasses JDBC/ODBC and exports data directly in
formats such as Parquet, ORC, and Avro. Alternatively, many cloud data warehouses
provide direct REST APIs.




Change Data Capture

Change data capture (CDC), introduced in Chapter 2, is the process of ingesting
changes from a source database system.
Batch-oriented CDC - If the database table in question has an updated_at field containing the last time a
record was written or updated, we can query the table to find all updated rows since
a specified time


Continuous CDC - read this log and
send the events to a target,


APIs


Message Queues and Event-Streaming Platforms


Managed Data Connectors standard set of connectors available out of the box
to spare data engineers building complicated plumbing to connect to a particular
source. We suggest using managed connector platforms instead of creating and managing
your connectors


Moving Data with Object Storage
object storage is the most optimal and secure way to handle file
exchange latest security standards, has a robust
track record of scalability and reliability, accepts files of arbitrary types and sizes, and
provides high-performance data movement.
 
EDI electronic data interchange (EDI). by email or flash drive


Databases and File Export


viii | Table of Cont


Practical Issues with Common File Formats
CSV is still ubiquitous
and highly error prone at the time of this writing default delimiter is
also one of the most familiar characters in the English language—the comma
More robust and expressive export formats include Parquet, Avro, Arrow, and ORC
or JSON. These formats natively encode schema information and handle arbitrary
string data with no particular intervention.



Shell


SSH protocol used with other ingestion strategies.
We use SSH in a few ways. First, SSH can be used for file transfer with SCP, as
mentioned earlier. Second, SSH tunnels are used to allow secure, isolated connections
to databases. Application databases should never be directly exposed on the internet Application databases should never be directly exposed on the internet. Instead, engineers
can set up a bastion host—i.e., an intermediate host instance that can connect
to the database in question. This host machine is exposed on the internet, although
locked down for minimal access from only specified IP addresses to specified ports.
To connect to the database, a remote machine first opens an SSH tunnel connection
to the bastion host and then connects from the host machine to the database.


SFTP and SCP
Accessing and sending data both from secure FTP (SFTP) and secure copy (SCP
SCP is a file-exchange protocol that runs over an SSH connection


Webhooks reverse APIs
Webhook-based data ingestion architectures can be brittle, difficult to maintain,
and inefficient.

Web Interface


Web Scraping


Transfer Appliances for Data Migration


Data Sharing



Security
Data that needs to move within
your VPC should use secure endpoints and never leave the confines of the VPC.
Use a VPN or a dedicated private connection if you need to send data between the
cloud and an on-premises network. This might cost money, but the security is a good
investment. If your data traverses the public internet, ensure that the transmission is
encrypted. It is always a good practice to encrypt data over the wire


Data Management

Schema changes
privacy sensitive data
monitoring failure Uptime, latency, and data volumes

Data-quality tests
logs to capture the history of data
changes, checks (nulls, etc.), and exception handling (try, catch, etc.).