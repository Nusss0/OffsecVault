---
tags:
  - WindowManager
  - Productivity
  - Tools
---
> A tiling window manager for X11 that arranges windows automatically without overlap, controlled entirely by keyboard.

> [!important]
> This note documents a **customised** configuration, not stock i3. Keybindings were chosen to mirror tmux so that motions transfer between layers. On a machine without this config, defaults differ — notably splits (`$mod+v` / `$mod+h`) and focus keys (`$mod+j/k/l/;`).

---

## Modifier

> The prefix key held with every i3 command, set in the config with `set $mod Mod4`.

`$mod` = **Super** (Windows key). Written as `Super` throughout this note.

| Config name | Physical key |
| --- | --- |
| `Mod1` | Alt |
| `Mod4` | Super |
| `Control` | Ctrl |
| `Shift` | Shift |

> [!info]
> `Mod4` is standard for tiling window managers because almost no application claims the Super key. Alt is heavily used by applications and would collide constantly.

---

## Launching and Closing

| Keys | Action |
| --- | --- |
| `Super+Enter` | Open terminal (alacritty) |
| `Super+d` | Application launcher (rofi drun) |
| `Super+Shift+d` | Run a raw command |
| `Super+Tab` | Window switcher |
| `Super+Shift+q` | Close focused window |

---

## Focus

> Moving which window receives input, without changing the layout.

| Keys | Action |
| --- | --- |
| `Super+h` | Focus left |
| `Super+j` | Focus down |
| `Super+k` | Focus up |
| `Super+l` | Focus right |
| `Super+a` | Focus parent container |
| `Super+Space` | Toggle focus between tiled and floating windows |

---

## Moving Windows

> Changing a window's position within the layout tree.

| Keys | Action |
| --- | --- |
| `Super+Shift+h` | Move window left |
| `Super+Shift+j` | Move window down |
| `Super+Shift+k` | Move window up |
| `Super+Shift+l` | Move window right |
| `Super+Shift+1`–`9` | Send window to that workspace |

---

## Resizing

| Keys | Action |
| --- | --- |
| `Super+Ctrl+h` | Shrink width |
| `Super+Ctrl+l` | Grow width |
| `Super+Ctrl+j` | Grow height |
| `Super+Ctrl+k` | Shrink height |

> [!info]
> Dragging a border with the mouse resizes as well. Both methods adjust the same container proportions.

---

## Split Direction

> Sets where the *next* opened window will be placed relative to the focused one.

| Keys | Next window opens |
| --- | --- |
| `Super+\` | To the right |
| `Super+-` | Below |

> [!caution]
> Split direction is set **before** opening the next window, not after. Pressing it with no subsequent window does nothing visible. This is the most common source of confusion when moving from tmux, where a split command creates the pane immediately.

---

## Layout Modes

> How multiple windows inside one container are arranged.

| Keys | Mode |
| --- | --- |
| `Super+e` | Split — side by side or stacked, all visible |
| `Super+w` | Tabbed — one visible, others as tabs along the top |
| `Super+s` | Stacking — one visible, others as titlebars |
| `Super+f` or `Super+z` | Fullscreen toggle |
| `Super+Shift+Space` | Float the window, freely movable |

---

## Workspaces

> Independent virtual screens, each holding its own set of windows.

| Keys | Action |
| --- | --- |
| `Super+1`–`9` | Switch to workspace |
| `Super+Shift+1`–`9` | Move focused window to workspace |
| `Super+Ctrl+Left` / `Right` | Focus the other monitor |
| `Super+Shift+<` / `>` | Move current workspace to the other monitor |
| `Super+p` | Re-apply saved display layout |

---

## Session

| Keys | Action |
| --- | --- |
| `Super+Shift+c` | Reload config |
| `Super+Shift+r` | Restart i3 in place, keeping windows |
| `Super+Shift+e` | Exit i3, returns to login screen |
| `Super+Shift+x` | Lock screen |

> [!caution]
> `Super+Shift+c` reloads the config but cannot remove bindings that already exist. After deleting or changing a binding, use `Super+Shift+r` to restart.

---

## Screenshots

| Keys | Action |
| --- | --- |
| `Super+Shift+s` or `Print` | Select region, copy to clipboard |
| `Super+Print` | Full screen, save to `~/Pictures/screenshots/` |

> [!info]
> These use `maim` rather than `flameshot`. Flameshot routes screenshot requests through `xdg-desktop-portal`, which times out under i3 even in a correct X11 session. `maim` captures X11 directly with no daemon or portal dependency.

---

## Hardware Keys

| Keys | Action |
| --- | --- |
| `XF86AudioRaiseVolume` / `Lower` | Volume via `pactl` |
| `XF86AudioMute` | Mute toggle |
| `XF86MonBrightnessUp` / `Down` | Brightness via `brightnessctl` |

---

## Comparison with tmux

> The keybindings were deliberately aligned so that the same motions apply at both the window and pane level.

| Action | i3 | tmux |
| --- | --- | --- |
| Focus | `Super+hjkl` | `prefix hjkl` |
| Move | `Super+Shift+hjkl` | `prefix {` / `}` |
| Resize | `Super+Ctrl+hjkl` | `prefix HJKL` |
| Fullscreen / zoom | `Super+z` | `prefix z` |
| Split right | `Super+\` | `prefix \|` |
| Split down | `Super+-` | `prefix -` |

> [!note]
> The key difference is timing. In i3 the split keybinding sets a *direction* for the next window. In tmux it creates the pane immediately.

---

## Autostart Components

> Programs launched by i3 at session start, since a window manager provides none of them itself.

| Program | Purpose |
| --- | --- |
| `picom` | Compositor — enables transparency and rounded corners |
| `dunst` | Notification daemon |
| `nm-applet` | Network tray icon, wifi and VPN |
| `polkit-mate-authentication-agent-1` | Privilege escalation prompts |
| `feh --bg-fill` | Sets the wallpaper |
| `xss-lock` | Locks the screen on suspend |
| `polybar` | Status bar |

> [!important]
> The polkit agent is not optional. Without it, `virt-manager` cannot obtain the privileges needed to start a VM, and fails with a permissions error that gives no indication of the real cause.

---