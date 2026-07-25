---
tags:
  - CPTS
  - HTB
  - Material
  - Networking
  - Shell
---
> Initial access to a remote server is usually in the context of a low-privileged user, which does not give complete access over the box. To gain full access, we need to find an internal/local vulnerability that escalates our privileges to the root user on Linux or the administrator/SYSTEM user on Windows.

---

## PrivEsc Checklists

> Once we gain initial access to a box, we thoroughly enumerate it to find any potential vulnerabilities we can exploit to achieve a higher privilege level.

Checklists and cheat sheets with a collection of checks and the commands to run them can be found online.

- HackTricks — checklist for both Linux and Windows local privilege escalation
- PayloadsAllTheThings — checklists for both Linux and Windows

---

## Enumeration Scripts

> Many enumeration commands can be run automatically with a script that goes through the output and looks for any weaknesses.

Common Linux enumeration scripts:

- LinEnum
- linuxprivchecker

Common Windows enumeration scripts:

- Seatbelt
- JAWS

> Privilege Escalation Awesome Scripts SUITE (PEASS) — well maintained, up to date, includes scripts for enumerating both Linux and Windows.

> [!warning] These scripts run many commands known for identifying vulnerabilities and create a lot of "noise" that may trigger anti-virus software or security monitoring software. This may prevent the scripts from running or trigger an alarm that the system has been compromised. In some instances, we may want to do a manual enumeration instead of running scripts.

Example — running the Linux PEASS script LinPEAS:

```shell
./linpeas.sh
...SNIP...

Linux Privesc Checklist: https://book.hacktricks.xyz/linux-unix/linux-privilege-escalation-checklist
 LEYEND:
  RED/YELLOW: 99% a PE vector
  RED: You must take a look at it
  LightCyan: Users with console
  Blue: Users without console & mounted devs
  Green: Common things (users, groups, SUID/SGID, mounts, .sh scripts, cronjobs)
  LightMangenta: Your username


====================================( Basic information )=====================================
OS: Linux version 3.9.0-73-generic
User & Groups: uid=33(www-data) gid=33(www-data) groups=33(www-data)
...SNIP...
```

Once the script runs, it collects information and displays it in a report.

---

## Kernel Exploits

> Whenever we encounter a server running an old operating system, we should start by looking for potential kernel vulnerabilities. If the server is not maintained with the latest updates and patches, it is likely vulnerable to specific kernel exploits found on unpatched versions of Linux and Windows.

For example, the script above showed the Linux version as `3.9.0-73-generic`. Searching for exploits for this version (via Google or `searchsploit`) reveals CVE-2016-5195, known as DirtyCow. The DirtyCow exploit can be downloaded and run on the server to gain root access.

The same concept applies to Windows, which has many vulnerabilities in unpatched/older versions that can be used for privilege escalation.

> [!caution] Kernel exploits can cause system instability. Take great care before running them on production systems. It is best to try them in a lab environment and only run them on production systems with explicit approval and coordination with the client.

---

## Vulnerable Software

> Another thing to look for is installed software.

- Linux: use `dpkg -l` to see installed software
- Windows: look at `C:\Program Files`

Look for public exploits for any installed software, especially older versions containing unpatched vulnerabilities.

---

## User Privileges

> Another critical aspect to look for after gaining access to a server is the privileges available to the user we have access to. If we are allowed to run specific commands as root (or as another user), we may be able to escalate our privileges or gain access as a different user.

Common ways to exploit certain user privileges:

- Sudo
- SUID
- Windows Token Privileges

> [!info] sudo The `sudo` command in Linux allows a user to execute commands as a different user. It is usually used to allow lower privileged users to execute commands as root without giving them access to the root user. This is generally done as specific commands can only be run as root (like `tcpdump`) or to allow the user to access certain root-only directories.

Check sudo privileges with `sudo -l`:

```shell
sudo -l

[sudo] password for user1:
...SNIP...

User user1 may run the following commands on ExampleServer:
    (ALL : ALL) ALL
```

The output above says we can run all commands with sudo, which gives complete access. We can use `su` with sudo to switch to the root user:

```shell
sudo su -

[sudo] password for user1:
whoami
root
```

The command above requires a password. On certain occasions we may be allowed to execute certain applications, or all applications, without providing a password:

```shell
sudo -l

    (user : user) NOPASSWD: /bin/echo
```

