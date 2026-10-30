---
weight: 12
title: "12: The Future of Data Systems"
bookHidden: false
---

# The Future of Data Systems

---

## Overview

The last chapter shifts from describing how things are to how they could be. It proposes ideas and approaches that could improve the way reliable, scalable and maintainable applications are designed and built: integrating many specialized tools through derived data, treating the dataflow of an organization as one big database, building correctness end to end, and taking responsibility for the effects of data systems on people.

---

## Data Integration

Every piece of software has use cases it is good at and others it handles poorly. In complex applications, data is used in several different ways, so no single tool can satisfy all needs. The real challenge is to combine several tools, for example an OLTP database, a full-text search index, a cache and an analytics system, and keep them consistent.

### Combining Specialized Tools by Deriving Data

When copies of the same data must be maintained in several storage systems, it is essential to be clear about the inputs and outputs:

- Where is data written first?
- Which representations are derived from which sources?
- How does data get into all the right places, in the right formats?

> [!WARNING]
> Writes should go through one `system of record` that decides their order. All other systems are `derived` from it, for example through `change data capture (CDC)` or an `event log`. If an application instead writes to the database and to the search index separately (`dual writes`), two clients can see their writes applied in different orders in the two systems, and the systems become permanently inconsistent.

### Derived Data Versus Distributed Transactions

Distributed transactions and derived data both keep different systems consistent, but they work differently:

{{% columns %}}
- **Distributed transactions**

  Decide the order of writes with locks for mutual exclusion. Use atomic commit to make a change take effect exactly once. Provide linearizability, which gives useful guarantees such as reading your own writes. In practice, XA has poor fault tolerance and performance.

- **Log-based derived data**

  Decide the order of writes with a log. Rely on deterministic retry and idempotence for exactly-once effects. Updates are usually asynchronous, so there is no recency guarantee by default. The book considers this the most promising approach for integrating different systems.
{{% /columns %}}

### The Limits of Total Ordering

Constructing a totally ordered event log is feasible for small systems, but it becomes hard at scale:

- A single leader node that decides the order has limited throughput. Partitioning the log makes the order between partitions ambiguous.
- With several geographically distributed datacenters, each with its own leader, the order of events from different datacenters is undefined.
- Microservices usually keep their state in separate stores, so events from different services have no defined order.
- Applications that update local state on the client without waiting for the server can see events in a different order from the server.

Deciding on a total order of events is `total order broadcast`, which is equivalent to consensus. Most consensus algorithms are designed for throughput that a single node can handle, and scaling them beyond that is an open research problem.

### Ordering Events to Capture Causality

When there is no causal link between events, the lack of a total order is not a big problem. Causal dependencies can be subtle, though. In the book's example, a user removes a friend and then sends a message to the remaining friends. If the "remove friend" event and the "send message" event are stored in different places, a notification system may process them in the wrong order and still send the message to the ex-friend. Partial solutions include logical timestamps, logging an event that records the state the user saw before making a decision, and conflict resolution algorithms.

### Batch and Stream Processing

The goal of data integration is to make sure that data ends up in the right form in all the right places. Batch and stream processors are the tools for that. Their outputs are derived datasets such as search indexes, materialized views, recommendations and aggregate metrics.

#### Reprocessing Data for Application Evolution

Derived views make it possible to evolve a system gradually. Reprocessing existing data with a batch job can build a completely new view of the data. A system can then maintain both the old schema and the new schema side by side as two independently derived views, shift a small number of users to the new view, and gradually increase that share. If something goes wrong, the old view is still available, which makes migrations reversible.

> [!NOTE]
> **The railway gauge analogy**
>
> In 19th-century England, competing railways used different track widths, and converting a line to the standard gauge was difficult. One solution was to add a third rail, so that trains of both gauges could run on the same line during the transition. Derived views work the same way: the old and new representations coexist until all consumers have moved over.

#### The Lambda Architecture

The `lambda architecture` records incoming data as immutable events appended to a dataset, as in event sourcing. It runs two systems in parallel: a batch system such as Hadoop MapReduce, which periodically produces a correct derived view, and a stream processor such as Storm, which produces a fast approximate update.

The approach has practical problems:

