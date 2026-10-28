---
tags:
  - SetUp
  - Kali-Linux
  - Productivity
  - Bash-Scripts
  - Workflow
---

# Kali Terminal Productivity Setup & Custom Helpers

A collection of custom shell functions and aliases designed to streamline the penetration testing workflow, maintain environment persistence across multiple terminal sessions, and accelerate note-taking into Obsidian.

---

## 1. Complete `.zshrc` Setup Block

Copy and append the entire code block below directly into your Kali Linux shell configuration (`~/.zshrc`):

```bash
# ==============================================================================
# PENTESTING PRODUCTIVITY HELPERS (SuperNote Vault)
# ==============================================================================

# 1. Target IP Persistence Helper
# Usage: setip 10.129.x.x
setip() {
    if [ -z "$1" ]; then
        echo "[-] Usage: setip <TARGET_IP>"
        return 1
    fi
    echo "$1" > ~/.target_ip
    export ip="$1"
    echo "[+] Target IP saved & exported: $ip"
}

# Auto-load target IP on new terminal startup
if [ -f ~/.target_ip ]; then
    export ip=$(cat ~/.target_ip)
fi

# Quick check target IP and connectivity
# Usage: getip
getip() {
    if [ -z "$ip" ]; then
        echo "[-] No target IP currently set. Use 'setip <IP>'."
        return 1
    fi
    echo "[*] Target IP: $ip"
    ping -c 1 -W 2 "$ip" >/dev/null 2>&1 && echo "[+] Host is UP (Ping responsive)" || echo "[-] Host is DOWN or ICMP dropped"
}

# 2. Nmap Output to Obsidian Markdown Table
# Usage: nmap2md scan.txt OR sudo nmap ... | nmap2md
nmap2md() {
    echo "| Port | State | Service | Notes |"
    echo "| :--- | :---: | :--- | :--- |"
    awk '/^[0-9]+\/(tcp|udp)/ {printf "| `%s` | %s | %s | |\n", $1, $2, $3}' "${1:-/dev/stdin}"
}

# 3. Fast Workspace Initializer
# Usage: mklab <lab_name> (Creates structured folder with notes)
mklab() {
    if [ -z "$1" ]; then
        echo "[-] Usage: mklab <lab_name>"
        return 1
    fi
    mkdir -p "$HOME/labs/$1"/{nmap,loot,exploits}
    cd "$HOME/labs/$1" || return
    echo "[+] Workspace initialized at: $PWD"
}

# ==============================================================================
```

---

## 2. Installation Steps

### Step 1: Append to `~/.zshrc`
Run the following one-liner in your Kali terminal:

```bash
cat << 'EOF' >> ~/.zshrc

# --- Pentest Helpers ---
setip() {
    [ -z "$1" ] && { echo "[-] Usage: setip <IP>"; return 1; }
    echo "$1" > ~/.target_ip
    export ip="$1"
    echo "[+] Target IP: $ip"
}
[ -f ~/.target_ip ] && export ip=$(cat ~/.target_ip)

nmap2md() {
    echo "| Port | State | Service | Notes |"
    echo "| :--- | :---: | :--- | :--- |"
    awk '/^[0-9]+\/(tcp|udp)/ {printf "| `%s` | %s | %s | |\n", $1, $2, $3}' "${1:-/dev/stdin}"
}
# -----------------------
EOF
```

### Step 2: Apply the Changes
Reload your shell configuration immediately:
```bash
source ~/.zshrc
```

---

## 3. How to Use

### A. Setting & Using `$ip` Across All Terminals
1. Set the target once in any open terminal:
   ```bash
   setip 10.129.202.41
   ```
2. Open a new terminal tab or window, and verify:
   ```bash
   echo $ip
   # Output: 10.129.202.41
   ```
3. Use `$ip` directly with tools without typing the number:
   ```bash
   sudo nmap -p- --min-rate=5000 $ip -Pn
   crackmapexec smb $ip -u 'alex' -p 'lol123!mD'
   smbclient -L //$ip
   ```

---

### B. Converting Nmap Output to Obsidian Tables
* **Directly while scanning:**
  ```bash
  sudo nmap -p- --min-rate=5000 $ip -Pn | nmap2md
  ```
* **From a saved scan file:**
  ```bash
  nmap2md scan.txt
  ```
* **Copy directly to clipboard (Ready to paste in Obsidian):**
  ```bash
  nmap2md scan.txt | xclip -selection clipboard
  ```

---

## 4. Mac-to-VM SSH Port Forwarding (RDP Bridge)

When running a headless Linux VM and accessing Windows targets with GUI via Mac's **Windows App**:

```bash
# Run on Mac terminal (Port 2222 forwards target port 3389 to local 127.0.0.1:3389):
ssh -p 2222 -N -L 3389:10.129.202.41:3389 nus@127.0.0.1
```
* **`-N`**: Do not execute a remote command / shell (creates quiet tunnel only).
* **Connect in Mac Windows App:** `127.0.0.1:3389`.
