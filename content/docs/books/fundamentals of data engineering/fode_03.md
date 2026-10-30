---
weight: 3
title: "03: Designing Good Data Architecture"
---

# Designing Good Data Architecture
---

## Data Architecture
---

`Enterprise architecture` involves designing flexible and reversible systems to support enterprise change through careful trade-off evaluations. It includes subsets like business, technical, application, and data architecture.

`Data architecture` is the design of systems to support the evolving data needs of an enterprise, achieved through flexible and reversible decisions based on a careful evaluation of trade-offs. It includes:

- `operational architecture`: the functional requirements of what needs to happen in terms of people, processes, and technology, for example which business processes the data serves and how quickly data must be available,
- `technical architecture`: how data is ingested, stored, transformed, and served throughout the data engineering lifecycle.

> [!NOTE]
> Jeff Bezos distinguishes **one-way doors**, decisions that are almost impossible to reverse, from **two-way doors**, decisions that are easy to reverse. Good architecture prefers two-way doors so the organization can iterate quickly.

### Good data architecture

`Good data architecture` serves business requirements with a common, widely reusable set of building blocks while keeping flexibility and making appropriate trade-offs. It is flexible and easily maintainable, and it evolves in response to changes in the business and new technologies.

`Bad data architecture` is tightly coupled, rigid, overly centralized, or uses the wrong tools for the job. It tries to force one-size-fits-all decisions on everyone and ends up as a *big ball of mud*.

The authors base their principles on the AWS Well-Architected Framework and Google Cloud's five principles for cloud-native architecture.

## Principles of data engineering architecture
---

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

Commonly used components in data engineering include object storage, version-control systems, observability, monitoring and orchestration systems, and processing engines. It is recommended to make these components accessible with strong security features to facilitate sharing among teams and discourage duplication.

### Principle 2: Plan for Failure.

To build robust data systems, consider failures in designs. Key terms to evaluate failure scenarios include:

- `Availability`: percentage of time an IT service or component is operable.
- `Reliability`: probability of meeting defined standards in performing its intended function during a specified interval.
- `Recovery time objective`: maximum acceptable time for a service or system outage.
- `Recovery point objective`: acceptable state after recovery, specifying the maximum tolerable data loss in data systems.


### Principle 3: Architect for Scalability

An ideal elastic system should automatically scale in response to load, even down to zero. However, improper scaling strategies can lead to complex systems and increased expenses.

### Principle 4: Architecture Is Leadership

Mentoring the development team to handle complex issues is a crucial aspect of being the architect. By enhancing the team's skills, architects can gain more leverage than by making all decisions themselves and becoming a bottleneck.

### Principle 5: Always Be Architecting

Modern architecture is collaborative and agile, not command-and-control or `waterfall`. The data architect maintains a dynamic target architecture that adapts to changing business needs.

### Principle 6: Build Loosely Coupled Systems

Loosely coupled system has the following properties:

1. Divided into small components.
2. Interact through abstraction layers.
3. Changes in one component do not affect others.
4. Each component is updated separately.

Jeff Bezos's API mandate at Amazon is a classic example: teams had to expose their data and functionality only through service interfaces, which decoupled them and is often credited with paving the way for AWS.

### Principle 7: Make Reversible Decisions

The data landscape changes fast. Today's best tool can become tomorrow's legacy system, so architecture decisions should be easy to undo.

- Prefer `reversible decisions` (two-way doors) over irreversible ones (one-way doors).
- Avoid lock-in to a single vendor or tool where you can, so you can swap components as better technology appears.
- Combined with loose coupling, reversible decisions keep the architecture simple and agile and let it change as tools and business needs change.

### Principle 8: Prioritize Security

- Move from `hardened-perimeter` security, which trusts everything inside the network boundary, to `zero-trust` security, which verifies every user and system on every access. Perimeter defenses fail against insider attacks and phishing.
- Understand the `shared responsibility model` of the cloud: the provider secures the cloud, and the customer is responsible for security in the cloud (configuration, access, data).
- Encourage data engineers to act as security engineers too. Many cloud breaches come from customer-side misconfiguration, such as publicly exposed storage buckets.

### Principle 9: Embrace FinOps

`FinOps` is a developing financial management discipline and cultural practice in the cloud that promotes collaboration between engineering, finance, technology, and business teams to make data-driven spending decisions, resulting in maximum business value.

## Major Architecture Concepts
---

### Domains and Services

A `domain` is the real-world subject area you are architecting, such as sales, accounting, or shipping. A `service` is a set of functionality whose goal is to accomplish a task, such as an order-processing service. A domain can contain several services, and a service can be shared across domains. To identify the right domains and services, talk to users and stakeholders about what they do and why.

### Elasticity

`Elasticity` is the ability of a system to scale dynamically based on workload. It includes scaling up and down, with the ability to scale down to zero.

### Availability

`Availability` is the percentage of time that an IT service or component is in an operational state.

```
availability = (total elapsed time - sum of downtime)/total elapsed time
```

For availability **99.99%**, system will be down for 52.6 minutes in a whole year.

### Reliability

`Reliability`: The system's probability of meeting defined standards in performing its intended function during a specified interval.

```
failure rate = number of failures/total time in service
```


### Scalability

`Scalability` is the ability to improve system performance and handle demand by increasing capacity. This can involve scaling a system to handle a high rate of queries or processing a large dataset.

`Vertical scaling` is increasing resources has limitations, and the machine's failure can lead to availability and reliability issues. Distributed systems offer higher overall scaling capacity and improved availability and reliability.

