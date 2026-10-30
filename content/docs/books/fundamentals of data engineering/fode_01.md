---
weight: 1
title: "01: Data Engineering Described"

---

# Data Engineering Described
---

## What Is Data Engineering?
---

The term has many competing definitions. The authors combine them into one working definition:

> [!NOTE]
> **Data engineering** is the development, implementation, and maintenance of systems and processes that take raw data and turn it into high-quality, consistent information for downstream use cases such as analytics and machine learning.

Data engineering sits at the intersection of security, data management, DataOps, data architecture, orchestration, and software engineering. A `data engineer` manages the `data engineering lifecycle`, which starts with getting data out of source systems and ends with serving data to its consumers.

The lifecycle has five stages:

1. Generation
2. Storage
3. Ingestion
4. Transformation
5. Serving

Six `undercurrents` cut across every stage: security, data management, DataOps, data architecture, orchestration, and software engineering. Chapter 2 covers the lifecycle in detail.

---

## Evolution of the Data Engineer
---

### The early days: 1980 to 2000, from data warehousing to the web

- Data engineering has its roots in `data warehousing`. Bill Inmon coined the term *data warehouse* in 1989.
- IBM developed the relational database and SQL, and Oracle popularized the technology.
- Ralph Kimball and Bill Inmon developed data modeling approaches for analytics, which gave rise to `business intelligence (BI)`.
- `Massively parallel processing (MPP)` databases appeared and allowed SQL over large volumes of data across many processors.
- The internet boom of the late 1990s created a new generation of web-first companies and pushed backend systems to their limits.

### The early 2000s: the birth of contemporary data engineering

- After the dot-com bust, survivors such as Yahoo, Google, and Amazon grew into powerhouses whose data volumes outgrew traditional monolithic databases and warehouses.
- Commodity hardware (servers, RAM, disks, flash) became cheap, so companies could build distributed systems on large clusters instead of expensive appliances.
- Google published the `Google File System (GFS)` paper in 2003 and the `MapReduce` paper in 2004, which started the era of ultra-scalable data processing.
- Yahoo engineers developed and open sourced `Apache Hadoop` in 2006, based on Google's papers.
- Amazon launched `EC2`, `S3`, and `DynamoDB`, and AWS became the first popular public cloud with pay-as-you-go compute and storage.

`Big data` refers to datasets too large to process with traditional tools. It is often described by the three Vs:

- `Velocity`: data arrives quickly.
- `Variety`: data comes in many formats.
- `Volume`: there is a lot of it.

### The 2000s and 2010s: big data engineering

- Open source tools in the Hadoop ecosystem (Hadoop, Pig, Hive, HBase, Cassandra, Spark, Presto, Storm, and others) let companies of any size use big data techniques.
- Data work moved from GUI-based tools toward code-first engineering. The `big data engineer` had to be a skilled software developer and a low-level infrastructure specialist.
- Running Hadoop clusters at scale required large, expensive teams. Apache Spark gradually displaced MapReduce as the processing engine of choice.
- "Big data" became a victim of its own success. Companies collected huge amounts of data without a clear purpose, and the term faded as tools became easier to use.

### The 2020s: engineering for the data lifecycle

- Tools keep becoming more managed, abstracted, and modular. Teams assemble the `modern data stack` from open source and third-party products instead of running monolithic frameworks.
- The data engineer becomes a `data lifecycle engineer`. Less time goes to low-level infrastructure and more to security, data management, DataOps, data architecture, and orchestration.
- Privacy regulations such as GDPR and CCPA make data management and governance a core part of the job.

---

## Data Engineering and Data Science
---

Data engineering sits upstream from data science. Data engineers provide the inputs that data scientists use, and data scientists turn that data into value.

Monica Rogati's `Data Science Hierarchy of Needs` puts ML and AI at the top of a pyramid. The lower layers are collecting, moving and storing, exploring and transforming, and aggregating and labeling data. Data scientists typically spend 70-80% of their time on these lower layers instead of on modeling.

> [!NOTE]
> A data engineer builds a solid data foundation in the lower layers of the pyramid, so data scientists can spend most of their time on analytics and ML.

---

## Data Engineering Skills and Activities
---

The skill set of a data engineer covers the undercurrents: security, data management, DataOps, data architecture, and software engineering. A data engineer must evaluate tools and balance them along several axes:

- cost,
- agility,
- `scalability`,
- simplicity,
- reuse,
- `interoperability`.

A data engineer's goals are to produce a good return on investment, reduce costs (financial and opportunity), reduce risk (security, data quality), and maximize the value and utility of data.

Data engineers typically do **not** build ML models, create reports or dashboards, perform data analysis, build KPIs, or develop software applications. They should still understand these areas well enough to serve the people who do.

---

## Data Maturity and the Data Engineer
---

`Data maturity` is the progression toward higher data utilization, capabilities, and integration across the organization. The maturity of a company's data shapes a data engineer's responsibilities. The authors use a simplified three-stage model.

{{< tabs "maturity" >}}
{{% tab "Stage 1: Starting with data" %}}
The company has fuzzy, loosely defined goals or none at all. The data team is small, and the data engineer is usually a generalist who may also act as a data scientist or software engineer.

Goals:
- Get buy-in from key stakeholders, including executive management.
- Define the right data architecture, driven by business goals.
- Identify and audit data that supports key initiatives.
- Build a solid data foundation for future analysts and data scientists.

