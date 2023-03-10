---
weight: 11
title: "11: The Future of Data Engineering"
bookHidden: true
---

# The Future of Data Engineering

The Data Engineering Lifecycle Isn’t Going Away
Some question whether increasingly simple tools and practices will lead to the disappearance
of data engineers. This thinking is shallow, lazy, and shortsighted. As
organizations leverage data in new ways, new foundations, systems, and workflows
will be needed to address these needs. Data engineers sit at the center of designing,
architecting, building, and maintaining these systems. If tooling becomes easier to
use, data engineers will move up the value chain to focus on higher-level work. The
data engineering lifecycle isn’t going away anytime soon


The Decline of Complexity and the Rise
of Easy-to-Use Data Tools
In the
2000s, deploying “big data” technologies required a large team and deep pockets. The
ascendance of SaaS-managed services has largely removed the complexity of understanding
the guts of various “big data” systems. Data engineering is now something
that all companies can do.

Another significant trend is the growth in popularity of off-the-shelf data connectors
(at the time of this writing, popular ones include Fivetran and Airbyte). Data engineers
have traditionally spent a lot of time and resources building and maintaining
plumbing to connect to external data sources. The new generation of managed
connectors is highly compelling, even for highly technical engineers, as they begin to
recognize the value of recapturing time and mental bandwidth for other projects. API
connectors will be an outsourced problem so that data engineers can focus on the
unique issues that drive their businesses.


The Cloud-Scale Data OS and Improved Interoperability
Now that these simplified services are available, the next frontier of evolution for this
notion of a cloud data operating system will happen at a higher level of abstraction.
Benn Stancil called for the emergence of standardized data APIs for building data
pipelines and data applications.1 We predict that data engineering will gradually
coalesce around a handful of data interoperability standards. Object storage in the
cloud will grow in importance as a batch interface layer between various data services.
New generation file formats (such as Parquet and Avro) are already taking over
for the purposes of cloud data interchange, significantly improving on the dreadful
interoperability of CSV and the poor performance of raw JSON.


Another critical ingredient of a data API ecosystem is a metadata catalog that
describes schemas and data hierarchies. Currently, this role is largely filled by the
legacy Hive Metastore. We expect that new entrants will emerge to take its place.
Metadata will play a crucial role in data interoperability, both across applications and
systems and across clouds and networks, driving automation and simplification.
We will also see significant improvements in the scaffolding that manages cloud
data services. Apache Airflow has emerged as the first truly cloud-oriented data
orchestration platform, but we are on the cusp of significant enhancement. Airflow
will grow in capabilities, building on its massive mindshare. New entrants such as
Dagster and Prefect will compete by rebuilding orchestration architecture from the
ground up.
This next generation of data orchestration platforms will feature enhanced data integration
and data awareness. Orchestration platforms will integrate with data cataloging
and lineage, becoming significantly more data-aware in the process. In addition,
orchestration platforms will build IaC capabilities (similar to Terraform) and code
deployment features (like GitHub Actions and Jenkins). This will allow engineers to
code a pipeline and then pass it to the orchestration platform to automatically build,
test, deploy, and monitor. Engineers will be able to write infrastructure specifications
directly into their pipelines; missing infrastructure and services (e.g., Snowflake databases,
Databricks clusters, and Amazon Kinesis streams) will be deployed the first
time the pipeline runs.
We will also see significant enhancements in the domain of live data—e.g., streaming
pipelines and databases capable of ingesting and querying streaming data. In the past,
building a streaming DAG was an extremely complex process with a high ongoing
operational burden (see Chapter 8). Tools like Apache Pulsar point the way toward
a future in which streaming DAGs can be deployed with complex transformations
using relatively simple code. We have already seen the emergence of managed stream
processors (such as Amazon Kinesis Data Analytics and Google Cloud Dataflow),
but we will see a new generation of orchestration tools for managing these services,
stitching them together, and monitoring them. We discuss live data in “The Live Data
Stack” on page 385.
What does this enhanced abstraction mean for data engineers? As we’ve already
argued in this chapter, the role of the data engineer won’t go away, but it will
evolve significantly. By comparison, more sophisticated mobile operating systems
and frameworks have not eliminated mobile app developers. Instead, mobile app
developers can now focus on building better-quality, more sophisticated applications.
We expect similar developments for data engineering as the cloud-scale data OS
paradigm increases interoperability and simplicity across various applications and
systems.


