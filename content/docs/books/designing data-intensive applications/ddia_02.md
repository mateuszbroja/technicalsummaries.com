---
weight: 2
title: "02: Data Models and Query Languages"
bookHidden: false
---

# Data Models and Query Languages
---

*Data models are perhaps the most important part of developing software, because they have such a profound effect: not only on how the software is written, but also on how we think about the problem that we are solving.*


Most applications are built by layering one data model on top of another:

1. objects or data structures and APIs,
2. general-purpose data model (e.g., JSON or XML documents),
3. bytes in memory, on disk, or on a network,
4. electrical currents, pulses of light, magnetic fields.

---

## Data Models

SQL, based on Edgar Codd's relational model from 1970, is the widely recognized and dominant data model for over 25-30 years.

The roots of relational databases lie in business data processing, which can be categorized into two main use cases:

{{< columns >}}
**Transaction Processing:**
- Entering sales or banking transactions
- Airline reservations
- Stock-keeping in warehouses

<--->

**Batch Processing:**
- Customer invoicing
- Payroll management
- Reporting
{{< /columns >}}

Over the years, there have been many competing approaches to data storage and querying:
- `Network model` (1970s-1980s)
- `Hierarchical model` (1970s-1980s)
- `Object databases` (brief resurgence in late 1980s and early 1990s)
- `XML databases` (limited adoption since early 2000s)

Relational databases have generalized well beyond business data processing and remain a key driving force behind the web today.

---
### The Birth of NoSQL

`NoSQL` emerged as a challenge to the relational model's dominance. The term was coined in 2009 as a catchy hashtag for a meetup on nonrelational databases. It stands for `Not Only SQL`, representing a range of technologies beyond traditional relational databases.

**Several driving forces behind the rise of NoSQL include:**
- Need for greater scalability
- Widespread preference for free and open source software
- Specialized query operations
- Frustration with the restrictiveness of relational schemas

NoSQL diverging into two main directions:
1. **Document databases**: designed for use cases where data is stored in self-contained documents, with limited relationships between documents.
2. **Graph databases**: tailored for use cases where any element can be potentially related to everything else, emphasizing complex relationships.

All three models - document, relational, and graph - are widely utilized today, with each excelling in its respective domain.

---
### Types of relationships

| Relationship Type  | Description                                                                                                                                                  | Example                                                                                            |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| **One-to-One (1:1)**   | Each record in Table A is associated with exactly one record in Table B, and vice versa.                                                                     | An employee has one employee ID, and an employee ID is assigned to only one employee.              |
| **One-to-Many (1:N)**  | Each record in Table A can be associated with multiple records in Table B, but each record in Table B is associated with only one record in Table A.         | A customer can have multiple orders, but each order is associated with only one customer.          |
| **Many-to-One (N:1)**  | Each record in Table A is associated with only one record in Table B, but each record in Table B can be associated with multiple records in Table A.         | Multiple students can enroll in a single course, but each course is taught by only one instructor. |
| **Many-to-Many (N:N)** | Multiple records in Table A can be associated with multiple records in Table B, and vice versa. This is typically implemented using a bridge/junction table. | A student can be enrolled in multiple courses, and each course can have multiple students.         |

---
### One-to-many relationship

The SQL data model faces criticism due to the **impedance mismatch** between relational tables and object-oriented programming languages. Object-oriented models represent data as objects with properties and methods, while relational models use tables with columns and rows. Flattening object hierarchies or joining multiple tables may be necessary. This requires a translation layer, like object-relational mapping (ORM) tools, adding complexity in handling data.

{{< hint info >}}
**LinkedIn Example**  
- Unique identifier: user_id
- Columns on the users table: first_name, last_name
- One-to-many relationship from the user to: job positions, education
{{< /hint >}}

How to represent this One-to-many relationship:
- **Separate Tables**: Positions, education, and contact information stored in separate tables with foreign key references.
- **Structured Datatypes**: SQL versions support structured datatypes, XML, and JSON for storing multi-valued data within a single row.
- **JSON/XML as a text**: Encode jobs, education, and contact info as JSON or XML documents stored in a text column in the database.

