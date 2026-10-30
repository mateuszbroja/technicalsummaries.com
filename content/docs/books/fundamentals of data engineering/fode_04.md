---
weight: 4
title: "04: Choosing Technologies Across the Data Engineering Lifecycle"
---

# Choosing Technologies Across the Data Engineering Lifecycle
---

## Architecture versus tools
---

Architecture is strategic: it answers what, why, and when. Tools are tactical: they answer how. Architecture is the foundation of a system, and tools make it a reality. A common mistake is choosing technologies before mapping out the architecture.

> [!NOTE]
> **Architecture first, technology second.** Choose technologies that add value to the data product and the wider business.

The authors group the considerations for choosing technologies as follows:

- team size and capabilities,
- speed to market,
- interoperability,
- cost optimization and business value,
- today versus the future: immutable versus transitory technologies,
- location (cloud, on premises, hybrid cloud, multicloud),
- build versus buy,
- monolith versus modular,
- serverless versus servers,
- optimization, performance, and the benchmark wars,
- the undercurrents of the data engineering lifecycle.

## Team Size and Capabilities
---

Take an inventory of your team's skills. A small team, or a team with weaker technical skills, should use as many managed and SaaS tools as possible and spend its limited bandwidth on complex problems that directly add business value.

Avoid `cargo-cult engineering`: copying the practices and tools of big tech companies without their scale, budgets, and specialized teams. Prefer simple tools with a gentle learning curve until the team grows.

## Speed to Market
---

Speed to market means choosing the right technologies that help you deliver features and data faster while keeping quality and security. Work in a tight feedback loop of launching, learning, iterating, and improving. Deliver value early and often.

Perfectionism and long analysis cycles slow teams down. Avoid `undifferentiated heavy lifting` that ties your team to complex systems with little value. Choose tools that let you move quickly, reliably, and safely.

## Interoperability
---

`Interoperability` describes how various technologies or systems connect, exchange information, and interact. When choosing a technology, check how it integrates with the rest of your stack. Common integration standards include:

- `JDBC` and `ODBC` for database connections,
- REST APIs,
- shared file formats and object storage.

Design for modularity so you can swap technologies as better ones appear.

## Cost Optimization and Business Value
---

Organizations expect a positive ROI from their data projects. The authors view costs through three lenses.

{{% columns %}}
- **TCO**

  `Total cost of ownership (TCO)` is the total estimated cost of an initiative, including the direct and indirect costs of products and services. Costs fall into `capital expenses (capex)`, an up-front investment such as buying hardware, and `operational expenses (opex)`, gradual pay-as-you-go spending. Opex, as in cloud services, gives teams more flexibility to choose and change their software and hardware.

- **TOCO**

  `Total opportunity cost of ownership (TOCO)` is the cost of lost opportunities that result from choosing a particular technology, architecture, or process. If you pick stack A, you forgo the benefits of all other options. The key question is how easily you can move away from a choice once it stops serving you. Avoid being trapped by inflexible technology, a so-called `bear trap`.

- **FinOps**

  `FinOps` operationalizes financial accountability and business value by applying DevOps-like practices of monitoring and dynamically adjusting systems. It is not only about saving money, but also about making money: faster releases, faster feature delivery, and data center consolidation. Rapid iteration and scaling in the cloud create business value.
{{% /columns %}}

## Today Versus the Future: Immutable Versus Transitory Technologies
---

Choose the best technology for the present and near future, but in a way that supports future unknowns and evolution.

`Immutable technologies` are components that underpin the cloud or languages and paradigms that have stood the test of time:

- object storage (Amazon S3, Azure Blob Storage),
- networking,
- servers,
- security,
- languages such as SQL and bash.

Immutable technologies benefit from the `Lindy effect`: the longer a technology has been established, the longer it will likely be used.

`Transitory technologies` come and go. They follow a common pattern: hype, rapid growth, slow decline, and obsolescence. JavaScript frontend frameworks are a typical example. Many data technologies will also fail or fade.

> [!NOTE]
> Given how quickly tools and best practices change, the authors suggest re-evaluating your tools every two years. Build on immutable technologies and keep transitory tools easy to replace.

## Location
---

Companies can deploy their stack on premises, in the cloud, in a hybrid cloud, or across multiple clouds.

