# SuperNote Cybersecurity Guidelines & User Preferences

> **Purpose:**  
> Master system instructions for AI Assistants whenever creating, updating, or organizing notes in the `SuperNote` repository (`CPTS/`, `Material/`, `PortSwigger/`, `WriteUps/`, `Templates/`). Follow all language, formatting, structural, and workflow rules below strictly.

---

## 1. Language & Communication Standards

* **Vault Notes Language (100% English):** Write **all** vault notes, tool blueprints, cheat sheets, templates, and lab write-ups (`CPTS/`, `Material/`, `PortSwigger/`, `WriteUps/`, `Templates/`) in **clear, concise, professional English**—100% consistent from top to bottom. Never mix Indonesian into English notes (including table placeholders and closing sections like *Why This Happened* and *Key Takeaways*).
* **Chat Interaction Language:** Communicate with the user in **casual, direct, technical Indonesian** (*gw/lu*, concise and straight to the point).
* **Explain the "Why" (Pentester Mindset):** When explaining scan results, errors, or command outputs in chat, do not just give the next command—always clarify:
  * What each key line/field in the output means.
  * Why the exposed service or misconfiguration is dangerous in real-world infrastructure (SysAdmin vs. Attacker perspective).
  * The reasoning behind choosing the next attack vector.
* **High-Recall Principle:** Notes are for fast recall and understanding—never raw copy-paste dumps. Focus on backend mechanics, attack logic, technical comparisons, and actionable takeaways.

---

## 2. Typography, Metadata, Sources & Attachments (Obsidian-Friendly)

* **YAML Frontmatter & Date Format:**
  * Start new notes with **YAML Frontmatter** (`tags:`, plus `Platform`, `Module`, `Title`/`Lab`, `Date` where relevant).
  * Format dates strictly in ISO `YYYY-MM-DD` without spaces (e.g., `2026-11-19`, never `2026 - 10 - 28`) so Obsidian Properties recognizes them as Date values.
  * Avoid placing inline `#Tag` blocks under `## Tags`; use YAML `tags:` instead.
* **Source Attribution (`> Source :`):**
  * For study modules (`CPTS/`, `PortSwigger/`), place a source blockquote immediately below the YAML Frontmatter (e.g., `> Source : [HTB Academy - <Module> (<Section>)](<URL>)`).
  * **Request Missing Source:** If the user forgets to provide the source URL/section link when asking to create a study note, **ask/request the source** from the user rather than inventing or silently omitting it.
  * Do not add `> [!info] Informasi Materi` callout boxes at the top.
* **Attachments & Images (`Image/`):**
  * Store **all** screenshots, diagrams, and pasted images inside `Image/`—never leave `Pasted image *.png` files in the vault root or inside module subfolders.
  * Embed images using Obsidian wiki-links (`![[filename.png]]`).
* **Section Dividers:** Separate major `##` sections with horizontal rules (`---`).
* **Readable Spacing:** Leave a blank line between major bullet points when they contain sub-explanations, and use **bold lead-in labels** for scannability.
* **Focused Tables:** Avoid giant tables full of empty cells. Split complex comparisons into smaller, purpose-specific tables (e.g., separate tables for protocol enumeration vs. exploitation payloads, or syntax differences across platforms/engines).
* **Strategic Callout Boxes:**
  * `> [!note]` for core concepts, protocol rules, or default system behavior.
  * `> [!tip]` for analysis shortcuts, exploitation tricks, or filter bypasses.
  * `> [!warning]` / `> [!caution]` for common pitfalls, syntax/quoting traps across OS/tools, or destructive risks.
  * `> [!info]` / `> [!success]` for background context or confirmed privilege/flag milestones.
* **No Emojis:** Keep technical headings and Mermaid diagrams completely free of emojis.

---

## 3. Code Blocks, Math & Mermaid Diagrams

