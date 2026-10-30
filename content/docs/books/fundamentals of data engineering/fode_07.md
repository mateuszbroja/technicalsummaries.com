---
weight: 7
title: "07: Ingestion"
bookHidden: false
---

# Ingestion

---

## What Is Data Ingestion?

---

`Data ingestion` is the process of moving data from one place to another, typically from source systems into storage, as an intermediate step in the data engineering lifecycle.

`Data integration` is a related but different idea: it combines data from disparate sources into a new dataset. Ingestion moves data; integration merges it.

A `data pipeline` is the combination of architecture, systems, and processes that move data through the stages of the lifecycle. The term is intentionally broad: a pipeline can be a modern stack of managed tools or a set of cron jobs and shell scripts.

> [!NOTE]
> Ingestion is mostly plumbing. Avoid building custom ingestion code when a managed connector or an existing tool already solves the problem, and spend the saved time on work that creates value.

---

## Key Engineering Considerations for the Ingestion Phase

---

Before building an ingestion system, ask: what is the use case, can the data be reused, where is it going, how often must it be updated, how large is it, what format is it in, and is it of good quality?

### Bounded Versus Unbounded Data

`Unbounded data` is data as it exists in reality, as events happen, sporadically or continuously. `Bounded data` is a convenient way of bucketing data across some boundary, such as time. **All data is unbounded until it is bounded.** Business processes have long imposed artificial bounds on data, such as daily batches; streaming systems preserve the unbounded nature of data.

### Frequency

Ingestion runs on a spectrum from batch through micro-batch to real-time. "Real-time" in practice means near real-time, with a latency that depends on the use case. Streaming ingestion patterns are increasingly common, yet ML models are still typically trained in batch, and streaming usually coexists with batch processing downstream.

### Synchronous Versus Asynchronous Ingestion

{{% columns %}}
- **Synchronous**

  Source, ingestion, and destination have tightly coupled dependencies. If one stage fails, the stages after it cannot start, and the whole process often has to be rerun.

- **Asynchronous**

  Dependencies operate at the level of individual events, much like a microservices backend. Each stage processes data as soon as it becomes available, for example events flowing through a stream buffer into parallel processors.
{{% /columns %}}

### Serialization and Deserialization

Moving data requires encoding it on the source side (`serialization`) and decoding it at the destination (`deserialization`). The destination must be able to correctly interpret the data it receives; a successful transfer of bytes the target cannot parse is still a failure.

### Throughput and Scalability

Ingestion must handle bursts, such as a source system that goes down and then delivers a backlog all at once. Build in buffering so that rate spikes do not cause data loss, and prefer managed services that scale automatically.

### Reliability and Durability

`Reliability` means high uptime and proper failover for ingestion systems. `Durability` means data is not lost or corrupted. Some sources do not retain data, so if ingestion fails the data is gone forever. Build appropriate redundancy and self-healing, and weigh the cost of losing data against the cost of preventing it.

### Payload

The `payload` is the dataset being ingested. Its characteristics:

- `Kind`: the type and format of the data. The type (for example tabular, image, video, text) drives the format, meaning how the data is expressed in bytes and file extensions.
- `Shape`: the dimensions, such as rows and columns of tabular data, the key-value structure of JSON, characters in text, or pixel dimensions of an image.
- `Size`: the number of bytes. Large payloads may be compressed or split into chunks.
- `Schema and data types`: the fields and the types of data within them. Schemas change frequently in source systems, often without the data team being notified. A `schema registry` maintains schema and data type integrity and tracks schema versions and history.
- `Metadata`: data about the data. It is as important as the payload and should never be neglected.

### Push Versus Pull Versus Poll Patterns

- `Push`: the source sends data to the target.
- `Pull`: the target reads data directly from the source.
- `Poll`: the target periodically checks the source for changes and pulls data when it detects them.

---

## Batch Ingestion Considerations

---

Batch ingestion processes data in bulk, for a time interval or once data reaches a size threshold.