- The same logic must be maintained in two different frameworks.
- The outputs of the batch and stream pipelines must be merged to answer user requests.
- Reprocessing the entire historical dataset is expensive, so batch jobs are often set up to process incremental batches, which brings back the problems of stream processing such as stragglers and windows across batch boundaries.

#### Unifying Batch and Stream Processing

More recent systems can implement both batch and stream computations in one system. This requires the ability to replay historical events through the same processing engine that handles the stream of recent events, exactly-once semantics for stream processors, and tools for windowing by event time instead of processing time.

---

## Unbundling Databases

At an abstract level, databases, Hadoop and operating systems all store data and allow processing and querying it. Unix provides a fairly low-level hardware abstraction, while relational databases give a high-level abstraction that hides the complexity of data structures on disk, concurrency and crash recovery.

### Composing Data Storage Technologies

A database already contains several features that resemble derived data systems:

- `Secondary indexes` are derived from the primary data.
- `Materialized views` are a precomputed cache of query results.
- `Replication logs` keep copies of the data on other nodes up to date.
- `Full-text search indexes` are built into some relational databases.

Creating a new index is very similar to setting up a new follower replica or bootstrapping change data capture: the database scans a consistent snapshot of the table, builds the index, then processes the backlog of writes that happened in the meantime. In this sense, the dataflow across an entire organization looks like one huge database. Batch and stream processors are like elaborate implementations of triggers, stored procedures and materialized view maintenance routines.

{{% columns %}}
- **Federated databases: unifying reads**

  A unified query interface over many underlying storage engines and processing methods, also known as a `polystore`. PostgreSQL's foreign data wrapper is an example. Applications that need a specialized data model can still access the underlying engine directly.

- **Unbundled databases: unifying writes**

  When a write must be reflected in several storage systems, it is the job of the data system, not the application, to keep them in sync. The book argues for doing this through an `asynchronous event log with idempotent writes`, which plays the role of an index-maintenance mechanism that spans several technologies.
{{% /columns %}}

### Making Unbundling Work

Synchronizing writes through an event log is much more robust and practical than distributed transactions across heterogeneous systems:

- **At the system level**, the event log buffers messages while a consumer is slow or has failed, so a fault in one component is contained locally instead of spreading through the system.
- **At the human level**, different teams can develop, improve and maintain their storage components independently, because the event log is a powerful and simple interface between them.

Unbundling does not replace databases. Databases are still needed for maintaining state in stream processors and for serving queries. The goal is to make it easy to combine several databases to cover a broad range of workloads. What is still missing is a high-level way to declare such combinations, the equivalent of a Unix shell pipeline for storage systems, for example something as simple as declaring that a search index should be kept in sync with a database.

---

## Designing Applications Around Dataflow

The book calls this approach "database inside-out": unbundling the components of a database and composing them with application code.

### Application Code as a Derivation Function

When one dataset is derived from another, it goes through a transformation function. A secondary index uses a simple, standard function. A full-text index applies natural language processing, and a machine learning model or a cache applies application-specific logic. Custom code for creating derived datasets is not handled well by most databases, which were not designed with modern application development requirements in mind.

### Separation of Application Code and State

Most web applications today are deployed as stateless services, with state kept in a database. Databases are poor at notifying the application about changes: an application has to poll to find out whether data has changed. Spreadsheets are a better model: when a cell changes, every formula that depends on it is recomputed automatically.

In a dataflow design, application code responds to state changes in one place by triggering state changes in another place. Maintaining derived data is different from asynchronous job execution with traditional message queues: the order of state changes matters, and fault tolerance is essential, because losing one message makes the derived state permanently inconsistent.

### Stream Processors and Services

A microservices architecture usually communicates through synchronous request/response calls. A dataflow architecture can be faster and more robust. In the book's example, a customer purchases an item priced in one currency but pays in another:

- **Microservice approach**: the purchase service queries an exchange-rate service at the time of purchase.
- **Dataflow approach**: the purchase service subscribes to a stream of exchange-rate updates in advance and records the current rate in a local database. At purchase time, it only queries the local database.

The dataflow approach removes a synchronous network request, which makes it faster and more resilient to the failure of the other service. It is a `time-dependent join` between the purchase events and the exchange-rate updates.