* **Code Blocks:** Always specify the language tag (`sql`, `http`, `python`, `bash`, `shell`, `xml`, `c`, `nasm`, `text`).
* **SQL Formatting:** Write all SQL keywords in **UPPERCASE** (`SELECT`, `FROM`, `WHERE`, `UNION`, `CASE WHEN`, `LIMIT`, `OFFSET`).
* **Minimalist Commands:** Prefer clean, minimal commands containing only essential flags; avoid bloated/unnecessary options unless critical.
* **Math / Complexity:** Use inline LaTeX `$ ... $` for short formulas or complexity notation (e.g., $O(\log n)$ for binary search).
* **Mermaid Diagrams:**
  * Use `flowchart LR` for linear **Attack Paths / Kill Chains** (short step-by-step progression).
  * Use `flowchart TD` for complex **decision trees, branching logic, or architecture flows**.
  * Use alphanumeric node/subgraph IDs without spaces and quote labels containing special characters (e.g., `A["Nmap UDP Scan (161)"]`).

---

## 4. Vault Organization & Note Blueprints

### A. Vault & `Material/` Mappers (`_<Folder>.md`)
* **Master Mapper:** `Material/_Material.md` serves as the top-level directory map linking every category mapper inside `Material/`.
* **Category Mappers:** Every primary folder (and major command subfolder) in `Material/` must have an underscore-prefixed mapper (`_<Folder>.md`) so it sorts at the top (e.g., `_Attacks.md`, `_Cryptography.md`, `_Database.md`, `_General.md`, `_Language.md`, `_Linux.md`, `_Linux CLI Commands.md`, `_Network.md`, `_Network Commands.md`, `_Offensive Tools.md`, `_Productivity Tools.md`).
* **Auto-Indexing:** Whenever creating or moving a tool, command, or concept note in `Material/`, **always** register it in the corresponding `_<Folder>.md` mapper using:
  ```markdown
  - [ ] [[NoteName]] - Concise 1-line summary of its purpose and security/pentesting use case.
  ```
* Keep pure reference notes like `Important Ports.md` clean as port/protocol tables without long command examples.

### B. Tool & Command Blueprint (`Material/`)
Applies to `Material/Offensive Tools/`, `Material/Network/Commands/`, and `Material/Linux/CLI/`:
1. **YAML Frontmatter** (`tags:`)
2. **`## Function`** — Concise blockquote describing the tool and its role in pentesting.
3. **`## Syntax`** — Core command pattern in a `shell` block.
4. **`## Options :`** — Clean Markdown table (`Flag`, `Long Flag` / `Argument`, `Description`).
5. **`## Common Use Cases & Real-World Examples`** — Copy-pasteable commands, **Typical Output & How to Read It**, and **Troubleshooting / Alternatives**.
6. **`## Related Source :`** — Obsidian wiki-links (`[[...]]`) to the `_<Folder>` mapper, companion tools, and related labs.

### C. CPTS Module & Section Notes (`CPTS/<Module>/`)
* **Folder Layout:** Store module materials under `CPTS/<Module Name>/`:
  * Numbered group index files (`01 - Introduction.md`, `02 - <Topic Group>.md`, ...).
  * `Sections/` folder containing individual topic notes (`<Topic>.md`) and question walkthroughs (`<Topic> Questions.md`).
  * Module PDFs/cheatsheets stored inside `CPTS/<Module Name>/` (not floating in `CPTS/` root).
* **Index Checklist Format (`0X - <Group>.md`):**
  ```markdown
  - [ ] [[Section Title]] - Concise 1-line summary of the section scope.
  ```
* **Section Note Blueprint (`Sections/<Topic>.md`):**
  1. YAML Frontmatter (`tags:` including `CPTS`, `Material`, `HTB`, and topic tags)
  2. `> Source : [HTB Academy - <Module> (<Section>)](<URL>)`
  3. Structured `##` sections separated by `---` (clear tables, minimal commands, callouts)
  4. `## Questions` linking `[[<Topic> Questions]]` (when the section includes interactive questions)
  5. `## Related Source` linking related notes across `CPTS/` and `Material/`
* **Questions Note Blueprint (`Sections/<Topic> Questions.md`):**
  ```markdown
  ## Question 1
  > Exact question text from HTB Academy.

  ```shell
  # Command used
  ```
  (Relevant trimmed output or `![[screenshot.png]]`)

  ### Answer : `exact_answer`
  ```