Pitfalls to avoid:
- Aim for quick wins, but recognize that they create technical debt.
- Get out and talk to people instead of working in a silo.
- Avoid undifferentiated heavy lifting and unnecessary technical complexity. Use off-the-shelf solutions where possible.
- Build custom solutions only where they create a competitive advantage.
{{% /tab %}}
{{% tab "Stage 2: Scaling with data" %}}
The company has moved away from ad hoc data requests and has formal data practices. The challenge is building scalable architectures and planning for a data-driven future.

Goals:
- Establish formal data practices.
- Create scalable and robust data architectures.
- Adopt DevOps and DataOps practices.
- Build systems that support ML.
- Keep avoiding undifferentiated heavy lifting.

Pitfalls to avoid:
- Adopting bleeding-edge technology because of social proof from Silicon Valley companies. Technology decisions should be driven by value to customers.
- Ignoring that the main bottleneck for scaling is the team, not cluster nodes or storage. Focus on solutions that are simple to deploy and manage.
- Acting as a technologist instead of a pragmatic leader. Communicate the usefulness of data and teach the organization how to consume it.
{{% /tab %}}
{{% tab "Stage 3: Leading with data" %}}
The company is data-driven. Automated pipelines and systems let people do self-service analytics and ML, and new data sources are introduced seamlessly.

Goals:
- Automate the introduction and use of new data.
- Build custom tools and systems that use data as a competitive advantage.
- Focus on enterprise aspects of data, such as data management (governance and quality) and DataOps.
- Deploy tools that expose and disseminate data across the organization, such as data catalogs, data lineage tools, and metadata management systems.
- Collaborate with software engineers, ML engineers, analysts, and others.

Pitfalls to avoid:
- Complacency. Organizations at this stage must keep maintaining and improving their systems or risk falling back to a lower stage.
- Technology distractions. Pursue custom builds only when they create a competitive advantage, not as expensive hobby projects.
{{% /tab %}}
{{< /tabs >}}

---

## The Background and Skills of a Data Engineer
---

There is no single path into data engineering. Many data engineers come from software engineering, data science, or analytics. A newcomer should first understand data management, the lifecycle, and the tools, and then build skills in the business and technical areas below.

### Business responsibilities

- Know how to communicate with technical and nontechnical people.
- Understand how to scope projects and gather business and product requirements.
- Understand the cultural foundations of Agile, DevOps, and DataOps.
- Control costs.
- Learn continuously, since the field changes fast.

### Technical responsibilities

Primary languages:

- `SQL`, the most common interface for databases and data lakes,
- `Python`, the bridge language between data engineering and data science,
- a JVM language such as `Java` or `Scala`, used by many open source data frameworks,
- `bash`, the command-line interface for Linux.

Secondary languages include R, JavaScript, Go, Rust, C/C++, C#, and Julia.

---

## The Continuum of Data Engineering Roles, from A to B
---

{{% columns %}}
- **Type A data engineers**

  *A* stands for *abstraction*. A Type A data engineer avoids undifferentiated heavy lifting, keeps the architecture as abstract and simple as possible, and uses off-the-shelf products and managed services. Type A data engineers work at companies at every level of data maturity.

- **Type B data engineers**

  *B* stands for *build*. A Type B data engineer builds data tools and systems that scale and leverage a company's core competency and competitive advantage. Type B data engineers are common at companies in stages 2 and 3, or when the initial data use case is so unique that custom tools are needed.
{{% /columns %}}

---

## Data Engineers Inside an Organization
---

### Internal-facing versus external-facing data engineers

- An `internal-facing` data engineer focuses on activities crucial to the needs of the business and internal stakeholders, such as maintaining data pipelines and data warehouses for BI dashboards, reports, data science, and ML.
- An `external-facing` data engineer works with the users of external-facing applications, such as social media apps, IoT devices, and e-commerce platforms. These systems face higher concurrency, query limits, and multitenancy demands, and security is more complex.

In practice, many data engineers do both.

### Data engineers and other technical roles

{{% columns %}}
- **Upstream stakeholders**

  - `Data architects` design the blueprint for organizational data management and bridge the technical and nontechnical sides of the organization. In smaller companies, data engineers often take on this role.
  - `Software engineers` build the software and systems that run the business and generate internal data. Data engineers should agree with them on events, schemas, and data formats.
  - `DevOps engineers` and `site reliability engineers (SREs)` produce data through operational monitoring and may consume data through dashboards.

- **Downstream stakeholders**

  - `Data scientists` build forward-looking models to make predictions and recommendations.
  - `Data analysts` seek to understand business performance and trends, usually through SQL, BI tools, and spreadsheets.
  - `Machine learning engineers` develop advanced ML techniques, train models, and design and maintain the infrastructure that runs ML in production.
  - `AI researchers` work on new, advanced ML techniques.
{{% /columns %}}

### Data engineers and business leadership

Data engineers also act as organizational connectors, often in a nontechnical role. They work with:

- `C-level executives` such as the CEO, CIO, CTO, chief data officer (CDO), and chief analytics officer (CAO), who define the data vision and strategy,
- `project managers`, who direct large initiatives that may take months or years and need data engineers to plan and prioritize infrastructure work,
- `product managers`, who oversee product development, increasingly including data products.

> [!NOTE]
> A data engineer needs a working understanding of the business, communication skills, and the ability to translate business goals into technical requirements, not only technical knowledge.
