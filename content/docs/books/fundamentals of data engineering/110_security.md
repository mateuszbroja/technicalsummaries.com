---
weight: 10
title: "10: Security and Privacy"
bookHidden: false
---

# Security and Privacy
---

Security is a key ingredient for privacy.

## People
---

- **People** are often the weakest link in security and privacy, so it is important to be aware of potential risks and take measures to protect sensitive information.
- **The Power of Negative Thinking** - Data engineers should think about the attack and leak scenarios.
- **Always Be Paranoid**
- Use good practices - `single-sign-on (SSO)`, multifactor authentication, never commit secrets to version control.

## Processes
---

**Security Theater Versus Security Habit** - Clients are mainly focused on ensuring compliance with internal rules, laws, but they often overlook potential security risks. It's important to remember that security doesn't have to be complicated.

**The principle of least privilege** is to provide only the necessary privileges and data to individuals or systems to accomplish their tasks and nothing more. It is important to remove these privileges and roles when they are no longer required, including service accounts.

**Shared Responsibility in the Cloud** - Cloud security breaches are more often caused by end users rather than by the cloud itself.

**Always Back Up Your Data** - `Data backup` is typically considered a part of both security and disaster recovery practices.


## Technology
---

- **Patch and Update Systems** - do updates regulary

- **Encryption** - essential for any organization that values security and privacy. It provides protection against basic attacks like network traffic interception.

{{< columns >}}
**Encryption at rest**
Data should be encrypted when it is stored on a storage device, which is known as `encryption at rest`. Full-disk encryption should be enabled on company laptops to ensure that data is protected in case the device is stolen.
<--->
**Encryption over the wire**
Data should be encrypted at rest and over the wire, with keys handled securely. `HTTPS` is now the default for current protocols, but bucket permissions must also be secured. Older protocols like `FTP` are not secure on public networks and should be avoided.
{{< /columns >}}


## Logging, Monitoring, and Alerting
---

- **Access**
- **Resources**: disk, CPU, memory, and I/O.
- **Billing**: especially with SaaS and cloud-managed services.
- **Excess permissions**: monitor for permissions that are not utilized.
 

## Network Access
---

Leave network security to security experts at your company. Understand open `IPs` and `ports`, allow incoming IPs of systems and users accessing them, and avoid broadly opening connections. Use encrypted connections when accessing the cloud or a SaaS tool, and don't use unencrypted websites from public places.