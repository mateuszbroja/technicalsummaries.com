---
weight: 11
title: "11: The Future of Data Engineering"
bookHidden: false
---

# The Future of Data Engineering

---

The final chapter is the authors' outlook on where the field is heading. Tools change quickly, but the lifecycle, the undercurrents, and the habit of choosing technology by business value stay relevant.

## The Data Engineering Lifecycle Isn't Going Away

---

Some people predict that simpler tools will make data engineering, and data engineers, unnecessary. The authors disagree. Tools get easier, but someone still has to design systems, choose technologies, manage data, and connect the stages of the lifecycle. **The role shifts toward higher levels of abstraction instead of disappearing.** The lifecycle and its undercurrents (security, data management, DataOps, data architecture, orchestration, and software engineering) remain the foundation of the work.

## The Decline of Complexity and the Rise of Easy-to-Use Data Tools

---

In the 2000s, big data systems such as Hadoop required large teams and significant resources to deploy and operate. Only big tech companies could afford them.

Today, managed cloud services and SaaS have removed much of that complexity:

- Cloud data warehouses and managed processing engines make petabyte-scale analytics available to companies of any size, with pay-as-you-go pricing.
- Open source tools have matured and are often offered as managed services.
- Off-the-shelf `data connectors`, such as `Fivetran` and `Airbyte`, replace custom ingestion code and save engineering time.

> [!NOTE]
> As complexity declines, data engineers spend less time on low-level infrastructure and more on architecture, data management, and delivering value to the business.

## The Cloud-Scale Data OS and Improved Interoperability

---

The authors compare cloud services to an operating system: just as an OS provides standard services (file systems, scheduling, device access) to applications, cloud platforms provide storage, compute, and APIs that data applications build on. The next step is a `cloud-scale data operating system` with higher levels of abstraction and better interoperability between tools.

Expected building blocks:

- **Object storage and standard file formats**: Cloud object storage and formats such as `Parquet` and `Avro` are becoming the standard layer for exchanging data between systems and clouds.
- **Metadata catalogs**: A catalog that describes schemas and data across systems will drive automation and simplification. The Hive Metastore played this role in the Hadoop era; newer catalogs aim to work across tools and clouds.
- **Data-aware orchestration**: Platforms such as `Apache Airflow`, `Dagster`, and `Prefect` will become much more aware of the data they move, including lineage, data quality, and dependencies between datasets rather than only between tasks.
- **Standard data APIs and interoperability**: Tools will plug into each other more easily, so that a pipeline can be assembled from interchangeable components.

## "Enterprisey" Data Engineering

---

The word "enterprisey" usually describes heavy, bureaucratic enterprise software. The authors use it for the good parts of enterprise practice: data management, governance, data quality, security, and DataOps.

Simpler tools free data engineers from low-level plumbing, so they can focus on these enterprise concerns. **The authors see a golden age of "enterprisey" data management tools**: practices that were once available only to large companies with big budgets are becoming accessible to organizations of all sizes.

## Titles and Responsibilities Will Morph

---

As simplicity moves up the stack, the boundaries between roles blur:

- Data scientists will spend less time on infrastructure and data wrangling, and more on analysis and modeling, while ML engineering continues to grow as its own discipline.
- Software engineers will need a deeper understanding of data engineering, because data and analytics will be built into applications.
- Data engineers will increasingly work inside application development teams, and the boundary between application backends and data tools will shrink through deep integration via streaming and event-driven architectures.

Titles may change, but the work of the data engineering lifecycle will remain.

## Moving Beyond the Modern Data Stack, Toward the Live Data Stack

---

The `modern data stack (MDS)` is a set of cloud-based, plug-and-play, easy-to-use tools: managed connectors, a cloud data warehouse, SQL-based transformations, and BI tools. It made analytics accessible, but it is fundamentally batch-oriented and focused on internal analytics.

### The Live Data Stack

The authors predict that the `live data stack` will succeed the MDS. It fuses real-time analytics and ML into applications using streaming technologies, covering the whole data lifecycle from application source systems to processing to serving. As with the MDS, these technologies will become available as easy-to-use cloud services, which democratizes real-time capabilities for companies of all sizes and opens new possibilities for user experiences and business value.

### Streaming Pipelines and Real-Time Analytical Databases

Two technologies drive the move from the MDS to the live data stack:

- **Streaming pipelines**: Streaming has grown fast and will keep growing, with the focus shifting from the technology itself to the business value of streaming data.
- **Real-time analytical databases**: These databases support fast ingestion and subsecond queries on fresh data, so applications and users can query events seconds after they happen.

{{% columns %}}
- **ELT (modern data stack)**

  Extract data in batches, load it into the warehouse, and transform it there.

- **STL (live data stack)**

  `Stream, transform, and load`: data is transformed continuously while it is in motion and loaded into real-time systems.
{{% /columns %}}

The authors describe this as a back-to-the-future moment: the industry moves from ELT toward a pattern that resembles ETL again, but executed on streams.

### The Fusion of Data with Applications

Today, application layers and data layers are mostly separate: applications run on OLTP databases, and data flows out to analytics systems. The authors expect **the fusion of application and data layers to be the next revolution**. Applications will integrate real-time automation and decision-making powered by streaming pipelines and ML. Emerging database technologies, real-time feature stores, and similar tools may improve the experience of engineering the live data stack.

### The Tight Feedback Between Applications and ML

The live data stack also tightens the feedback loop between applications and ML. Applications generate data, ML models learn from it in near real time, and model output feeds back into the application. As ML becomes part of most applications, this cycle leads to ever-smarter applications and growing business value.

### Dark Matter Data and the Rise of Spreadsheets

Despite all the sophisticated data systems, the most widely used data platform is the spreadsheet. Huge amounts of analysis happen in spreadsheets, outside of any governed system: the authors call this `dark matter data`. Spreadsheets let users interact with data directly and handle surprisingly complex analytics, but they have limited scale and no shared source of truth.

The authors predict a new class of tools that combines the interactive analytics of a spreadsheet with the backend power of cloud OLAP systems.

## Conclusion

---

The future belongs to engineers who keep learning. The specific tools will change, but the fundamentals covered in the book (the lifecycle, the undercurrents, sound architecture, and a focus on business value) remain useful. The authors encourage readers to stay curious, join the data community, and contribute to its growth.
