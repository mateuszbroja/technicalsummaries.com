---
weight: 4
title: "04: Encoding and Evolution"
bookHidden: false
---

# Encoding and Evolution
---

Applications inevitably change over time, and a change to features usually requires a change to the data the application stores. Programs work with data in (at least) two different representations:

- **In-memory data**: objects, structs, lists, arrays, hash tables, trees, and so on. These structures are optimized for efficient access and manipulation by the CPU, typically with pointers.
- **Data written to a file or sent over the network**: a self-contained sequence of bytes. Pointers make no sense to another process, so this representation looks quite different.

> [!NOTE]
> Translating the in-memory representation to a byte sequence is called **encoding** (also known as `serialization` or `marshalling`). The reverse is called **decoding** (`parsing`, `deserialization`, `unmarshalling`).

---

## Evolution and Compatibility

A relational database assumes that all data conforms to one schema. The schema can be changed, but exactly one schema is in force at any point in time. **Schema-on-read (schemaless) databases do not enforce a schema, so they can contain a mixture of older and newer data formats.**

When a data format or schema changes, the application code has to change too, but in a large application the change cannot happen instantaneously:

- **Server-side applications** use a `rolling upgrade` (`staged rollout`): the new version is deployed to a few nodes at a time, and each node is checked before moving on. This allows deployments without downtime and therefore more frequent releases and better evolvability.
- **Client-side applications** depend on the user, who may not install an update for some time.

Old and new versions of the code, and old and new data formats, may therefore all coexist in the system at the same time. Compatibility is needed in both directions:

- `Backward compatibility`: newer code can read data that was written by older code. This is usually not hard, because the author of the new code knows the old format.
- `Forward compatibility`: older code can read data that was written by newer code. This is trickier, because old code has to ignore additions made by a newer version.

---

## Formats for Encoding Data

### Language-Specific Formats

Many programming languages have built-in encoding support: `java.io.Serializable` in Java, `Marshal` in Ruby, `pickle` in Python. They are convenient but have deep problems:
- The encoding is tied to one programming language, which makes reading the data from another language very difficult.
- Decoding needs to instantiate arbitrary classes, which is a source of **security problems**: an attacker who can make the application decode arbitrary bytes can often execute arbitrary code.
- Versioning is often an afterthought, so forward and backward compatibility are neglected.
- Efficiency (CPU time and encoded size) is often an afterthought too. Java's built-in serialization is notorious for bad performance and bloated encoding.

**It is generally a bad idea to use a language's built-in encoding for anything other than very transient purposes.**

---

### JSON, XML, and Binary Variants

`JSON`, `XML`, and `CSV` are widely known, widely supported, and textual, so they are somewhat human-readable. They have subtle problems:

- **Ambiguity around numbers**: XML and CSV cannot distinguish a number from a string that happens to consist of digits without an external schema. JSON distinguishes strings and numbers, but not integers and floating-point numbers, and does not specify a precision. Integers greater than 2^53 cannot be represented exactly as IEEE 754 doubles, which is why Twitter's API returns 64-bit tweet IDs twice: as a JSON number and as a decimal string.
- **No binary strings**: JSON and XML support Unicode text but not raw byte sequences. Binary data is usually encoded as Base64, which works but increases the size by 33%.
- **Schemas are optional and complicated**: XML Schema and JSON Schema are powerful but complex to learn and implement. Applications without a schema must hardcode the encoding and decoding logic.
- **CSV has no schema at all**, so the application defines the meaning of each row and column. Changes such as a new column must be handled manually, and escaping rules are vague and not implemented by all parsers.

Despite these flaws, JSON, XML, and CSV are good enough for many purposes, especially as data interchange formats between organizations, where getting everyone to agree on a format matters more than efficiency.

**Binary encodings of JSON and XML** exist, such as `MessagePack`, `BSON`, `BJSON`, `UBJSON`, `BISON`, and `Smile` for JSON, and `WBXML` and `Fast Infoset` for XML. They do not prescribe a schema, so they must include all the object field names within the encoded data. The size reduction is therefore small: in the book's example, MessagePack shrinks an 81-byte JSON record to only 66 bytes.

