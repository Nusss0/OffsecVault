---
tags:
  - Material
  - Productivity
  - Tools
---
---

> A terminal multiplexer that lets a single terminal window host multiple sessions, windows, and panes, and keeps those sessions alive on the server after the client disconnects.

> [!important]
> This cheatsheet documents a **customised** configuration, not stock tmux. The prefix is rebound to `Ctrl+Space`, splits use `|` and `-`, and copy mode uses vi keys. On a machine without this `.tmux.conf`, the default prefix is `Ctrl+b`.

---

## Prefix

> A key pressed and released before a command key, telling tmux the next keystroke is meant for it rather than the program running inside the pane.

Prefix in this configuration: `Ctrl+Space` — written `⎵` throughout this note.

---

## Sessions

> A session is a collection of windows managed by the tmux server. It persists independently of any terminal attached to it.

```shell
tmux                      # new session, auto-named
tmux new -s htb           # new named session
tmux ls                   # list sessions
tmux attach -t htb        # reattach by name
tmux kill-session -t htb  # destroy one session
tmux kill-server          # destroy all sessions
```

| Key | Action |
| --- | --- |
| `⎵ d` | Detach — session keeps running |
| `⎵ s` | Session picker |
| `⎵ $` | Rename session |

> [!important]
> `exit` closes a pane. When the last pane in the last window exits, the session is destroyed along with anything running in it. `⎵ d` detaches instead, leaving processes running.

---

## Windows

> A window fills the whole session view and contains one or more panes. Equivalent to a tab.

| Key | Action |
| --- | --- |
| `⎵ c` | New window |
| `⎵ n` | Next window |
| `⎵ p` | Previous window |
| `⎵ Tab` | Last used window |
| `⎵ 1`–`9` | Jump to window by number |
| `⎵ ,` | Rename window |
| `⎵ w` | Window picker |
| `⎵ &` | Kill window |

---

## Panes

> A pane is a subdivision of a window, each running its own shell.

| Key | Action |
| --- | --- |
| `⎵ \|` | Split vertically |
| `⎵ -` | Split horizontally |
| `⎵ h` `j` `k` `l` | Move between panes |
| `⎵ H` `J` `K` `L` | Resize (repeatable — hold without re-prefixing) |
| `⎵ z` | Zoom pane to fullscreen, toggle back |
| `⎵ Space` | Cycle preset layouts |
| `⎵ {` `}` | Swap pane left / right |
| `⎵ x` | Kill pane |
| `⎵ !` | Break pane into its own window |

> [!info]
> Mouse mode is enabled: click a pane to focus it, drag a border to resize, scroll to enter copy mode.

---

## Copy Mode

> A mode for scrolling back through pane history and selecting text, navigated with vi keys.

| Key | Action |
| --- | --- |
| `⎵ Esc` | Enter copy mode |
| `k` `j` | Scroll up / down |
| `g` `G` | Top / bottom of history |
| `Ctrl+u` `Ctrl+d` | Page up / down |
| `/` `?` | Search forward / backward |
| `n` `N` | Next / previous match |
| `v` | Begin selection |
| `Ctrl+v` | Toggle block selection |
| `y` | Yank selection and exit |
| `Esc` | Cancel |

> [!caution]
> tmux captures mouse events, so dragging to select no longer copies to the system clipboard. Hold `Shift` while dragging to bypass tmux and use the terminal's native selection.

> [!info]
> Yanking uses `xclip` when a local X display is available. Over SSH it falls back to OSC 52, an escape sequence that asks the terminal emulator to set the clipboard, allowing copy from a remote host back to the local machine.

---

## Configuration

| Key | Action |
| --- | --- |
| `⎵ r` | Reload `~/.tmux.conf` |
| `⎵ ?` | List all keybindings |
| `⎵ t` | Clock |

> [!caution]
> `⎵ r` sources the config but cannot remove bindings that already exist. After changing or deleting a binding, run `tmux kill-server` and start a fresh session.

---