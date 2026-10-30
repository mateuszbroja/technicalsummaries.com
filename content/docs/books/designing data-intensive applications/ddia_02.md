---
weight: 2
title: "02: Data Models and Query Languages"
bookHidden: false
---

# Data Models and Query Languages
---

Data models shape not only how software is written but also how we think about the problem. Most applications are built by layering one data model on top of another, and each layer hides the complexity of the layer below behind a clean data model:

`Objects or data structures and APIs` --> `General-purpose data model (e.g., JSON or XML documents, relational tables, graphs)` --> `Bytes in memory, on disk, or on a network` --> `Electrical currents, pulses of light, magnetic fields`

---

## Relational Model Versus Document Model

The best-known data model is `SQL`, based on the relational model proposed by Edgar Codd in 1970: data is organized into relations (tables), and each relation is an unordered collection of tuples (rows). By the mid-1980s, relational database management systems had become the tool of choice for most people who needed to store and query data with some regular structure.

The roots of relational databases lie in business data processing on mainframes, which falls into two main use cases:

{{% columns %}}
- **Transaction processing:**
  - entering sales or banking transactions,
  - airline reservations,
  - stock-keeping in warehouses.

- **Batch processing:**
  - customer invoicing,
  - payroll,
  - reporting.
{{% /columns %}}

Over the years, many competing approaches to data storage and querying appeared, generated hype, and faded:
- the `network model` and the `hierarchical model` (1970s and early 1980s),
- `object databases` (late 1980s and early 1990s),
- `XML databases` (early 2000s, niche adoption).

Relational databases generalized remarkably well beyond business data processing, and much of what we see on the web today is still powered by them.

---

### The Birth of NoSQL

`NoSQL` is the latest attempt to challenge the relational model's dominance. The name started in 2009 as a catchy Twitter hashtag for a meetup on open source, distributed, nonrelational databases. It was later reinterpreted as `Not Only SQL`.

**Driving forces behind the adoption of NoSQL databases:**
- a need for greater scalability than relational databases can easily achieve, including very large datasets or very high write throughput,
- a widespread preference for free and open source software over commercial database products,
- specialized query operations that are not well supported by the relational model,
- frustration with the restrictiveness of relational schemas and a desire for a more dynamic and expressive data model.

Different applications have different requirements, so relational databases will likely continue to be used alongside nonrelational datastores. This is sometimes called `polyglot persistence`.

---

### The Object-Relational Mismatch

Most application code is written in object-oriented languages, while data is stored in relational tables. This disconnect is called the `impedance mismatch`, and it requires an awkward translation layer between objects and tables. Object-relational mapping (ORM) frameworks such as ActiveRecord and Hibernate reduce the boilerplate, but they cannot completely hide the differences.

A résumé (a LinkedIn profile) is a good example of a `one-to-many` relationship: one person has many positions, many periods of education, and many pieces of contact information. There are several ways to represent it:
- **Separate tables**: positions, education, and contact information are stored in their own tables with a foreign key reference to the users table.
- **Structured datatypes**: later versions of the SQL standard added support for structured datatypes and XML/JSON data, so multi-valued data can be stored within a single row and still be queried and indexed.
- **JSON or XML as text**: the jobs, education, and contact info are encoded as a document and stored in a text column. The database then usually cannot query the values inside that column.

For a self-contained document like a résumé, a JSON representation is quite appropriate. Document-oriented databases such as `MongoDB`, `RethinkDB`, `CouchDB`, and `Espresso` support this data model.

```json
{
  "user_id": 251,
  "first_name": "Bill",
  "last_name": "Gates",
  "positions": [
    { "job_title": "Co-chair", "organization": "Bill & Melinda Gates Foundation" },
    { "job_title": "Co-founder, Chairman", "organization": "Microsoft" }
  ]
}
```

> [!NOTE]
> **Data locality** - in the JSON representation, all the relevant information is in one place, so a single query is enough to fetch the whole profile. The multi-table representation needs several queries or a messy multi-way join.