---

## Observing Derived State

> [!WARNING]
> The `write path` is the part of the process that is precomputed eagerly when data comes in, regardless of whether anyone has asked for it. The `read path` is the part that happens only when someone asks for it. The derived dataset is the place where the two paths meet, and it represents a trade-off between the amount of work done at write time and at read time.

### Materialized Views and Caching

A full-text search index illustrates the trade-off. Without an index, every search query has to scan all documents, so all work happens on the read path. With an index, the write path updates the index entries for each document, and the read path only looks up the query words. A cache of the results for common queries shifts more work to the write path. Caches, indexes and materialized views move the boundary between the read and write paths.

### Stateful, Offline-Capable Clients

The traditional web application model has a stateless client and all data on the server. Single-page applications and mobile apps can keep a lot of state locally and work offline. On-device state can be thought of as a cache of state on the server, and the screen is a materialized view of the client's model objects.

### Pushing State Changes to Clients

Protocols such as `server-sent events` and `WebSockets` let a server push state changes to the browser as soon as they happen. This extends the write path all the way to the end user. A device that was offline for some time can catch up by reading the events it missed, like a consumer of a log-based message broker. Tools for client-side state management, such as the Elm language and Facebook's React, Flux and Redux, already manage internal client state by subscribing to a stream of events.

### Reads Are Events Too

A read request can also be represented as an event and sent through the same stream processor as the writes. The processor responds to the read event by emitting the result to an output stream. This turns a request into a stream-table join. Recording read events can also help track causal dependencies and data provenance, at the cost of additional storage and I/O. The same idea enables distributed execution of queries that need data from several partitions, as in Storm's distributed RPC feature.

---

## Aiming for Correctness

For stateless services, a bug is easy to fix: you correct the code and restart. Stateful systems remember things forever, so mistakes also last forever. Transactions have been the traditional way of building correct applications, but weak isolation levels and other subtleties mean that many applications have bugs that only show up under concurrency or faults.

### The End-to-End Argument for Databases

Even a database with strong safety properties, such as serializable transactions, does not guarantee that the application is free from data loss or corruption. An application bug that writes incorrect data or deletes data cannot be undone by the database. Immutable and append-only data makes it easier to recover from such mistakes.

#### Exactly-Once Execution of an Operation

`Exactly-once` (or `effectively-once`) means that the final effect is the same as if no faults had occurred, even if the operation was retried. One approach is to make operations `idempotent`.

#### Duplicate Suppression

TCP suppresses duplicate packets, but only within the context of a single connection. If a client sends a `COMMIT` and the connection breaks before it receives the response, the client does not know whether the transaction was committed. It may retry and execute the transaction twice. The same problem exists between the user's browser and the web server.

#### Operation Identifiers

> [!NOTE]
> To make an operation idempotent through several hops of network communication, generate a unique identifier for the operation, such as a UUID, on the client. Pass this `request ID` all the way to the database and store it in a table with a uniqueness constraint, in the same transaction as the operation itself. A retried request then fails the uniqueness check and does not execute twice. The requests table also acts as a kind of event log.

#### The End-to-End Argument

The `end-to-end argument`, formulated by Saltzer, Reed and Clark in 1984, says that a function can be implemented completely and correctly only with the knowledge and help of the application at the endpoints of the communication system. Duplicate suppression is an example: TCP, database transactions and stream processors each suppress duplicates at their own level, but none of them removes all duplicates on its own. Only a transaction identifier passed from the end-user client all the way to the database solves the problem.

The book argues that it is worth finding better abstractions that make it easy to provide application-specific end-to-end correctness while keeping good performance in a large-scale distributed environment.

### Enforcing Constraints

#### Uniqueness Constraints Require Consensus

Enforcing a uniqueness constraint, such as a unique username or a seat that can be booked only once, requires consensus: when several concurrent requests have the same value, the system must decide which one wins. The common approach is to make a single node the leader responsible for these decisions. Uniqueness checking can be scaled out by partitioning on the value that needs to be unique.

#### Uniqueness in Log-Based Messaging

A log guarantees that all consumers see messages in the same order, which is total order broadcast and equivalent to consensus. To enforce unique usernames:

