## Question 1
>Enumerate the SNMP service and obtain the email address of the admin. Submit it as the answer.

Doing some check on community string, and we got : 
```shell
┌──(nus㉿master)-[/opt/SecLists/Discovery/SNMP]
└─$ onesixtyone -c common-snmp-community-strings-onesixtyone.txt $ip

Scanning 1 hosts, 120 communities
10.129.42.195 [public] Linux NIX02 5.4.0-90-generic #101-Ubuntu SMP Fri Oct 15 20:00:55 UTC 2021 x86_64
10.129.42.195 [public] Linux NIX02 5.4.0-90-generic #101-Ubuntu SMP Fri Oct 15 20:00:55 UTC 2021 x86_64
```

Now we could try to do `snmpwalk` and find the email address using
```shell
snmpwalk -v2c -c public $ip
```
![[Pasted image 20260924165340.png]]

### Answer : `devadmin@inlanefreight.htb`

---
## Question 2
>What is the customized version of the SNMP server?

From question 1, we also obtain the cutomized version

### Answer : `InFreight SNMP v0.91`

---
## Question 3
>Enumerate the custom script that is running on the system and submit its output as the answer.

From the command in `Question 1`, we could also get the flag 
![[Pasted image 20260924165607.png]]
This happens because the server has run the script by its self : 
```shell
iso.3.6.1.2.1.25.1.7.1.2.1.2.4.70.76.65.71 = STRING: "/usr/share/flag.sh"
```

### Answer : `HTB{5nMp_fl4g_uidhfljnsldiuhbfsdij44738b2u763g}`

