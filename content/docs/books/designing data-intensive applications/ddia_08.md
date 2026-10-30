---
weight: 8
title: "08: The Trouble with Distributed Systems"
bookHidden: false
---

# The Trouble with Distributed Systems

---

*Assuming anything that can go wrong will go wrong*

---

## Overview

The previous chapters dealt with replica failover, replication lag and concurrency control. This chapter turns the pessimism up to the maximum: networks lose and delay messages, clocks drift and jump, and processes can freeze at any moment. The job of an engineer is to build a system that still meets its guarantees under these conditions, which means building a reliable system from unreliable components.

---

## Faults and Partial Failures

A program on a single computer is usually deterministic: the same operation produces the same result. When the hardware fails, the computer typically crashes completely instead of returning a wrong result. A single machine therefore either works or does not.

A distributed system behaves differently.

> [!WARNING]
> A `partial failure` happens when some parts of a system are broken in an unpredictable way while other parts work fine. Partial failures are `nondeterministic`: an operation that involves several nodes and the network may sometimes succeed and sometimes fail, and you may not even know whether it succeeded.

### Cloud Computing and Supercomputing

There are two philosophies for building large-scale computing systems:

{{% columns %}}
- **High-performance computing (HPC)**

  Supercomputers with thousands of CPUs run long scientific batch jobs. A job periodically checkpoints its state to durable storage. When a node fails, the whole cluster stops and restarts from the last checkpoint. A partial failure is escalated to a total failure, which makes a supercomputer behave like a single machine.

- **Cloud computing and internet services**

  Online services must serve users with low latency at all times, so stopping the whole cluster is not acceptable. They run on commodity machines that fail more often, communicate over IP and Ethernet, and are often spread across geographic regions. Rolling upgrades and failing nodes are normal, so the software must tolerate partial failure.
{{% /columns %}}

Fault tolerance has to be designed into the software. Even a small system benefits from assuming that faults will happen and from testing how the software reacts to them.

> [!NOTE]
> **Building a reliable system from unreliable components**
>
> This idea is old. Error-correcting codes transmit digital data accurately over a noisy channel, and TCP provides reliable, ordered delivery on top of IP, which may drop, delay, duplicate or reorder packets. The higher-level system is more reliable than its parts, but there is always a limit to how much it can hide.

---

## Unreliable Networks

The book focuses on `shared-nothing` systems: machines that share no memory or disk and communicate only over the network. Datacenter networks are `asynchronous packet networks`: a node can send a message to another node, but the network gives no guarantee about when it arrives or whether it arrives at all.

When a node sends a request and expects a response, many things can go wrong:

1. The request is lost, for example because a cable was unplugged.
2. The request waits in a queue and is delivered later, for example because the network or the recipient is overloaded.
3. The remote node has crashed or was powered down.
4. The remote node is temporarily unresponsive, for example during a long garbage collection pause, and will respond later.
5. The remote node processed the request, but the response was lost.
6. The remote node processed the request, but the response is delayed.

> [!CAUTION]
> The sender cannot tell which of these cases happened. The only information it has is that it has not received a response yet. The usual remedy is a `timeout`: after some time, the sender stops waiting and assumes the response will not arrive. Even then it does not know whether the remote node got the request and acted on it.

### Network Faults in Practice

Network problems are surprisingly common even in datacenters operated by a single company. Studies cited in the book report regular faults caused by misconfigured switches, failing network hardware and human error. Adding redundant networking gear helps less than expected, because it does not protect against human error. Public clouds such as EC2 are known for frequent transient network glitches.

A `network partition` (or `netsplit`) happens when one part of the network is cut off from another. You do not necessarily need to tolerate every network fault, but you need to know how your software reacts to them, because a cluster could otherwise become permanently unable to serve requests or even lose data. Deliberately triggering network problems, as Netflix's `Chaos Monkey` does, is a way to test this.

### Detecting Faults

Many systems need to detect faulty nodes automatically: a load balancer must stop sending requests to a dead node, and a single-leader database must promote a follower when the leader fails. Sometimes the system gets explicit feedback:

- If the machine is reachable but no process listens on the port, the operating system replies with a `RST` or `FIN` packet and closes the TCP connection.
- If a node process crashes but the operating system keeps running, a script can notify other nodes so that failover happens quickly.
- A switch management interface can reveal that a link is down at the hardware level.
- A router can reply with an ICMP `Destination Unreachable` packet when the destination IP is not reachable.

This feedback is useful but cannot be relied on. A TCP acknowledgment only says that the packet reached the remote operating system, not that the application processed it. To be sure that a request succeeded, you need a positive response from the application itself.

### Timeouts and Unbounded Delays

There is no simple answer to how long a timeout should be:

- A **long timeout** means a long wait until a dead node is declared dead, and users see errors or delays during that time.
- A **short timeout** detects faults faster, but risks declaring a node dead when it is only slow. If the node is in the middle of an action and another node takes over, the action may be performed twice. Moving the load of a "dead" node onto other nodes can also cause a `cascading failure` when the system is already overloaded.

If the network guaranteed a maximum delay `d` for every packet and every node handled a request within time `r`, a timeout of `2d + r` would be reasonable. Asynchronous networks and most server implementations give neither guarantee: delays are `unbounded`.

> [!NOTE]
> **Network congestion and queueing**
>
> Most of the variability of packet delays comes from queueing:
>
> - Several nodes send packets to the same destination at once, and the network switch must queue them on the outgoing link. If the queue fills up, packets are dropped and must be resent.
> - When all CPU cores of the destination machine are busy, the operating system queues the incoming request until the application can handle it.
> - In virtualized environments, the hypervisor pauses a running operating system while another virtual machine uses the CPU, and incoming data is buffered meanwhile.
> - TCP `flow control` (congestion avoidance or backpressure) makes a node limit its own sending rate, which queues data at the sender.
> - TCP retransmits lost packets after a timeout. The application sees the loss only as a delay.

In public clouds and multi-tenant datacenters, resources are shared with other customers, and a `noisy neighbor` using a lot of resources can make delays highly variable. Under these conditions, the only practical approach is to choose timeouts experimentally: measure the distribution of round-trip times over an extended period and across many machines. Better still, the system can measure response times continuously and adjust its timeouts automatically, as the `Phi Accrual failure detector` used in Akka and Cassandra does.

> [!NOTE]
> **UDP versus TCP**
>
> Latency-sensitive applications such as videoconferencing and Voice over IP use UDP. UDP has no flow control and does not retransmit lost packets, so it avoids some of the causes of variable delay. This fits cases where delayed data is worthless anyway: a caller cannot use a few seconds of retransmitted audio.

### Synchronous Versus Asynchronous Networks

The fixed-line telephone network is very reliable and has bounded delay. A call sets up a `circuit`: a fixed, guaranteed amount of bandwidth along the entire route between the two callers, reserved for the duration of the call. Because there is no queueing, the maximum end-to-end latency is fixed. Such a network is called `synchronous`.

Datacenter networks and the internet use `packet switching` instead, because it is optimized for `bursty traffic`. A web request or a file transfer has no fixed bandwidth requirement: it should simply finish as quickly as possible with whatever bandwidth is available. Reserving bandwidth for it would either waste capacity or make the transfer unnecessarily slow.

> [!WARNING]
> **Latency and resource utilization**
>
> Variable delays are a consequence of `dynamic resource partitioning`. A circuit statically divides the bandwidth, which gives guaranteed latency but lower utilization. A packet network shares the bandwidth dynamically, which gives better utilization and lower cost but variable delays. Quality of service and admission control can partly emulate circuit switching, but they are not enabled in today's multi-tenant datacenters and public clouds. Network congestion, queueing and unbounded delays will happen, so there is no "correct" timeout value: it has to be determined experimentally.

---

## Unreliable Clocks

Applications use clocks for two kinds of questions:

- **Durations**: Has this request timed out? What is the 99th percentile response time? How long did a user spend on a page?
- **Points in time**: When was this article published? At what date and time should this reminder email be sent? When does this cache entry expire?

