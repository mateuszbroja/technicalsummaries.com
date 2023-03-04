# Choosing Technologies Across the Data Engineering Lifecycle

## Interview questions

1. What are the considerations for choosing data technologies? Name all 11 of them.
2. What is interoperability?
3. What are containers?

## Architecture versus tools

A lot of people confuse architecture and tools. Architecture is strategic; tools are tactical. Architecture is the what, why, and when. Tools are used to make the architecture a reality; tools are the how.

Architecture first, technology second.


## Considerations for choosing data technologies across the data engineering lifecycle


**Team size and capabilities:** use as many managed and SaaS tools as possible, and dedicate your limited bandwidth to solving the complex problems that directly add value to the business. Take an inventory of your team’s skills.

**Speed to market:** work in a tight feedback loop of launching, learning, iterating, and making improvements. Deliver value early and often.

**Interoperability:** you’ll need to ensure that it interacts and operates with other technologies. Interoperability describes how various technologies or systems connect, exchange information, and interact.

**Cost optimization and business value:** consider three main lenses: total cost of ownership, opportunity cost, and FinOps.

**Today versus the future: immutable versus transitory technologies:** You should choose the best technology for the moment and near future, but in a way that supports future unknowns and evolution. Given the rapid pace of tooling and best-practice changes, we suggest evaluating tools every two years

```
Immutable technologies - components that have stood the test of time. Examples: object storage, networking, servers, and security, Amazon S3, Azure Blob Storage, power grid, x86 processor architecture. Immutable technologies benefit from the Lindyeffect: the longer a technology has been established, the longer it will be used.
```

```
Transitory technologies - those that come and go. Examples: JavaScript frontend frameworks. Almost every technology follows this inevitable path of decline.
```

**Location:** Choose between locations, which could be on-prem, cloud, hybrid cloud, multi cloud. Choose the best technologies for your current needs and concrete plans for the near future. Choose your deployment platform based on real business needs while focusing on simplicity and flexibility. And have an escape plan. Cases for on-prem:
- huge amount of data
- huge bandwidth
- limited use cases

**Build versus buy:** The argument for building is that you have end-to-end control over the solution and are not at the mercy of a vendor or open source community. The argument supporting buying comes down to resource constraints and expertise; do you have the expertise to build a better solution than something already available? Either decision comes down to TCO, TOCO, and whether the solution provides a competitive advantage to your organization.

In general, we favor OSS and COSS by default, which frees you to focus on improving those areas where these options are insufficient. Focus on a few areas where building something will add significant value or reduce friction substantially.

**Monolith versus modular**

Monolithic systems are self-contained, often performing multiple functions under a single system. The monolith camp favors the simplicity of having everything in one place. It’s easier to reason about a single entity, and you can move faster because there are fewer moving parts. The modular camp leans toward decoupled, best-of-breed technologies performing tasks at which they are uniquely great. Especially given the rate of change in products in the data world, the argument is you should aim for interoperability among an ever-changing array of solutions.

Modularity - Instead of relying on a massive monolith to handle your needs, why not break apart systems and processes into their self-contained areas of concern? Microservices can communicate via APIs, allowing developers to focus on their domains while making their applications accessible to other microservices.

Two-pizza rule: no team should be so large that two pizzas can’t feed the whole group

In a modular microservice environment, components are swappable, and it’s possible to create a polyglot (multiprogramming language) application; a Java service can replace a service written in Python. Service customers need worry only about the technical specifications of the service API, not behind-the-scenes details of implementation. Data-processing technologies have shifted toward a modular model by providing strong support for interoperability The Distributed Monolith Pattern The distributed monolith pattern is a distributed architecture that still suffers from many of the limitations of monolithic architecture. The basic idea is that one runs a distributed system with different services to perform different tasks. Still, services and nodes share a common set of dependencies or a common codebase One standard example is a traditional Hadoop cluster. A Hadoop cluster can simultaneously host several frameworks, such as Hive, Pig, or Spark. The cluster also has many internal dependencies. In addition, the cluster runs core Hadoop components: Hadoop common libraries, HDFS, YARN, and Java. In practice, a cluster often has one version of each component installed.

While monoliths are attractive because of ease of understanding and reduced complexity, this comes at a high cost. The cost is the potential loss of flexibility, opportunity cost, and high-friction development cycles.
- Interoperability
- Avoiding the “bear trap”
- Flexibility

**Serverless versus servers**
Severless - started from AWS Lambda in 2014. executing small chunks of code on an as-needed basis without having to manage a server As with other areas of ops, it’s critical to monitor and model. Monitor to determine cost per event in a real-world environment and maximum length of serverless execution, and model using this cost per event to determine overall costs as event rates grow.

Containers
In conjunction with serverless and microservices, containers are one of the most powerful trending operational technologies as of this writing. Containers play a role in both serverless and microservices.

