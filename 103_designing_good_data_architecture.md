# Designing Good Data Architecture
## What Is Data Architecture?

Enterprise Architecture

```
Enterprise architecture is the design of systems to support change in the enterprise, achieved by flexible and reversible decisions reached through careful evaluation of trade-offs. Enterprise architecture has many subsets, including business, technical, application, and data.
```

Data Architecture

```
Data architecture is the design of systems to support the evolving data needs of an enterprise, achieved by flexible and reversible decisions reached through a careful evaluation of trade-offs.

It contains:
- Operational architecture, which encompasses the functional requirements of what needs to happen related to people, processes, and technology.
- Technical architecture, which outlines how data is ingested, stored, transformed, and served along the data engineering lifecycle.
```
---
## Principles of data engineering architecture

Principles of data engineering architecture

```
1. Choose common components wisely.
2. Plan for failure.
3. Architect for scalability.
4. Architecture is leadership.
5. Always be architecting.
6. Build loosely coupled systems.
7. Make reversible decisions.
8. Prioritize security.
9. Embrace FinOps.
```
---

Principle 1. Choose common components wisely.

```
Common components include object storage, version-control systems, observability, monitoring and orchestration systems, and processing engines. Common components should be accessible to everyone with an appropriate use case, and teams are encouraged to rely on common components already in use rather than reinventing the wheel. Common components must support robust permissions and security to enable sharing of assets among teams while preventing unauthorized access.
```

Principle 2: Plan for Failure.

```
To build highly robust data systems, you must consider failures in your designs. Here are a few key terms for evaluating failure scenarios.

- Availability - The percentage of time an IT service or component is in an operable state.

- Reliability - The system’s probability of meeting defined standards in performing its intended function during a specified interval.

- Recovery time objective - The maximum acceptable time for a service or system outage. The recovery time objective (RTO) is generally set by determining the business impact of an outage. An RTO of one day might be fine for an internal reporting system. A website outage of just five minutes could have a significant adverse business impact on an online retailer.

- Recovery point objective - The acceptable state after recovery. In data systems, data is often lost during an outage. In this setting, the recovery point objective (RPO) refers to the maximum acceptable data loss.
```

Principle 3: Architect for Scalability

```
An elastic system can scale dynamically in response to load, ideally in an automated fashion. It would be great if they could scale to zero.

Note that deploying inappropriate scaling strategies can result in over-complicated systems and high costs.
```

Principle 4: Architecture Is Leadership

```
In many ways, the most important activity of Architectus Oryzus is to mentor the development team, to raise their level so they can take on more complex issues. Improving the development team’s ability gives an architect much greater leverage than being the sole decision-maker and thus running the risk of being an architectural bottleneck.
```


Principle 5: Always Be Architecting

```
We add that modern architecture should not be command-and-control or waterfall but collaborative and agile. The data architect maintains a target architecture and sequencing plans that change over time. The target architecture becomes a moving target, adjusted in response to business and technology changes internally and worldwide.
```


Principle 6: Build Loosely Coupled Systems

```
For software architecture, a loosely coupled system has the following properties:

1. Systems are broken into many small components.

2. These systems interface with other services through abstraction layers, such as a messaging bus or an API. These abstraction layers hide and protect internal details of the service, such as a database backend or internal classes and method calls.

3. As a consequence of property 2, internal changes to a system component don’t require changes in other parts. Details of code updates are hidden behind stable APIs. Each piece can evolve and improve separately.

4. As a consequence of property 3, there is no waterfall, global release cycle for the whole system. Instead, each component is updated separately as changes and improvements are made.
```


Principle 7: Make Reversible Decisions

```
Given the pace of change—and the decoupling/modularization of technologies across your data architecture—always strive to pick the best-of-breed solutions that work for today. Also, be prepared to upgrade or adopt better practices as the landscape evolves.
```


Principle 8: Prioritize Security