“Enterprisey” Data Engineering
The increasing simplification of data tools and the emergence and documentation of
best practices means data engineering will become more “enterprisey.”2 This will make
many readers violently cringe. The term enterprise, for some, conjures Kafkaesque
nightmares of faceless committees dressed in overly starched blue shirts and khakis,
endless red tape, and waterfall-managed development projects with constantly slipping
schedules and ballooning budgets. In short, some of you read “enterprise” and
imagine a soulless place where innovation goes to die.

Fortunately, this is not what we’re talking about; we’re referring to some of the good
things that larger companies do with data—management, operations, governance,
and other “boring” stuff. We’re presently living through the golden age of “enterprisey”
data management tools. Technologies and practices once reserved for giant
organizations are trickling downstream. The once hard parts of big data and streaming
data have now largely been abstracted away, with the focus shifting to ease of use,
interoperability, and other refinements.

This allows data engineers working on new tooling to find opportunities in the
abstractions of data management, DataOps, and all the other undercurrents of data
engineering. Data engineers will become “enterprisey.” Speaking of which…


Titles and Responsibilities Will Morph...

While the data engineering lifecycle isn’t going anywhere anytime soon, the boundaries
between software engineering, data engineering, data science, and ML engineering
are increasingly fuzzy. In fact, like the authors, many data scientists are
transformed into data engineers through an organic process; tasked with doing “data
science” but lacking the tools to do their jobs, they take on the job of designing and
building systems to serve the data engineering lifecycle.
As simplicity moves up the stack, data scientists will spend a smaller slice of their
time gathering and munging data. But this trend will extend beyond data scientists.
Simplification also means data engineers will spend less time on low-level tasks in the
data engineering lifecycle (managing servers,

Another area in which titles may morph is at the intersection of software engineering
and data engineering. Data applications, which blend traditional software applications
with analytics, will drive this trend. Software engineers will need to have a much
deeper understanding of data engineering. They will develop expertise in things like
streaming, data pipelines, data modeling, and data quality. We will move beyond the
“throw it over the wall” approach that is now pervasive. Data engineers will be integrated
into application development teams, and software developers will acquire data
engineering skills. The boundaries that exist between application backend systems
and data engineering tools will be lowered as well, with deep integration through
streaming and event-driven architectures.


Moving Beyond the Modern Data Stack,
Toward the Live Data Stack

Presently, this level of sophistication is locked away behind custom-built technologies
at large technology companies, but this sophistication and power are becoming
democratized, similar to the way the MDS brought cloud-scale data warehouses and
pipelines to the masses. The data world will soon go “live.”


The Live Data Stack
This democratization of real-time technologies will lead us to the successor to the
MDS: the live data stack will soon be accessible and pervasive. The live data stack,
depicted in Figure 11-1, will fuse real-time analytics and ML into applications by
using streaming technologies, covering the full data lifecycle from application source
systems to data processing to ML, and back.
Just as the MDS took advantage of the cloud and brought on-premises data warehouse
and pipeline technologies to the masses, the live data stack takes real-time data
application technologies used at elite tech companies and makes them available to
companies of all sizes as easy-to-use cloud-based offerings. This will open up a new
world of possibilities for creating even better user experiences and business value


Streaming Pipelines and Real-Time Analytical Databases
The MDS limits itself to batch techniques that treat data as bounded. In contrast,
real-time data applications treat data as an unbounded, continuous stream. Streaming
pipelines and real-time analytical databases are the two core technologies that will
facilitate the move from the MDS to the live data stack. While these technologies have
been around for some time, rapidly maturing managed cloud services will see them
be deployed much more widely.
Streaming technologies will continue to see extreme growth for the foreseeable
future. This will happen in conjunction with a clearer focus on the business utility
of streaming data. Up to the present, streaming systems have frequently been treated
like an expensive novelty or a dumb pipe for getting data from A to B. In the future,
streaming will radically transform organizational technology and business processes;
data architects and engineers will take the lead in these fundamental changes.
Real-time analytical databases enable both fast ingestion and subsecond queries on
this data. This data can be enriched or combined with historical datasets. When
combined with a streaming pipeline and automation, or dashboard that is capable
of real-time analytics, a whole new level of possibilities opens up. No longer are
you constrained by slow-running ELT processes, 15-minute updates, or other slowmoving
parts. Data moves in a continuous flow. As streaming ingestion becomes
more prevalent, batch ingestion will be less and less common. Why create a batch

In conjunction with the rise of streams, we expect a back-to-the-future moment for
data transformations. We’ll shift away from ELT—in database transformations—to
something that looks more like ETL. We provisionally refer to this as stream, transform,
and load (STL). In a streaming context, extraction is an ongoing, continuous
process. Of course, batch transformations won’t entirely go away. Batch will still
be very useful for model training, quarterly reporting, and more. But streaming
transformation will become the norm.

While the data warehouse and data lake are great for housing large amounts of data
and performing ad hoc queries, they are not so well optimized for low-latency data
ingestion or queries on rapidly moving data. The live data stack will be powered by
OLAP databases that are purpose-built for streaming. Today, databases like Druid,
ClickHouse, Rockset, and Firebolt are leading the way in powering the backend of
the next generation of data applications. We expect that streaming technologies will
continue to evolve rapidly and that new technologies will proliferate.
Another area we think is ripe for disruption is data modeling, where there hasn’t
been serious innovation since the early 2000s. The traditional batch-oriented data
modeling techniques you learned about in Chapter 8 aren’t suited for streaming data.
New data-modeling techniques will occur not within the data warehouse but in the
systems that generate the data. We expect data modeling will involve some notion
of an upstream definitions layer—including semantics, metrics, lineage, and data
definitions (see Chapter 9)—beginning where data is generated in the application.
Modeling will also happen at every stage as data flows and evolves through the full
lifecycle.


The Fusion of Data with Applications
We expect the next revolution will be the fusion of the application and data layers.
Right now, applications sit in one area, and the MDS sits in another. To make
matters worse, data is created with no regard for how it will be used for analytics.
Consequently, lots of duct tape is needed to make systems talk with one another. This
patchwork, siloed setup is awkward and ungainly.
Soon, application stacks will be data stacks, and vice versa. Applications will integrate
real-time automation and decision making, powered by the streaming pipelines and
ML. The data engineering lifecycle won’t necessarily change, but the time between
stages of the lifecycle will drastically shorten. A lot of innovation will occur in new
technologies and practices that will improve the experience of engineering the live
data stack. Pay attention to emerging database technologies designed to address the
mix of OLTP and OLAP use cases; feature stores may also play a similar role for ML
use cases.

he Tight Feedback Between Applications and ML
Another area we’re excited about is the fusion of applications and ML. Today, applications
and ML are disjointed systems, like applications and analytics. Software
engineers do their thing over here, data scientists and ML engineers do their thing
over there.
ML is well-suited for scenarios where data is generated at such a high rate and
volume that humans cannot feasibly process it by hand. As data sizes and velocity
grow, this applies to every scenario. High volumes of fast-moving data, coupled with
sophisticated workflows and actions, are candidates for ML. As data feedback loops
become shorter, we expect most applications to integrate ML. As data moves more
quickly, the feedback loop between applications and ML will tighten. The applications
in the live data stack are intelligent and able to adapt in real time to changes in the
data. This creates a cycle of ever-smarter applications and increasing business value.
Dark Matter Data and the Rise of...Spreadsheets?!
We’ve talked about fast-moving data and how feedback loops will shrink as applications,
data, and ML work more closely together. This section might seem odd, but we
need to address something that’s widely ignored in today’s data world, especially by
engineers.
What’s the most widely used data platform? It’s the humble spreadsheet. Depending
on the estimates you read, the user base of spreadsheets is between 700 million and
2 billion people. Spreadsheets are the dark matter of the data world. A good deal of
data analytics runs in spreadsheets and never makes its way into the sophisticated
data systems that we describe in this book. In many organizations, spreadsheets
handle financial reporting, supply-chain analytics, and even CRM.
At heart, what is a spreadsheet? A spreadsheet is an interactive data application that
supports complex analytics. Unlike purely code-based tools such as pandas (Python
Data Analysis Library), spreadsheets are accessible to a whole spectrum of users,
ranging from those who just know how to open files and look at reports to power
users who can script sophisticated procedural data processing. So far, BI tools have
failed to bring comparable interactivity to databases. Users who interact with the
UI are typically limited to slicing and dicing data within certain guardrails, not
general-purpose programmable analytics.
We predict that a new class of tools will emerge that combines the interactive analytics
capabilities of a spreadsheet with the backend power of cloud OLAP systems.
Indeed, some candidates are already in the running. The ultimate winner in this
product category may continue to use spreadsheet paradigms, or may define entirely
new interface idioms for interacting with data.





