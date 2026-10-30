---
weight: 2
title: "02: The Data Engineering Lifecycle"
---

# The Data Engineering Lifecycle
---

The `data engineering lifecycle` comprises the stages that turn raw data into a useful end product, ready for consumption by analysts, data scientists, ML engineers, and others. It shifts the conversation away from technology and toward the data itself and the goals it serves.

## Components of the lifecycle
---

{{% columns %}}
- **Lifecycle:**

  - Generation
  - Storage
  - Ingestion
  - Transformation
  - Serving data

- **Undercurrents of the lifecycle:**

  - Security
  - Data management
  - DataOps
  - Data architecture
  - Orchestration
  - Software engineering
{{% /columns %}}

The stages are not a neat sequence. They overlap, repeat, and sometimes run out of order. Storage, for example, underpins all the other stages.

> [!NOTE]
> The **data lifecycle** is broader than the **data engineering lifecycle**. The data engineering lifecycle is the subset of the full data lifecycle that data engineers control.

## Generation: Source Systems
---

A `source system` is the origin of the data used in the lifecycle, such as an IoT device, an application message queue, or a transactional database. Data engineers consume data from source systems but usually do not own or control them.

**Questions for evaluating source systems:**
- What are the essential characteristics of the data source? Is it an application, a swarm of IoT devices, or a database?
- How is data persisted in the source system? Is it kept long term or deleted quickly?
- At what rate is data generated (events per second, gigabytes per hour)?
- What level of consistency and quality can be expected? How often do errors, nulls, and duplicates occur?
- Will data arrive late, possibly much later than related messages?
- What is the schema of the ingested data? Will it require joins across several tables or systems?
- How are schema changes handled and communicated to downstream stakeholders?
- How frequently should data be pulled from the source?
- For stateful systems, is data provided as periodic snapshots or as change data capture (CDC) update events?
- Who or what is the data provider that transmits data downstream?
- Will reading from the source impact its performance?
- Does the source have upstream data dependencies?
- Are data quality checks in place for late or missing data?

Two schema patterns are common:
- `Schemaless`: the application defines the schema as data is written, for example in a document database or a message queue.
- `Fixed schema`: a traditional model built on relational database storage.

## Storage
---

Storage runs across the entire lifecycle. Data is stored in several places, and many storage solutions also process data (for example, cloud data warehouses run queries).

**Considerations for storage:**
- Is the storage solution compatible with the required write and read speeds?
- Will storage become a bottleneck for downstream processes?
- Is the solution used in an optimal way? For example, random record updates in object storage are an antipattern.
- Can the storage handle the anticipated future scale (total capacity, read and write rates, throughput)?
- Will downstream users retrieve data within the required SLA?
- Is metadata captured about schema evolution, data flows, and data lineage?
- Is it a pure storage solution (object storage) or does it support complex queries (cloud data warehouse)?
- Is it schema-agnostic (object storage), does it have a flexible schema (Cassandra), or does it enforce a schema (cloud data warehouse)?
- How is master data, golden-record quality, and lineage tracked for data governance?
- How does it handle regulatory compliance and data sovereignty?

**Temperatures of data (access frequency):**
- `Hot data` is accessed frequently, often many times per day or per second.
- `Lukewarm data` is accessed every so often, for example weekly or monthly.
- `Cold data` is rarely queried and suits archival systems. It is often retained for compliance or disaster recovery.

There is no one-size-fits-all storage technology. Choose storage based on use cases, data volumes, ingestion frequency, format, and size.

## Ingestion
---

Ingestion is usually where the biggest bottlenecks of the lifecycle are. Source systems are normally outside your direct control and might become unresponsive or provide data of poor quality.

**Key engineering considerations for ingestion:**
- What are the use cases for the data being ingested? Can the data be reused instead of creating multiple versions?
- Are the source systems reliable, and is the data available when needed?
- What is the destination after ingestion?
- How frequently will the data be accessed?
- In what volume will the data typically arrive?
- What format is the data in, and can downstream storage and transformation handle it?
- Is the data in good shape for immediate downstream use? If so, for how long?
- If the data comes from a streaming source, does it need to be transformed before reaching its destination?

### Batch versus streaming

`Batch ingestion` processes data in large chunks, for example a full day's worth of data in a single batch, or ingests data when it reaches a size threshold.

`Streaming ingestion` provides data to downstream systems continuously, in real time or near real time. Near real time means data is available downstream a short time after it is produced, for example less than one second later.

`Micro-batching` sits between the two. Spark Streaming, for example, processes data in batches of about one second.

**Questions before choosing streaming:**
- If data is ingested in real time, can downstream storage handle the rate of flow?
- Do you need millisecond real-time ingestion, or would micro-batching work?
- What are the use cases for streaming, and what benefits would real time bring over batch?
- Does streaming cost more in time, money, maintenance, downtime, and opportunity cost than batch?
- Are the pipeline and system reliable and redundant if infrastructure fails?
- Which tools fit best: managed services (Amazon Kinesis, Google Cloud Pub/Sub, Google Cloud Dataflow) or self-managed (Kafka, Flink, Spark, Pulsar)?
- If deploying an ML model, what benefits come from online predictions and continuous training?
- What is the impact of getting data from a live production instance?