`Horizontal scaling` involves adding more machines to satisfy load and resource requirements, typically led by a leader node. Redundancy is built into modern distributed architectures through data replication, enabling other machines to take over if one fails, and the cluster can add more machines to restore capacity.


## Architectural patterns
---

The `tightly coupled pattern` involves highly centralized dependencies and workflows, where each domain and service is dependent on one another.

In contrast, the `loosely coupled pattern` involves decentralized domains and services that do not have strict dependencies on each other. To implement this pattern, assign common standards, ownership, responsibility, and accountability to the teams that own their respective domains and services.


{{% columns %}}
- **Single-tier architecture**

  A `single-tier architecture` tightly couples the database and application, residing on a single server such as a laptop or a virtual machine in the cloud. The tightly coupled nature of this architecture means that if the server, database, or application fails, the entire architecture fails. While single-tier architectures are suitable for prototyping and development, they are not recommended for production environments due to the risks of failures.

- **Multitier architecture**

  A `multitier` or `n-tier` architecture consists of separate layers such as data, application, business logic, and presentation. The layers are hierarchical: the upper layers depend on the lower layers, but not the other way around. The common `three-tier architecture` is a client-server design with data, application/logic, and presentation tiers. Each tier is isolated, which allows separation of concerns and different technologies in each tier.
{{% /columns %}}



### Monoliths and Microservices

The `monolith` architecture pattern involves having as much as possible under a single roof. In its extreme version, a monolith comprises a single codebase running on a single machine that provides both the application logic and user interface.

A `microservices architecture` consists of **separate, decentralized, and loosely coupled services**, with each service performing a specific function and decoupled from other services operating within its domain. In this architecture, if one service goes down temporarily, it will not affect the ability of other services to continue functioning.

## Other considerations
---

When considering `multitenancy` in user access, two crucial factors are performance and security. In a cloud system with multiple large tenants, the system must support consistent performance for all tenants, and high usage from one tenant should not degrade performance for others (i.e., noisy neighbor problem). Engineers must prevent data leakage and use appropriate strategies for data isolation, such as using multitenant tables and isolating data through views.

A `shared-nothing architecture` means that each request is handled by a single node that does not share resources such as memory, disk, or CPU with other nodes. This architecture isolates data and resources to each node. Alternatively, multiple nodes can handle multiple requests and share resources, but this can result in resource contention. Another consideration is whether nodes should share the same disk and memory accessible by all nodes, known as a shared disk architecture. This architecture is useful for shared resources in case of a random node failure.

### Brownfield Versus Greenfield Projects

- `Brownfield projects` refactor or reorganize an existing architecture and are constrained by present and past choices. Instead of a risky "big bang" rewrite, the `strangler pattern` replaces legacy components incrementally, one piece at a time, which keeps decisions reversible.
- `Greenfield projects` start fresh. The main risks are shiny-object syndrome and resume-driven development: picking the newest technology instead of what serves the project's goals.

## Event-Driven Architecture
---

`Events` refer to changes in the state of something, such as a new order created by a customer or an update to an existing order.

An `event-driven architecture` comprises components that enable the creation, update, and asynchronous transfer of events across different parts of the data engineering lifecycle. The workflow includes event production, routing, and consumption, with no tightly coupled dependencies among the producer, event router, and consumer.

## Types of Data Architecture
---

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

Databricks popularized the `lakehouse`, a new approach to managing data that combines the benefits of data lakes and data warehouses. It incorporates the controls, data management, and data structures typically found in a data warehouse. However, it still allows data to be stored in object storage and supports a variety of query and transformation engines.

One significant feature of the lakehouse is **support for atomicity, consistency, isolation, and durability (ACID) transactions**. This represents a big departure from the original data lake approach, where data was simply poured in and never updated or deleted.

### Modern Data Stack

The modern data stack prioritizes self-service analytics and pipelines, agile data management, and open-source or simple proprietary tools with clear pricing. Community is key. Plug-and-play modularity with easy pricing is important for the future of data management. The focus is on flexibility and scalability to adapt to changing business needs.


### Combining streaming and batch

Data engineers had to combine batch and streaming data into a single architecture, leading to the popular `Lambda architecture`. In this approach, **systems operate independently of each other for batch, streaming, and serving**. The source system sends data to stream and batch destinations for processing, with a serving layer providing a combined view.

Lambda architecture has challenges with managing multiple systems and codebases, making it error-prone and difficult to reconcile. While still popular, other technology and practices have emerged for combining streaming and batch data for analytics.

Jay Kreps proposed the `Kappa architecture` as an alternative to Lambda architecture. **It uses a stream-processing platform as the backbone for all data handling**, facilitating a true event-based architecture.

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

Zhamak Dehghani introduced the `data mesh`, a new approach to data architecture that **addresses the limitations of monolithic platforms** such as centralized data lakes and data warehouses. It seeks to overcome the divide between operational and analytical data by applying the concept of domain-driven design to data architecture.

Key components of the data mesh include:

- Domain-oriented decentralized data ownership and architecture
- Data as a product
- Self-serve data infrastructure as a platform
- Federated computational governance

### Other Data Architecture Examples

The authors also mention data fabric, data hub, scaled architecture, metadata-first architecture, event-driven architecture, and the live data stack. Architectures come and go, so focus on the principles behind them, not on the labels.

## Who's Involved in Designing a Data Architecture?
---

Data architecture is not designed in isolation. Some companies employ dedicated `data architects`, while in many others data engineers take on the architect role themselves.

Data engineers should work alongside a data architect or take on that role, and collaborate with business stakeholders on two questions:

- Which business problems should the architecture solve?
- Which trade-offs (for example, between a data warehouse and a data lake, or between cloud services) fit the organization's needs?
