---
weight: 10
title: "10: Security and Privacy"
bookHidden: true
---

# Security and Privacy

Security is a key ingredient for privacy

People

The weakest link in security and privacy is you. Security is often compromised at the
human level, so conduct yourself as if you’re always a target. A

The Power of Negative Thinking
Data engineers should think about the attack and leak scenarios with any data pipeline
or storage system they utilize

Always Be Paranoid

Processes
Security Theater Versus Security Habit
With our corporate clients, we see a pervasive focus on compliance (with internal
rules, laws, recommendations from standards bodies), but not enough attention to
potentially bad scenarios
Security doesn’t need to be complicated

The Principle of Least Privilege
The principle of least privilege means that a person or system should be given only the
privileges and data they need to complete the task at hand and nothing more.
When these roles are no longer needed, take them away. The same
rule applies to service accounts

Shared Responsibility in the Cloud
Most cloud security breaches continue to be caused by
end users, not the cloud

Always Back Up Your Data
Data backup doesn’t strictly fit under security and privacy practices; it goes under the
larger heading of disaster prevention


An Example Security Policy

Protect Your Credentials
Use a single-sign-on (SSO) for everything. Avoid passwords whenever possible,
and use SSO as the default.
• Use multifactor authentication with SSO.
• Don’t share passwords or credentials. This includes client passwords and credentials.
If in doubt, see the person you report to. If that person is in doubt, keep
digging until you find an answer.
• Beware of phishing and scam calls. Don’t ever give your passwords out. (Again,
prioritize SSO.)
• Disable or delete old credentials. Preferably the latter.
• Don’t put your credentials in code. Handle secrets as configuration and never
commit them to version control. Use a secrets manager where possible.
• Always exercise the principle of least privilege. Never give more access than is
required to do the job. This applies to all credentials and privileges in the cloud
and on premises.


Protect Your Devices
Use device management for all devices used by employees. If an employee leaves
the company or your device gets lost, the device can be remotely wiped.
• Use multifactor authentication for all devices.
• Sign in to your device using your company email credentials.
• All policies covering credentials and behavior apply to your device(s).
Treat your device as an extension of yourself. Don’t let your assigned device(s)
out of your sight.
• When screen sharing, be aware of exactly what you’re sharing to protect sensitive
information and communications. Share only single documents, browser tabs,
or windows, and avoid sharing your full desktop. Share only what’s required to
convey your point.
• Use “do not disturb” mode when on video calls; this prevents messages from
appearing during calls or recordings.

Software Update Policy
• Restart your web browser when you see an update alert.
• Run minor OS updates on company and personal devices.
• The company will identify critical major OS updates and provide guidance.
• Don’t use the beta version of an OS.
• Wait a week or two for new major OS version releases.



Technology
Patch and Update Systems

Encryption
Encryption is a baseline
requirement for any organization that respects security and privacy. It will protect
you from basic attacks, such as network traffic interception.

Encryption at rest
Be sure your data is encrypted when it is at rest (on a storage device). Your company
laptops should have full-disk encryption enabled to protect data if a device is stolen.


Encryption over the wire
Encryption over the wire is now the default for current protocols. For instance,
HTTPS is generally required for modern cloud APIs. Data engineers should always
be aware of how keys are handled; bad key handling is a significant source of data
leaks. In addition, HTTPS does nothing to protect data if bucket permissions are left
open to the public, another cause of several data scandals over the last decade

Engineers should also be aware of the security limitations of older protocols. For
example, FTP is simply not secure on a public network. While this may not appear
to be a problem when data is already public, FTP is vulnerable to man-in-the-middle
attacks, whereby an attacker intercepts downloaded data and changes it before it
arrives at the client. It is best to simply avoid FTP.


Logging, Monitoring, and Alerting
Here are some areas you should monitor:
Access
Resources disk, CPU, memory, and I/O
Billing Especially with SaaS and cloud-managed services
Excess permissions monitor for permissions that are
not utilized by a user or service account over some tim
 

Network Access
network security should be left to security experts at your company.
Understand
what IPs and ports are open, to whom, and why. Allow the incoming IP addresses of
the systems and users that will access these ports (a.k.a. whitelisting IPs) and avoid
broadly opening connections for any reason. When accessing the cloud or a SaaS
tool, use an encrypted connection. For example, don’t use an unencrypted website
from a coffee shop.