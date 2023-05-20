---
weight: 2
title: "02: The Data Engineering Lifecycle"
---

# The Data Engineering Lifecycle
---

## Components of the lifecycle
---

{{< columns >}}
**Lifecycle:**

- Generation
- Storage
- Ingestion
- Transformation
- Serving data

<--->

**Undercurrents of the lifecycle:**

- Security
- Data management
- DataOps
- Data architecture
- Orchestration
- Software engineering
{{< /columns >}}

## Generation
---

**Considerations for generation:**
- Type of data source (application/IoT/database)
- Data generation rate
- Data quality
- Schema of the data
- Data ingestion frequency
- Impact on source system performance when reading data

## Storage
---

**Considerations for storage:**
- Data characteristics such as volume, frequency of ingestion, and file format
- Scaling capabilities including available storage, read/write rates, and throughput
- Metadata capture for schema evolution, data lineage, and data flows
- Storage solution type: object storage or cloud data warehouse
- Schema management: schema-agnostic object storage, flexible schema with Cassandra, or enforced schema with a cloud data warehouse
- Master data management, golden records, data quality, and data lineage for data governance
- Regulatory compliance and data sovereignty considerations

**Temperatures of data**
- hot data
- lukewarm data
- cold data

## Ingestion
---

Ingestion part is usually located biggest bottlenecks of the lifecycle. The source systems are normally outside your direct control and might randomly become unresponsive or provide data of poor quality.

**Considerations for the ingestion:**
- Data availability and source reliability.
- How sink will handle volume, format and frequency?
- Batch or streaming?
- Push or Pull?


`Batch ingestion`: convenient way of processing this stream in large chunks—for example, handling a full day’s worth of data in a single batch.

`Streaming ingestion`: allows  to provide data to downstream systems in a continuous, real-time fashion. Real-time (or near real-time) means that the data is available to a downstream system a short time after it is produced (e.g., less than one second later).

`Micro-batching`: used in ex. Spark Streaming with data taken from 1 second period.

`Push model`: a source system writes data out to a target, whether a database, object store, or filesystem. Example is standard ETL process.

`Pull model`: data is retrieved from the source system. Example is CDC with logs.


## Transformation
---

**Examples of transformations:**
- mapping data into correct types
- transforming the data schema and applying normalization
- large-scale aggregation for reporting
- featurizeing data for ML processes
- enriching the data

`Reverse ETL` takes processed data from the output side of the data engineering lifecycle and feeds it back into source systems. It allows us to take analytics, scored models, etc., and feed these back into production systems or SaaS platforms. For some engineers view as a anti-pattern.


## Security
---

### Security good practices

- `Principle of least privilege`: give access only to the essential data and resources needed to perform an intended function.
- Create a culture of security.
- Protect data from unwanted visibility using `encryption`, `tokenization`, `data masking`, obfuscation, and access controls.
- Implement user and identity access management (IAM) roles, policies, groups, network security, password policies, and encryption.

## Data Management
---

**Disciplines of Data Management:**

- Data governance, including data quality, integrity, security, discoverability and accountability
- Data modeling and design
- Metadata management
- Data lineage
- Storage and operations
- Data integration and interoperability
- Data lifecycle management
- Data systems for advanced analytics and ML
- Ethics and privacy

The Data Management Association International (DAMA) `Data Management Body of Knowledge (DMBOK)`, which we consider to be the definitive book for enterprise data management, offers this definition:

{{< hint info >}} 
**Data management** is the development, execution, and supervision of plans, policies, programs, and practices that deliver, control, protect, and enhance the value of data and information assets throughout their lifecycle. {{< /hint >}}

### Data governance

According to Data Governance: The Definitive Guide the definition of data governance is:

{{< hint info >}} 
**Data governance** is, first and foremost, a data management function to ensure the quality, integrity, security, and usability of the data collected by an organization. {{< /hint >}}


### Master Data Management

Master data is data about business entities such as employees, customers, products, and locations. As organizations grow larger maintaining a consistent picture of entities more challenging. Master data management (MDM) is the practice of building consistent entity definitions known as `golden records`.

### Data lineage

Data lineage describes the recording of an audit trail of data through its lifecycle, tracking both the systems that process the data and the upstream data it depends on. Data lineage helps with error tracking, accountability, and debugging of data and the systems that process it.

### Data integration and interoperability

Data integration is becoming increasingly important as data engineers move away from single-stack analytics and towards a heterogeneous cloud environment. The process involves integrating data across various tools and processes.

### Data privacy

Data privacy and data retention laws such as the `GDPR` and the `CCPA` require data engineers to actively manage data destruction to respect users’ `right to be forgotten`.

Data engineers need to ensure:
- that datasets mask `personally identifiable information (PII)` and other sensitive information,
- that your data assets are compliant with a growing number of data regulations, such as GDPR and CCPA.


## DataOps
---

DataOps is like DevOps, but for data products. It's a set of practices that enable rapid innovation, high data quality, collaboration, and clear measurement and monitoring.

**DataOps has three core technical elements:**
- automation,
- monitoring and observability,
- incident response.

### Automation

- change management (environment, code, and data version control),
- `continuous integration/continuous deployment` (CI/CD),
- configuration as code,
- monitor and maintain the reliability of technology and ,zsystems (data pipelines, orchestration, etc.), with the added dimension of checking for data quality, data/model drift, metadata integrity, and more.

### Observability and monitoring

- monitoring,
- logging,
- alerting,
- tracing are all critical to getting ahead of any problems along the data engineering lifecycle.

### Incident response

Incident response is about using the automation and observability capabilities mentioned previously to rapidly identify root causes of an incident and resolve it as reliably and quickly as possible.

## Other concepts
---

### Orchestration

Orchestration is the process of coordinating multiple jobs efficiently on a schedule. It ensures high availability, job history, visualization, and alerting. Advanced engines can backfill new tasks and DAGs, but orchestration is strictly a batch concept.

### Infrastructure as code (IaC)

`IaC (Infrastructure as Code)` applies software engineering practices to managing infrastructure configuration. Data engineers use IaC frameworks to manage their infrastructure in a cloud environment, instead of manually setting up instances and installing software.