In a distributed system, time is tricky because communication is not instantaneous and each machine has its own clock, usually a quartz crystal oscillator. These clocks are not perfectly accurate, so each machine has its own notion of time. The `Network Time Protocol (NTP)` adjusts clocks according to the time reported by a group of servers, which in turn get their time from more accurate sources such as GPS receivers.

### Monotonic Versus Time-of-Day Clocks

{{% columns %}}
- **Time-of-day clock**

  Returns the current date and time according to some calendar, also called `wall-clock time`. Examples are `clock_gettime(CLOCK_REALTIME)` on Linux and `System.currentTimeMillis()` in Java, which return the number of seconds or milliseconds since the `epoch` (midnight UTC on January 1, 1970). The clock is usually synchronized with NTP. If the local clock is too far ahead of the NTP server, it may be forcibly reset and appear to jump back in time. This makes it unsuitable for measuring elapsed time.

- **Monotonic clock**

  Suitable for measuring a duration, such as a timeout or a service's response time. Examples are `clock_gettime(CLOCK_MONOTONIC)` on Linux and `System.nanoTime()` in Java. It is guaranteed to always move forward. Its absolute value is meaningless, and comparing values from two different computers makes no sense. NTP may adjust the rate at which it moves forward (`slewing`), but cannot make it jump.
{{% /columns %}}

In a distributed system, using a monotonic clock for measuring elapsed time, such as a timeout, is usually fine, because it does not assume any synchronization between the clocks of different nodes.

### Clock Synchronization and Accuracy

Monotonic clocks need no synchronization, but time-of-day clocks must be set according to an NTP server or another external source. The methods for getting a correct time are less reliable than one might hope:

- The quartz clock `drifts`: it runs faster or slower depending on the temperature. Google assumes a drift of 200 parts per million for its servers. That is 6 ms of drift for a clock resynchronized every 30 seconds, or 17 seconds for a clock resynchronized once a day.
- If a computer's clock differs too much from an NTP server, it may refuse to synchronize or be forcibly reset, so applications may see time go backward or jump forward.
- A node may be accidentally firewalled off from NTP servers, and the misconfiguration may go unnoticed for some time.
- NTP synchronization is only as good as the network delay. On a congested network, the error can be large.
- Some NTP servers are wrong or misconfigured and report time that is off by hours.
- `Leap seconds` produce a minute that is 59 or 61 seconds long. They have crashed large systems in the past, because many systems do not expect them.
- In virtual machines, the hardware clock is virtualized. When a VM is paused so that another VM can use the CPU, the application sees the clock suddenly jump forward.
- On devices you do not control, such as mobile phones, the user may deliberately set a wrong date and time.

High accuracy is achievable with significant investment. For example, European financial regulation (MiFID II) requires high-frequency trading funds to synchronize their clocks to within 100 microseconds of UTC. This requires GPS receivers, the `Precision Time Protocol (PTP)` and careful deployment and monitoring.

### Relying on Synchronized Clocks

> [!CAUTION]
> Clocks have a surprising number of pitfalls. A day may not have exactly 86,400 seconds, time-of-day clocks may move backward, and the time on one node may be quite different from another. If software depends on accurately synchronized clocks, a drifting clock does not crash the system. It causes `silent and subtle data loss`. Any software that relies on synchronized clocks must therefore monitor the clock offsets between all machines and declare a node with a drifting clock dead.

#### Timestamps for Ordering Events

Ordering events by time-of-day timestamps across nodes is dangerous. Consider `last write wins (LWW)` conflict resolution, used in multi-leader and leaderless databases such as Cassandra and Riak. Client A writes `x = 1` on node 1, the write is replicated to node 3, and client B then increments `x` to 2 on node 3. If node 3's clock lags behind node 1's clock, B's write gets an earlier timestamp than A's. Every node then discards B's write, even though it happened later.

The problems with LWW include:

- A node with a lagging clock cannot overwrite values written by a node with a fast clock until the clock skew has elapsed, so writes are silently dropped without any error reported to the application.
- LWW cannot distinguish writes that happened quickly in sequence from writes that were truly concurrent. Causality tracking, such as `version vectors`, is needed for that.
- Two nodes can generate writes with the same timestamp, particularly when the clock has only millisecond resolution.

> [!NOTE]
> **Logical clocks**
>
> The definition of "most recent" depends on a local time-of-day clock, which may be wrong. A safer alternative for ordering events is a `logical clock`, based on incrementing counters instead of an oscillating quartz crystal. Logical clocks measure only the relative ordering of events. Time-of-day and monotonic clocks, which measure actual elapsed time, are called `physical clocks`.

#### Clock Readings Have a Confidence Interval

A clock may report time with microsecond resolution, but that does not mean it is accurate to the microsecond. A clock reading is better thought of as a range of times within a `confidence interval`, for example 95% confidence that the time is between 10.3 and 10.5 seconds past the minute. The uncertainty bound depends on the time source: a GPS receiver or atomic clock attached directly to the computer has an error of microseconds, while a server that syncs with NTP over the internet may have an error of tens of milliseconds or more.

Most systems do not expose this uncertainty. An exception is Google's `TrueTime` API in `Spanner`, which explicitly reports the confidence interval of the local clock as a pair `[earliest, latest]`.

#### Synchronized Clocks for Global Snapshots

Snapshot isolation needs a monotonically increasing transaction ID to decide which writes are visible to a snapshot. On a single node, a counter is enough. In a database distributed across many machines and datacenters, a global counter becomes a bottleneck, and synchronized time-of-day timestamps are not reliable enough to use instead.

Spanner implements snapshot isolation across datacenters by using TrueTime confidence intervals. If two intervals do not overlap, the order of the two events is certain. Before committing a read-write transaction, Spanner deliberately waits for the length of the confidence interval, so that any transaction that may read the data starts after the interval has passed. To keep this wait short, Google deploys a GPS receiver or atomic clock in each datacenter, which keeps the uncertainty to about 7 ms.

---

## Process Pauses

Consider a database with a single leader per partition. To know that it is still the leader, the leader holds a `lease` from the other nodes, which is like a lock with a timeout. The leader must renew the lease periodically. A simple request loop might look like this:

```text
while (true) {
  request = getIncomingRequest();
  // ensure that the lease always has at least 10 seconds remaining
  if (lease.expiryTimeMillis - System.currentTimeMillis() < 10000) {
    lease = lease.renew();
  }
  if (lease.isValid()) {
    process(request);
  }
}
```

This code has two problems. First, it compares an expiry time set by a different machine with the local system clock, so it relies on synchronized clocks. Second, even with a local monotonic clock, it assumes that very little time passes between checking the lease and processing the request. If the thread is paused for 15 seconds, the lease has expired and another node has become leader, but the paused thread will not notice and will process the request anyway.

A running thread can be paused for a long time for many reasons:

- `Garbage collection (GC)` in runtimes such as the JVM may "stop the world" for seconds or even minutes.
- A virtual machine can be `suspended` and resumed, for example during `live migration` to another host.
- A laptop user may close the lid, which suspends the machine.
- The operating system may `context-switch` to another thread, or the hypervisor may switch to another VM (`steal time`).
- The thread may wait for slow `synchronous disk I/O`, which can be triggered unexpectedly, for example when the JVM lazily loads a class file.
- If the system uses `swap`, a simple memory access can cause a page fault that waits for disk, and in extreme cases the operating system spends most of its time `thrashing`.
- A Unix process can be paused with `SIGSTOP`, for example by pressing Ctrl-Z, and resumed later with `SIGCONT`.

> [!CAUTION]
> A node in a distributed system must assume that its execution can be paused for a significant length of time at any point, even in the middle of a function. During the pause, the rest of the world keeps moving and may declare the paused node dead. When the node resumes, it may not even notice that it was asleep.

### Response Time Guarantees

