---
tags:
  - HTB
  - Material
  - CPTS
  - Networking
---
>The use of cloud, such as [AWS](https://aws.amazon.com/), [GCP](https://cloud.google.com/), [Azure](https://azure.microsoft.com/en-us/), and others, is now one of the essential components for many companies nowadays. After all, all companies want to be able to do their work from anywhere, so they need a central point for all management.


> [!important]- Cloud Security
> Even though cloud providers secure their infrastructure centrally, this does not mean that companies are free from vulnerabilities. The configurations made by the administrators may nevertheless make the company's cloud resources vulnerable. This often starts with the `S3 buckets` (AWS), `blobs` (Azure), `cloud storage` (GCP), which can be accessed without authentication if configured incorrectly.

---
## Company Hosted Servers
>Often cloud storage is added to the DNS list when used for administrative purposes by other employees. This step makes it much easier for the employees to reach and manage them.

However, there are many different ways to find such cloud storage. One of the easiest and most used is Google search combined with Google Dorks. For example, we can use the Google Dorks `inurl:` and `intext:` to narrow our search to specific terms. In the following example, we see red censored areas containing the company name.

![[Pasted image 20260815155327.png]]

![[Pasted image 20260815155317.png]]

Here we can see that the links presented by Google contain PDFs. Such content is also often included in the source code of the web pages, from where the image, JavaScript codes, or CSS are loaded. This procedure often relieves the web server and does not store unnecessary content.

---
## Target Website - Source Code
> Third-party providers such as [domain.glass](https://domain.glass/) can also tell us a lot about the company's infrastructure. As a positive side effect, we can also see that Cloudflare's security assessment status has been classified as "Safe". This means we have already found a security measure that can be noted for the second layer (gateway).

![[Pasted image 20260815155841.png]]

Another very useful provider is [GrayHatWarfare](https://buckets.grayhatwarfare.com/). We can do many different searches, discover AWS, Azure, and GCP cloud storage, and even sort and filter by file format. Therefore, once we have found them through Google, we can also search for them on GrayHatWarefare and passively discover what files are stored on the given cloud storage.

![[Pasted image 20260815155925.png]]

> [!NOTE]- Abbreviation
> Many companies also use abbreviations of the company name, which are then used accordingly within the IT infrastructure. Such terms are also part of an excellent approach to discovering new cloud storage from the company. We can also search for files simultaneously to see the files that can be accessed at the same time.

---
## Private and Public SSH Keys Leaked
>Sometimes when employees are overworked or under high pressure, mistakes can be fatal for the entire company. These errors can even lead to SSH private keys being leaked, which anyone can download and log onto one or even more machines in the company without using a password.

![[Pasted image 20260815160139.png]]


