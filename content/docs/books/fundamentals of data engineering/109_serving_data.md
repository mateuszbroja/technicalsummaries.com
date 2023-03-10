---
weight: 9
title: "09: Serving Data for Analytics, Machine Learning, and Reverse ETL"
bookHidden: true
---

# Serving Data for Analytics, Machine Learning, and Reverse ETL

## General Considerations

Trust end users need to trust
the data they’re receiving
utilize data validation and data
observability processes, in conjunction with visually inspecting and confirming validity
with stakeholders

Data validation is analyzing data to ensure that it accurately
represents financial information, customer interactions, and sales. Data observability
provides an ongoing view of data and data processes. These processes must be applied
throughout the data engineering lifecycle

SLA tells users what to
expect from your data produc

what’s the use case, and who’s the
user

Data Products


Self-Service or Not

Using a semantic layer, you consolidate business definitions and logic in a reusable
fashion. Write once, use anywhere. This paradigm is an object-oriented approach
to metrics, calculations, and logic. We’ll

Data definition refers to the meaning of data as it is understood throughout the organization

Data logic stipulates formulas for deriving metrics from data—say, gross sales or
customer lifetime value


Data Mesh
Data mesh fundamentally
changes the way data is served within an organization. Instead of siloed data
teams serving their internal constituents, every domain team takes on two aspects of
decentralized, peer-to-peer data serving.

Analytics
Business analytics uses historical and current data to make strategic and actionable
decisions.


Operational Analytics

Operational analytics versus business analytics =
immediate action versus actionable insights

The big difference between operational and business analytics is time
An example of operational analytics is real-time application monitoring

The line between business and operational analytics has begun to blur. As streaming
and low-latency data become more pervasive, it is only natural to apply operational
approaches to business analytics problems


Whereas business and operational analytics are internally focused, a recent trend is
external-facing or embedded analytics. With so much data powering applications,
companies increasingly provide analytics to end users. These are typically referred to
as data applications, often with analytics dashboards embedded within the application
itself. Also known as embedded analytics, these end-user-facing dashboards give users
key metrics about their relationship with the application

Machine Learning

What a Data Engineer Should Know About ML

The difference between supervised, unsupervised, and semisupervised learning.
• The difference between classification and regression techniques.
• The various techniques for handling time-series data. This includes time-series
analysis, as well as time-series forecasting.
• When to use the “classical” techniques (logistic regression, tree-based learning,
support vector machines) versus deep learning. We constantly see data scientists
immediately jump to deep learning when it’s overkill. As a data engineer, your
basic knowledge of ML can help you spot whether an ML technique is appropriate
and scales the data you’ll need to provide.
• When would you use automated machine learning (AutoML) versus handcrafting
an ML model? What are the trade-offs with each approach regarding the data
being used?
• What are data-wrangling techniques used for structured and unstructured data?
• All data that is used for ML is converted to numbers. If you’re serving structured
or semistructured data, ensure that the data can be properly converted during the
feature-engineering process.
• How to encode categorical data and the embeddings for various types of data.
• The difference between batch and online learning. Which approach is appropriate
for your use case?
• How does the data engineering lifecycle intersect with the ML lifecycle at your
company? Will you be responsible for interfacing with or supporting ML technologies
such as feature stores or ML observability?
• Know when it’s appropriate to train locally, on a cluster, or at the edge. When
would you use a GPU over a CPU? The type of hardware you use largely depends
on the type of ML problem you’re solving, the technique you’re using, and the
size of your dataset.
350 | Chapter 9: Serving Data for Analytics, Machine Learning, and Reverse ETL
• Know the difference between the applications of batch and streaming data in
training ML models. For example, batch data often fits well with offline model
training, while streaming data works with online training.
• What are data cascades, and how might they impact ML models?
• Are results returned in real time or in batch? For example, a batch speech
transcription model might process speech samples and return text in batch after
an API call. A product recommendation model might need to operate in real
time as the customer interacts with an online retail site.
• The use of structured versus unstructured data. We might cluster tabular (structured)
customer data or recognize images (unstructured) by using a neural net.


## Ways to Serve Data for Analytics and ML

File Exchange
We process data and generate files to pass
to data consumers.

Databases
Streaming Systems
Query Federation
Data Sharing
Semantic and Metrics Layers

Fundamentally, a metrics layer is a tool for maintaining and computing business
logic.4 (A semantic layer is extremely similar conceptually,5 and headless BI is another
closely related term.) This layer can live in a BI tool or in software that builds
transformation queries. Two

Serving Data in Notebooks


## Reverse ETL
Today, reverse ETL is a buzzword that describes serving data by loading it from an
OLAP database back into a source system.
Using reverse ETL and loading the scored leads back into the CRM is the easiest
and best approach for this data product

