## Tips

Remember that enumeration is an iterative process. After performing our `Nmap` port scans, make sure to perform detailed enumeration against all open ports based on what is running on the discovered ports. Follow the same process as we did with `Nibbles`:

- Enumeration/Scanning with `Nmap` - perform a quick scan for open ports followed by a full port scan
- Web Footprinting - check any identified web ports for running web applications, and any hidden files/directories. Some useful tools for this phase include `whatweb` and `Gobuster`
- If you identify the website URL, you can add it to your '/etc/hosts' file with the IP you get in the question below to load it normally, though this is unnecessary.
- After identifying the technologies in use, use a tool such as `Searchsploit` to find public exploits or search on Google for manual exploitation techniques
- After gaining an initial foothold, use the `Python3 pty` trick to upgrade to a pseudo TTY
- Perform manual and automated enumeration of the file system, looking for misconfigurations, services with known vulnerabilities, and sensitive data in cleartext such as credentials
- Organize this data offline to determine the various ways to escalate privileges to root on this target

There are two ways to gain a foothold—one using `Metasploit` and one via a manual process. Challenge ourselves to work through and gain an understanding of both methods.

There are two ways to escalate privileges to root on the target after obtaining a foothold. Make use of helper scripts such as [LinEnum](https://github.com/rebootuser/LinEnum) and [LinPEAS](https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/tree/master/linPEAS) to assist you. Filter through the information searching for two well-known privilege escalation techniques.

Have fun, never stop learning, and do not forget to `think outside of the box`!

---
This box has the same steps as in previous nibble sections. So let's check with `Gobuster` first :
```shell
gobuster dir -u <Target's IP> -w /usr/share/seclists/Discovery/Web-Content/common.txt 
```

We found some interesting page : 
```shell
admin                (Status: 301) [Size: 314] [--> http://10.129.137.63/admin/]                                                 \u2502
backups              (Status: 301) [Size: 316] [--> http://10.129.137.63/backups/]                                               \u2502
data                 (Status: 301) [Size: 313] [--> http://10.129.137.63/data/]                                                  \u2502
index.php            (Status: 200) [Size: 5485]                                                                                  \u2502
plugins              (Status: 301) [Size: 316] [--> http://10.129.137.63/plugins/]                                               \u2502
robots.txt           (Status: 200) [Size: 32]                                                                                    \u2502
server-status        (Status: 403) [Size: 278]                                                                                   \u2502
sitemap.xml          (Status: 200) [Size: 431]                                                                                   \u2502
theme                (Status: 301) [Size: 314] [--> http://10.129.137.63/theme/] 
```

Let's check for `/data`, we could find some interesting thing `/data/users/admin.xml` :
```shell
$ curl http://10.129.137.63/data/users/admin.xml
<?xml version="1.0" encoding="UTF-8"?>
<item><USR>admin</USR><NAME/><PWD>d033e22ae348aeb5660fc2140aec35850c4da997</PWD><EMAIL>admin@gettingstarted.com</EMAIL><HTMLEDITOR>1</HTMLEDITOR><TIMEZONE/><LANG>en_US</LANG></item>
```

So, the `username` is *admin*, and the `password` is *d033e22ae348aeb5660fc2140aec35850c4da997* (it was a has, the real password is `admin`)
Let's try to get into the admin page and find anything interesting 