Containers are often referred to as lightweight virtual machines. This provides some of the principal benefits of virtualization (i.e., dependency and code isolation) without the overhead of carrying around an entire operating system kernel. And services such as AWS Fargate and Google App Engine run containers without managing a compute cluster required for Kubernetes. These services also fully isolate containers, preventing the security issues associated with multitenancy.

Important:
- Expect servers to fail.
- Use clusters and autoscaling.
- Treat your infrastructure as code.
- Use containers.

**Optimization, performance, and the benchmark wars:** be careful using benchmarks.

**The undercurrents of the data engineering lifecycle:** Data Management, DataOps, Data Architecture.


## Cost optimization
### Total cost of ownership (TCO)

Total cost of ownership (TCO) - is the total estimated cost of an initiative, including the direct and indirect costs of products and services utilized.

Direct costs can be directly attributed to an initiative.

Indirect costs, also known as overhead, are independent of the initiative and must be paid regardless of where they’re attributed.

Expenses fall into two big groups: capital expenses and operational expenses.

Capital expenses, also known as capex, require an up-front investment. Payment is required today. Operational expenses, also known as opex, are the opposite of capex in certain respects. Opex is gradual and spread out over time. Whereas capex is long-term focused, opex is short-term.

In general, opex allows for a far greater ability for engineering teams to choose their software and hardware. Cloud-based services let data engineers iterate quickly with various software and technology configurations, often inexpensively.

### Total Opportunity Cost of Ownership


Total opportunity cost of ownership (TOCO) is the cost of lost opportunities that we incur in choosing a technology, an architecture, or a process.

The first step to minimizing opportunity cost is evaluating it with eyes wide open. We’ve seen countless data teams get stuck with technologies that seemed good at the time and are either not flexible for future growth or simply obsolete. Inflexible data technologies are a lot like bear traps. They’re easy to get into and extremely painful to escape.

### FinOps

If it seems that FinOps is about saving money, then think again. FinOps is about making money. Cloud spend can drive more revenue, signal customer base growth, enable more product and feature release velocity, or even help shut down a data center.

In our setting of data engineering, the ability to iterate quickly and scale dynamically is invaluable for creating business value. This is one of the major motivations for shifting data workloads to the cloud.

## Location
### Centralized
**On Premises** - companies are operationally responsible for their hardware and the software that runs on it. They need to buy, update it, maintain, etc.

**Cloud** - instead of purchasing hardware, you simply rent hardware and managed services from a cloud provider (such as AWS, Azure, or Google Cloud). IaaS, PaaS, SaaS, serverless products. Remember that vendors want to lock you into their offerings.

**Strategy Lift and shift** - moving on-premises servers one by one to VMs in the cloud.

**Hybrid Cloud** - cloud model, which assumes that an organization will indefinitely maintain some workloads outside the cloud. Usually, companies with this model keep operational functions on premise and analytics on a cloud.

**Multicloud** - refers to deploying workloads to multiple public clouds. Users can take advantage of the best services across several clouds. Drawbacks are: networking between clouds, complexity. There are service, which operates on multicloud, like Snowflake and are called *cloud of clouds*.

### Decentralized
Whereas today’s applications mainly run on premises and in the cloud, the rise of blockchain, Web 3.0, and edge computing may invert this paradigm.

## Build Versus Buy

**Open Source Software** - OSS is created and maintained by a distributed team of
collaborators. OSS is free to use, change, and distribute most of the time, but with specific caveats.

OSS has two main flavors:
- community managed
- commercial OSS


### community-managed OSS

The following are factors to consider with a community-managed OSS project:
- Mindshare - Avoid adopting OSS projects that don’t have traction and popularity. Look at the number of GitHub stars, forks, and commit volume and recency.
- Maturity
- Troubleshooting
- Project management - Look at Git issues and the way they’re addressed
- Team - Is a company sponsoring the OSS project? Who are the core contributors?
- Contributing - Does the project encourage and accept pull requests?
- Self-hosting and maintenance

### Commercial OSS

Commercial OSS - Typically, a vendor will offer the “core”
of the OSS for free while charging for enhancements, curated code distributions, or fully managed services. Examples of such vendors include Databricks (Spark),
Confluent (Kafka), DBT Labs (dbt), and there are many, many others.

The following are factors to consider with a commercial OSS project:
- Value
- Delivery model - How do you access the service? Is the product available via download, API, or web/mobile UI? Be sure you can easily access the initial version and subsequent releases.
- Support
- Releases and bug fixes
- Sales cycle and pricing
- Company finances
- Logos versus revenue - Is the company focused on growing the number of customers (logos), or is it trying to grow revenue?


Independent offerings
- Interoperability
- Mindshare and market share
- Documentation and support
- Pricing
- Longevity


Cloud platform proprietary service offerings. Cloud vendors develop and sell their proprietary services for storage, databases, and more.