```
- Zero-trust security models

- The shared responsibility model - In general, all cloud providers operate on some form of this shared responsibility model. They secure their services according to published specifications. Still, it is ultimately the user’s responsibility to design a security model for their applications and data and leverage cloud capabilities to realize this model.

- Data engineers as security engineers
```


Principle 9: Embrace FinOps

```
FinOps is an evolving cloud financial management discipline and cultural practice that enables organizations to get maximum business value by helping engineering, finance, technology, and business teams to collaborate on data-driven spending decisions.
```
---

## Major Architecture Concepts

Domains and Services

```
Domain: A sphere of knowledge, influence, or activity. The subject area to which the user applies a program is the domain of the software.

A domain is the real-world subject area for which you’re architecting. A service is a set of functionality whose goal is to accomplish a task.

A domain can contain multiple services. For example, you might have a sales domain with three services: orders, invoicing, and products.
```
---

Scalability

```
Allows us to increase the capacity of a system to improve performance and handle the demand. For example, we might want to scale a system to handle a high rate of queries or process a huge data set.
```
---

Elasticity

```
The ability of a scalable system to scale dynamically; a highly elastic system can automatically scale up and down based on the current workload. Scaling up is critical as demand increases, while scaling down saves money in a cloud environment. Modern systems sometimes scale to zero, meaning they can automatically shut down when idle.
```
---

Availability

```
The percentage of time an IT service or component is in an operable state.

Percentage of availability = (total elapsed time – sum of downtime)/total elapsed time

For availability 99.99%, system will be down for 52.6 minutes in a whole year.
```
---

Reliability

```
The system’s probability of meeting defined standards in performing its intended function during a specified interval.

Failure rate = number of failures/total time in service
```
---

Distributed systems (vertical and horizontal scaling).

```
A single machine can be scaled vertically; you can increase resources (CPU, disk, memory, I/O). But there are hard limits to possible resources on a single machine. Also, what happens if this machine dies? Given enough time, some components will eventually fail. What’s your plan for backup and failover? Single machines generally can’t offer high availability and reliability.

We utilize a distributed system to realize higher overall scaling capacity and increased availability and reliability. Horizontal scaling allows you to add more machines to satisfy load and resource requirements. Common horizontally scaled systems have a leader node that acts as the main point of contact for the instantiation, progress, and completion of workloads. When a workload is started, the leader node distributes tasks to the worker nodes within its system, completing the tasks and returning the results to the leader node. Typical modern distributed architectures also build in redundancy. Data is replicated so that if a machine dies, the other machines can pick up where the missing server left off; the cluster may add more machines to restore capacity.
```
---

## Architectural patterns

Tightly coupled pattern

```
Extremely centralized dependencies and workflows. Every part of a domain and service is vitally dependent upon every other domain and service.
```

Loosely coupled pattern

```
Decentralized domains and services that do not have strict dependence on each other. Be sure to assign common standards, ownership, responsibility, and accountability to the teams owning their respective domains and services.
```
---

## Architecture tiers

Single tier

```
In a single-tier architecture, your database and application are tightly coupled, residing on a single server. This server could be your laptop or a single virtual machine (VM) in the cloud. The tightly coupled nature means if the server, the database, or the application fails, the entire architecture fails. While single-tier architectures are good for prototyping and development, they are not advised for production environments because of the obvious failure risks.

Database <--> Application
```

Multitier (n-tier)

```
The challenges of a tightly coupled single-tier architecture are solved by decoupling the data and application.

A multitier (also known as n-tier) architecture is composed of separate layers: data, application, business logic, presentation, etc. These layers are bottom-up and hierarchical, meaning the lower layer isn’t necessarily dependent on the upper layers; the upper layers depend on the lower layers. The notion is to separate data from the application, and application from the presentation.
```

Three-tier architecture