---

### Thrift and Protocol Buffers

`Apache Thrift` (originally developed at Facebook) and `Protocol Buffers` (`protobuf`, developed at Google) are binary encoding libraries based on the same principle. Both require a **schema** for any data that is encoded, defined in an interface definition language (IDL), and both come with a code generation tool that produces classes implementing the schema in various programming languages.

The key difference from binary JSON is that **the encoded data contains no field names**. Instead, it contains `field tags`: numbers such as 1, 2, 3 that appear in the schema definition. This makes the encoding much more compact.

#### Apache Thrift

- Has two main binary encoding formats: `BinaryProtocol` and `CompactProtocol` (and `DenseProtocol`, supported only in C++).
- `BinaryProtocol` encodes the example record in 59 bytes.
- `CompactProtocol` packs the field type and tag number into a single byte and uses variable-length integers, which brings the same record down to 34 bytes.
- Has a dedicated `list` datatype, parameterized with the type of the list elements, which supports nested lists.

#### Protocol Buffers

- Has only one binary encoding format, which does the bit packing slightly differently from Thrift's CompactProtocol. The example record takes 33 bytes.
- Has no list or array datatype. A field is marked `repeated` instead, which means the same field tag simply appears multiple times in the record.

#### Schema Evolution with Field Tags

- **Field names can change**, because the encoded data never refers to field names.
- **Field tags cannot change**, because that would make all existing encoded data invalid.
- **Adding a field**: give it a new tag number. Old code ignores fields with tag numbers it does not recognize; the datatype annotation tells the parser how many bytes to skip. This keeps **forward compatibility**.
- New code can always read old data, because the tag numbers still mean the same thing. However, **a newly added field cannot be required**, otherwise new code would fail to read old data that does not contain it. To keep **backward compatibility**, every field added after the initial deployment must be optional or have a default value.
- **Removing a field** works like adding one in reverse: only optional fields can be removed, and the same tag number must never be used again.
- **Changing a datatype** may be possible but risks losing precision or truncating values. For example, if a 32-bit integer becomes a 64-bit integer, old code reading new data truncates the value.
- In Protocol Buffers, an optional (single-valued) field can be changed into a `repeated` (multi-valued) field. New code reading old data sees a list with zero or one element; old code reading new data sees only the last element of the list.

---

### Apache Avro

`Apache Avro` is another binary encoding format, started in 2009 as a subproject of Hadoop because Thrift was not a good fit for Hadoop's use cases.

- It uses a schema, with two schema languages: `Avro IDL`, intended for human editing, and a JSON-based one that is more easily machine-readable.
- **The encoding contains no field names and no tag numbers**, and nothing identifies the datatypes. It is just values concatenated together. This makes it the most compact of the formats: 32 bytes for the example record.
- To parse the binary data, the reader goes through the fields in the order they appear in the schema. **The data can only be decoded correctly if the reading code uses exactly the same schema as the writing code**, or a compatible one.

#### The Writer's Schema and the Reader's Schema

- The `writer's schema` is the schema used by the application that encodes the data.
- The `reader's schema` is the schema the decoding application expects.
- **They do not have to be the same, only compatible.** The Avro library resolves the differences by looking at both schemas side by side and translating the data from the writer's schema into the reader's schema. Fields are matched by name, so their order may differ.
- A field that appears in the writer's schema but not in the reader's schema is ignored. A field that the reader expects but the writer did not write is filled in with the default value declared in the reader's schema.

#### Schema Evolution Rules

- **Forward compatibility**: a new version of the schema as writer and an old version as reader. **Backward compatibility**: a new version as reader and an old version as writer.
- To maintain compatibility, **only fields that have a default value can be added or removed**.
- `null` is not an acceptable default value for any variable unless a `union` type is used, for example `union { null, long, string }`. Avro has no `optional` and `required` markers; it uses union types and default values instead.
- Changing the datatype of a field is possible if Avro can convert the type.
- Changing the name of a field is possible but tricky: the reader's schema can contain aliases for field names, so it can match an old writer's field name. This is backward compatible but not forward compatible.
- Adding a branch to a union type is backward compatible but not forward compatible.

