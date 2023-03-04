---
weight: 3
title: "03: Designing Good Data Architecture"
---

# Designing Good Data Architecture
## Data Architecture

`Enterprise architecture` involves designing systems that support enterprise change, utilizing flexible and reversible decisions that are made by evaluating trade-offs carefully. It includes various subsets, such as business, technical, application, and data architecture.

`Data architecture` is the design of systems to support the evolving data needs of an enterprise, achieved by flexible and reversible decisions reached through a careful evaluation of trade-offs.

It comprises:
- Operational architecture, which covers the functional requirements related to people, processes, and technology.
- Technical architecture, which details the ingestion, storage, transformation, and serving of data throughout the data engineering lifecycle.

---
## Principles of data engineering architecture

1. Choose common components wisely.
2. Plan for failure.
3. Architect for scalability.
4. Architecture is leadership.
5. Always be architecting.
6. Build loosely coupled systems.
7. Make reversible decisions.
8. Prioritize security.
9. Embrace FinOps.

### Principle 1: Choose common components wisely.

Common components include:
- object storage,
- version-control systems,
- observability,
- monitoring and orchestration systems,
- processing engines.

Make commonly used components accessible with strong security features to facilitate sharing among teams and discourage duplication.

### Principle 2: Plan for Failure.

To build highly robust data systems, you must consider failures in your designs. Here are a few key terms for evaluating failure scenarios.

- `Availability` is the percentage of time an IT service or component is in an operable state.

- `Reliability` is the system’s probability of meeting defined standards in performing its intended function during a specified interval.

- `Recovery time objective` is the maximum acceptable time for a service or system outage. The recovery time objective (RTO) is generally set by determining the business impact of an outage. A one-day RTO could suffice for internal reporting, but a five-minute website outage can greatly harm an e-commerce business.

- `Recovery point objective ` is the acceptable state after recovery. Specifies the maximum tolerable data loss in data systems, which frequently experience data loss during outages.


### Principle 3: Architect for Scalability


An ideal elastic system should automatically scale in response to load, even down to zero. However, improper scaling strategies can lead to complex systems and increased expenses.


### Principle 4: Architecture Is Leadership

Mentoring the development team to handle complex issues is a crucial aspect of being the architect. By enhancing the team's skills, architects can gain more leverage than by making all decisions themselves and becoming a bottleneck.


### Principle 5: Always Be Architecting

Modern architecture should not follow a command-and-control or `waterfall approach`, but rather be collaborative and agile. The data architect is responsible for maintaining a target architecture and sequencing plans that can adapt to changing business. Thus, the target architecture is a dynamic entity that evolves with time.

### Principle 6: Build Loosely Coupled Systems

For software architecture, a loosely coupled system has the following properties:

1. Systems are divided into small components.

2. Components interact with other services through abstraction layers, like messaging buses or APIs, which protect internal details of the service.

3. Changes in one component do not require changes in other parts due to stable APIs, allowing each piece to evolve independently.

4. Each component is updated separately, eliminating a global release cycle for the whole system.


### Principle 7: Make Reversible Decisions

To keep up with the rapidly changing technological landscape and decoupled data architecture, prioritize selecting the best solutions available today. Remain open to upgrading or adopting better practices as the landscape evolves.


### Principle 8: Prioritize Security

- Embrace zero-trust security models.

- Understand the shared responsibility model in cloud computing, where providers secure their services, but users are responsible for designing their own security model for applications and data.

- Encourage data engineers to also act as security engineers.

### Principle 9: Embrace FinOps

`FinOps` is a developing financial management discipline and cultural practice in the cloud that promotes collaboration between engineering, finance, technology, and business teams to make data-driven spending decisions, resulting in maximum business value.

---

## Major Architecture Metrics

### Elasticity

`Elasticity` refers to a scalable system's ability to scale dynamically, automatically scaling up and down based on the workload. Scaling up is crucial when demand increases, while scaling down can save costs in a cloud environment. Modern systems can scale down to zero, which means they automatically shut down when idle.

### Availability

`Availability` is the percentage of time that an IT service or component is in an operational state.

```
availability = (total elapsed time – sum of downtime)/total elapsed time
```

For availability **99.99%**, system will be down for 52.6 minutes in a whole year.

### Reliability

`Reliability`: The system’s probability of meeting defined standards in performing its intended function during a specified interval.

```
failure rate = number of failures/total time in service
```


### Scalability

`Scalability` is the ability to improve system performance and handle demand by increasing capacity. This can involve scaling a system to handle a high rate of queries or processing a large dataset.

