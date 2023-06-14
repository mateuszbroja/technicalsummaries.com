---
weight: 4
title: "04: Encoding and Evolution"
bookHidden: false
---

# Encoding and Evolution
---

Programs have two types of data:

- **In-memory data**: data in objects, structs, lists, arrays, hash tables, trees, etc. Optimized for access and manipulation by the CPU.
- **Data to be sent over the network/stored on disk**: This data is encoded in a self-contained sequence of bytes. Optimized for size.

{{< hint warning >}}
Translating the in-memory representation to a byte sequence is called **encoding** (aka. Serialization or marshalling). The reverse is called decoding.
{{< /hint >}}

---
## Evolution

Relational databases conforms to one schema although that schema can be changed, there is one schema in force at any point in time. **Schema-on-read (or schemaless) contain a mixture of older and newer data formats.**

---
### Compatibility

Old and new versions of the code, and old and new data formats, may potentially all coexist. We need to maintain compatibility in both directions:

- `Backward compatibility`, newer code can read data that was written by older code.
- `Forward compatibility`, older code can read data that was written by newer code.

{{< hint info >}}
**Rolling out Changes**

Changes to a product's feature set often require updates to the data storage and application code. However, these updates cannot happen instantaneously. How can the updates be rolled out effectively?

1. **Server-side Application Solution**:
   - Perform a **`rolling upgrade`**: Deploy the new version to a subset of nodes at a time.
   - Continuously monitor the rollout to ensure smooth operation.
   - Benefits: Allows more frequent releases and enhances system evolvability.

2. **Client-side Application Solution**:
   - Relies on users to update their applications.
   - Requires users to manually update their software to access the latest features and changes.
{{< /hint >}}
  
---
## Formats for Encoding Data

There are many ways to encode data (JSON, XML, Protos, Thrift, Avro).

**Key considerations when choosing a data format:**
- Backwards/forwards compatibility
- Support across different languages/clients
- Size/efficiency
- Expressiveness
- Need for explicit versioning
- Need for documentation
- Need for static types

Using programming language-specific encodings for in-memory objects is generally not recommended due to limitations in:
- interoperability,
- security vulnerabilities,
- versioning challenges,
- and potential inefficiencies.

**It is better to use standardized encodings.**

---
### JSON, XML, CSV

- **`JSON`**: Widely known, human-readable, and supported. Challenges with number parsing, lack of binary data support, and schema complexity.
- **`XML`**: Widely known, human-readable, and supported. Challenges with number encodings, lack of binary data support, and schema complexity.
- **`CSV`**: Widely supported for tabular data. Challenges with number encodings, lack of schema support, and manual handling of new rows or columns.

---
### Binary Encoding

- **Compact**: Binary encodings are more space-efficient compared to text-based formats.
- **Schemas**: Provide documentation and ensure data compatibility. Allows for checking backward and forward compatibility.
- **Up-to-date Documentation**: Schemas ensure that the documentation is always accurate and reflects the latest changes.
- **Efficient Type Checking**: Code generation from schemas enables type checking at compile time.

  | Format           | Created By | Encoding Formats | Schema Support?               | Backwards/Forwards Compatability                                                   |
  | ---------------- | ---------- | ---------------- | ----------------------------- | ---------------------------------------------------------------------------------- |
  | Avro             | Apache     | Binary           | Yes. Supports `union`, `null` | Yes. Writer/Reader schemas are auto-translated                                     |
  | Protocol Buffers | Google     | Binary           | Yes. Supports `repeated`      | Yes. Can change field names, but can only add fields. New fields must be optional. |
  | Thrift           | Facebook   | Binary           | Yes. Supports nested lists    | Yes. Can change field names, but can only add fields. New fields must be optional. |

#### Apache Thrift 

- Two binary encoding formats: `BinaryProtocol` and `Compact Protocol`
- Field tags for compact field identification
- `Compact Protocol` includes additional data compaction strategies

#### Protocol Buffers

