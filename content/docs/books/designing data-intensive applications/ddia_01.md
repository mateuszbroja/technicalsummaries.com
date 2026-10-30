---
weight: 1
title: "01: Reliable, Scalable, and Maintainable Applications"
bookHidden: false
---

# Reliable, Scalable, and Maintainable Applications
---

An application has to meet functional requirements (what it should do) and nonfunctional requirements, such as `security`, `reliability`, `compliance`, `scalability`, `compatibility`, and `maintainability`. This chapter focuses on three of them: reliability, scalability, and maintainability.

{{% columns %}}
- **Data-intensive applications** - the limiting factor is the amount of data, its complexity, and the speed at which it changes. Most applications today fall into this group.

- **Compute-intensive applications** - the limiting factor is raw CPU power.
{{% /columns %}}

**Typical building blocks of a data-intensive application:**
- store data so that it can be found again later (*databases*),
- remember the result of an expensive operation to speed up reads (*caches*),
- let users search data by keyword or filter it (*search indexes*),
- send a message to another process to be handled asynchronously (*stream processing*),
- periodically crunch a large amount of accumulated data (*batch processing*).

The boundaries between these categories are blurring. Some datastores are also used as message queues (`Redis`), and some message queues offer database-like durability guarantees (`Apache Kafka`). Applications often combine several tools behind one API, and the application developer becomes a data system designer who has to decide which guarantees the combined system provides.

---

## Reliability
---

`Reliability` means that the system continues to work correctly, at the desired level of performance, even when things go wrong. Things that can go wrong are called `faults`, and systems that anticipate them are `fault-tolerant` or `resilient`.

> [!NOTE]
> **A fault is not the same as a failure.** A fault is one component deviating from its spec. A failure is the system as a whole no longer providing the required service to the user. Faults cannot be reduced to zero, so the goal is to design mechanisms that prevent faults from causing failures.

It can make sense to increase the rate of faults deliberately, for example by randomly killing processes without warning. Netflix's `Chaos Monkey` does this to make sure that the fault-tolerance machinery is continually exercised and tested.

{{< tabs "reliability" >}}
{{% tab "Hardware Faults" %}}

**Examples of hardware faults:**
- hard disk crashes (hard disks have a mean time to failure of about 10 to 50 years, so a cluster of 10,000 disks loses on average one disk per day),
- faulty RAM,
- blackouts in the power grid,
- someone unplugging the wrong network cable.

The first response is `redundancy` of hardware components: RAID disks, dual power supplies, hot-swappable CPUs, batteries and diesel generators.

As data volumes and computing demands grow, applications use more machines, and cloud platforms can make virtual machines unavailable without warning. Systems therefore increasingly tolerate the loss of entire machines with software fault-tolerance techniques. Such systems also allow `rolling upgrades`, where one node is patched at a time without downtime of the whole system.

{{% /tab %}}
{{% tab "Software Errors" %}}

**Software errors are systematic faults.** Unlike hardware faults, which are mostly random and independent, they are correlated across nodes and tend to cause many more system failures.

Examples:
- a bug that crashes every instance of a server when given a particular bad input (for example, the Linux kernel leap second bug of June 30, 2012),
- a runaway process that uses up a shared resource such as CPU time, memory, disk space, or network bandwidth,
- a service that the system depends on slows down, stops responding, or returns corrupted responses,
- `cascading failures`, where a small fault in one component triggers faults in other components.

There is no quick solution, but many small things help:
- carefully thinking about assumptions and interactions in the system,
- thorough testing,
- process isolation,
- allowing processes to crash and restart,
- measuring, monitoring, and analyzing system behavior in production, and having the system check its own guarantees (for example, that incoming and outgoing message counts match).

{{% /tab %}}
{{% tab "Human Errors" %}}

**Human errors are a leading cause of outages.** In one study of large internet services, configuration errors by operators were the leading cause of outages, while hardware faults played a role in only 10-25% of outages.

