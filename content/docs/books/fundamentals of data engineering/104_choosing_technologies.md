---
weight: 4
title: "04: Choosing Technologies Across the Data Engineering Lifecycle"
---

# Choosing Technologies Across the Data Engineering Lifecycle
---

## Architecture versus tools
---

Architecture is strategic, answering what, why, and when, while tools are tactical, answering how. Architecture is the foundation of a system, while tools make it a reality. **Architecture first, technology second.**

## Considerations for choosing technologies
---

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

{{< hint info >}} **Strategy Lift and shift** is moving on-premises servers one by one to VMs in the cloud. {{< /hint >}}

**Hybrid Cloud** - cloud model, which assumes that an organization will indefinitely maintain some workloads outside the cloud. Usually, companies with this model keep operational functions on premise and analytics on a cloud.

**Multicloud** - refers to using multiple public clouds to deploy workloads, offering the best services across several clouds. However, it can introduce networking complexity. There are also services, such as Snowflake, that operate on multicloud and are known as `cloud of clouds`.

**Decentralized** - whereas today’s applications mainly run on premises and in the cloud, the rise of blockchain, Web 3.0, and edge computing may invert this paradigm.

### Build versus buy
When deciding whether to build or buy a solution, consider factors like control, resources, and expertise. Choose open source and commercial open source options where possible, and focus on building solutions that add significant value or reduce friction.

### Monolith versus modular

**Monolithic systems are self-contained, while modular systems favor decoupled technologies for specific tasks.** The argument for modularity is the need for interoperability in a rapidly changing landscape of solutions. Monoliths offer simplicity and speed, while modularity provides flexibility and specialization.

`Modularity` involves breaking systems and processes into self-contained areas of concern. Microservices communicate via APIs, enabling developers to focus on their domains while making their applications accessible to other microservices.

`Two-pizza rule`: no team should be so large that two pizzas can’t feed the whole group

In modular microservice architecture, components can be swapped and written in different languages for interoperability, while distributed monolith pattern suffers from limitations of monolithic architecture by running a distributed system with common dependencies. Hadoop cluster is an example of this pattern, hosting multiple frameworks and internal dependencies while running core Hadoop components.

| Monoliths             | Modular                  |
|-----------------------|--------------------------|
| ease of understanding | interoperability         |
| reduced complexity    | avoiding the “bear trap” |
| less flexibility      | flexibility              |


### Serverless versus servers

`Serverless technology`, starting with AWS Lambda in 2014, allows for the execution of small code portions on an as-needed basis without having to manage a server. It's essential to monitor and model serverless usage to determine costs and performance as event rates increase.

`Containers` are lightweight virtual machines that offer virtualization benefits without carrying an entire OS kernel. They're used in serverless and microservices and are a powerful operational technology. Services like AWS Fargate and Google App Engine run containers without managing a compute cluster and isolate containers to prevent security issues associated with multitenancy.

Considerations:
- expect servers to fail,
- use clusters and autoscaling,
- treat your infrastructure as code,
- use containers.

### Cost optimization

{{< columns >}}
**TCO**

`Total cost of ownership (TCO)` refers to the total cost of an initiative, including direct and indirect costs, categorized into capital expenses and operational expenses. Opex provides greater flexibility for engineering teams to choose their software and hardware through cloud-based services.

<--->

**TOCO**

`Total Opportunity Cost of Ownership (TOCO)` is the cost of missed opportunities that can result from choosing a particular technology, architecture, or process. Evaluating TOCO is essential to minimize the risk of being trapped with inflexible technologies that can limit future growth or become obsolete.

<--->

**FinOps**

`FinOps` is a practice of managing cloud resources to optimize spending and maximize business value. It's not only about reducing cloud costs, but also about increasing revenue, improving product release times, and facilitating data center consolidation. The ability to rapidly iterate and scale in the cloud is critical for data engineering to create business value.

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

Commercial OSS offers a core OSS for free, with the option to pay for enhancements or managed services. Consider value, support, pricing, and more. Independent offerings should be evaluated for interoperability, mindshare, market share, documentation, pricing, and longevity. Cloud platforms offer proprietary services for storage, databases, etc.