For a self-contained document-like data structure like a résumé, a JSON representation is appropriate. It also provides better data locality. Document-oriented databases such as `MongoDB`, `RethinkDB`, `CouchDB`, and `Espresso` support this model.

```json
{
  "positions": [
    {
      "job_title": "Co-chair",
      "organization": "Bill & Melinda Gates Foundation"
    },
    {
      "job_title": "Co-founder, Chairman",
      "organization": "Microsoft"
    }
  ]
}
```

{{< hint warning >}}
**Data Locality** - storing all relevant information in one place, which facilitates efficient retrieval using a single query.
{{< /hint >}}

---
### Many-to-One and Many-to-Many Relationships

{{< hint warning >}}
**Normalized schema** - As a rule of thumb, duplicating values that could be stored in just one place indicates that the schema is not normalized.
{{< /hint >}}

If we choose to normalize the data by replacing actual values with IDs and utilizing separate tables, there are several advantages:

- **Standardization**: Values are standardized, ensuring consistent style and avoiding ambiguity (e.g., cities with the same name).
- **Ease of Updating**: Data updates become easier as the values are stored in a single place.
- **Localization Support**: Standardized lists can be easily localized when the site is translated into different languages.

However, there are some drawbacks to normalization in the document model:

- **Many-to-One Relationships**: Normalizing data with many-to-one relationships is challenging in the document model.
- **Join Limitations**: Limited join support in document databases leads to complex joins emulated through multiple queries, impacting performance.
- **Increasing Interconnections**: Growing application features may require many-to-many relationships due to increasing data interconnections.

{{< hint info >}}
**History lesson**

The hierarchical model (one big tree) in the 1970s was effective for one-to-many relationships but posed difficulties for many-to-many relationships and lacked join support. Developers had to decide **whether to duplicate data or manually handle references** to overcome these limitations.

The solutions proposed to address the limitations of the hierarchical model were:
- the relational model (`SQL`, which took over the world),
- the network model (`CODASYL`).
{{< /hint >}}

Relational and document databases **both use unique identifiers** (foreign keys in relational, document references in document) to represent many-to-one and many-to-many relationships.

---
### Graph-Like Data Models

Many-to-many relationship:
- **Document model**: Suitable for applications with mostly one-to-many relationships or tree-structured data.
- **Relational model**: Handles simple cases of many-to-many relationships.
- **Graph model**: More natural for modeling complex relationships and interconnected data.

A graph data model consists of vertices (nodes/entities) and edges (relationships/arcs). Graphs are good for evolvability: as you add features to your application, a graph can easily be extended. Various types of data can be represented as a graph, including:

- Social graphs: Vertices represent people, and edges indicate relationships between them.
- Web graphs: Vertices represent web pages, and edges represent links between pages.
- Road or rail networks: Vertices represent junctions, and edges represent roads or railway lines.

Facebook, for example, maintains a single graph that incorporates different types of vertices and edges. Vertices can represent people, locations, events, check-ins, and comments, while edges represent friendships, check-ins at locations, comments on posts, event attendance, and more.

---

## Relational Versus Document Databases

The main arguments in favor of the document data model are:
- Schema flexibility
- Better performance due to locality
- Closer alignment with application data structures

On the other hand, the relational model offers:
- Better support for joins
- Handling many-to-one and many-to-many relationships effectively

---
### Which data model leads to simpler application code?

For highly interconnected data, the document model can be awkward, the relational model is acceptable, and graph models are the most natural and intuitive choice. 

---
### Schemas

{{< columns >}}
**Schema-on-write (relational databases):**
- Relational databases enforce an explicit schema during data writing.
- Similar to static (compile-time) type checking.
- Schemas are valuable for documenting and enforcing consistent structure.

<--->

**Schema-on-read (document/graph databases):**
- Data structure is implicit and interpreted during reading.
- Similar to dynamic (runtime) type checking.
- Used for collections with varying structures.
{{< /columns >}}