- **Time-interval or size-based**: Time-interval ingestion is widespread in traditional ETL for data warehousing, for example a daily batch for daily reporting. Size-based ingestion is common when data moves from a streaming system into object storage, where the stream must be cut into discrete blocks for later processing in a data lake.
- **Snapshot or differential extraction**: A full snapshot reads the entire current state of the source on each update. A differential (incremental) update pulls only the changes since the last read. Differential updates reduce network traffic and storage use, but full snapshots remain common because they are simple.
- **File-based export and ingestion**: The source system exports data to files and pushes them to the target. This push-based pattern has security advantages, because the target needs no direct access to the source, and it gives source engineers full control over what is exported and how it is preprocessed. Files can be delivered via object storage, SFTP, EDI, or SCP.
- **ETL versus ELT**: ETL transforms data before loading it into the target. ELT loads raw data first and transforms it inside the target system.
- **Inserts, updates, and batch size**: Batch-oriented systems often perform poorly when users issue many small operations instead of fewer large ones. A columnar database, for example, handles single-row inserts badly. Understand the limits and characteristics of your tools.
- **Data migration**: Moving data to a new database or environment is rarely trivial. Schema differences need attention, and bulk transfer is usually done through files. Object storage is an excellent intermediate stage for migrations.

---

## Message and Stream Ingestion Considerations

---

- **Schema evolution**: Fields get added or removed and value types change, which can break downstream pipelines. A schema registry versions these changes. A `dead-letter queue` stores events that could not be processed so they can be investigated. Communicate with upstream stakeholders about upcoming schema changes.
- **Late-arriving data**: Events can arrive after their peers, for example because of internet latency. Use both event time and ingestion time, and set a cutoff after which late data is no longer processed.
- **Ordering and multiple delivery**: Streaming platforms are distributed systems, so messages can arrive out of order or more than once. This is called `at-least-once delivery`; design consumers to handle it.
- **Replay**: Replay lets readers rewind to a point in time and reingest and reprocess a range of historical messages. Kafka, Kinesis, and Pub/Sub support event retention and replay.
- **Time to live (TTL)**: The maximum message retention time. A TTL that is too short makes messages disappear before they are processed. A TTL that is too long leaves unprocessed messages sitting for a long time and creates a backlog.
- **Message size**: Make sure the streaming framework can handle the largest expected message. Amazon Kinesis supports a maximum message size of 1 MB. Kafka defaults to 1 MB but can be configured for 20 MB or more.
- **Error handling and dead-letter queues**: Events that fail ingestion, for example because they are too large or have an expired TTL, are routed to a dead-letter queue so they do not block other events.
- **Consumer pull and push**: Subscribers receive events either by pulling them or via push subscriptions. Kafka and Kinesis support only pull subscriptions. Pull is the default for most data engineering applications; push is needed for specialized cases.
- **Location**: Ingesting close to where data originates usually improves bandwidth and latency, while integrating streams across several locations improves redundancy. Balance this against the cost of moving data between regions.

---

## Ways to Ingest Data

---

### Direct Database Connection

Data can be pulled from databases over `ODBC` or `JDBC`. A driver translates commands to the database and converts results into a form the client understands. These protocols struggle with nested data and send data as rows, so throughput is limited; parallel queries and native file export are common workarounds. Many cloud data warehouses also offer direct REST APIs for ingestion.

### Change Data Capture

`Change data capture (CDC)` ingests changes from a source database.

{{% columns %}}
- **Batch-oriented CDC**

  Queries the table for rows updated since a given time, typically using an `updated_at` field. It captures only the latest state of each row, not every intermediate change.

- **Continuous CDC**

  Reads the database log and sends each write to a target as an event in near real time, for example with Debezium streaming changes into Kafka.
{{% /columns %}}

CDC can also feed replicas: a synchronous replica stays fully in sync with the primary, while an asynchronous replica lags behind. CDC consumes database resources, so run heavy CDC jobs against a replica or off-peak.

### APIs