**On premises**: companies own their hardware and are operationally responsible for it and the software that runs on it. They must buy, upgrade, maintain, and replace hardware, and plan capacity for peak loads. On-premises teams have established operational practices but compete with cloud-native companies on agility.

**Cloud**: instead of buying hardware, you rent hardware and managed services from a cloud provider such as AWS, Azure, or Google Cloud. Offerings range from `IaaS` and `PaaS` to `SaaS` and `serverless` products. The cloud lets you scale on demand and pay only for what you use.

> [!NOTE]
> **Lift and shift** moves on-premises servers one by one to VMs in the cloud. It is a valid first step, but running cloud servers like on-premises servers is usually expensive. Cloud workloads should be optimized to use cloud-native services.

### Cloud economics

- `Cloud services and credit default swaps`: cloud providers slice hardware into products with different cost, performance, and risk characteristics. For example, archival storage is cheap because the provider can use slower, denser hardware.
- `Cloud ≠ on premises`: the cloud has different pricing models. Lifting and shifting servers without rethinking them often costs more than the old data center.
- `Data gravity`: once data is in a cloud, moving it out is expensive. Cloud providers charge for data egress, while ingress is usually free. This creates a significant switching cost.

**Hybrid cloud**: an organization keeps some workloads outside the cloud indefinitely. A common pattern keeps operational systems on premises and moves analytics to the cloud. Data flows into the cloud for free, and the analytics results sent back are small.

**Multicloud**: workloads run across multiple public clouds. This lets a company use the best services of each provider and, for SaaS vendors, serve customers on every cloud. Multicloud adds complexity, especially in networking and egress costs. Services such as Snowflake run on several clouds and act as a `cloud of clouds`.

**Decentralized**: today's applications run mainly on premises and in the cloud, but blockchain, Web 3.0, and edge computing may change this paradigm in the future.

### Cloud repatriation

Some companies move workloads back from the cloud to their own hardware. Dropbox is the best-known example. Repatriation makes sense only for companies at very large scale with a specialized, bandwidth-heavy workload that is central to their business, as storage is for Dropbox. For almost everyone else, the cloud is the better choice.

> [!WARNING]
> Choose a location for your current needs and concrete plans for the near future. Keep your options open: have an escape plan in case you must move later.

## Build Versus Buy
---

Build-versus-buy decisions balance control, resources, and expertise. The authors advise building and customizing only when it provides a competitive advantage. Otherwise, use open source or commercial solutions and avoid undifferentiated heavy lifting.

### Open source software

{{< tabs "oss" >}}
{{% tab "Community-managed OSS" %}}
A community-managed OSS project is maintained by its users and contributors. Factors to consider:

- **Mindshare**: is the project popular, with many stars, forks, and active users?
- **Maturity**: how long has it existed, and is it proven in production?
- **Troubleshooting**: who fixes problems, you or the community?
- **Project management**: are issues and fixes handled transparently?
- **Team**: is a company sponsoring the project, and who are the core contributors?
- **Developer relations and community management**: is there an active community, chat, and forum?
- **Contributing**: does the project accept pull requests?
- **Roadmap**: is there a clear roadmap?
- **Self-hosting and maintenance**: do you have the resources to host and maintain it?
- **Giving back to the community**: consider supporting projects you depend on.
{{% /tab %}}
{{% tab "Commercial OSS" %}}
`Commercial OSS (COSS)` offers an open source core for free and charges for enhancements or a managed service. Factors to consider:

- **Value**: is the managed offering worth more than running the OSS yourself?
- **Delivery model**: how do you access the service (download, API, web UI)?
- **Support**: what support is included, and at what cost?
- **Releases and bug fixes**: is the vendor transparent about releases and fixes?
- **Sales cycle and pricing**: on-demand or long-term contracts?
- **Company finances**: is the vendor viable?
- **Logos versus revenue**: is the vendor growing customers or revenue?
- **Community support**: does the vendor support the OSS community?
{{% /tab %}}
{{% tab "Proprietary walled gardens" %}}
Proprietary tools come in two forms:

- **Independent offerings** from companies outside the big clouds. Evaluate interoperability, mindshare and market share, documentation and support, pricing, and longevity.
- **Cloud platform proprietary services** for storage, databases, and analytics. They integrate tightly with the provider's ecosystem. Compare them with OSS and independent alternatives on cost, features, and lock-in.
{{% /tab %}}
{{< /tabs >}}

## Monolith Versus Modular
---