---
### Data locality for queries

**Advantages of Locality:**
- Better performance when accessing large parts of the document simultaneously.

**Disadvantages of Locality:**
- Updating the document often requires rewriting the entire document.
- It is advisable to keep documents small and avoid writes that increase document size to maintain performance.

Locality is utilized in other databases:
- Google's Spanner: Allows table rows to be interleaved or nested within a parent table for managing locality.
- Bigtable (used by Cassandra and HBase): Implements the column-family concept to manage locality.

---
### Future

Relational and document databases are becoming more similar over time. A hybrid approach combining relational and document models is beneficial for the future of databases.

---

## Query Languages for Data

Data models have specific query languages or frameworks:
- `SQL` for relational databases.
- `MapReduce` for distributed data processing.
- MongoDB's `Aggregation Pipeline` for advanced aggregation.
- `Cypher` for graph databases.
- `SPARQL` for querying RDF data.
- `Datalog` for logic programming and databases.

---
### Imperative vs. declarative

|                      | Declarative                             | Imperative                                     |
|----------------------|-----------------------------------------|------------------------------------------------|
| **Used in**              | SQL                                     | CODASYL, Many commonly used programming languages  |
| **Definition**           | You specify the pattern of the data you want but not how to achieve that goal   | An imperative language tells the computer to perform certain operations in a certain order  |
| **Parallel Execution**   | Good because the database is free to use a parallel implementation of the query language. CPUs are getting faster by adding more cores, not by running at significantly higher clock speeds  | Imperative code is very hard to parallelize across multiple cores and multiple machines because it specifies instructions that must be performed in a particular order. |

Examples:

{{< tabs "imperative_delarative" >}}
{{< tab "Imperative" >}}
```javascript
function getOtherAnimals() {
    var otherAnimals = [];
    for (var i = 0; i < animals.length; i++) {
        if (animals[i].family !== "Sharks") {
            otherAnimals.push(animals[i]);
        }
    }
    return otherAnimals;
}
```
{{< /tab >}}
{{< tab "Declarative" >}}
```sql
SELECT TOP 10 customer_name, order_date, total_amount
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.country = 'USA'
GROUP BY customer_name
HAVING COUNT(*) > 5
ORDER BY total_amount DESC;
```
{{< /tab >}}
{{< /tabs >}}

---
### MapReduce Querying

`MapReduce` is a programming model used for processing large data sets across multiple machines. It combines elements of declarative and imperative approaches, using map and reduce functions. NoSQL datastores like MongoDB and CouchDB support a limited form of MapReduce. While higher-level query languages like SQL can be implemented using MapReduce, SQL is not restricted to single-machine execution. NoSQL systems may inadvertently resemble SQL in certain aspects.

---
### The Cypher Query Language

Cypher is a declarative query language specifically designed for property graphs (used in `Neo4j`).

A subset of the data represented as a Cypher query:

```javascript
CREATE
(NAmerica:Location {name:'North America', type:'continent'}),
(USA:Location {name:'United States', type:'country' }),
(Idaho:Location {name:'Idaho', type:'state' }),
(Lucy:Person {name:'Lucy' }),
(Idaho) -[:WITHIN]-> (USA) -[:WITHIN]-> (NAmerica),
(Lucy) -[:BORN_IN]-> (Idaho)
```

Cypher query to find people who emigrated from the US to Europe:

```javascript
MATCH
(person) -[:BORN_IN]-> () -[:WITHIN*0..]-> (us:Location {name:'United States'}),
(person) -[:LIVES_IN]-> () -[:WITHIN*0..]-> (eu:Location {name:'Europe'})
RETURN person.name
```

  
**The query looks for a vertex called `person` that satisfies the following criteria:**

1. The person has a `BORN_IN` edge leading to a vertex connected by a chain of `WITHIN` edges, ultimately reaching a `Location` vertex with the name `United States`.
2. The person also has a `LIVES_IN` edge leading to a vertex connected by a chain of `WITHIN` edges, ultimately reaching a `Location` vertex with the name `Europe`.
