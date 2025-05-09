
# Install Proot-Distro debian with XFCE4/Termux X11, Chromium and VSCode

Install Termux Proot-Distro (XFCE4-Desktop) with Termux:x11 support.
For better convenience additionally some developer stuff like [__VSCode__](https://github.com/microsoft/vscode), [__Chromium__](https://github.com/chromium/chromium), Git, Python3 and Node.JS will be installed.

## Debian

- Install [__Termux__](https://github.com/termux/termux-app/releases) Android app from [__GitHub__](https://github.com/termux).
- Install [__Termux X11__](https://github.com/termux/termux-x11/releases) Android app from [__GitHub__](https://github.com/termux).
- In the terminal clone this repo and run script:
  - Debian:
```bash
curl -Lf https://raw.githubusercontent.com/brian200508/proot-distro-debian-termux-x11/main/install-debian.sh -o install-debian.sh && chmod +x install-debian.sh && ./install-debian.sh
```
  - Ubuntu:
```bash
curl -Lf https://raw.githubusercontent.com/brian200508/proot-distro-debian-termux-x11/main/install-ubuntu.sh -o install-ubuntu.sh && chmod +x install-ubuntu.sh && ./install-ubuntu.sh
```

- Restart Termux: run the command below, close Termux App and open Termux App again
```bash
exit
```

## Notes

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
curl -Lf https://raw.githubusercontent.com/brian200508/proot-distro-debian-termux-x11/main/fix-desktop-links.sh -o ~/fix-desktop-links.sh && chmod +x ~/fix-desktop-links.sh && ~/fix-desktop-links.sh
```

And for all further updates:
```bash
~/fix-desktop-links.sh
```

### Start XFCE
You also can (re-)start XFCE manually (in Termux - __not in Proot-Distro!!!__) using this script:
```bash
~/startxfce4_debian.sh
```