**Monolithic systems are self-contained, while modular systems use decoupled technologies for specific tasks.** The argument for modularity is the need for interoperability in a rapidly changing landscape of tools.

{{% columns %}}
- **Monolith**

  Pros:
  - easy to reason about,
  - lower cognitive burden and less context switching.

  Cons:
  - brittle and vertically integrated,
  - upgrades are slow and risky because many components depend on each other,
  - one user's bad query can affect everyone,
  - multitenancy is hard,
  - switching costs are high.

- **Modular**

  Pros:
  - components can be swapped for better ones,
  - each component can use the best tool and language for its job,
  - interoperability through standard APIs and file formats.

  Cons:
  - more systems to understand and operate,
  - orchestration and coordination become harder.
{{% /columns %}}

`Modularity` breaks systems and processes into self-contained areas of concern. Microservices communicate through APIs, so developers can focus on their domains while making their functionality available to other services.

`Two-pizza rule` (Amazon): no team should be so large that two pizzas cannot feed it.

The `distributed monolith pattern` is a distributed architecture that still suffers from many limitations of a monolith: its components share common dependencies. A traditional Hadoop cluster is an example. It hosts many frameworks (Hive, Pig, Spark), and upgrading one component can break the others. Ephemeral, job-specific infrastructure in the cloud reduces this problem.

> [!NOTE]
> Monoliths offer simplicity, and modularity offers flexibility. Interoperability, an architecture with orchestration, and the ability to swap tools favor a modular approach for most teams.

## Serverless Versus Servers
---

`Serverless` technology, which started with AWS Lambda in 2014, runs small portions of code on demand without managing servers. You pay per execution. Serverless is cheap at low event rates but can become expensive at high, constant rates. Monitor and model serverless usage and cost as event rates grow.

`Containers` are lightweight virtual machines. They package an application and its dependencies but share the host's OS kernel instead of carrying a full one. Containers underpin serverless platforms and microservices. Container clusters such as Kubernetes provide isolation between workloads, but this isolation is weaker than that of full VMs, so multitenant clusters need careful security. Services such as AWS Fargate and Google App Engine run containers while the provider manages the underlying cluster.

**When infrastructure (servers) makes more sense than serverless:**
- **Workload size and complexity**: serverless suits simple, discrete tasks.
- **Execution frequency and duration**: high request rates or long-running jobs can make serverless expensive.
- **Requests and networking**: serverless platforms limit concurrent requests and networking options.
- **Language**: the platform may not support your language.
- **Runtime limitations**: serverless functions have limits on memory, execution time, and dependencies.
- **Cost**: model the cost at expected and peak rates.

**If you run servers:**
- expect servers to fail,
- use clusters and autoscaling,
- treat your infrastructure as code,
- use containers.

> [!NOTE]
> Start with serverless and move to servers when serverless usage outgrows its limits or its cost advantage.

## Optimization, Performance, and the Benchmark Wars
---

Vendors publish benchmarks to show their product is the fastest. Read them critically:

- **Big data for the 1990s**: many benchmarks use small datasets that fit on a smartphone and do not reflect real big data workloads.
- **Nonsensical cost comparisons**: comparisons can ignore how systems are billed, for example by comparing an ephemeral cloud system with an always-on cluster.
- **Asymmetric optimization**: a vendor tunes its own system and runs competitors with default settings, or picks queries that favor its architecture.
- **Caveat emptor**: test technologies yourself, on your own data and use cases.

## Undercurrents and Their Impacts on Choosing Technologies
---

- **Data management**: check how a technology handles governance, data quality, privacy, and regulatory compliance before you adopt it. Ask vendors how they protect data.
- **DataOps**: check how a technology supports automation, monitoring, and incident response. With managed services, you depend on the vendor's SLAs and incident handling.
- **Data architecture**: good architecture means assessing trade-offs and choosing the best tools for the job while keeping decisions reversible.
- **Orchestration**: Apache Airflow is the best-known open source orchestrator. Its strengths are a large community, wide adoption, and managed offerings (Astronomer, Google Cloud Composer, Amazon MWAA). Its weaknesses include scaling limits of its core components. Newer tools such as Prefect and Dagster address some of these issues.
- **Software engineering**: build where you gain a competitive advantage, and buy or use open source for undifferentiated work. Avoid building custom tools for problems that existing tools already solve.
