## Question 1
> Perform a WHOIS lookup against the `paypal.com` domain. What is the registrar Internet Assigned Numbers Authority (IANA) ID number?

```shell
whois paypal.com | grep -i "IANA ID"
```

Output:
```text
Registrar IANA ID: 292
```

### Answer : `292`

---
## Question 2
> What is the admin email contact for the `tesla.com` domain (also in-scope for the Tesla bug bounty program)?

```shell
whois tesla.com | grep -i "Admin Email"
```

Output:
```text
Registrant Email: admin@dnstinations.com
```

### Answer : `admin@dnstinations.com`