**How to make systems reliable despite unreliable humans:**
- Design systems that minimize opportunities for error: well-designed abstractions, APIs, and admin interfaces make the right thing easy and the wrong thing hard.
- Decouple the places where people make the most mistakes from the places where mistakes cause failures, for example with fully featured non-production sandbox environments.
- Test thoroughly at all levels, from unit tests to whole-system integration tests and manual tests. Automated testing is especially valuable for corner cases.
- Allow quick and easy recovery from human errors: fast configuration rollback, gradual rollout of new code, and tools to recompute data.
- Set up detailed and clear monitoring (`telemetry`) of performance metrics and error rates.
- Implement good management practices and training.

{{% /tab %}}
{{< /tabs >}}

Reliability matters for more than nuclear power stations and air traffic control. Bugs in business applications cause lost productivity and legal risk, and outages of e-commerce sites cost revenue and reputation. Sometimes it is reasonable to sacrifice reliability to reduce development or operational cost, but that should be a conscious decision.

---

## Scalability
---

`Scalability` is the term used to describe a system's ability to cope with increased load. It is not a one-dimensional label. Discussing scalability means asking: "If the system grows in a particular way, what are our options for coping with the growth?" and "How can we add computing resources to handle the additional load?"

---

### Describing Load

Load is described with a few numbers called `load parameters`. The best choice depends on the architecture: requests per second to a web server, the ratio of reads to writes in a database, the number of simultaneously active users in a chat room, the hit rate on a cache, or something else.

> [!NOTE]
> **Twitter example (data from 2012)**
>
> - *Post tweet*: about 4.6k requests per second on average, over 12k at peak.
> - *Home timeline*: about 300k requests per second to read the tweets of the people a user follows.
>
> Two ways to implement the home timeline:
>
> 1. **Join on read**: store all tweets in a global collection and, when a user requests the timeline, look up everyone they follow and merge their tweets.
> 2. **Fan-out on write**: keep a cache of every user's home timeline and, when a user posts a tweet, insert it into the timeline cache of each follower.
>
> Reads happen almost two orders of magnitude more often than writes, so Twitter moved from approach 1 to approach 2. The cost is that one tweet from a user with 30 million followers turns into 30 million writes. Twitter ended up with a hybrid: most tweets are fanned out on write, while tweets from celebrities are fetched separately and merged at read time. The **distribution of followers per user** is the key load parameter here.

---

### Describing Performance

Once the load is described, there are two ways to look at what happens when it increases:
- Increase a load parameter and keep the resources unchanged. How is the performance affected?
- Increase a load parameter. How much do the resources need to grow to keep the performance unchanged?

{{% columns %}}
- In a batch processing system such as Hadoop, we usually care about **throughput**: the number of records processed per second, or the total time to run a job on a dataset of a certain size.

- In online systems, the **response time** usually matters more: the time between a client sending a request and receiving a response.
{{% /columns %}}

**Response time and latency are not synonyms.** Response time is what the client sees: the actual service time plus network delays and queueing delays. Latency is the duration that a request is waiting to be handled, during which it is *latent*.

Response time varies from request to request, so it is a **distribution of values**, not a single number:
- The arithmetic **mean** does not tell how many users actually experienced a given delay.
- The **median** (`p50`) is a better measure of the typical response time: half of the requests are faster, half are slower.
- High **percentiles** (`p95`, `p99`, `p999`) show the `tail latencies`, which directly affect user experience. Amazon describes response time requirements for internal services at the 99.9th percentile, because the customers with the slowest requests often have the most data in their accounts, which makes them the most valuable customers. Optimizing the 99.99th percentile was judged too expensive.

Percentiles are often used in `service level objectives (SLOs)` and `service level agreements (SLAs)`. For example, a service may be considered up if its median response time is below 200 ms and its 99th percentile is below 1 s.

> [!WARNING]
> **Queueing delays** cause a large part of the high-percentile response times. A server can process only a few things in parallel, so a few slow requests hold up the requests behind them (`head-of-line blocking`). A load-testing client must therefore keep sending requests independently of the response times, otherwise it artificially keeps the queues short.

When one end-user request requires several backend calls, the slowest call determines the total response time. Even if only a small share of backend calls is slow, many end-user requests end up slow. This effect is called `tail latency amplification`.

Percentiles should be computed over a rolling window. Averaging percentiles from several machines or time windows is mathematically meaningless. The right way to aggregate response time data is to add the histograms.

---

### Approaches for Coping with Load