```
A common multitier architecture is a three-tier architecture, a widely used client-server design.

Data layer --> Application/logic later --> Presentation layer

Each tier is isolated from the other, allowing for separation of concerns. With a three-tier architecture, you’re free to use whatever technologies you prefer within each tier without the need to be monolithically focused.
```
---

Shared-nothing architecture and shared disk architecture

```
Shared-nothing architecture: a single node handles each request, meaning other nodes do not share resources such as memory, disk, or CPU with this node or with each other. Data and resources are isolated to the node.

Alternatively, various nodes can handle multiple requests and share resources but at the risk of resource contention. Another consideration is whether nodes should share the same disk and memory accessible by all nodes. This is called a shared disk architecture and is common when you want shared resources if a random node failure occurs.
```
---

Monoliths

```
The general notion of a monolith includes as much as possible under one roof; in its most extreme version, a monolith consists of a single codebase running on a single machine that provides both the application logic and user interface.
```
---

Microservices

```
Microservices architecture comprises separate, decentralized, and loosely coupled services. Each service has a specific function and is decoupled from other services operating within its domain. If one service temporarily goes down, it won’t affect the ability of other services to continue functioning.
```
---

## Other considerations

User Access: Single Versus Multitenant

```
We have two factors to consider in multitenancy: performance and security. With multiple large tenants within a cloud system, will the system support consistent performance for all tenants, or will there be a noisy neighbor problem? (That is, will high usage from one tenant degrade performance for other tenants?) Regarding security, data from different tenants must be properly isolated. When a company has multiple external customer tenants, these tenants should not be aware of one another, and engineers must prevent data leakage. Strategies for data isolation vary by system. For instance, it is often perfectly acceptable to use multitenant tables and isolate data through views. However, you must make certain that these views cannot leak data. Read vendor or project documentation to understand appropriate strategies and risks.
```
---

Brownfield projects

```
Brownfield projects often involve refactoring and reorganizing an existing architecture and are constrained by the choices of the present and past. Brownfield projects require a thorough understanding of the legacy architecture and the interplay of various old and new technologies
```

Greenfield Projects

```
On the opposite end of the spectrum, a greenfield project allows you to pioneer a fresh start, unconstrained by the history or legacy of a prior architecture. There’s also a temptation to do resume-driven development, stacking up impressive new technologies without prioritizing the project’s ultimate goals. Always prioritize requirements over building something cool.
```
---

## Event-Driven Architecture

Event and state

```
These are all examples of events that are broadly defined as something that happened, typically a change in the state of something. For example, a new order might be created by a customer, or a customer might later make an update to this order.
```

Event-Driven architecture components

```
An event-driven workflow (Figure 3-8) encompasses the ability to create, update, and asynchronously move events across various parts of the data engineering lifecycle. This workflow boils down to three main areas: event production, routing, and consumption. An event must be produced and routed to something that consumes it without tightly coupled dependencies among the producer, event router, and consumer.
```
---

## Types of Data Architecture

Data Warehouse

```
A data warehouse is a central data hub used for reporting and analysis. Data in a data warehouse is typically highly formatted and structured for analytics use cases. It’s among the oldest and most well-established data architectures.

The organizational data warehouse architecture has two main characteristics:
- Separates online analytical processing (OLAP) from production databases (online transaction processing). This separation is critical as businesses grow. Moving data into a separate physical system directs load away from production systems and improves analytics performance.

- Centralizes and organizes data. Traditionally, a data warehouse pulls data from application systems by using ETL. The extract phase pulls data from source systems. The transformation phase cleans and standardizes data, organizing and imposing business logic in a highly modeled form. The load phase pushes data into the data warehouse target database system. Data is loaded into multiple data marts that serve the analytical needs for specific lines or business and departments. The data warehouse and ETL go hand in hand with specific business structures, including DBA and ETL developer teams that implement the direction of business leaders to ensure that data for reporting and analytics corresponds to business processes.
```
---

MPPs