> [!info] NOPASSWD The `NOPASSWD` entry shows that the `/bin/echo` command can be executed without a password. This is useful if we gained access through a vulnerability and did not have the user's password.

As it says `user`, we can run sudo as that user (not as root) by specifying the user with `-u user`:

```shell
sudo -u user /bin/echo Hello World!

    Hello World!
```

Once we find an application we can run with sudo, we can look for ways to exploit it to get a shell as the root user.

- GTFOBins — a list of commands and how they can be exploited through sudo. Search for the application we have sudo privilege over; if it exists, it may tell us the exact command to execute to gain root access.
- LOLBAS — a list of Windows applications we may be able to leverage to perform certain functions, like downloading files or executing commands in the context of a privileged user.

---

## Scheduled Tasks

> In both Linux and Windows, there are methods to have scripts run at specific intervals to carry out a task. Some examples are an anti-virus scan running every hour or a backup script that runs every 30 minutes.

Two ways to take advantage of scheduled tasks (Windows) or cron jobs (Linux) to escalate privileges:

- Add new scheduled tasks/cron jobs
- Trick them into executing malicious software

The easiest way is to check if we are allowed to add new scheduled tasks. In Linux, a common form of maintaining scheduled tasks is through Cron Jobs. Specific directories may be utilized to add new cron jobs if we have write permissions over them:

- `/etc/crontab`
- `/etc/cron.d`
- `/var/spool/cron/crontabs/root`

If we can write to a directory called by a cron job, we can write a bash script with a reverse shell command, which should send us a reverse shell when executed.

---

## Exposed Credentials

> Next, we can look for files we can read and see if they contain any exposed credentials. This is very common with configuration files, log files, and user history files (`bash_history` in Linux and PSReadLine in Windows).

The enumeration scripts discussed earlier usually look for potential passwords in files and provide them:

```shell
...SNIP...
[+] Searching passwords in config PHP files
[+] Finding passwords inside logs (limit 70)
...SNIP...
/var/www/html/config.php: $conn = new mysqli(localhost, 'db_user', 'password123');
```

The database password `password123` is exposed, which would allow us to log in to the local mysql databases and look for interesting information.

> [!info] Password Reuse We may also check for Password Reuse, as the system user may have used their password for the databases, which may allow us to use the same password to switch to that user.

```shell
su -

Password: password123
whoami

root
```

We may also use the user credentials to ssh into the server as that user.

---

## SSH Keys

> If we have read access over the `.ssh` directory for a specific user, we may read their private ssh keys found in `/home/user/.ssh/id_rsa` or `/root/.ssh/id_rsa`, and use it to log in to the server.

If we can read the `/root/.ssh/` directory and read the `id_rsa` file, we can copy it to our machine and use the `-i` flag to log in with it:

```shell
vim id_rsa
chmod 600 id_rsa
ssh root@10.10.10.10 -i id_rsa

root@10.10.10.10#
```

> [!important] We used `chmod 600 id_rsa` on the key after creating it on our machine to change the file's permissions to be more restrictive. If ssh keys have lax permissions (i.e., maybe read by other people), the ssh server would prevent them from working.

If we find ourselves with write access to a user's `.ssh/` directory, we can place our public key in the user's ssh directory at `/home/user/.ssh/authorized_keys`. This technique is usually used to gain ssh access after gaining a shell as that user.

> [!important] The current SSH configuration will not accept keys written by other users, so it will only work if we have already gained control over that user.

We must first create a new key with `ssh-keygen` and the `-f` flag to specify the output file:

```shell
ssh-keygen -f key

Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): *******
Enter same passphrase again: *******

Your identification has been saved in key
Your public key has been saved in key.pub
The key fingerprint is:
SHA256:...SNIP... user@parrot
The key's randomart image is:
+---[RSA 3072]----+
|   ..o.++.+      |
...SNIP...
|     . ..oo+.    |
+----[SHA256]-----+
```

This gives two files: `key` (used with `ssh -i`) and `key.pub` (copied to the remote machine). Copy `key.pub`, then on the remote machine add it into `/root/.ssh/authorized_keys`:

```shell
echo "ssh-rsa AAAAB...SNIP...M= user@parrot" >> /root/.ssh/authorized_keys
```

Now the remote server should allow us to log in as that user using our private key:

```shell
ssh root@10.10.10.10 -i key

root@remotehost#
```

We can now ssh in as the user root.

---

## Related Source