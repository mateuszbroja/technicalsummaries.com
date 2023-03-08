---
weight: 7
title: "07: Ingestion"
bookHidden: false
---

# Ingestion

`Data ingestion` involves moving data from source systems to storage.

`Data integration`, which involves merging data from various sources into a single dataset.

**Security:**

- Keep data within your VPC using secure endpoints.
- Use a VPN or private connection for data transfer between cloud and on-premises networks.
- Encrypt data transmission over public internet.

**Data Management:**

- Handle schema changes, privacy-sensitive data, and monitor uptime, latency, and data volumes.
- Conduct data-quality tests, capture data changes through logs, and perform checks and exception handling.

## Factors when designing your ingestion architecture:

**Bounded versus unbounded** - Unbounded data is real-time and ongoing, while bounded data is separated into buckets, often by time.

**Frequency** - Ingestion processes can be batch, micro-batch, or real-time. Real-time ingestion patterns are becoming more common, although ML models are still typically trained on a batch basis. Streaming architectures often coexist with batch processing.

**Synchronous versus asynchronous** - Synchronous ingestion has tightly coupled and complex dependencies, while asynchronous ingestion operates at the level of individual events, allowing for parallel processing at each pipeline stage.

**Serialization and deserialization** - Moving data requires serialization and deserialization, with the destination needing to properly interpret the data it receives.

**Throughput and scalability** - Systems should be designed to handle bursty data ingestion, with built-in buffering to prevent data loss during rate spikes

**Reliability and durability** - Reliability requires high uptime and failover, while durability prevents data loss or corruption. To avoid permanent data loss, redundancy and self-healing are necessary.

**Payload** -  refers to the dataset being ingested. Payload characteristics:
- `Kind` refers to type and format, with type influencing the way data is expressed in bytes and file extensions.
- `Shape` describes dimensions, such as tabular, JSON, unstructured text, and images.
- `Size` refers to the number of bytes in the payload.
- `Schema` and data types define the fields and types of data within them, with schema changes being common in source systems. Schema registries maintain schema and data type integrity and track schema versions and history.
- `Metadata` is also critical and should not be neglected.

**Push versus pull versus poll patterns** - Push strategy sends data from the source to the target, while pull strategy has the target directly read from the source. Polling periodically checks for changes and pulls data when changes are detected.

---
## Batch Ingestion Considerations

**Time-based or Size-based** - Time-interval batch ingestion processes data once a day for daily reporting, while size-based batch ingestion cuts data into blocks for future processing in a data lake.

**Snapshot or Differential Extraction** - Data ingestion can involve full snapshots or differential updates. Differential updates minimize network traffic and storage, but full snapshot reads are still common due to their simplicity.

**File-Based Export and Ingestion** - File-based export is a push-based ingestion pattern that offers security advantages and allows source system engineers control over data export and preprocessing. Files can be provided to the target system using various methods, such as object storage, SFTP, EDI, or SCP.

**ETL Versus ELT**

**Inserts, Updates, and Batch Size** - Batch-oriented systems may perform poorly when users attempt many small-batch operations rather than fewer large operations. It's important to understand the limits and characteristics of your tools.

**Data Migration** - Migrating data to a new database or environment is typically not straightforward, requiring bulk data transfer. File or object storage can serve as an excellent intermediate stage for transferring data.

---
## Message and Stream Ingestion Considerations


**Schema Evolution** - Schema evolution is common in event data. A schema registry can version changes, while a dead-letter queue can help investigate unhandled events.

**Late-Arriving Data** - Late-arriving data can occur due to internet latency issues, requiring a cutoff time for processing such data.

**Ordering and Multiple Delivery** - Streaming platforms, built out of distributed systems, may have complications such as messages being delivered out of order or more than once, known as at-least-once delivery.

**Replay** - Replay is a key capability in many streaming ingestion platforms, allowing rewinding to a specific point in time for reingesting and reprocessing data. Kafka, Kinesis, and Pub/Sub support event retention and replay.

**Time to Live** - The maximum message retention time, or TTL, must be balanced to avoid negatively impacting the data pipeline. A short TTL might cause most messages to disappear before processing, while a long TTL could create a backlog of unprocessed messages and result in long wait times.

**Message Size** - When working with streaming frameworks, ensure they can handle the maximum message size (e.g. Kafka's maximum is 20 MB). A dead-letter queue is necessary to segregate problematic events that cannot be ingested.

**Consumer Pull and Push** - Subscribers can use push or pull subscriptions to receive events from a topic, but Kafka and Kinesis only support pull subscriptions. While pull is the default choice for most data engineering applications, push may be needed for specialized use cases.

**Location** - Integrating streaming across several locations can enhance redundancy. As a general rule, the closer your ingestion is to where the data originates, the better your bandwidth and latency.

---
## Ways to Ingest Data


- Direct Database Connection: Data can be pulled from databases for ingestion using ODBC or JDBC, but they struggle with nested data and sending data as rows. Some databases support native file export, while cloud data warehouses provide direct REST APIs for ingestion.

- Change Data Capture: Change data capture (CDC) ingests changes from a source database system. Batch-oriented CDC queries the table for updated rows since a specified time. Continuous CDC reads the log and sends events to a target in real-time.

- APIs

- Message Queues and Event-Streaming Platforms

- Managed Data Connectors

- Moving Data with Object Storage
 
- EDI electronic data interchange (EDI)

- Databases and File Export

- Practical Issues with Common File Formats: CSV is still commonly used but highly error-prone, while more robust and expressive export formats like Parquet, Avro, Arrow, ORC, or JSON natively encode schema information and handle arbitrary string data.

- Shell

- SSH can be used for file transfer with SCP and for secure connections to databases through SSH tunnels. To connect to a database, a remote machine first opens an SSH tunnel connection to a bastion host, which connects to the database. This helps keep databases isolated and secure.

- SFTP and SCP are secure file-exchange protocols that run over an SSH connection. They are commonly used for transferring files between systems securely. 

- Webhooks (reverse API) - webhook-based data ingestion can be difficult to maintain and inefficient.

- Web Interface

- Web Scraping

- Transfer Appliances for Data Migration

- Data Sharing