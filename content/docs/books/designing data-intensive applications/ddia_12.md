---
weight: 12
title: "12: The Future of Data Systems"
bookHidden: true
---

# The Future of Data Systems

## Data Integration: Bridging the Gap

Data integration is a complex task that requires evaluating tools from different vendors with a critical eye. No single technology can meet all requirements, making the combination of multiple tools necessary. Derived views allow for gradual evolution and enable easier read operations, ensuring data ends up in the right form in the right place.

## Unbundling Databases: The Power of Flexibility

Unbundling databases presents the opportunity to unify reads (federated databases) and writes (unbundled databases). This approach enables a unified query language, aggregating data from various storage technologies. Synchronized writes across systems ensure data integrity and provide flexibility in choosing the right technology for different use cases.

## Designing Applications Around Dataflow: Embracing Change

The future lies in designing applications around dataflow, where stateless application logic is separated from state management. By responding to state changes, applications can trigger corresponding changes in other parts of the system. Materialized views and caching optimize the read and write paths, while spreadsheets offer advanced dataflow capabilities beyond traditional databases.

## Aiming for Correctness: Beyond Consistency

Traditional consistency guarantees are being challenged as applications move away from strict requirements. Operation identifiers and end-to-end procedures help ensure correctness, even in the face of distributed systems. Striving for correctness requires considering the full flow of requests and leveraging idempotence and duplicate suppression.

## Enforcing Constraints: Taming Complexity

Enforcing constraints, such as uniqueness or transactional consistency, can be complex. Log-based messaging and derived instructions offer a way to maintain integrity without the need for atomic commit across all partitions. By leveraging sequential processing and message deduplication, constraints can be efficiently enforced.

## Timeliness and Integrity: Balancing Priorities

Timeliness and integrity are crucial considerations in data systems. While timeliness is important, integrity, the absence of data corruption, takes precedence. Loose constraints can be managed through existing processes, ensuring that violations are addressed in a timely manner without sacrificing data integrity.

## Trust, but Verify: Auditing for Confidence

Auditing plays a vital role in verifying data integrity and system correctness. Regular backups and cryptographic techniques enhance the trustworthiness of data. Emphasizing transparency and accountability in data collection and processing builds user confidence and fosters responsible data practices.

## Doing the Right Thing: Ethics and Privacy

Ethical considerations must guide data storage and usage practices. Privacy concerns, surveillance, and tracking raise important questions about consent and user agency. Striving for privacy means respecting individuals' control over their data, providing transparency, and protecting against misuse.

The future lies in the responsible and ethical use of data, where users are treated as humans deserving respect, dignity, and control over their own information.
