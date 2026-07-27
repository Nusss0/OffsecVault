---
tags:
  - Material
  - HTB
  - CPTS
---

# Saving the Results

> Nmap scan results can be saved to disk in multiple formats, allowing later comparison between scanning methods and reuse for documentation and reporting.

---

## Output Formats
> `-oA` saves all three formats at once, using one base name for every file.

```shell
sudo nmap 10.129.2.28 -p- -oA target
```

> [!caution]
> If no full path is given in the base name, files are written to the current working directory. `-oA` does not create missing directories.

The command above produces three files:

```shell
ls
target.gnmap  target.xml  target.nmap
```

---

## Normal Output

> The `.nmap` file is the human-readable format — identical to the on-screen output, with one port per line.

```shell
cat target.nmap
```

---

## Grepable Output

> The `.gnmap` file places one host on a single line, making it easy to filter with line-based tools like `grep`, `cut`, and `awk`.

> [!note]
> One line per host is the whole point — everything about a host sits together, so a single `grep` can pull it out. The format is deprecated; XML is the recommended choice for serious automation.

```shell
cat target.gnmap
```

---

## XML Output

> The `.xml` file is a structured, machine-readable format containing full scan detail. It is the recommended format for automation and for generating reports.

```shell
cat target.xml
```

---

## Style Sheets (HTML Report)

> XML output can be converted into a clean HTML report that is readable even by non-technical people, useful for documentation. The `xsltproc` tool performs the conversion.

```shell
xsltproc target.xml -o target.html
```

> [!note]
> Opening the resulting `target.html` in a browser shows a structured, clear presentation of the scan results.

---

## Related Source
[[Nmap]]