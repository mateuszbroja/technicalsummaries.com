---
weight: 9
title: "09: Serving Data for Analytics, Machine Learning, and Reverse ETL"
bookHidden: false
---

# Serving Data for Analytics, Machine Learning, and Reverse ETL
---

Serving is the final stage of the data engineering lifecycle, where data is handed to people and systems that act on it. Everything upstream matters only if this stage delivers data that people trust and use.

## General Considerations for Serving Data
---

### Trust

**Trust is the most important consideration.** Data that end users do not trust will not be used, and trust that is lost is very hard to regain. Building trust requires `data validation` and `data observability`, and agreements on what users can expect.

> [!NOTE]
> **Data validation** analyzes data to ensure that it accurately represents what it should, such as financial information, customer interactions, and sales.

> [!NOTE]
> **Data observability** provides an ongoing view of data and data processes throughout the data engineering lifecycle.

A `service-level agreement (SLA)` tells users what to expect from a data product, for example that data will be available and of a given quality at a given time. A `service-level objective (SLO)` is a measurable target within the SLA, such as 99% uptime of a pipeline. Communicate openly when an SLA is at risk.

### What's the Use Case, and Who's the User?

Data has value only when it leads to action. Start from the use case and work backward: who will use the data, what action will they take, and what do they expect? Ask:

- Who will use the data, and how?
- What do stakeholders expect from it?
- How can I collaborate with them on the data model and on how the data is presented?

### Data Products

A `data product` is a product that facilitates an end goal through the use of data. It may serve internal or external users and may combine data with code. Good data products answer the question of which job the user hires the product to do. Positive feedback loops between users and the product, and between the product and its data, keep it improving.

### Self-Service or Not?

`Self-service` gives users the ability to build reports, analyses, and ML models on their own. It is hard to implement well: users need the right data, tools, and skills. Know your users: executives usually want predefined dashboards, while analysts may want direct query access. Self-service also requires governance and a balance between flexibility and guardrails.

### Data Definitions and Logic

`Data definitions` describe what data means as it is understood across the organization, for example what exactly counts as a "customer". `Data logic` covers formulas and rules for deriving metrics, such as gross sales or customer lifetime value. Much of this knowledge is tribal knowledge held by people. Capture it in documentation and in code, so that every report uses the same definitions.

### Data Mesh

`Data mesh` changes how data is served: each domain team prepares its data for consumption as a data product and serves it to other teams. Teams become both producers and consumers of data, and the work of serving data is decentralized.

## Analytics
---

Analytics is the discovery, exploration, identification, and visualization of patterns in data.

### Business Analytics

`Business analytics` uses historical and current data to make strategic and actionable decisions. It typically takes three forms:

- **Dashboards**: concise views of core metrics over time.
- **Reports**: detailed answers to specific questions, sometimes created ad hoc and then turned into recurring reports.
- **Ad hoc analysis**: investigation of a specific question or anomaly, often by an analyst.

Analysts are often the first to notice data-quality problems, so involve them in the feedback loop.

### Operational Analytics

`Operational analytics` uses data to take immediate action, while business analytics produces insights for strategic decisions. Examples are real-time application monitoring and live inventory views. **The line between business and operational analytics is blurring** as streaming and low-latency data become common: a factory might use real-time defect data to stop a production line immediately and analyze trends over weeks.

### Embedded Analytics

`Embedded analytics` (external-facing analytics) serves analytics to customers inside an application, for example usage dashboards in a SaaS product or a smart thermostat showing energy usage. It brings tough requirements:

- **Latency**: users expect results almost instantly.
- **Concurrency**: thousands of users may query at the same time.
- **Data quality and access control**: a customer must see correct data, and only their own.

## Machine Learning
---

ML is one of the most important outcomes of serving data. Data engineers prepare features, training data, and serving infrastructure, and the boundary between data engineering and ML engineering is often blurry.

What a data engineer should know about ML:

- The difference between `supervised`, `unsupervised`, and `semi-supervised learning`.
- The difference between `classification` and `regression`.
- Techniques for handling time-series data.
- When to use classical techniques (logistic regression, tree-based methods) versus `deep learning`.
- When to use automated machine learning (AutoML) versus handcrafting a model.
- Data-wrangling techniques for structured and unstructured data.
- How to encode categorical data and the embeddings used for various types of data.
- The difference between batch and online learning.
- How the data engineering lifecycle intersects with the ML lifecycle.
- When to train locally, on a cluster, or at the edge, and when a GPU is better than a CPU.
- How batch and streaming data are used in training ML models.
- What `data cascades` are and how they impact ML models.
- Whether results are returned in real time or in batch.

> [!WARNING]
> Before building ML, make sure the data foundation is ready. Many ML projects fail because the data is not available or not of good enough quality, not because of the model.

## Ways to Serve Data for Analytics and ML
---

### File Exchange

Data is processed into files and passed to consumers, for example a spreadsheet emailed to a partner or files dropped in object storage. Prefer modern delivery such as object storage, a data lake, or data sharing over emailing files.

### Databases

OLAP databases such as cloud data warehouses are a critical serving layer. They impose order and schema on data, offer access control at the table, row, and column level, and serve many concurrent users. Watch out for `compute contention`; cloud warehouses can isolate workloads with separate compute clusters.

### Streaming Systems

Operational analytics increasingly requires streaming. Real-time analytical databases, or databases that combine streaming ingestion with fast queries, serve both historical and current data.

### Query Federation

`Federated queries` pull data from multiple sources, such as data lakes, RDBMSs, and warehouses, through a single query interface without moving the data first. They are useful for ad hoc analysis and when data is spread across systems. Be careful not to overload production sources.

### Data Sharing

Cloud data warehouses let organizations share data with partners, other departments, or the public on a read-only basis. The consumer queries the provider's data directly and the provider controls access, so nothing needs to be copied or ingested.

### Semantic and Metrics Layers

A `semantic layer` (or `metrics layer`) consolidates business definitions and logic in a reusable way: write once, use anywhere. It treats metrics, calculations, and logic in an object-oriented way, so that dashboards and analyses share the same definitions. Looker's LookML and dbt are examples of tools in this space.

### Serving Data in Notebooks

Data scientists often work in notebooks such as Jupyter. Data engineers help them connect to data sources at scale: notebooks that load whole datasets into local memory hit limits quickly, and the solution is to push processing into a warehouse or a cluster. Manage credentials carefully; never hard-code them in notebooks.

## Reverse ETL
---

`Reverse ETL` loads processed data from an OLAP system back into source systems, such as a CRM, an ad platform, or an e-commerce system. Example: a model scores leads in the warehouse, and the scores are pushed back into Salesforce, where the sales team actually works. Bringing data into the tools people already use often has more impact than another dashboard.

> [!CAUTION]
> Reverse ETL creates feedback loops: data flows from source to warehouse and back again. A bug or a bad model can spread quickly to production systems, so monitor these flows and set guardrails, for example spend limits on ad platforms.

## Whom You'll Work With
---

At the serving stage, data engineers interface with many stakeholders: data analysts, data scientists, MLOps and ML engineers, and the business, including executives and product owners. Data engineers typically own the systems and pipelines that serve data, while the consumers own how the data is used. Keep that division clear, and stay close to users to understand how they use the data.

## Undercurrents
---

- **Security**: Serving exposes data to the most people, so apply the principle of least privilege. Use access controls, views, and row-level security to show each user only the data they need.
- **Data management**: Ensure users get accurate, trustworthy data. Consider anonymization or synthetic data to protect privacy where full detail is not required.
- **DataOps**: Monitor data health and downtime, latency, data quality, system performance, and the pipelines that feed serving.
- **Data architecture**: Serving uses the same architecture as the rest of the lifecycle. Make it easy to serve data in the ways users need, including feedback loops.
- **Orchestration**: Serving is the last step of many pipelines, often across teams. Orchestration coordinates dependencies so that data arrives on time.
- **Software engineering**: Keep serving code simple, test it, and treat dashboards, queries, and models as code under version control.