The one-to-many relationships from the user profile to its positions and education imply a **tree structure** in the data, and JSON makes this tree explicit.

---

### Many-to-One and Many-to-Many Relationships

Fields such as region or industry are better stored as IDs that refer to a separate list of standardized values than as free text. Using IDs has several advantages:
- **Consistent style and spelling** across profiles.
- **Avoiding ambiguity**, for example several cities with the same name.
- **Ease of updating**: the name is stored in only one place, so it is easy to change everywhere.
- **Localization support**: the standardized lists can be translated when the site is translated into other languages.
- **Better search**: for example, a search for philanthropists in Washington can match a profile in Seattle because the list of regions encodes that Seattle is in Washington.

> [!NOTE]
> **Normalization** - an ID has no meaning to humans, so it never needs to change, even if the information it identifies changes. Anything that is meaningful to humans may need to change, and duplicating it means every copy must be updated. Removing such duplication is the key idea behind normalization in databases.

Normalizing data requires `many-to-one` relationships (many people live in one region), which fit the document model poorly:
- **Join support is weak** in many document databases, so the join has to be emulated in application code with multiple queries.
- **Data tends to become more interconnected** as features are added. For example, organizations and schools may become entities in their own right, and a recommendation written by one user for another creates a `many-to-many` relationship.

| Relationship type | Description | Example |
| ----------------- | ----------- | ------- |
| **One-to-one (1:1)** | Each record in table A is associated with exactly one record in table B, and vice versa. | An employee has exactly one employee ID, and each employee ID belongs to one employee. |
| **One-to-many (1:N)** | Each record in table A can be associated with many records in table B, but each record in table B belongs to only one record in table A. | A customer can have many orders, but each order belongs to one customer. |
| **Many-to-one (N:1)** | Many records in table A are associated with one record in table B. | Many users live in the same region. |
| **Many-to-many (M:N)** | Records in table A can be associated with many records in table B, and vice versa. Relational databases implement this with a junction table. | A student can attend many courses, and each course has many students. |

---

### Are Document Databases Repeating History?

> [!NOTE]
> **History lesson**
>
> IBM's `Information Management System (IMS)`, originally developed for stock-keeping in the Apollo space program and first released commercially in 1968, used the **hierarchical model**: all data was a tree of records nested within records, much like JSON. It worked well for one-to-many relationships, but many-to-many relationships were hard and joins were not supported. Developers had to decide **whether to duplicate data or resolve references manually**.
>
> Two solutions were proposed to overcome these limitations:
> - the **network model** (`CODASYL`): a record could have multiple parents, and records were linked with pointers. The only way to reach a record was to follow an `access path` from a root record. Queries were written imperatively by moving a cursor along these paths, and changing the access paths required rewriting a lot of handwritten query code.
> - the **relational model** (`SQL`): data is laid out in the open as tables. The `query optimizer` automatically decides in which order to execute the parts of a query and which indexes to use, and adding a new index does not require changing any queries. The relational model took over the world.

Document databases reverted to the hierarchical model in one respect: they store nested records (one-to-many relationships) within their parent record rather than in a separate table. For many-to-one and many-to-many relationships, however, relational and document databases **both use unique identifiers**: a foreign key in the relational model and a `document reference` in the document model. The identifier is resolved at read time with a join or follow-up queries.

---

## Relational Versus Document Databases Today

The main arguments in favor of the document data model:
- schema flexibility,
- better performance due to locality,
- for some applications, a structure closer to the data structures used by the application.

The relational model counters with:
- better support for joins,
- better support for many-to-one and many-to-many relationships.

---

### Which Data Model Leads to Simpler Application Code?

If the data has a document-like structure (a tree of one-to-many relationships, usually loaded all at once), the document model is a good fit. Splitting such a document across multiple tables (`shredding`) leads to cumbersome schemas and complicated code.

The document model has limitations: nested items cannot be referred to directly, and joins are poorly supported. For **highly interconnected data**, the document model is awkward, the relational model is acceptable, and graph models are the most natural.

