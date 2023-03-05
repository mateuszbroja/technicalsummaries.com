---
weight: 4
title: "04: Choosing Technologies Across the Data Engineering Lifecycle"
---

# Choosing Technologies Across the Data Engineering Lifecycle
## Architecture versus tools

It's important to distinguish between architecture and tools. Architecture is a strategic consideration that answers questions like what, why, and when, while tools are tactical and answer how. Architecture is the foundation of a system, while tools are used to make the architecture a reality. **Architecture first, technology second.**

---
## Considerations for choosing technologies

### Team size and capabilities
Use as many managed and SaaS tools as possible, and dedicate your limited bandwidth to solving the complex problems that directly add value to the business. Take an inventory of your team’s skills.

### Speed to market
Work in a tight feedback loop of launching, learning, iterating, and making improvements. Deliver value early and often.

### Interoperability
Ensure that your technology is interoperable, meaning it can connect, exchange information, and interact with other technologies or systems.

### Cost optimization and business value
Consider three main lenses: total cost of ownership, opportunity cost, and FinOps.

### Immutable versus transitory technologies
Choose the best technology for the present and near future while allowing for future growth. Re-evaluate your technology strategy every two years due to rapid changes in tooling and best practices.

`Immutable technologies` are components that have stood the test of time. Examples:
- object storage,
- networking,
- servers,
- security,
- Amazon S3,
- Azure Blob Storage.

Immutable technologies benefit from the `Lindy effect`: the longer a technology has been established, the longer it will be used.

`Transitory technologies` are those that come and go. Examples: JavaScript frontend frameworks. Almost every technology follows this inevitable path of decline.

### Location
Important is choosing a deployment platform, consider on-prem, cloud, hybrid cloud, or multi-cloud options, depending on your current needs and plans for the future. Focus on simplicity and flexibility and have an escape plan. On-prem deployment may be suitable for scenarios involving:
- huge amounts of data,
- high bandwidth, 
- limited use cases.

**On Premises** - companies are operationally responsible for their hardware and the software that runs on it. They need to buy, update it, maintain, etc.

**Cloud** - instead of purchasing hardware, you simply rent hardware and managed services from a cloud provider (such as AWS, Azure, or Google Cloud). IaaS, PaaS, SaaS, serverless products. Remember that vendors want to lock you into their offerings.

{{< hint info >}} *Strategy Lift and shift* is moving on-premises servers one by one to VMs in the cloud. {{< /hint >}}

**Hybrid Cloud** - cloud model, which assumes that an organization will indefinitely maintain some workloads outside the cloud. Usually, companies with this model keep operational functions on premise and analytics on a cloud.

**Multicloud** - refers to deploying workloads to multiple public clouds. Users can take advantage of the best services across several clouds. Drawbacks are: networking between clouds, complexity. There are service, which operates on multicloud, like Snowflake and are called *cloud of clouds*.

**Decentralized** - whereas today’s applications mainly run on premises and in the cloud, the rise of blockchain, Web 3.0, and edge computing may invert this paradigm.

### Build versus buy
When deciding whether to build or buy a solution, consider factors like control, resources, and expertise. Choose open source and commercial open source options where possible, and focus on building solutions that add significant value or reduce friction.

### Monolith versus modular

**Monolithic systems are self-contained, while modular systems favor decoupled technologies for specific tasks.** The argument for modularity is the need for interoperability in a rapidly changing landscape of solutions. Monoliths offer simplicity and speed, while modularity provides flexibility and specialization.

`Modularity` involves breaking systems and processes into self-contained areas of concern. Microservices communicate via APIs, enabling developers to focus on their domains while making their applications accessible to other microservices.

`Two-pizza rule`: no team should be so large that two pizzas can’t feed the whole group

In a modular microservice environment, components are swappable and can be written in different programming languages. This approach promotes interoperability and allows developers to focus on the technical specifications. However, the distributed monolith pattern is a distributed architecture that still suffers from many of the limitations of monolithic architecture. It involves running a distributed system with different services to perform different tasks, but with a common set of dependencies or a common codebase. A traditional Hadoop cluster is one example of this pattern, which hosts multiple frameworks and has many internal dependencies, while also running core Hadoop components.

| Monoliths             | Modular                  |
|-----------------------|--------------------------|
| ease of understanding | interoperability         |
| reduced complexity    | avoiding the “bear trap” |
| less flexibility      | flexibility              |


### Serverless versus servers

`Serverless technology`, starting with AWS Lambda in 2014, allows for the execution of small code portions on an as-needed basis without having to manage a server. It's essential to monitor and model serverless usage to determine costs and performance as event rates increase.

`Containers` are lightweight virtual machines that provide benefits of virtualization without the overhead of carrying an entire operating system kernel. They play a role in both serverless and microservices and are one of the most powerful trending operational technologies. Services like AWS Fargate and Google App Engine run containers without managing a compute cluster required for Kubernetes, and fully isolate containers to prevent security issues associated with multitenancy.

Considerations:
- expect servers to fail,
- use clusters and autoscaling,
- treat your infrastructure as code,
- use containers.

### Cost optimization

{{< columns >}}
**TCO**

`Total cost of ownership (TCO)` is the total cost of an initiative, including direct and indirect costs. Direct costs are attributed to the initiative, while indirect costs are independent of it. Expenses are categorized into capital expenses (up-front investment) and operational expenses (spread out over time). Opex provides greater flexibility for engineering teams to choose their software and hardware, often inexpensively through cloud-based services.

<--->

**TOCO**

`Total Opportunity Cost of Ownership (TOCO)` is the cost of lost opportunities due to the choice of technology, architecture, or process. It's important to evaluate it to minimize the risk of getting stuck with inflexible technologies that limit future growth or become obsolete. Such technologies can be like bear traps, easy to get into but difficult to escape from.

<--->

**FinOps**

`FinOps` is not just about saving money, but also about making money. Cloud spend can lead to revenue growth, customer base expansion, faster product release, and help with data center shutdown. In data engineering, the ability to iterate quickly and scale dynamically in the cloud is crucial for creating business value.

{{< /columns >}}


### Build Versus Buy

**Community-managed OSS**

Factors to consider with a community-managed OSS project:
- Mindshare
- Maturity
- Troubleshooting
- Project management
- Team
- Contributing
- Self-hosting and maintenance

**Commercial OSS**

Commercial OSS is the core of the OSS offered for free, with the option to pay for enhancements or fully managed services. Factors to consider include value, delivery model, support, releases, bug fixes, sales cycle, pricing, and company finances.

Independent offerings should be evaluated for interoperability, mindshare, market share, documentation and support, pricing, and longevity.

Cloud platform proprietary service offerings include proprietary services for storage, databases, and more.