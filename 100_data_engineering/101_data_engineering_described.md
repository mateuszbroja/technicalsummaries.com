# Data Engineering Described

## Basics

Data Engineer goals.
```
A data engineer has several top-level goals across the data lifecycle: produce optimum
ROI and reduce costs (financial and opportunity), reduce risk (security, data quality),
and maximize data value and utility.
```

History of data engineering.

Bill Inmon officially coining the term data warehouse in 1989.

IBM developed the relational database and Structured Query Language (SQL).

Oracle popularized this technology.

Data warehousing ushered in the first age of scalable analytics, with new massively
parallel processing (MPP) databases that use multiple processors to crunch large
amounts of data coming on the market and supporting unprecedented volumes
of data.

The internet went mainstream around the mid-1990s, creating a whole new generation
of web-first companies such as AOL, Yahoo, and Amazon.

The new generation of the systems must be cost-effective, scalable, available, and reliable.

In 2003, Google published a paper on the Google File System, and shortly after
that, in 2004, a paper on MapReduce, an ultra-scalable data-processing paradigm.
In truth, big data has earlier antecedents in MPP data warehouses and data management
The Google papers inspired engineers at Yahoo to develop and later open source
Apache Hadoop in 2006.

Around the same time, Amazon had to keep up with its own exploding data needs
and created elastic computing environments (Amazon Elastic Compute Cloud, or
EC2), infinitely scalable storage systems (Amazon Simple Storage Service, or S3),
highly scalable NoSQL databases (Amazon DynamoDB), and many other core data
building blocks.7 Amazon elected to offer these services for internal and external
consumption through Amazon Web Services (AWS), becoming the first popular
public cloud. AWS

with the transition from batch computing to event streaming, ushering in a new era of big “real-time” data.

Engineers could choose the latest and greatest—Hadoop, Apache Pig, Apache Hive,
Dremel, Apache HBase, Apache Storm, Apache Cassandra, Apache Spark, Presto,
and numerous other new technologies that came on the scene. Traditional enterprise-oriented
and GUI-based data tools suddenly felt outmoded,

Hadoop ecosystem
including Hadoop, YARN, Hadoop Distributed File System (HDFS), and
MapReduce—big data engineers had to be proficient in software development and
low-level infrastructure hacking,

Despite the term’s popularity, big data has lost steam. What happened? One word:
simplification. Despite the power and sophistication of open source big data tools,
managing them was a lot of work and required constant attention. Often, companies
employed entire teams of big data engineers, costing millions of dollars a year, to
babysit these platforms. Big data engineers often spent excessive time maintaining
complicated tooling and arguably not as much time delivering the business’s insights
and value.

Today, data is moving faster than ever and growing ever larger, but big data processing
has become so accessible that it no longer merits a separate term; every company
aims to solve its data problems, regardless of actual data size. Big data engineers are
now simply data engineers.

Whereas data
engineers historically tended to the low-level details of monolithic frameworks such
as Hadoop, Spark, or Informatica, the trend is moving toward decentralized, modularized,
managed, and highly abstracted tools.




## other 
They complement each other, but they
are distinctly different. Data engineering sits upstream from data science (Figure 1-4),
meaning data engineers provide the inputs used by data scientists (downstream from
data engineering), who convert these inputs into something useful.

Upstream
Downstream


What are the skills of DE?

```
- security
- data management
- DataOps
- data architecture
- software engineering

Must constantly optimize along the axes of cost, agility,scalability, simplicity, reuse, and interoperability
```



What is Data maturity?

Data maturity is the progression toward higher data utilization, capabilities, and
integration across the organization.

So, we’ll create our own simplified data maturity model. Our data
maturity model (Figure 1-8) has three stages: starting with data
scaling with data,
and leading with data. Let’s look at each of these stages and at what a data engineer
typically does at each stage.



Big Data will be dead in 5 years
Data as a Product
Data as a Service

Most project managers operate according to some variation of Agile and Scrum, with
Waterfall still appearing occasionally. Business never sleeps, and business stakeholders
often have a significant backlog of things they want to address and new initiatives
they want to launch. Project managers must filter a long list of requests and prioritize
critical deliverables to keep projects on track and better serve the company.


Product managers oversee product development, often owning product lines. In the
context of data engineers, these products are called data products. Data products
are either built from the ground up or are incremental improvements upon existing
products. Data engineers interact more frequently with product managers as the
corporate world has adopted a data-centric focus. Like project managers, product
managers balance the activity of technology teams against the needs of the customer
and business.

• Defining data engineering and describing what data engineers do
• Describing the types of data maturity in a company
• Type A and type B data engineers
• Whom data engineers work with

Chief executive officer.
Chief data officer.

Upstream stakeholders
Data architects
Software engineers.
DevOps engineers

Downstream stakeholders
Data scientists.
Data analysts.
Machine learning engineers and AI researchers.

