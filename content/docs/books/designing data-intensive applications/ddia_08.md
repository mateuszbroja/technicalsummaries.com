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

In distributed systems, we must embrace the potential for partial failures and design software that is fault-tolerant. We are creating reliable systems from unreliable components. In contrast to single-system applications, which either work or don't, distributed systems operate in a gray area.

`Partial failures`, where some parts of the system malfunction while others function correctly, are common in distributed systems. These are nondeterministic and can unpredictably impact operations involving multiple nodes and the network. 

Reliability in distributed systems is approached `probabilistically`. Absolute reliability (100%) is unattainable, but high degrees of reliability (like 99%) are feasible. 

---
## Common Partial Failures in Distributed Systems

### Network Issues

Network irregularities can delay, queue indefinitely, or lose messages, making detection challenging. When no response is received from a node, the reason is unclear. The common remedy is a _timeout_, where you stop waiting after a period and assume the response won't arrive. Testing system responses to network issues is crucial. Positive responses from applications confirm successful requests.

---
### Clock Synchronization

Clocks often vary between nodes and might jump anytime. Types include:
- **Time of day clocks**: Provide absolute time, frequently synced with NTP.
- **Monotonic clocks**: Useful for measuring durations, always move forward.
- **Logical clocks**: Use counters to avoid synchronization.

Synchronizing clocks is costly. Best practice assumes time is accurate within a confidence interval. Using clocks for event ordering is risky and can lead to silent data losses. Google's Spanner uses clocks' confidence interval for snapshot isolation across datacenters.

---
## Knowledge, Truth, and Lies in Distributed Systems

Defining reality can be challenging due to potentially faulty senses.

**Truth is often determined by the majority**: In distributed systems, certain actions require agreement, usually from a majority. For instance, a node might believe it's the leader, but the majority might disagree.

**Leases and locks can help maintain order**: To prevent a former leader from assuming its role, a fencing token can be used to block outdated tokens.

**Byzantine Faults**: Systems might unintentionally lie rather than intentionally send incorrect information. You need to consider and possibly build tolerance for these.

**System Model and Reality**:
- **Models**:
    - `Synchronous`: Bounded network delay and time drift.
    - `Partially synchronous`: Sometimes experiences asynchronous properties.
    - `Asynchronous`: No timing assumptions.
- **Faults**:
    - `Crash-stop`: When a node faults, it permanently stops.
    - `Crash-recovery`: Faulting nodes may appear dead but could recover later.
    - `Byzantine`: Nodes might intentionally deceive.

Most systems fall into partially synchronous and crash recovery categories in the model/fault matrix.

**Being prepared for various scenarios is crucial due to the complex and unpredictable nature of distributed systems.**