Some software, such as the controls of an aircraft or a car airbag, must respond within a specified time. These are `hard real-time` systems. They need a `real-time operating system (RTOS)` that guarantees CPU time allocation, library functions with documented worst-case execution times, restricted or no dynamic memory allocation, and a lot of testing. This is expensive and restrictive, and "real-time" here is not the same as "high-performance". Most server-side data systems are not real-time, so they must tolerate pauses and clock problems.

### Limiting the Impact of Garbage Collection

Pauses cannot be eliminated, but their effect can be reduced:

- Treat GC pauses like brief planned outages. The runtime warns the application that a node will soon need a GC pause, the application stops sending new requests to that node, waits for outstanding requests to finish and then lets GC run.
- Use the garbage collector only for short-lived objects, which are fast to collect, and restart processes periodically before they accumulate enough long-lived objects to need a full GC. Restarts are done one node at a time, like a rolling upgrade.

---

## Knowledge, Truth, and Lies

A node in a distributed system cannot know anything for sure. It can only make guesses based on the messages it receives or does not receive over the network. If a remote node does not respond, there is no way to tell whether the node or the network has a problem.

### The Truth Is Defined by the Majority

A node cannot trust its own judgment of a situation. Imagine these cases:

- A node can receive messages but its outgoing messages are dropped. Other nodes declare it dead, even though it is working.
- A node experiences a long GC pause. Other nodes declare it dead and elect a new leader. The paused node then resumes as if nothing had happened.

Many distributed algorithms therefore rely on a `quorum`: a vote among the nodes. Decisions such as declaring a node dead require a minimum number of votes from several nodes, which reduces the dependence on any single node. The most common quorum is an `absolute majority` of more than half the nodes. A majority quorum lets the system keep working when individual nodes fail, and it is safe because there can only be one majority at a time.

### The Leader and the Lock

Often a system needs exactly one of something:

- Only one node may be the leader for a database partition, to avoid split brain.
- Only one transaction or client may hold the lock for a particular resource, to prevent concurrent writes and corruption.
- Only one user may register a particular username, because it must identify a user uniquely.

Even if a node believes it is "the chosen one", that does not mean a quorum of nodes agrees. A node that held a lease, was paused, and resumed may keep acting as the leader even though the lease expired and another node took over. The book describes a real data-corruption bug in HBase caused by exactly this: a client whose lease had expired during a pause still wrote to a file in storage, overwriting the writes of the client that now held the lease.

### Fencing Tokens

> [!WARNING]
> A `fencing token` protects a resource against a node that wrongly believes it still holds a lock or lease. Every time the lock service grants a lock or lease, it also returns a number that increases with every grant. The client must include this token with every write request to the storage service. The storage service remembers the highest token it has processed and rejects any request with a lower token.

For example, client 1 gets a lease with token 33 and then pauses. The lease expires, and client 2 gets a lease with token 34 and writes to storage. When client 1 wakes up and sends its write with token 33, the storage server rejects it, because it has already processed token 34.

If `ZooKeeper` is the lock service, the transaction ID `zxid` or the node version `cversion` can serve as the fencing token, because they are guaranteed to increase monotonically. The resource itself must actively check the tokens: it is not enough for clients to check their own lock status.

### Byzantine Faults

Fencing tokens protect against nodes that are inadvertently acting in error. They assume that nodes are unreliable but honest: a node either does not respond or responds according to the protocol as far as it knows.

> [!CAUTION]
> A `Byzantine fault` happens when a node may "lie": it sends arbitrary faulty or corrupted responses, for example claiming to have received a message that it never received. Reaching consensus in such an untrusting environment is known as the `Byzantine Generals Problem`. A system is `Byzantine fault-tolerant` if it keeps operating correctly even when some nodes malfunction and do not obey the protocol, or when malicious attackers interfere with the network.

Byzantine fault tolerance matters in a few settings:

- In aerospace, radiation can corrupt the memory or CPU registers of a computer, which may then respond in unpredictable ways. Flight control systems must tolerate this.
- In a system with several participating organizations, some participants may try to cheat or defraud others. Peer-to-peer networks such as Bitcoin and other blockchains address this problem.