#### How Does the Reader Know the Writer's Schema?

Including the whole schema with every record would make the encoding pointless, so it depends on the context:
- **Large file with lots of records**: the writer includes its schema once at the beginning of the file (`object container files`).
- **Database with individually written records**: each record starts with a version number, and the database keeps a list of schema versions. The reader fetches the record, extracts the version number, and looks up the writer's schema. Espresso works this way.
- **Sending records over a network connection**: the two processes negotiate the schema version on connection setup and use it for the lifetime of the connection. The Avro RPC protocol works this way.

A **database of schema versions** is useful in any case, because it acts as documentation and makes it possible to check schema compatibility.

#### Dynamically Generated Schemas

Avro does not use tag numbers, which makes it **friendlier to dynamically generated schemas**. For example, to dump the contents of a relational database to a file, an Avro schema can be generated from the relational schema, with each table becoming a record and each column a field. If the database schema changes, a new Avro schema is generated, and fields are still matched by name. With Thrift or Protocol Buffers, an administrator would have to assign field tags manually.

#### Code Generation

Thrift and Protocol Buffers rely on code generation, which is useful in statically typed languages such as Java, C++, or C#: it allows efficient in-memory structures and type checking. In dynamically typed languages such as JavaScript, Ruby, or Python, code generation adds little. Avro provides **optional** code generation: an Avro object container file is self-describing because it contains the writer's schema, so it can be opened with the Avro library like a JSON file. This is useful for dynamic data processing languages such as Apache Pig.

---

### The Merits of Schemas

Binary encodings based on schemas have a long history, going back to `ASN.1` (standardized in 1984). They have several advantages over JSON and XML:
- **Compact**: they can be much more compact than binary JSON variants because they omit field names.
- **Documentation**: the schema is required for decoding, so it is always up to date, unlike manually maintained documentation.
- **Compatibility checks**: a database of schemas allows checking forward and backward compatibility of schema changes before anything is deployed.
- **Type checking**: generating code from the schema enables type checking at compile time in statically typed languages.

| Format | Created by | Field identification | Schema evolution |
| ------ | ---------- | -------------------- | ---------------- |
| Thrift | Facebook | Tag numbers | Names can change; tags cannot. Only optional fields can be added or removed. |
| Protocol Buffers | Google | Tag numbers | Same rules as Thrift; an optional field can become `repeated`. |
| Avro | Apache (Hadoop) | None; values in schema order | Writer's and reader's schemas are resolved by field name. Only fields with defaults can be added or removed. |

---

## Modes of Dataflow

Compatibility is a relationship between one process that encodes the data and another that decodes it. The most common ways data flows between processes are:
- via databases,
- via service calls (REST and RPC),
- via asynchronous message passing.

---

### Dataflow Through Databases

> [!WARNING]
> **Data outlives code.** When a new version of an application is deployed, the old code may be replaced within minutes, but a database may contain records that were written five years ago. Rewriting (migrating) data into a new schema is possible but expensive on a large dataset, so most databases avoid it.

- **Backward compatibility** is necessary: a value written by an older version of the code will be read by a newer version later.
- **Forward compatibility** is often needed too: during a rolling upgrade, a value written by a newer version may be read by an older version that is still running.
- **Preserving unknown fields**: if new code adds a field and old code reads the record, updates it, and writes it back, the old code should keep the new field intact. Decoding into model objects and re-encoding them can silently lose such a field.
- Most relational databases allow simple schema changes, such as adding a new column with a `null` default value, without rewriting existing data. When an old row is read, the database fills in `null` for the missing column. LinkedIn's document database Espresso uses Avro for storage, which allows it to use Avro's schema evolution rules.
- **Archival storage**: database snapshots for backups or for loading into a data warehouse are typically encoded with the latest schema, even if the source contained a mixture of versions. Such a dump is written in one go and is immutable afterwards, so formats like Avro object container files or column-oriented formats such as `Parquet` are a good fit.

---

### Dataflow Through Services: REST and RPC

The most common arrangement for communication over a network involves **clients and servers**: the servers expose an API over the network, and clients connect to make requests. The API exposed by the server is known as a `service`.

