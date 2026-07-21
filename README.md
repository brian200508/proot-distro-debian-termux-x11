# DebTX11

```
██▄   ▀██▀  █  █   ▄█   ▄█
█  █   ██    ██ ▒   █▒   █▒
█▄▄▀▒  ██▒  █  █   ▄█▄  ▄█▄ 
 ▒▒▒    ▒▒   ▒  ▒   ▒▒▒  ▒▒▒
```

# Install Proot-Distro debian with XFCE4/Termux X11, Chromium and VSCode

Install Termux Proot-Distro (XFCE4-Desktop) with Termux:x11 support.
For better convenience additionally some developer stuff like [__VSCode__](https://github.com/microsoft/vscode), [__Chromium__](https://github.com/chromium/chromium), Git, Python3 and Node.JS will be installed.

This project is the renamed successor of the shell-script installer it was
forked from, kept as plain shell scripts (no companion Android app).

## Debian

- Install [__Termux__](https://github.com/termux/termux-app/releases) Android app from [__GitHub__](https://github.com/termux).
- Install [__Termux X11__](https://github.com/termux/termux-x11/releases) Android app from [__GitHub__](https://github.com/termux).
- In the terminal clone this repo and run script:
```bash
curl -Lf https://raw.githubusercontent.com/brian200508/debtx11/main/install-x11.sh -o install-x11.sh && chmod +x install-x11.sh && ./install-x11.sh
```

- For Command Line Interface only:
```bash
curl -Lf https://raw.githubusercontent.com/brian200508/debtx11/main/install-cli.sh -o install-cli.sh && chmod +x install-cli.sh && ./install-cli.sh
```

- Restart Termux: run the command below, close Termux App and open Termux App again
```bash
exit
```

## Notes

### Configuration wizard

All configuration decisions (create a user account? username/password,
autostart Termux:X11, autostart Debian, Nord+ bash theme) are gathered right
at the start, before anything is installed. A summary is then shown with a
final prompt:

```
ok            proceed with the install
reconfigure   (default text) go through the questions again
quit          exit without changing anything
```

Once confirmed, the rest of the install runs with no further prompts,
just progress output for each step (pressing Enter alone at the summary
prompt defaults to `ok`). Skipping user account creation falls back to
using the `root` account for the rest of the install. Locale setup
(`en_US.UTF-8` by default) also runs fully non-interactively, so it no
longer pops up the `dpkg-reconfigure locales` dialog.

### Non-interactive / unattended install

Both installers accept optional flags to skip prompts and pacing pauses,
for scripted or repeated installs. With no flags at all, behavior is
unchanged from the fully interactive configuration wizard.

```bash
# Fully unattended: username "debian", no password (passwordless sudo),
# auto-start Termux:X11 and Debian, no confirmations or "press any key" pauses.
./install-x11.sh --yes

# Pick specific options:
./install-x11.sh -u brian -p hunter2 --autostart-x11 --autostart-debian
./install-cli.sh -u brian --no-autostart-debian
```

Available flags:

| Flag | Description |
| --- | --- |
| `-u`, `--user NAME` | Username to create inside Debian. Skips the interactive account setup prompts. |
| `-p`, `--password PASS` | Password for that user (omit for a passwordless/NOPASSWD sudo account). |
| `--autostart-x11` / `--no-autostart-x11` | Auto-start Termux:X11 with Termux, or not (X11 installer only, skips prompt). |
| `--autostart-debian` / `--no-autostart-debian` | Auto-start Debian with Termux, or not (skips prompt). |
| `--bashrc-theme` / `--no-bashrc-theme` | Apply the Nord+ theme to Debian's bash (prompt, `ls`/`grep`/`less` colors), or not (skips prompt). |
| `-y`, `--yes` | Accept all defaults, skip every confirmation and pacing pause (including the configuration summary prompt). Implies `--autostart-x11 --autostart-debian --bashrc-theme` (X11 installer) / `--autostart-debian --bashrc-theme` (CLI-only installer) and username `debian`, unless `-u` is also given. |
| `-h`, `--help` | Show usage and exit. |

Re-running an installer with `--user`/`--yes` is safe: if the account
already exists it is detected and account creation is skipped instead of
failing.

When Debian autostart is enabled, opening a new Termux shell shows a 3
second countdown before Debian launches automatically; press any key
during that window to stay in Termux instead.

### Git config

Don't forget Your Git config:
```bash
git config --global user.name "Your Name"
```
```bash
git config --global user.email "your.email-address@domain.com"
```

### Chromium or VSCode update

After updating Chromium or VSCode You max loose the ```--no-sandbox``` argument in the desktop application links and Chromium or VSCode will start no longer. You can fix the desktop application links by running these commands (__in Proot-Distro__) once:
```bash
curl -Lf https://raw.githubusercontent.com/brian200508/debtx11/main/fix-links-pd.sh -o ~/fix-links-pd.sh && chmod +x ~/fix-links-pd.sh && ~/fix-links-pd.sh
```

And for all further updates:
```bash
~/fix-links-pd.sh
```

### Start XFCE
You also can (re-)start XFCE manually (in Termux - __not in Proot-Distro!!!__) using this script:
```bash
~/startxfce4-pd.sh
```

### Multiple Termux sessions / shells

`startxfce4-pd.sh` is safe to (re-)run from multiple Termux sessions or
tabs at once (e.g. via `.bashrc` autostart on every new shell, or re-tapping a
launcher shortcut). It tracks the running `termux-x11` PID in
`~/.termux-x11.pid`:

- If a session is already alive, the script just refocuses the Termux:X11
  activity and exits -- it no longer kills the running server.
- Only when no live session is tracked does it fall back to cleaning up any
  stale process and starting a fresh Termux:X11 + XFCE4 session.
- The lock file is removed again once XFCE4 itself exits.

This replaces the previous unconditional `kill -9 $(pgrep -f "termux.x11")`
at the top of the script, which used to tear down the whole live XFCE4
session (and every app open inside it) any time the script ran a second time.

### Color scheme

The banner and all script output use a **Nord+** palette -- the
[Nord](https://www.nordtheme.com/) color scheme, tweaked so red (errors) and
green (success) are easier to tell apart at a glance:

| Role | Color | Truecolor |
| --- | --- | --- |
| Errors / prompt accents (`R`) | darkened red | `#A3424C` |
| Success / step headers (`G`) | brightened green | `#94C758` |
| Warnings / highlights (`Y`) | Nord yellow | `#EBCB8B` |
| Banner shadow (`B`) | Nord frost blue | `#5E81AC` |
| Info / secondary text (`C`) | Nord frost cyan | `#88C0D0` |

Requires a truecolor-capable terminal (Termux's terminal and most modern
terminal emulators support this).

### Nord+ theme for Debian's bash

Optionally (enabled by default, toggle with `--bashrc-theme`/
`--no-bashrc-theme` or the configuration wizard), the installers add a
Nord+-colored block to Debian's own `~/.bashrc` (inside proot-distro, not
Termux's):

- Prompt: username (cyan) `@` hostname (blue) `:` working directory (yellow),
  with the trailing `$` colored green after a successful command and red
  after a failed one -- the same readable red/green pairing as the installer
  banners.
- `ls`/`dir` colors, `grep` match/filename/line-number colors, and `less`
  (man page) heading/underline colors, all using the same palette.

Only foreground colors are changed, so it stays readable regardless of your
terminal's background. Re-running an installer with the option disabled
cleanly removes the block again; running it enabled again just skips
re-adding it if already present.