In a datacenter controlled by one organization, nodes are usually assumed not to be Byzantine. Byzantine fault-tolerant algorithms are complicated and require a supermajority of more than two-thirds of the nodes to function correctly. They also cannot protect against a software bug, because the same faulty code would run on all nodes. Traditional security mechanisms such as authentication, access control, encryption and firewalls remain the main protection against attackers.

Weak forms of lying can still be guarded against cheaply:

- `Checksums` in the application protocol catch packets corrupted by hardware, operating system or driver bugs.
- A publicly accessible application must carefully `sanitize` user input, for example by checking that values are within a reasonable range.
- An NTP client can query several servers and ignore one whose time is an outlier.

---

## System Model and Reality

Distributed algorithms are written for a `system model`, an abstraction that describes which faults the algorithm must tolerate.

{{% columns %}}
- **Timing assumptions**

  - `Synchronous model`: bounded network delay, bounded process pauses and bounded clock error. This is not realistic for most practical systems.
  - `Partially synchronous model`: the system behaves synchronously most of the time, but occasionally exceeds the bounds for delays, pauses and clock drift. This is realistic for many systems.
  - `Asynchronous model`: no timing assumptions at all, and no clock, so timeouts cannot be used. This is very restrictive.

- **Node failures**

  - `Crash-stop faults`: a node can fail only by crashing, and then it is gone forever.
  - `Crash-recovery faults`: a node may crash at any moment and may start responding again later. It is assumed to keep data on stable storage, but loses its in-memory state.
  - `Byzantine faults`: nodes may do absolutely anything, including trying to trick and deceive other nodes.
{{% /columns %}}

For modeling real systems, the `partially synchronous model with crash-recovery faults` is generally the most useful.

### Correctness: Safety and Liveness

An algorithm is correct if it satisfies the properties of its specification in all situations allowed by the system model. For an algorithm that generates fencing tokens, the properties could be:

- **Uniqueness**: no two requests for a fencing token return the same value.
- **Monotonic sequence**: if request x returned token `tx` and request y returned token `ty`, and x completed before y began, then `tx < ty`.
- **Availability**: a node that requests a fencing token and does not crash eventually receives a response.

> [!NOTE]
> **Safety and liveness**
>
> - A `safety` property means that nothing bad happens. If it is violated, you can point to the moment when it was broken, and the damage cannot be undone. Uniqueness and monotonic sequence are safety properties.
> - A `liveness` property means that something good eventually happens. It may not hold at some point in time, but there is always hope that it will be satisfied later. Availability is a liveness property, and liveness properties often contain the word "eventually".
>
> Distributed algorithms commonly require safety properties to always hold, even if all nodes crash or the whole network fails. Liveness properties may come with caveats, for example that a request gets a response only if a majority of nodes has not crashed and the network eventually recovers.

### Mapping System Models to the Real World

System models are simplifications of reality. A quorum algorithm assumes that a node remembers the data it has stored, but in reality a disk can be corrupted, a firmware bug can wipe data, or a misconfiguration can make a node forget what it stored. Some situations that a model calls impossible can still happen in practice, and an implementation may have to handle them, even if only by printing an error and asking an operator for help.

Theoretical proofs that an algorithm is correct are valuable, because they reveal problems that would otherwise stay hidden. The implementation can still have bugs, so theoretical analysis and empirical testing are equally important.

---

## Summary

- Packets sent over the network may be lost or arbitrarily delayed, and so may replies. Without a response, you cannot know whether a message got through.
- A node's clock may be significantly out of sync with other nodes, may jump forward or back in time, and rarely reports its own error bound.
- A process may pause for a substantial amount of time at any point, be declared dead by other nodes, and then resume without noticing that it was paused.
- Detecting faults is hard: most systems rely on timeouts, which cannot distinguish network faults from node faults.
- A node cannot trust its own judgment, so decisions require a quorum of nodes. Fencing tokens protect resources from nodes that wrongly believe they still hold a lock.
- Building fault tolerance into distributed software is hard, so a single-node system is preferable when it is enough. Scalability, fault tolerance and low latency are the reasons to accept the complexity of a distributed system.