---

### Schema Flexibility in the Document Model

Document databases are sometimes called *schemaless*, but that is misleading: the code that reads the data usually assumes some structure, so there is an implicit schema that the database does not enforce.

{{% columns %}}
- **Schema-on-write (relational databases):**
  - The schema is explicit, and the database ensures that all written data conforms to it.
  - Similar to static (compile-time) type checking.
  - A format change needs a migration, for example `ALTER TABLE` plus an `UPDATE`. Most databases execute `ALTER TABLE` in a few milliseconds, but MySQL copies the entire table, and an `UPDATE` on a large table is slow on any database.

- **Schema-on-read (document databases):**
  - The structure of the data is implicit and only interpreted when the data is read.
  - Similar to dynamic (runtime) type checking.
  - A format change is handled in application code, for example by filling in a missing field when an old document is read.
{{% /columns %}}

Schema-on-read is advantageous when items in a collection do not all have the same structure: there are many different types of objects, or the structure is determined by external systems over which you have no control.

---

### Data Locality for Queries

A document is usually stored as a single continuous string, encoded as JSON, XML, or a binary variant such as MongoDB's `BSON`.

**Advantages of locality:**
- Better performance when the application often needs large parts of the document at the same time, because it avoids multiple index lookups and disk seeks.

**Disadvantages of locality:**
- The database usually loads the entire document even if only a small part of it is accessed.
- An update usually rewrites the entire document. Only modifications that do not change the encoded size can easily be done in place.
- It is therefore recommended to keep documents fairly small and to avoid writes that increase their size.

Locality is not limited to the document model:
- `Google Spanner` allows the rows of a table to be interleaved (nested) within a parent table.
- `Oracle` offers a similar feature called multi-table index cluster tables.
- `Bigtable`, `Cassandra`, and `HBase` manage locality with the `column-family` concept.

---

### Convergence of Document and Relational Databases

Relational and document databases are becoming more similar over time:
- Most relational databases (except MySQL at the time of writing) have supported XML for years, and PostgreSQL, MySQL, and IBM DB2 added JSON support.
- `RethinkDB` supports relational-like joins in its query language, and some MongoDB drivers automatically resolve document references.

A hybrid of the relational and document models is a good route for databases to take in the future.

---

## Query Languages for Data

Each data model comes with its own query languages or frameworks:
- `SQL` for relational databases,
- `MapReduce` for processing large amounts of data in bulk across many machines,
- MongoDB's `aggregation pipeline`,
- `Cypher` for property graphs,
- `SPARQL` for triple-stores,
- `Datalog`, a logic language that underlies several graph query systems.

---

### Declarative Versus Imperative Queries

|                        | Declarative | Imperative |
| ---------------------- | ----------- | ---------- |
| **Used in**            | SQL, relational algebra, CSS | IMS and CODASYL, most common programming languages |
| **Definition**         | You specify the pattern of the data you want (conditions, sorting, grouping), but not how to achieve that goal. | You tell the computer to perform certain operations in a certain order. |
| **Optimization**       | The query optimizer decides which indexes and join methods to use, and the database can improve performance without changing queries. | The code relies on a specific order and implementation. |
| **Parallel execution** | Easy to parallelize, which matters because CPUs get faster by adding more cores, not by running at higher clock speeds. | Very hard to parallelize across cores and machines because the instructions must run in a particular order. |

Example: return all animals in the shark family.

{{< tabs "imperative_declarative" >}}
{{% tab "Imperative" %}}
```javascript
function getSharks() {
  var sharks = [];
  for (var i = 0; i < animals.length; i++) {
    if (animals[i].family === "Sharks") {
      sharks.push(animals[i]);
    }
  }
  return sharks;
}
```
{{% /tab %}}
{{% tab "Declarative" %}}
```sql
SELECT * FROM animals WHERE family = 'Sharks';
```
{{% /tab %}}
{{< /tabs >}}