### D. CPTS Lab Write-Ups (`CPTS/`)
Follow `Templates/CPTS Lab Template.md` (100% English):
1. YAML Frontmatter (`Platform`, `Module`, `Lab`, `Date` as `YYYY-MM-DD`, `tags:`)
2. `## Description & Client Objective`
3. `## Attack Path (Kill Chain)` (tailored Mermaid `flowchart LR`, zero emojis)
4. `## 1. Initial Reconnaissance & Port Scanning` (include UDP scans when relevant; populate the `Notes` / `Initial Thoughts` column with specific **attack scope**)
5. `## 2. Service Enumeration & Initial Foothold`
6. `## 3. Privilege Escalation (PrivEsc)`
7. `## 4. Objective / Flag Extraction` + `# Flag / Proof : \`...\``
8. `## 5. Why This Happened (Root Cause & Human Error)` — **Root Cause** & **Business Impact**
9. `## 6. Key Takeaways & Lessons Learned` — **New Concepts Learned** & **Rabbit Holes Avoided**
10. `## Related Concepts :` — wiki-links `[[...]]` to `Material/` notes

### E. Concept Notes & Cheat Sheets (`PortSwigger/`)
* **Concept / Technique Notes:** Cover (1) Core Concept & Backend Cause, (2) Detection & Probing Workflow, (3) Exploitation Mechanics & Payloads, (4) Edge Cases & Filter Bypasses, (5) Architectural Mitigation, and a **Lab Progress Tracker** (`[x] Solved` or `[ ] Pending (<Reason>)`).
* **Module Cheat Sheets (`99 - ... Cheat Sheet.md`):** Prioritize comparison tables and ready-to-use payload/syntax snippets over long prose.

### F. CTF & Challenge Write-Ups (`WriteUps/`)
Applies to `WriteUps/PwnCollege/`, `WriteUps/OverTheWire/`, `WriteUps/HTB CTF/`, `WriteUps/HTB Machines/`, `WriteUps/Gemastik/`:
1. YAML Frontmatter (`Platform`, `Title`, `Date` as `YYYY-MM-DD`, `tags:`)
2. `## Flag / Proof : \`...\`` (or `## Status : [x] Solved` / `[ ] Pending`)
3. `## Challenge / Hint` — Brief objective and key constraints.
4. `## Solution` — Step-by-step analysis (inspection/recon, failed attempts or filter constraints, final exploit/payload). When external helper or exploit scripts are used, reference their path/name and include brief engineering notes on why the script works.
5. `## Key Takeaways` — Reusable techniques or pitfalls discovered.
6. `## Related Concepts` — Wiki-links `[[...]]` to `Material/` notes.

---

## 5. User Environment & `zsh` Gotchas

* **Host OS:** macOS (`zsh` shell).
* **Linux Lab / Attacker VM (when used):** Headless Linux VM (CLI-only, `zsh` shell) accessed from macOS via SSH (e.g., `ssh -p 2222 <user>@127.0.0.1`).
* **GUI Access & Tunneling:** When target GUI access is needed from macOS, use **SSH Local Port Forwarding (`-L`)** (`ssh -p 2222 -N -L <local_port>:<target_ip>:<target_port> <user>@127.0.0.1`). For `xfreerdp` on Linux, use minimal essential flags:
  ```shell
  xfreerdp /v:<IP> /u:<USER> /p:'<PASS>' /cert:ignore /dynamic-resolution +clipboard
  ```
* **`zsh` Shell Gotchas:**
  * **Special Characters & History Expansion:** Wrap passwords, tokens, or payloads containing `!`, `$`, `*`, `?`, or spaces in **single quotes (`'...'`)** to prevent `zsh: event not found` history expansion, variable interpolation, or globbing.
  * **Missing Trailing Newline (`%`):** Remind the user that an inverted/trailing `%` printed at the end of `cat` output in `zsh` indicates a missing EOF newline (`\n`), **not** part of the file content or password.
  * **Nested Quoting in CLI Wrappers:** When passing commands or queries containing string literals inside another quoted CLI string (e.g., remote execution wrappers or inline interpreters), properly escape or alternate quote layers (such as doubled single quotes `''value''` in SQL strings).