> [!WARNING]
> Batch is an excellent approach for many common use cases, such as model training and weekly reporting. Adopt true real-time streaming only after identifying a business use case that justifies the trade-offs.

### Push versus pull

`Push model`: the source system writes data out to a target, such as a database, object store, or filesystem. Example: IoT sensors or applications that send events directly to an endpoint or event-streaming platform.

`Pull model`: data is retrieved from the source system. Example: the extract step of a traditional ETL process, which queries a source table snapshot on a fixed schedule.

The line between the two is often blurry. Log-based `change data capture (CDC)` can work either way: some systems read the database log (pull), and others push messages to a queue as changes happen.

## Transformation
---

Transformation changes data from its original form into something useful for downstream use cases. Without it, data sits inert.

**Examples of transformations:**
- mapping data into correct types (for example, string to date or number),
- putting records into standard formats and removing bad ones,
- transforming the data schema and applying normalization,
- large-scale aggregation for reporting,
- featurizing data for ML processes,
- enriching data with other datasets.

**Key considerations:**
- What is the cost and return on investment (ROI) of the transformation? What is the associated business value?
- Is the transformation as simple and self-isolated as possible?
- What business rules does it support?

Transformation is often entangled with other stages. Data can be transformed in source systems or during ingestion, for example by adding a timestamp. `Business logic` is a major driver of transformation, and it is often implemented in data modeling. `Data featurization` for ML extracts and enhances features useful for training models. Data scientists define the features, and data engineers can automate the process.

## Serving Data
---

Data has value only when it is used for practical purposes. Projects that collect data without a clear purpose create *data vanity projects*.

### Analytics

{{% columns %}}
- **Business intelligence**

  `BI` uses data to describe the business's past and current state. It applies business logic during queries (`logic-on-read`). Mature companies move toward `self-service analytics`.

- **Operational analytics**

  `Operational analytics` focuses on the fine-grained details of operations and promotes immediate action, such as live dashboards of inventory or application health.

- **Embedded analytics**

  `Embedded analytics` (customer-facing) serves analytics to customers in SaaS platforms. Request rates are much higher, and access control and multitenancy are critical.
{{% /columns %}}

### Machine learning

ML is often the most exciting part of the data value chain, but it requires a high level of data maturity. Data engineers support it by building data and feature pipelines, feature stores, and data discovery. Before investing heavily in ML, a company should build a solid data foundation.

**Considerations for serving data for ML:**
- Is the data of sufficient quality to perform reliable feature engineering?
- Is the data discoverable by data scientists and ML engineers?
- Where are the technical and organizational boundaries between data engineering and ML engineering?
- Does the dataset properly represent ground truth, and is it unfairly biased?

### Reverse ETL

`Reverse ETL` takes processed data from the output side of the lifecycle and feeds it back into source systems. It sends analytics, scored models, and other results back into production systems or SaaS platforms, for example to put customer scores into a CRM. Some engineers consider it an antipattern, but it has become important as businesses rely on SaaS and external platforms.

## Major Undercurrents
---

### Security

- `Principle of least privilege`: give users and systems only the access essential to perform their intended function.
- Create a culture of security. People and organizational processes are often the weakest link.
- Protect data from unwanted visibility, both in flight and at rest, using `encryption`, `tokenization`, `data masking`, obfuscation, and simple, robust access controls.
- Know user and `identity access management (IAM)` roles, policies, groups, network security, password policies, and encryption.

### Data Management

The Data Management Association International (DAMA) `Data Management Body of Knowledge (DMBOK)` is considered the definitive book for enterprise data management. It offers this definition:

> [!NOTE]
> **Data management** is the development, execution, and supervision of plans, policies, programs, and practices that deliver, control, protect, and enhance the value of data and information assets throughout their lifecycle.

**Facets of data management:**

- data governance, including discoverability and accountability,
- data modeling and design,
- data lineage,
- storage and operations,
- data integration and interoperability,
- data lifecycle management,
- data systems for advanced analytics and ML,
- ethics and privacy.

#### Data governance

According to *Data Governance: The Definitive Guide*:

> [!NOTE]
> **Data governance** is, first and foremost, a data management function to ensure the quality, integrity, security, and usability of the data collected by an organization.

Its main categories are discoverability, security, and accountability. Within them sit data quality, metadata, and privacy.

- `Discoverability`: end users should be able to find data, know where it comes from, how it relates to other data, and what it means.
- `Metadata` is data about data. It can be autogenerated or human-generated. The authors describe four categories:
  - `business metadata`: how data is used in the business, such as definitions, rules, and owners,
  - `technical metadata`: data created and used by systems, such as schemas, pipeline metadata, and data lineage,
  - `operational metadata`: operational results of systems, such as job statistics, run IDs, and error logs,
  - `reference metadata`: data used to classify other data, such as time zones, codes, and lookup tables.