1. Every request for a username is appended as a message to a log partition determined by a hash of the username.
2. A stream processor reads the messages sequentially and keeps a local database of taken usernames. It emits a success message for a free username and a rejection message for a taken one.
3. The client watches the output stream for the result.

The same approach works for many kinds of constraints. Because messages for one value always go to the same partition and are processed sequentially, conflicting writes are resolved deterministically.

#### Multi-Partition Request Processing

A request that affects several partitions, such as a money transfer from account A to account B, can be handled without an atomic commit:

1. The request to transfer money gets a unique request ID and is appended to a log partition based on that ID.
2. A stream processor reads the request log and emits two messages: a debit instruction for account A, partitioned by A, and a credit instruction for account B, partitioned by B. Both messages carry the original request ID.
3. Further processors consume the credit and debit streams, deduplicate by request ID and apply the changes to the account balances.

Because the request is durably logged once, and every later step is deterministic and idempotent, the transfer is applied exactly once even when processors crash and restart.

### Timeliness and Integrity

The term "consistency" conflates two different requirements:

{{% columns %}}
- **Timeliness**

  Users observe the system in an up-to-date state. A violation is temporary and resolves itself by waiting and trying again. Eventual consistency is a violation of timeliness.

- **Integrity**

  Absence of corruption: no data loss and no contradictory or false data. A violation is permanent, and waiting does not fix it. It requires explicit checking and repair.
{{% /columns %}}

> [!CAUTION]
> In most applications, integrity is much more important than timeliness. A credit card transaction that does not appear on the statement for 24 hours is an acceptable timeliness violation. A statement whose balance does not equal the sum of its transactions, or a charge without a corresponding payment, is a serious integrity violation.

#### Correctness of Dataflow Systems

ACID transactions usually provide both timeliness (linearizability) and integrity (atomic commit). Event-based dataflow systems decouple the two: they do not guarantee timeliness unless consumers are built for it, but they can preserve integrity without distributed transactions by combining these mechanisms:

- Represent the content of a write operation as a single message, which can easily be written atomically.
- Derive all other state updates from that message with deterministic derivation functions.
- Pass a client-generated request ID through all these levels of processing, for end-to-end duplicate suppression and idempotence.
- Make messages immutable and allow derived data to be reprocessed, which makes recovery from bugs easier.

#### Loosely Interpreted Constraints

Many real applications can tolerate a temporary constraint violation, as long as it is fixed afterward with an `apology` or a `compensating transaction`:

- If two people book the same seat or username, one of them gets an apology and an alternative.
- Airlines overbook flights on purpose and compensate passengers who cannot board.
- If more items are ordered than are in stock, the business orders more or apologizes for the delay and offers a discount.
- A bank can charge an overdraft fee and ask for repayment instead of rejecting a withdrawal.

If the cost of the apology is acceptable, the application can write optimistically and check the constraint afterward. Integrity must still be preserved, but timeliness for the constraint check is not required.

#### Coordination-Avoiding Data Systems

Dataflow systems can maintain integrity guarantees on derived data without atomic commit, linearizability or synchronous cross-partition coordination. Many applications can also use loosely interpreted constraints. Such `coordination-avoiding` systems can achieve better performance and fault tolerance than systems that need synchronous coordination. They can operate across several datacenters in a multi-leader configuration and replicate asynchronously between regions. Coordination can still be used where it is truly needed, for example serializable transactions within a single partition.

### Trust, but Verify

System models make assumptions, such as that data written to disk is not lost after `fsync` and that memory is not corrupted. In practice, these assumptions are probabilities, not certainties. Hardware can corrupt data, for example through bit flips caused by the `rowhammer` attack on memory, and mature databases such as MySQL and PostgreSQL have had bugs that violated their own guarantees.

> [!WARNING]
> A system should not blindly trust what storage and software promise. Large-scale storage systems such as HDFS and Amazon S3 run background processes that continually read back files, compare them with other replicas and repair corrupted data. Applications benefit from the same culture of `auditing`: periodically checking the integrity of their own data.

#### Designing for Auditability

When a transaction mutates several objects in a database, it is hard to tell afterward what the transaction meant. Event-based systems give better auditability: the event describing the user input is stored immutably, and derived state updates are deterministic. Running the same events through the same version of the code again reproduces the derived state, which makes it possible to check integrity end to end and to debug problems.