```
MPPs support essentially the same SQL semantics used in relational application databases. Still, they are optimized to scan massive amounts of data in parallel and thus allow high-performance aggregation and statistical calculations. In recent years, MPP systems have increasingly shifted from a row-based to a columnar architecture to facilitate even larger data and queries, especially in cloud data warehouses. MPPs are indispensable for running performant queries for large enterprises as data and reporting needs grow
```
---

The Cloud Data Warehouse

```
Amazon Redshift kicked off the cloud data warehouse revolution.

Instead of needing to appropriately size an MPP system for the next several years and sign a multimillion-dollar contract to procure the system, companies had the option of spinning up a Redshift cluster on demand, scaling it up over time as data and analytics demand grew. They could even spin up new Redshift clusters on demand to serve specific workloads and quickly delete clusters when they were no longer needed.

Google BigQuery, Snowflake, and other competitors popularized the idea of separating compute from storage. In this architecture, data is housed in object storage, allowing virtually limitless storage. This also gives users the option to spin up computing power on demand, providing ad hoc big data capabilities without the long-term cost of thousands of nodes.

They typically support data structures that allow the storage of tens of megabytes of raw text data per row or extremely rich and complex JSON documents. As cloud data warehouses (and data lakes) mature, the line between the data warehouse and the data lake will continue to blur.
```
---

Data marts

```
A data mart is a more refined subset of a warehouse designed to serve analytics and reporting, focused on a single suborganization, department, or line of business; every department has its own data mart, specific to its needs. This is in contrast to the full data warehouse that serves the broader organization or business.
```
---

Data Lake

```
Data lake 1.0 started with HDFS. As the cloud grew in popularity, these data lakes moved to cloud-based object storage, with extremely cheap storage costs and virtually limitless storage capacity. Instead of relying on a monolithic data warehouse where storage and compute are tightly coupled, the data lake allows an immense amount of data of any size and type to be stored.

When this data needs to be queried or transformed, you have access to nearly unlimited computing power by spinning up a cluster on demand, and you can pick your favorite data-processing technology for the task at hand—MapReduce, Spark, Ray, Presto, Hive, etc.

Despite the promise and hype, data lake 1.0 had serious shortcomings. The data lake became a dumping ground; terms such as data swamp, dark data, and WORN were coined as once-promising data projects failed. Data grew to unmanageable sizes, with little in the way of schema management, data cataloging, and discovery tools. In addition, the original data lake concept was essentially write-only, creating huge headaches with the arrival of regulations such as GDPR that required targeted deletion of user records.

Relatively banal data transformations such as joins were a huge headache to code as MapReduce jobs.
```

Convergence, Next-Generation Data Lakes, and the Data Platform

```
The lakehouse incorporates the controls, data management, and data structures found in a data warehouse while still housing data in object storage and supporting a variety of query and transformation engines. In particular, the data lakehouse supports atomicity, consistency, isolation, and durability (ACID) transactions, a big departure from the original data lake, where you simply pour in data and never update or delete it. The term data lakehouse suggests a convergence between data lakes and data warehouses.
```
---

Modern Data Stack

```
Key outcomes of the modern data stack are self-service (analytics and pipelines), agile data management, and using open source tools or simple proprietary tools with clear pricing structures. Community is a central aspect of the modern data stack as well. Regardless of where “modern” goes, we think the key concept of plug-and-play modularity with easy-to-understand pricing and implementation is the way of the future.
```
---

Lambda Architecture