`Vertical scaling` is increasing resources has limitations, and the machine's failure can lead to availability and reliability issues. Distributed systems offer higher overall scaling capacity and improved availability and reliability.

`Horizontal scaling` involves adding more machines to satisfy load and resource requirements, typically led by a leader node. Redundancy is built into modern distributed architectures through data replication, enabling other machines to take over if one fails, and the cluster can add more machines to restore capacity.


## Architectural patterns

The `tightly coupled pattern` involves highly centralized dependencies and workflows, where each domain and service is dependent on one another.

In contrast, the `loosely coupled pattern` involves decentralized domains and services that do not have strict dependencies on each other. To implement this pattern, assign common standards, ownership, responsibility, and accountability to the teams that own their respective domains and services.


{{< columns >}}
**Single-tier architecture**

A `single-tier architecture` tightly couples the database and application, residing on a single server such as a laptop or a virtual machine in the cloud. The tightly coupled nature of this architecture means that if the server, database, or application fails, the entire architecture fails. While single-tier architectures are suitable for prototyping and development, they are not recommended for production environments due to the risks of failures.

<--->

**Multitier**

A `multitier` or `n-tier` architecture consists of separate layers such as data, application, business logic, and presentation. These layers are hierarchical, with the lower layers not necessarily dependent on the upper layers but the upper layers depending on the lower layers. The architecture separates data from the application and application from the presentation.

<--->

**Multitier architecture**

A widely used `multitier architecture` is the three-tier architecture, a client-server design consisting of three layers:
- data, 
- application/logic, 
- and presentation. 

Each tier is isolated from the other, allowing for separation of concerns. With this architecture, it is possible to use different technologies within each tier without being monolithically focused on a single technology stack.

{{< /columns >}}



### Monoliths and Microservices

The `monolith` architecture pattern involves having as much as possible under a single roof. In its extreme version, a monolith comprises a single codebase running on a single machine that provides both the application logic and user interface.

A `microservices architecture` consists of **separate, decentralized, and loosely coupled services**, with each service performing a specific function and decoupled from other services operating within its domain. In this architecture, if one service goes down temporarily, it will not affect the ability of other services to continue functioning.

---

## Other considerations

When considering `multitenancy` in user access, two crucial factors are performance and security. In a cloud system with multiple large tenants, the system must support consistent performance for all tenants, and high usage from one tenant should not degrade performance for others (i.e., noisy neighbor problem). Engineers must prevent data leakage and use appropriate strategies for data isolation, such as using multitenant tables and isolating data through views.


A `shared-nothing architecture` means that each request is handled by a single node that does not share resources such as memory, disk, or CPU with other nodes. This architecture isolates data and resources to each node. Alternatively, multiple nodes can handle multiple requests and share resources, but this can result in resource contention. Another consideration is whether nodes should share the same disk and memory accessible by all nodes, known as a shared disk architecture. This architecture is useful for shared resources in case of a random node failure.

---

## Event-Driven Architecture

`Events` refer to changes in the state of something, such as a new order created by a customer or an update to an existing order.

An `event-driven architecture` comprises components that enable the creation, update, and asynchronous transfer of events across different parts of the data engineering lifecycle. The workflow includes event production, routing, and consumption, with no tightly coupled dependencies among the producer, event router, and consumer.

---

## Types of Data Architecture

### Data Warehouse

A `data warehouse` is a centralized data repository used for reporting and analysis, typically containing highly formatted and structured data for analytics use cases. 

It is an established data architecture with two main characteristics:

- Separation of `online analytical processing (OLAP)` from production databases (online transaction processing), directing load away from production systems and improving analytics performance as businesses grow.

- Centralization and organization of data, accomplished traditionally through `ETL` processes that extract, transform, and load data from source systems into the data warehouse target database system. Multiple data marts serve specific analytical needs for business lines and departments.

### MPPs

`MPPs` (Massively Parallel Processing systems) support SQL semantics used in relational application databases but are optimized for parallel scanning of large volumes of data, enabling high-performance aggregation and statistical calculations. To support even larger data and queries, MPP systems have **shifted from row-based to columnar architecture**, especially in cloud data warehouses. As data and reporting needs grow, MPPs are crucial for running performant queries for large enterprises.

### The Cloud Data Warehouse

`Amazon Redshift` led the revolution of cloud data warehouses by allowing companies to spin up clusters on demand and scale them over time to meet data and analytics demand. Competitors such as `Google BigQuery` and `Snowflake` separated compute from storage, **enabling virtually limitless storage and on-demand computing power** for ad hoc big data capabilities.