- `Data accountability` means assigning a person to govern a portion of data. That person coordinates the governance activities of other stakeholders.
- `Data quality` is the optimization of data toward the desired state. It has three main characteristics:
  - `accuracy`: the data is factually correct, without duplicates, and numeric values are accurate,
  - `completeness`: records are complete and all required fields contain valid values,
  - `timeliness`: records are available in a timely fashion.

#### Master data management

`Master data` is data about business entities such as employees, customers, products, and locations. As organizations grow, keeping a consistent picture of these entities gets harder. `Master data management (MDM)` is the practice of building consistent entity definitions known as `golden records`.

#### Data modeling and design

`Data modeling` converts data into a usable form for analytics and ML. Data engineers must understand modeling best practices and be flexible enough to apply the right level and type of modeling to the data source and use case.

#### Data lineage

`Data lineage` records an audit trail of data through its lifecycle, tracking both the systems that process the data and the upstream data it depends on. It helps with error tracking, accountability, and debugging of data and the systems that process it.

#### Data integration and interoperability

Data integration is the process of integrating data across tools and processes. It is becoming more important as data engineers move away from single-stack analytics toward heterogeneous cloud environments. Orchestration and APIs connect these systems.

#### Data lifecycle management

Cloud object storage made it cheap to keep data forever. Data engineers must decide what to archive, and when to destroy data for compliance.

#### Ethics and privacy

Data privacy and retention laws such as `GDPR` and `CCPA` require data engineers to actively manage data destruction to respect users' `right to be forgotten`.

Data engineers need to ensure:
- that datasets mask `personally identifiable information (PII)` and other sensitive information,
- that bias in datasets is identified and tracked,
- that data assets comply with a growing number of data regulations, such as GDPR and CCPA.

### DataOps

`DataOps` maps the best practices of Agile methodology, DevOps, and statistical process control to data. Its goal is to improve the release and quality of data products: rapid innovation, high data quality, collaboration, and clear measurement and monitoring.

DataOps is first a set of cultural habits: communicating and collaborating with the business, breaking down silos, learning from successes and mistakes, and iterating quickly.

**DataOps has three core technical elements:**
- automation,
- observability and monitoring,
- incident response.

#### Automation

- change management (environment, code, and data version control),
- `continuous integration/continuous deployment (CI/CD)`,
- configuration as code,
- monitoring and maintaining the reliability of technology and systems (data pipelines, orchestration), with the added dimension of checking data quality, data and model drift, and metadata integrity.

Automation matures over time: from cron jobs on a single instance, to an orchestration framework such as Airflow, to automated DAG deployment with tests.

#### Observability and monitoring

Monitoring, logging, alerting, and tracing help you get ahead of problems along the lifecycle. Bad data can sit undetected for months, and stakeholders lose trust in data teams that discover issues after their users. Andy Petrella's `DODD (data observability driven development)` method is one way to build data observability into every stage.

#### Incident response

Incident response is about using automation and observability to rapidly identify the root causes of an incident and resolve it as reliably and quickly as possible. Data engineers should find issues proactively, before the business reports them.

### Data Architecture

A data architecture reflects the current and future state of data systems that support an organization's long-term data needs and strategy. A data engineer must understand the needs of the business, gather requirements for new use cases, and translate them into designs that balance cost and operational simplicity. Chapter 3 covers this in detail.

### Orchestration

Orchestration is the process of coordinating many jobs to run as quickly and efficiently as possible on a scheduled cadence. An orchestration engine such as Apache Airflow builds in metadata about job dependencies, generally as a `directed acyclic graph (DAG)`.

Orchestration systems:
- stay online with high availability,
- can monitor jobs and send alerts when tasks fail or do not finish on time,
- keep job history, visualization, and alerting,
- can backfill new DAGs or individual tasks over historical data.

Newer orchestrators include Prefect, Dagster, Argo, and Metaflow. Orchestration is strictly a batch concept. The streaming alternative is a streaming DAG, built with tools such as Apache Pulsar.

### Software Engineering

Software engineering has always been a central skill for data engineers. Key areas:

- `Core data processing code`: data engineers must be proficient in frameworks and languages such as Spark, SQL, or Beam, and must understand testing methods such as unit, regression, integration, end-to-end, and smoke tests.
- `Development of open source frameworks`: before building new internal tooling, survey the OSS landscape.
- `Streaming`: streaming is more complex than batch. Joins and windowing methods (session, sliding windows) need engineering effort.
- `Infrastructure as code (IaC)` applies software engineering practices to the configuration and management of infrastructure. Data engineers use IaC frameworks to manage cloud infrastructure instead of setting up instances manually.
- `Pipelines as code` define data tasks and their dependencies in code, which the orchestration system then runs.
- `General-purpose problem solving`: data engineers often need to write custom code, for example a connector for an unsupported data source.
