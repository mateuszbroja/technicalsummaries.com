---
weight: 10
title: "10: Security and Privacy"
bookHidden: false
---

# Security and Privacy
---

Security is vital to the practice of data engineering, and it is a key ingredient for privacy. A data breach damages a company's reputation and customer trust and can bring large fines. Privacy regulations such as `GDPR` in Europe, `CCPA` in California, and `HIPAA` for US health data make privacy a legal obligation, not only an ethical one.

Security is not a separate project: it should be part of every stage of the lifecycle and every decision a data engineer makes. The book organizes it around three themes: people, processes, and technology.

## People
---

**People are often the weakest link** in security and privacy. Attackers often target people through phishing and social engineering, and careless handling of credentials or data causes many leaks.

### The Power of Negative Thinking

Data engineers should actively imagine attack and leak scenarios for the data they handle. Before collecting sensitive data, ask whether it is truly needed. The best way to protect sensitive data is often not to ingest or store it at all. When data must be stored, think through how it could leak and how to limit the damage.

### Always Be Paranoid

Be cautious whenever someone asks for credentials or sensitive data. Verify requests through a second channel, for example by calling the person, before sharing anything. When in doubt, ask security and privacy colleagues for help.

Basic good practices:

- Use `single sign-on (SSO)` and `multifactor authentication (MFA)`.
- Never share credentials, and never commit secrets to version control.
- Treat unexpected messages, links, and attachments with suspicion; phishing is a common entry point.

## Processes
---

### Security Theater Versus Security Habit

Many organizations focus on compliance with internal rules, laws, and recommendations from standards bodies, but pay too little attention to what could actually go wrong. `Security theater` is security on paper: policies that nobody reads and annual reviews that change nothing. A `security habit` is a culture where people practice security every day and keep it simple enough to follow.

### Active Security

`Active security` means thinking about and researching the threats that apply specifically to your organization, instead of relying only on generic checklists. For example, look at recent phishing attacks against companies like yours and train people on them, or review which data would be most attractive to attackers.

### The Principle of Least Privilege

> [!NOTE]
> **The principle of least privilege** means a person or system gets only the privileges and data needed to do the task at hand, and nothing more.

- Do not grant administrator access by default; grant specific roles for specific tasks.
- Remove privileges and roles when they are no longer needed, including those of service accounts.
- Apply the principle to data as well as to systems: give users access only to the columns, rows, and datasets they need, and mask or hash sensitive fields where possible.

### Shared Responsibility in the Cloud

Cloud vendors are responsible for the security **of** the cloud: physical data centers, hardware, and the underlying services. Users are responsible for security **in** the cloud: configuration, access policies, and the data they store. Most cloud security breaches are caused by end users, not by the cloud provider, for example misconfigured object storage buckets exposed to the public.

### Always Back Up Your Data

Data can disappear because of hardware failures, human errors, or attacks such as ransomware. `Data backup` belongs to both security and disaster recovery. Back up regularly, keep backups in a separate location, and test that you can actually restore from them.

### An Example Security Policy

A simple, practical policy that people can actually follow:

**Protect your credentials**

- Use SSO wherever possible, together with MFA.
- Never share passwords or credentials; use a password or secrets manager.
- Never embed credentials in code; keep secrets in a secrets manager or in environment configuration.
- Use cloud identity and access management (IAM) roles instead of long-lived keys.
- Beware of phishing and social engineering.

**Protect your devices**

- Use device management so that lost or stolen devices can be wiped remotely.
- Enable full-disk encryption and automatic screen locks.
- Use a VPN on untrusted networks.
- Do not use personal devices for company work.

**Keep software up to date**

- Update operating systems, browsers, and applications as soon as updates are released.
- Report devices or systems that cannot be updated to the security team.

### Privacy in Practice

Privacy regulations turn privacy into concrete engineering work:

- **Collect less**: ingest and keep only the personal data that a use case actually needs.
- **Protect what you keep**: mask, hash, or tokenize personally identifiable information (PII) when analytics do not need raw values, and restrict access to the raw data.
- **Be able to delete**: laws such as GDPR give people the right to have their data erased. Pipelines, backups, and derived datasets must make it possible to find and remove one person's data.
- **Know where data lives**: track which systems hold sensitive data and who can access it, so that requests and audits can be answered quickly.

## Technology
---

### Patch and Update Systems

Software gets stale and vulnerabilities are discovered constantly. Patch and update operating systems, libraries, and data tools regularly, and automate the process where possible. Managed SaaS and cloud services take part of this burden off your team.

### Encryption

Encryption is not a magic bullet: it does little to help when an attacker gains access through stolen credentials. It is, however, a baseline requirement for any organization that respects security and privacy, and it protects against basic attacks such as intercepting network traffic.

{{% columns %}}
- **Encryption at rest**

  Data is encrypted when it is stored on a device. Cloud storage and databases typically encrypt data at rest by default. Full-disk encryption should be enabled on company laptops so that data is protected if a device is stolen.

- **Encryption over the wire**

  Data is encrypted as it travels between systems. `HTTPS` is now the default for most current protocols. Keys and certificates must be handled securely. Older protocols such as `FTP` are not secure on public networks and should be avoided.
{{% /columns %}}

### Logging, Monitoring, and Alerting

Hackers and intruders typically do not announce themselves. Log access to data and systems, monitor those logs, and alert on anomalies. Watch these areas:

- **Access**: who accesses what, when, and from where. Watch for unusual patterns, such as a login from an unexpected location or a user suddenly downloading large volumes of data.
- **Resources**: disk, CPU, memory, and I/O. A sudden, unexplained spike can indicate a compromised system.
- **Billing**: especially for SaaS and cloud-managed services. Unexpected costs often reveal misuse; set budgets and billing alerts.
- **Excess permissions**: monitor for permissions that users or systems no longer use, and remove them.

### Network Access

Network security is often the responsibility of security specialists, but data engineers still need to understand it.

- Know which IPs and ports are open, to whom, and why.
- Allow only the incoming IP addresses of the systems and users that need access; never open a database or SSH to the whole internet (`0.0.0.0/0`).
- Use bastion hosts or private connections to reach sensitive systems.
- Use encrypted connections to cloud services and SaaS tools, and avoid unencrypted websites, especially on public networks.

### Security for Low-Level Data Engineering

Engineers who work on the internals of storage and processing systems must consider the security implications of every component, including libraries, drivers, and open source dependencies.

`Internal security research`: encourage engineers to look for security issues in the systems they build and use, and to report them. Engineers who know a system deeply are often best placed to spot its weaknesses, and they should feel responsible for its security rather than leaving it entirely to a security team.

> [!WARNING]
> Security is everyone's job. Make it a habit in daily work rather than a checklist completed once a year.