```
Data engineers needed to figure out how to reconcile batch and streaming data into a single architecture. The Lambda architecture was one of the early popular responses to this problem.

In a Lambda architecture (Figure 3-14), you have systems operating independently of each other—batch, streaming, and serving. The source system is ideally immutable and append-only, sending data to two destinations for processing: stream and batch. In-stream processing intends to serve the data with the lowest possible latency in a “speed” layer, usually a NoSQL database. In the batch layer, data is processed and transformed in a system such as a data warehouse, creating precomputed and aggregated views of the data. The serving layer provides a combined view by aggregating query results from the two layers.

Lambda architecture has its share of challenges and criticisms. Managing multiple systems with different codebases is as difficult as it sounds, creating error-prone systems with code and data that are extremely difficult to reconcile. We mention Lambda architecture because it still gets attention and is popular in search-engine results for data architecture. Lambda isn’t our first recommendation if you’re trying to combine streaming and batch data for analytics. Technology and practices have moved on.
```

Kappa Architecture

```
As a response to the shortcomings of Lambda architecture, Jay Kreps proposed an alternative called Kappa architecture

The central thesis is this: why not just use a stream-processing platform as the backbone for all data handling—ingestion, storage, and serving? This facilitates a true event-based architecture. Real-time and batch processing can be applied seamlessly to the same data by reading the live event stream directly and replaying large chunks of data for batch processing

Though the original Kappa architecture article came out in 2014, we haven’t seen it widely adopted. There may be a couple of reasons for this. First, streaming itself is still a bit of a mystery for many companies; it’s easy to talk about, but harder than expected to execute. Second, Kappa architecture turns out to be complicated and expensive in practice. While some streaming systems can scale to huge data volumes, they are complex and expensive; batch storage and processing remain much more efficient and cost-effective for enormous historical datasets.
```
---


The Dataflow Model and Unified Batch and Streaming

```
One of the central problems of managing batch and stream processing is unifying multiple code paths. While the Kappa architecture relies on a unified queuing and storage layer, one still has to confront using different tools for collecting real-time statistics or running batch aggregation jobs. Today, engineers seek to solve this in several ways. Google made its mark by developing the Dataflow model and the Apache Beam framework that implements this model

The core idea in the Dataflow model is to view all data as events, as the aggregation is performed over various types of windows. Ongoing real-time event streams are unbounded data. Data batches are simply bounded event streams, and the boundaries provide a natural window. Engineers can choose from various windows for real-time aggregation, such as sliding or tumbling. Real-time and batch processing happens in the same system using nearly identical code. The philosophy of “batch as a special case of streaming” is now more pervasive. Various frameworks such as Flink and Spark have adopted a similar approach.
```
---


Architecture for IoT

```
The Internet of Things (IoT) is the distributed collection of devices, aka things— computers, sensors, mobile devices, smart home devices, and anything else with an internet connection.

Components:
- Devices - (also known as things) are the physical hardware connected to the internet, sensing the environment around them and collecting and transmitting data to a downstream destination

- IoT gateway - a hub for connecting devices and securely routing devices to the appropriate destinations on the internet. While you can connect a device directly to the internet without an IoT gateway, the gateway allows devices to connect using extremely little power. It acts as a way station for data retention and manages an internet connection to the final data destination.

- Ingestion - begins with an IoT gateway, as discussed previously. From there, events and measurements can flow into an event ingestion architecture.

- Storage - storage requirements will depend a great deal on the latency requirement for the IoT devices in the system. For example, for remote sensors collecting scientific data for analysis at a later time, batch object storage may be perfectly acceptable.

- Serving - Serving patterns are incredibly diverse. In a batch scientific application, data might be analyzed using a cloud data warehouse and then served in a report. Data will be presented and served in numerous ways in a home-monitoring application.
```
---

Data Mesh

```
The data mesh is a recent response to sprawling monolithic data platforms, such as centralized data lakes and data warehouses, and “the great divide of data,” wherein the landscape is divided between operational data and analytical data. The data mesh attempts to invert the challenges of centralized data architecture, taking the concepts of domain-driven design (commonly used in software architectures) and applying them to data architecture.

Key components:
• Domain-oriented decentralized data ownership and architecture
• Data as a product
• Self-serve data infrastructure as a platform
• Federated computational governance
```