- A server can itself be a client of another service. This approach of decomposing a large application into smaller services by area of functionality is called `service-oriented architecture` (`SOA`), more recently refined and rebranded as `microservices`.
- A key design goal is to make the application easier to change by making services **independently deployable and evolvable**. Old and new versions of servers and clients will run at the same time, so the encoding must be compatible across versions of the service API.

#### Web Services

When HTTP is used as the underlying protocol, the service is called a web service. There are two popular approaches:
- `REST` is not a protocol but a design philosophy that builds on the principles of HTTP: simple data formats, URLs for identifying resources, and HTTP features for cache control, authentication, and content type negotiation. An API designed according to these principles is called `RESTful`. Definition formats such as `OpenAPI` (`Swagger`) can describe RESTful APIs and produce documentation.
- `SOAP` is an XML-based protocol for making network API requests. The API of a SOAP web service is described in the XML-based Web Services Description Language (`WSDL`), which enables code generation. SOAP relies heavily on tool support, and interoperability between different vendors' implementations often causes problems. It has fallen out of favor in most smaller companies.

#### The Problems with Remote Procedure Calls (RPCs)

The `RPC` model, dating back to the 1970s, tries to make a request to a remote network service look the same as calling a function within the same process (`location transparency`). This approach is fundamentally flawed, because a network request is very different from a local function call:
- A local call is predictable. A network request is unpredictable: the request or response may be lost, or the remote machine may be slow or unavailable.
- A network request may return **without a result** because of a timeout, and there is no way to know whether the request got through.
- **Retrying** a failed request may cause the action to be performed multiple times if only the response was lost. This requires deduplication (`idempotence`) in the protocol.
- **Latency** of a network request is much higher and wildly variable compared to a local call.
- Parameters must be encoded into bytes. Passing references to objects in local memory is impossible, and large objects become a problem.
- Client and service may be implemented in different programming languages, so the RPC framework must translate datatypes, which is not always clean (for example, JavaScript's problems with numbers greater than 2^53).

#### Current Directions for RPC

Despite these problems, RPC is not going away. Frameworks built on the encodings above include Thrift and Avro RPC, `gRPC` (based on Protocol Buffers), `Finagle` (Thrift), and `Rest.li` (JSON over HTTP). The new generation of frameworks is more explicit about the fact that a remote request differs from a local call:
- **Futures** (`promises`) encapsulate asynchronous actions that may fail and simplify situations where a service makes requests to several services in parallel and combines their results.
- **Streams**: gRPC supports a call that consists of a series of requests and responses over time, not just one request and one response.
- **Service discovery**: some frameworks let a client find out at which IP address and port number a particular service can be found.

Custom RPC protocols with binary encoding can achieve better performance than JSON over REST. RESTful APIs, however, are good for experimentation and debugging (they can be called from a web browser or `curl`), are supported by all mainstream languages and platforms, and have a vast ecosystem of tools. **REST is the predominant style for public APIs; RPC frameworks are mainly used for requests between services owned by the same organization.**

#### Data Encoding and Evolution for RPC

It is reasonable to assume that all servers are updated first and all clients second. Then only **backward compatibility on requests** and **forward compatibility on responses** are needed.
- The compatibility properties of an RPC scheme are inherited from its encoding: Thrift, gRPC, and Avro RPC evolve according to the rules of their formats, SOAP according to XML schemas, and RESTful JSON APIs usually by adding optional request parameters and new fields to responses.
- When a service is used across organizational boundaries, the provider has no control over its clients and cannot force them to upgrade, so compatibility must be maintained for a long time, perhaps indefinitely. If a breaking change is required, the provider ends up running multiple versions of the API side by side.
- There is no agreement on how API versioning should work. For RESTful APIs, the common approaches are a version number in the URL or in the HTTP `Accept` header. For services that use API keys, the requested version can be stored on the server and updated through an administrative interface.

---

### Message-Passing Dataflow

`Asynchronous message-passing systems` are somewhere between RPC and databases. A client's request (a `message`) is delivered to another process with low latency, as with RPC. The message is not sent via a direct network connection, but through an intermediary called a `message broker` (`message queue`), which stores it temporarily, similar to a database.

**Advantages of a message broker over direct RPC:**
- It acts as a **buffer** if the recipient is unavailable or overloaded, which improves system reliability.
- It can automatically **redeliver** messages to a process that has crashed, which prevents messages from being lost.
- The sender does not need to know the IP address and port number of the recipient, which is useful in a cloud deployment where virtual machines come and go.
- One message can be sent to **several recipients**.
- It **logically decouples** the sender from the recipient: the sender just publishes messages and does not care who consumes them.

Communication is usually **one-way**: the sender does not wait for the message to be delivered. A process can send a response, but that is usually done on a separate channel. This pattern is asynchronous.

#### Message Brokers

Examples are commercial enterprise software such as `TIBCO`, `IBM WebSphere`, and `webMethods`, and open source implementations such as `RabbitMQ`, `ActiveMQ`, `HornetQ`, `NATS`, and `Apache Kafka`.
- One process sends a message to a named `queue` or `topic`, and the broker ensures that the message is delivered to one or more `consumers` of or `subscribers` to that queue or topic. There can be many producers and many consumers on the same topic.
- A topic provides only one-way dataflow. A consumer may itself publish messages to another topic, or to a reply queue consumed by the sender of the original message, which allows a request/response dataflow similar to RPC.
- Message brokers typically do not enforce any particular data model: a message is just a sequence of bytes with some metadata, so **any encoding format can be used**. If the encoding is backward and forward compatible, publishers and consumers can be changed and deployed independently, in any order.
- If a consumer republishes messages to another topic, it must preserve unknown fields, the same issue as with databases.

#### Distributed Actor Frameworks

The `actor model` is a programming model for concurrency in a single process. Logic is encapsulated in **actors** instead of dealing directly with threads, race conditions, locking, and deadlock. Each actor typically represents one client or entity, may have some local state that is not shared with any other actor, and communicates with other actors by sending and receiving asynchronous messages. **Message delivery is not guaranteed**: in certain error scenarios, messages are lost. Each actor processes only one message at a time, so it does not need to worry about threads.

In **distributed actor frameworks**, the model is used to scale an application across multiple nodes. The same message-passing mechanism is used whether sender and recipient are on the same node or on different nodes. Location transparency works better in the actor model than in RPC, because the actor model already assumes that messages may be lost, even within a single process.

A distributed actor framework essentially integrates a message broker and the actor programming model into a single framework. For rolling upgrades, forward and backward compatibility still have to be considered, because a node running the new version may send messages to a node running the old version:
- `Akka` uses Java's built-in serialization by default, which provides no forward or backward compatibility, but it can be replaced with something like Protocol Buffers.
- `Orleans` by default uses a custom encoding format that does not support rolling upgrades; a new version requires setting up a new cluster and moving traffic to it.
- In `Erlang OTP`, it is surprisingly hard to make changes to record schemas, even though the system has many features designed for high availability.

---

## Summary

- Many services need to support **rolling upgrades**, where a new version is deployed to a few nodes at a time. This allows releases without downtime and makes deployments less risky, which is good for evolvability.
- During a rolling upgrade, different nodes run different versions of the code, so all data flowing around the system must be encoded with **backward compatibility** (new code can read old data) and **forward compatibility** (old code can read new data).
- Encoding formats:
  - **Language-specific encodings** are restricted to one language and often fail to provide compatibility.
  - **Textual formats** such as JSON, XML, and CSV are widespread, and their compatibility depends on how they are used. They are vague about datatypes.
  - **Binary schema-driven formats** such as Thrift, Protocol Buffers, and Avro allow compact, efficient encoding with clearly defined forward and backward compatibility semantics. The schemas are useful for documentation and code generation, but the data must be decoded before it is human-readable.
- Modes of dataflow: **databases** (the writer encodes, the reader decodes), **RPC and REST APIs** (the client encodes a request, the server decodes it and encodes a response), and **asynchronous message passing** through message brokers or actors (nodes communicate by sending each other messages encoded by the sender and decoded by the recipient).