> [!NOTE]
> **Scaling up** or **vertical scaling**: moving to a more powerful machine.
>
> **Scaling out** or **horizontal scaling**: distributing the load across multiple smaller machines. Distributing load across multiple machines is also known as a `shared-nothing` architecture.
>
> **Elastic systems**: automatically add computing resources when they detect a load increase. This is useful when load is unpredictable, but manually scaled systems are simpler and have fewer operational surprises.

Good architectures usually mix both approaches: several fairly powerful machines can be simpler and cheaper than a large number of small virtual machines.

It is relatively easy to distribute **stateless services** across multiple machines. Taking a **stateful data system** from a single node to a distributed setup adds a lot of complexity. For this reason, common wisdom used to be to keep a database on a single node until scaling cost or high-availability requirements forced a distributed setup. As tools for distributed systems improve, this may change.

There is no generic, one-size-fits-all scalable architecture. A system handling 100,000 requests per second of 1 kB each looks very different from a system handling 3 requests per minute of 2 GB each, even though both have the same data throughput. An architecture that scales well is built around assumptions about which operations will be common and which will be rare: the load parameters. If those assumptions turn out to be wrong, the scaling effort is wasted, so early-stage products should favor quick iteration over scaling for hypothetical future load.

---

## Maintainability
---

**The majority of the cost of software is in its ongoing maintenance**, not in its initial development: fixing bugs, keeping systems operational, investigating failures, adapting to new platforms and use cases, repaying technical debt, and adding new features. Three design principles help minimize the pain of maintenance:

- `Operability`: make it easy for operations teams to keep the system running smoothly.
- `Simplicity`: make it easy for new engineers to understand the system by removing as much complexity as possible. This does not mean a simple user interface.
- `Evolvability`: make it easy for engineers to change the system in the future, adapting it to unanticipated use cases as requirements change. This is also known as extensibility, modifiability, or plasticity.

{{< tabs "Maintainability" >}}
{{% tab "More on operability" %}}
**An operations team is responsible for tasks such as:**
- monitoring the health of the system and quickly restoring service when it goes into a bad state,
- tracking down the cause of problems, such as system failures or degraded performance,
- keeping software and platforms up to date, including security patches,
- keeping track of how different systems affect each other,
- anticipating future problems, such as capacity planning,
- establishing good practices and tools for deployment and configuration management,
- performing complex maintenance tasks, such as moving an application from one platform to another,
- maintaining the security of the system,
- defining processes that make operations predictable,
- preserving the organization's knowledge about the system as people come and go.

**How data systems make routine tasks easy:**
- visibility into runtime behavior and internals, with good monitoring,
- support for automation and integration with standard tools,
- no dependency on individual machines, so that machines can be taken down for maintenance,
- good documentation and an easy-to-understand operational model,
- good default behavior, with the freedom to override defaults,
- self-healing where appropriate, with manual control when needed,
- predictable behavior that minimizes surprises.

{{% /tab %}}
{{% tab "More on simplicity" %}}
A project mired in complexity is sometimes described as a `big ball of mud`.

**Symptoms of complexity:**
- explosion of the state space,
- tight coupling of modules,
- tangled dependencies,
- inconsistent naming and terminology,
- hacks aimed at solving performance problems,
- special-casing to work around issues elsewhere.

Complexity is `accidental` if it is not inherent in the problem that the software solves for its users, but arises only from the implementation.

**Abstraction is one of the best tools for removing accidental complexity:**
- It hides a great deal of implementation detail behind a clean, simple-to-understand facade.
- High-level programming languages hide machine code, CPU registers, and syscalls.
- SQL hides complex on-disk and in-memory data structures, concurrent requests from other clients, and inconsistencies after crashes.
- A good abstraction can be reused across many applications, so improvements to it benefit all of them.

{{% /tab %}}
{{% tab "More on evolvability" %}}

Requirements are in constant flux: new facts are learned, new use cases appear, business priorities change, users request new features, platforms are replaced, and legal requirements change.

Agile working patterns provide a framework for adapting to change, and technical tools such as test-driven development (TDD) and refactoring help in a frequently changing environment. Most of these techniques operate at a small, local scale. **The ease with which a data system can be modified is closely linked to its simplicity and its abstractions**, and the book uses the term evolvability for agility at the level of a larger data system.

{{% /tab %}}
{{< /tabs >}}
