---
weight: 9
title: "09: Serving Data for Analytics, Machine Learning, and Reverse ETL"
bookHidden: true
---

# Serving Data for Analytics, Machine Learning, and Reverse ETL

## General Considerations


End users must trust the data they receive.
Use data validation and observability processes

Data validation checks for accuracy in financial, customer, and sales data.

Data observability provides ongoing monitoring of data and processes throughout the data engineering lifecycle.

SLA tells users what to
expect from your data produc

what’s the use case, and who’s the user

Data Products

Self-Service or Not

Semantic layer consolidates business definitions and logic in a reusable fashion. Write once, use anywhere. This paradigm is an object-oriented.

Data definition refers to the meaning of data as understood by the organization, while data logic specifies the formulas used to derive metrics from data, such as gross sales or customer lifetime value.


Data Mesh
Data mesh changes how data is served in organizations. It moves from siloed data teams serving internal users to a decentralized, peer-to-peer data serving approach, where every domain team takes on two aspects of serving data.


Operational Analytics

Operational analytics involves immediate action, while business analytics provides actionable insights. Real-time application monitoring is an example of operational analytics. The line between business and operational analytics is blurring with the prevalence of streaming and low-latency data. External-facing or embedded analytics is a recent trend where companies provide analytics to end-users through data applications or embedded analytics dashboards within the application itself.



Machine Learning

What a Data Engineer Should Know About ML:

Supervised, unsupervised, and semisupervised learning
Classification and regression techniques
Techniques for handling time-series data
When to use classical techniques versus deep learning
When to use automated machine learning versus handcrafting a model
Data-wrangling techniques for structured and unstructured data
How to encode categorical data and embeddings for various data types
Batch and online learning
Intersection of data engineering and ML lifecycles
Training locally, on a cluster, or at the edge
Applications of batch and streaming data in training ML models
Data cascades and their impact on ML models
Results returned in real-time or batch
Structured versus unstructured data.


## Ways to Serve Data for Analytics and ML

File exchange: Data is processed and generated into files to be passed to data consumers.
Databases: Data is stored and accessed through database management systems.
Streaming systems: Data is continuously processed and analyzed in real-time.
Query federation: Data is accessed and integrated from multiple sources through a single query interface.
Data sharing: Data is shared between organizations or departments to improve collaboration and decision-making.
Semantic and metrics layers: Tools for maintaining and computing business logic.
Serving data in notebooks: Data is served directly in notebooks for easy analysis and visualization.