#### Tools for Auditable Data Systems

Cryptographic tools can prove the integrity of a system in a way that is robust against hardware and software issues and even against malicious actions. Blockchains and distributed ledgers such as Bitcoin and Ethereum are essentially Byzantine fault-tolerant replicated logs, but their throughput is low. `Merkle trees` can efficiently prove that a record appears in a dataset, and `certificate transparency` uses them to check the validity of TLS certificates. The book expects integrity-checking and auditing algorithms of this kind to be used more widely in data systems in the future.

---

## Doing the Right Thing

Every system is built for a purpose, and engineers are responsible for the consequences of the systems they build, including consequences they did not intend. Many datasets are about people, so they must be treated with respect for human dignity.

### Predictive Analytics

Algorithms increasingly decide whether someone gets a loan, an insurance policy, a job interview or a flight seat. A person who is systematically excluded based on an algorithm's prediction can end up in an `algorithmic prison`, without any way to find out why or to appeal the decision.

- **Bias and discrimination**: An algorithm trained on historical data learns and amplifies the biases in that data. The book cites the observation that machine learning can work like money laundering for bias. Predictive analytics only extrapolates from the past, so it encodes discrimination that existed in the past.
- **Responsibility and accountability**: When a human makes a mistake, they can be held accountable and the decision can be appealed. It is not clear who is accountable when an algorithm makes a mistake. A credit score summarizes how a person actually behaved in the past, but predictive analytics often judges people by who is similar to them, which amounts to stereotyping.
- **Feedback loops**: Predictions can create self-reinforcing loops. For example, if employers use credit scores to evaluate candidates, someone who falls behind on bills because of misfortune may be unable to get a job, which makes their situation worse.

### Privacy and Tracking

When a system only stores data that a user explicitly entered, the system performs a service for the user. When the user's activity is tracked and logged as a side effect, the relationship is different, and the service starts to serve its own interests, which may conflict with the user's.

> [!CAUTION]
> **Surveillance**
>
> The book suggests a thought experiment: replace the word "data" with "surveillance" and see whether a phrase still sounds good. "In our surveillance-driven organization we collect real-time surveillance streams and store them in our surveillance warehouse" sounds very different from the original.

- **Consent and freedom of choice**: Users agree to terms of service and privacy policies that few people read, and they have little knowledge of what data is collected and how it is processed. For services with strong network effects, declining is not a real choice, because it comes with a social cost.
- **Privacy and use of data**: Privacy does not mean keeping everything secret. It means having the freedom to choose what to reveal to whom. When data is collected through surveillance, this decision right is transferred from the individual to the data collector, who often decides to keep the data secret from the user while exploiting it.
- **Data as assets and power**: Behavioral data is valuable, so it is treated as an asset. It is also a liability: it can leak, be stolen, or be compelled by a future government. Collecting data creates a power imbalance between those who collect it and those who are surveilled.
- **Remembering the Industrial Revolution**: The Industrial Revolution brought economic growth, but also pollution and exploitative working conditions, which took regulation to address. The book quotes Bruce Schneier's view that data is the pollution problem of the information age, and that protecting privacy is the corresponding environmental challenge.
- **Legislation and self-regulation**: Data protection laws were written before the internet era and may be outdated. Engineers should not wait for regulation. They should treat users as humans with dignity and agency, educate users about how their data is used, allow individuals to maintain control over their data, and not keep data forever: purge it as soon as it is no longer needed.

---

## Summary

- No single tool serves all needs, so applications compose several specialized systems. Batch processing and event streams keep derived data consistent with a system of record, which is more robust than distributed transactions.
- The dataflow of an organization can be seen as an unbundled database: storage and processing components connected through asynchronous event logs and idempotent writes.
- Derived state can be observed by pushing changes all the way to end-user devices, and reads can themselves be treated as events.
- Correctness requires end-to-end measures such as client-generated request IDs. Constraints can be enforced through log-based, partitioned processing, and integrity matters more than timeliness.
- Systems should be audited instead of trusted blindly, and engineers carry ethical responsibility for predictive analytics and for the privacy of the people whose data they process.
