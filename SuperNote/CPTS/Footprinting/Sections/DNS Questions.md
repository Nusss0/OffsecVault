## Question 1 
>Interact with the target DNS using its IP address and enumerate the FQDN of it for the "inlanefreight.htb" domain.

```shell
dig any inlanefreight.htb @$ip
```

### Answer : `ns.inlanefreight.htb`

---
## Question 2
>Identify if its possible to perform a zone transfer and submit the TXT record as the answer. (Format: HTB{...})

```shell
#Perform axlr digging on internal
dig axlr internal.inlanefreight.htb @$ip
```

### Answer : `HTB{DN5_z0N3_7r4N5F3r_iskdufhcnlu34}`

---
## Question 3
>What is the IPv4 address of the hostname DC1?

We could see from the answer on Question 2
### Answer : `10.129.34.16`

---
## Question 4
>What is the FQDN of the host where the last octet ends with "x.x.x.203"?

Do a full bruteforce scan using the word list from [DNSenum](https://github.com/fwaeytens/dnsenum).
### Answer : `win2k.dev.inlanefreight.htb`