APIs are an increasingly important source, but there is no universal standard for data exchange over APIs. Options to reduce custom work include client libraries, managed data connector platforms, and data sharing. Reserve custom API connector code for cases where nothing else exists.

### Message Queues and Event-Streaming Platforms

Message queues and event-streaming platforms are common ways to ingest real-time data from web and mobile applications, IoT sensors, and smart devices. A `message` is handled at a low level and is usually removed once consumed. A `stream` is an append-only log of event records that can be persisted and replayed.

### Managed Data Connectors

Vendors such as Fivetran and Airbyte provide prebuilt connectors to common sources, with settings for frequency, incremental updates, and schemas. Use them instead of maintaining connector code yourself whenever practical.

### Moving Data with Object Storage

Object storage is a scalable, reliable, and secure way to exchange files between teams and organizations. Use signed URLs to grant temporary access.

### EDI

`Electronic data interchange (EDI)` is a somewhat archaic way of moving data, such as sending files by email or on a flash drive. Automate what you can, for example by triggering ingestion when an attachment lands in object storage.

### Databases and File Export

Export queries can put significant load on a source, so run them against read replicas or schedule them sensibly. **CSV is still common but highly error-prone**: delimiters, quoting, and encoding vary. Formats such as Parquet, Avro, Arrow, ORC, or JSON natively encode schema information and handle arbitrary string data.

### Shell

The shell can run scripts that read data, transform it, and load it. It is simple, but for complex processes a proper orchestrator is more robust.

### SSH, SFTP, and SCP

`SSH` supports file transfer with SCP and secure connections to databases through SSH tunnels: a remote machine opens a tunnel to a bastion host, which connects to the isolated database. `SFTP` and `SCP` are secure file-exchange protocols that run over SSH. Partners may require SFTP; be careful about which ports and IPs you open.

### Webhooks

`Webhooks` are sometimes called reverse APIs: the data provider calls an endpoint you expose. Webhook-based ingestion architectures can be brittle, difficult to maintain, and inefficient; managed serverless components help.

### Web Interface and Web Scraping

Some SaaS tools still only allow data export through a web interface, which requires a person to click a button. `Web scraping` extracts data from web pages. It raises legal and ethical questions, can put load on the target site, and breaks whenever the page structure changes.

### Transfer Appliances for Data Migration

For hundreds of terabytes or more, cloud vendors ship physical appliances, such as AWS Snowball, that are loaded with data and returned to the vendor. This is faster than transferring the data over the internet.

### Data Sharing

Platforms such as Snowflake, Redshift, and BigQuery let data providers share datasets with consumers on a read-only basis. The consumer does not own or physically ingest the data; the provider controls access.

---

## Whom You'll Work With

---

- **Upstream stakeholders**: the software engineers who own the source systems. Engage them early as partners; data engineering can help them see the value of their data, which motivates them to keep data quality high and announce changes.
- **Downstream stakeholders**: data scientists, analysts, ML engineers, and executives. Find out early what they need from the ingested data, and frame ingestion work in terms of the business value it enables.

---

## Undercurrents

---

**Security**

- Keep data within your VPC by using secure endpoints.
- Use a VPN or a dedicated private connection between cloud and on-premises networks.
- Encrypt any data that travels over the public internet.

**Data management**

- Handle schema changes, ideally through communication with source owners and automated detection.
- Treat privacy-sensitive data carefully, for example by hashing or tokenizing it at ingestion when raw values are not needed.
- Monitor uptime, latency, and data volumes, and run data-quality tests on ingested data.

**DataOps**

Ingestion is where most data pipeline problems first appear, so monitoring is critical: track whether data arrives on time, in the expected volume, and in the expected shape. Data-quality tests and exception handling catch problems before they spread downstream.

**Orchestration**

Ingestion is usually the first stage of an orchestrated pipeline. As ingestion grows more complex, move from simple scheduling to a proper orchestration engine with dependency management.

**Software engineering**

Simple, well-tested ingestion code with version control and CI/CD is easier to maintain. Keep the code decoupled so that a change in one source does not break others.