---

### Declarative Queries on the Web

The advantages of declarative languages are not limited to databases. Highlighting the title of the selected page in a website navigation takes one CSS selector (`li.selected > p`). The same effect written imperatively with the JavaScript DOM API is longer, harder to understand, breaks when the `selected` class is removed, and cannot benefit from future browser optimizations.

---

### MapReduce Querying

`MapReduce`, popularized by Google, is a programming model for processing large amounts of data in bulk across many machines. It is neither fully declarative nor fully imperative: the processing logic is expressed in code, but the framework calls it repeatedly.

- The `map` and `reduce` functions must be **pure functions**: they use only the data passed to them as input, cannot perform additional database queries, and must not have side effects. This lets the database run them anywhere, in any order, and rerun them after a failure.
- `MongoDB` and `CouchDB` support a limited form of MapReduce for read-only queries across many documents.
- SQL can be implemented as a pipeline of MapReduce operations, but nothing in SQL restricts it to a single machine, and MapReduce does not have a monopoly on distributed query execution.
- Writing two carefully coordinated functions is harder than writing a single query, so MongoDB 2.2 added the declarative `aggregation pipeline`. It is similar in expressiveness to a subset of SQL but uses a JSON-based syntax. A NoSQL system may find itself accidentally reinventing SQL in disguise.

---

## Graph-Like Data Models

How to choose a model for many-to-many relationships:
- **Document model**: appropriate when the application has mostly one-to-many relationships (tree-structured data) or no relationships between records.
- **Relational model**: can handle simple cases of many-to-many relationships.
- **Graph model**: becomes more natural as the connections within the data grow more complex.

A graph consists of `vertices` (nodes, entities) and `edges` (relationships, arcs). Typical examples:
- **Social graphs**: vertices are people, and edges indicate which people know each other.
- **The web graph**: vertices are web pages, and edges are HTML links between them.
- **Road or rail networks**: vertices are junctions, and edges are roads or railway lines between them.

Well-known algorithms operate on these graphs: car navigation finds the shortest path, and `PageRank` determines the popularity of a web page. Graphs are not limited to one type of data. Facebook maintains a single graph with vertices for people, locations, events, check-ins, and comments, and edges for friendships, check-ins at locations, comments on posts, event attendance, and so on.

---

### Property Graphs

In the `property graph` model (implemented by `Neo4j`, `Titan`, and `InfiniteGraph`):

{{% columns %}}
- **Each vertex has:**
  - a unique identifier,
  - a set of outgoing edges,
  - a set of incoming edges,
  - a collection of properties (key-value pairs).

- **Each edge has:**
  - a unique identifier,
  - the vertex at which it starts (`tail vertex`),
  - the vertex at which it ends (`head vertex`),
  - a label that describes the relationship,
  - a collection of properties (key-value pairs).
{{% /columns %}}

A property graph can be stored in two relational tables, one for vertices and one for edges. Important properties of the model:
- Any vertex can have an edge connecting it with any other vertex. No schema restricts which kinds of things can be associated.
- Given any vertex, its incoming and outgoing edges can be found efficiently, so the graph can be traversed in both directions.
- Different labels for different kinds of relationships let a single graph store several kinds of information while keeping a clean data model.

Graphs are good for **evolvability**: as features are added to an application, the graph can easily be extended to accommodate changes in the data structures.

---

### The Cypher Query Language

`Cypher` is a declarative query language for property graphs, created for the Neo4j graph database.

Inserting a subset of the data:

```cypher
CREATE
  (NAmerica:Location {name:'North America', type:'continent'}),
  (USA:Location      {name:'United States', type:'country'}),
  (Idaho:Location    {name:'Idaho',         type:'state'}),
  (Lucy:Person       {name:'Lucy'}),
  (Idaho) -[:WITHIN]->  (USA) -[:WITHIN]-> (NAmerica),
  (Lucy)  -[:BORN_IN]-> (Idaho)
```

Finding people who emigrated from the United States to Europe:

```cypher
MATCH
  (person) -[:BORN_IN]->  () -[:WITHIN*0..]-> (us:Location {name:'United States'}),
  (person) -[:LIVES_IN]-> () -[:WITHIN*0..]-> (eu:Location {name:'Europe'})
RETURN person.name
```

**The query looks for any vertex `person` that meets both conditions:**

1. `person` has an outgoing `BORN_IN` edge to some vertex. From that vertex, a chain of zero or more outgoing `WITHIN` edges eventually reaches a `Location` vertex named `United States`.
2. `person` also has an outgoing `LIVES_IN` edge. Following that edge and then a chain of `WITHIN` edges eventually reaches a `Location` vertex named `Europe`.

As with any declarative language, the query optimizer chooses the execution strategy, for example whether to start from the people or from the two location vertices.

---

### Graph Queries in SQL

Graph data stored in relational tables can be queried with SQL, but with difficulty. The number of joins needed to follow a chain of `WITHIN` edges is not known in advance. Since SQL:1999, variable-length traversal paths can be expressed with `recursive common table expressions` (`WITH RECURSIVE`). The same emigration query that takes 4 lines in Cypher takes 29 lines in SQL, which shows that different data models are designed for different use cases.

---

### Triple-Stores and SPARQL

In a `triple-store`, all information is stored as three-part statements: `(subject, predicate, object)`, for example `(Jim, likes, bananas)`.
- The subject is equivalent to a vertex.
- The object is either a primitive value (then the predicate and object form a property of the subject, such as `(lucy, age, 33)`) or another vertex (then the predicate is an edge, such as `(lucy, marriedTo, alain)`).

Triples can be written in the `Turtle` format, a subset of Notation3. Triple-stores are closely associated with the **semantic web** and the `Resource Description Framework (RDF)`, which was designed to let websites publish data in a consistent, machine-readable format. The semantic web never took off in practice, but triples remain a good internal data model for applications.

`SPARQL` is a query language for triple-stores using the RDF data model. It predates Cypher, and Cypher's pattern matching syntax is borrowed from it, so the emigration query looks very similar in both languages.

> [!NOTE]
> **Graph databases are not the network model (CODASYL) again:**
> - CODASYL had a schema that specified which record types could be nested within which. A graph database allows any vertex to have an edge to any other vertex.
> - In CODASYL, the only way to reach a record was to traverse an access path. In a graph database, any vertex can be referred to directly by its unique ID or found with an index.
> - In CODASYL, the children of a record were an ordered set. Vertices and edges in a graph database are not ordered.
> - In CODASYL, all queries were imperative and broke when the schema changed. Graph databases support declarative languages such as Cypher and SPARQL.

---

### The Foundation: Datalog

`Datalog` is a much older language than SPARQL or Cypher, studied extensively in academia in the 1980s. It provides the foundation that later query languages build upon, and it is used in `Datomic` and in `Cascalog`, a Datalog implementation for querying large datasets in Hadoop.

- Data is written as `predicate(subject, object)`, similar to the triple-store model.
- Queries are defined as **rules** that tell the database about new predicates. Rules can refer to other rules and to themselves, which makes recursive traversals natural.
- Complex queries are built up one small piece at a time. This is less convenient for simple one-off queries, but it copes better with complex data.

---

## Summary

- Historically, data started out as one big tree (the hierarchical model), which was bad for many-to-many relationships. The relational model was invented to solve that problem.
- NoSQL datastores have diverged in two main directions:
  1. **Document databases** target use cases where data comes in self-contained documents and relationships between documents are rare.
  2. **Graph databases** target use cases where anything is potentially related to everything.
- All three models (document, relational, and graph) are widely used today, and each is good in its respective domain. One model can be emulated in terms of another, but the result is often awkward.
- Document and graph databases typically do not enforce a schema, which makes it easier to adapt applications to changing requirements. The application still assumes a structure, so the real question is whether the schema is explicit (enforced on write) or implicit (handled on read).