- Similar to Thrift's Compact Protocol
- Backward Compatibility: Field tags cannot be changed, new fields must be optional or have default values
- Forward Compatibility: Old code can ignore new tag numbers, optional fields can become repeated

#### Apache Avro

**Schema Management:**
- Utilizes two distinct schema languages for humans and machines.
- Requires the same schema for decoding which directs the data type.
- Writer's and reader's schemas handle encoding and decoding; they need to be compatible.

**Compatibility Handling:**
- Adds or removes fields using default values to maintain compatibility.
- Handles changes in field names and *union types* with certain limitations.

**Schema Accessibility:**
- Stores the writer's schema in several ways - top of the file, with record as version number, or communicated at connection setup.

**Schema Database:**
- Encourages a database of schemas for compatibility checks and documentation.

**Dynamic Generation and Code Generation:**
- Excels in dynamically generating schemas, ideal for relational databases dumping content into a file.
- Supports optional code generation for statically typed languages.

**Efficiency:**
- Delivers a compact and tag-less encoding format.
- Stands out in flexibility, efficient schema difference resolution, and performance.
  
---
## Models of Dataflow:

How does data flow between processes?

  | Protocol | Data format                     | Schema                                                |
  | -------- | ------------------------------- | ----------------------------------------------------- |
  | REST     | JSON                            | Often no schema. Can be codegenned, eg. using Swagger |
  | SOAP     | XML                             | Yes, using WSDL                                       |
  | RPC      | Binary (eg. gRPC uses Protobuf) | Yes                                                   |
  | GraphQL  | JSON                            | Yes                                                   |

---
### Via Databases

{{< hint warning >}}
**Data outlives code**: While code is updated often, some data in your DB might be years old. It's critical that you can continue to read + parse this data, ideally without paying the cost of expensive data migrations.
{{< /hint >}}

- **Backward Compatibility:** Necessary for data reading by future versions of processes and databases.

- **Forward Compatibility:** Essential due to multiple processes interacting with the database, some may be utilizing newer code.

- **Compatibility Issues:** Challenges arise when new code introduces new fields, which may be unknown to old code.

- **Data Longevity:** The schema evolution should aid code in maintaining compatibility with old data, as data often outlives code.

---
### Via Services calls: REST and RPC

- **Service-oriented Architecture:** Aim for independent deployment and evolution of services, resulting in a mix of server versions.

- **SOAP:** XML-based alternative to `REST`, facing interoperability challenges, hence less popular among smaller companies.

- **RPC Model:** Aims to resemble a local function or method call, but suffers from unpredictability, latency, potential idempotence issues, and datatype compatibility challenges across languages.

- **Streams:** Series of requests and responses over time.

- **Promises:** Encapsulates asynchronous actions for simpler parallelization.

- **RPC vs REST:** `RPC` protocols with binary encoding perform better than `JSON` over `REST`, but `RESTful APIs` offer benefits like easy experimentation, debugging, and wide tool support.

- **Backward and Forward Compatibility:** `RPC` inherits these properties from its encoding. Multiple versions of service API may need to be supported due to its usage across organizations.


- **Versioning:** Can be applied in `REST`. Tracked in the database for users with an API key or in the request header.

---
### Via asynchronous message passing

- **Message Brokering:** Messages are sent to a `Queue` or `Topic` and delivered to consumers or subscribers by a message broker.

- **Benefits of Async Message Passing:** Acts as a buffer for overloaded recipients, improves reliability, prevents message loss, handles changing IPs, and allows for multicasting. Decouples sender and receiver.

- **Message Delivery:** Occurs through a message broker, which serves as a temporary message store. The sender does not wait for the message delivery.

- **Processing:** Consumers may process the message and enqueue it to another topic or a response queue for reply to the sender.

- **Encoding:** Any format can be used as long as it supports backward and forward compatibility. This allows for independent deployment and rollout of publishers and consumers.

- **Distributed Actor Frameworks:** Logic is contained within actors, not threads. Supports scaling across multiple nodes and location transparency. Assumes potential message loss.