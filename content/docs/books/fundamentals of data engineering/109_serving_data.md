---
weight: 9
title: "09: Serving Data for Analytics, Machine Learning, and Reverse ETL"
bookHidden: false
---

# Serving Data for Analytics, Machine Learning, and Reverse ETL
---

## General Considerations
---

- End users must trust the data they receive
- Use data validation and observability processes

{{< hint info >}} **Data validation** checks for accuracy in financial, customer, and sales data. {{< /hint >}}
{{< hint info >}} **Data observability** provides ongoing monitoring of data and processes throughout the data engineering lifecycle. {{< /hint >}}

- What’s the use case, and who’s the user
- Define `Data Products`
- Decide about `Self-Service`

- Use `semantic layer` consolidates business definitions and logic in a reusable fashion. Write once, use anywhere. This paradigm is an object-oriented.

## Serving Layer
---

### Operational Analytics

`Operational analytics` involves immediate action, while business analytics provides actionable insights. Real-time application monitoring is an example of operational analytics. **The line between business and operational analytics is blurring with the prevalence of streaming and low-latency data.** External-facing or `embedded analytics` is a recent trend where companies provide analytics to end-users through data applications or embedded analytics dashboards within the application itself.


### Machine Learning

What a Data Engineer Should Know About ML:

- `Supervised`, `unsupervised`, and semi-supervised `learning`.

- `Classification and regression` techniques.

- Techniques for handling time-series data.

- When to use classical techniques versus `deep learning`.

- When to use automated machine learning versus handcrafting a model.

- Data-wrangling techniques for structured and unstructured data.

- Batch and online learning.

- Intersection of data engineering and ML lifecycles.

- Training locally, on a cluster, or at the edge.

- Applications of batch and streaming data in training ML models.

- Data cascades and their impact on ML models.

- Results returned in real-time or batch.


## Ways to Serve Data for Analytics and ML
---

- **File exchange**: Data is processed and generated into files to be passed to data consumers.
- **Databases**: Data is stored and accessed through database management systems.
- **Streaming systems**: Data is continuously processed and analyzed in real-time.
- **Query federation**: Data is accessed and integrated from multiple sources through a single query interface.
- **Data sharing**: Data is shared between organizations or departments to improve collaboration and decision-making.
- **Semantic and metrics layers**: Tools for maintaining and computing business logic.
- **Serving data in notebooks**: Data is served directly in notebooks for easy analysis and visualization.