These systems support data structures for storing tens of megabytes of raw text data per row or rich and complex JSON documents. As cloud data warehouses and data lakes mature, the line between the two will continue to blur.

### Data marts

A `data mart` is a subset of a data warehouse that is designed to serve analytics and reporting for a specific suborganization, department, or line of business. **Each department can have its own data mart, customized to its specific needs, unlike a full data warehouse that serves the broader organization** or business.

### Data Lake

First versions of data lakes initially relied on Hadoop Distributed File System (HDFS) for storage. Problems were:

1. The data lake became a dumping ground for data, leading to issues with unmanageable data sizes and limited schema management, data cataloging, and discovery tools.
2. The original data lake concept was write-only, leading to challenges with regulations such as GDPR that required targeted deletion of user records.
3. Even simple data transformations, such as joins, were difficult to code as MapReduce jobs.

However, with the growing popularity of cloud computing, data lakes have migrated to cloud-based object storage. The benefits of this include:
- cheap storage costs,
- virtually limitless storage capacity.

In contrast to monolithic data warehouses, **data lakes offer more flexibility and the ability to store an immense amount of data of any size and type**. Users can choose from a variety of data-processing technologies, such as MapReduce, Spark, Ray, Presto, or Hive, depending on the specific requirements of the task at hand.

### Next-Generation Data Lakes

The `lakehouse` is a new approach to managing data that combines the benefits of data lakes and data warehouses. It incorporates the controls, data management, and data structures typically found in a data warehouse. However, it still allows data to be stored in object storage and supports a variety of query and transformation engines.

One significant feature of the lakehouse is **support for atomicity, consistency, isolation, and durability (ACID) transactions**. This represents a big departure from the original data lake approach, where data was simply poured in and never updated or deleted.

### Modern Data Stack

The modern data stack prioritizes self-service analytics and pipelines, agile data management, and open-source or simple proprietary tools with clear pricing. Community is key. Plug-and-play modularity with easy pricing is important for the future of data management. The focus is on flexibility and scalability to adapt to changing business needs.


### Combining streaming and batch

Data engineers had to combine batch and streaming data into a single architecture, leading to the popular `Lambda architecture`. In this approach, **systems operate independently of each other for batch, streaming, and serving**. The source system sends data to stream and batch destinations for processing, with a serving layer providing a combined view.

Lambda architecture has challenges with managing multiple systems and codebases, making it error-prone and difficult to reconcile. While still popular, other technology and practices have emerged for combining streaming and batch data for analytics.

`Kappa architecture` was proposed as an alternative to Lambda architecture. **It uses a stream-processing platform as the backbone for all data handling**, facilitating a true event-based architecture.

However, Kappa architecture has not been widely adopted, possibly because streaming is still a mystery for many companies, and it can be complicated and expensive in practice. While some streaming systems can handle huge data volumes, they are complex and expensive, making batch storage and processing more efficient and cost-effective for large historical datasets.

While the Kappa architecture uses a unified queuing and storage layer, different tools are still needed for real-time statistics and batch aggregation jobs. To address this, Google developed the Dataflow model and Apache Beam framework. **Dataflow views all data as events, with real-time and batch processing happening in the same system using nearly identical code**. Other frameworks like Flink and Spark have adopted a similar approach, with the philosophy of "batch as a special case of streaming" becoming more pervasive.


### Architecture for IoT

`The Internet of Things (IoT)` is a distributed network of connected devices, including computers, sensors, mobile devices, and smart home devices. These devices collect and transmit data to downstream destinations.

Key components of IoT include:

-   **Devices**: The physical hardware connected to the internet, which sense the environment and collect and transmit data.
-   **IoT gateway**: A hub that connects devices and securely routes them to the appropriate destinations on the internet, allowing devices to connect with low power consumption.
-   **Ingestion**: IoT events and measurements flow into an event ingestion architecture, typically beginning with an IoT gateway.
-   **Storage**: Storage requirements depend on the latency requirement for the IoT devices. For remote sensors collecting scientific data for later analysis, batch object storage may be sufficient.
-   **Serving**: IoT data can be analyzed and served in various ways depending on the application, such as using a cloud data warehouse for batch scientific applications or presenting data in multiple ways for home-monitoring applications.


### Data Mesh

The `data mesh` is a new approach to data architecture that **addresses the limitations of monolithic platforms** such as centralized data lakes and data warehouses. It seeks to overcome the divide between operational and analytical data by applying the concept of domain-driven design to data architecture.

Key components of the data mesh include:

- Domain-oriented decentralized data ownership and architecture
- Data as a product
- Self-serve data infrastructure as a platform
- Federated computational governance
