#!/bin/bash

# Nord+ palette (Nord, with red darkened / green brightened for contrast)
R="$(printf '\033[38;2;163;66;76m')"
G="$(printf '\033[38;2;148;199;88m')"
Y="$(printf '\033[38;2;235;203;139m')"
B="$(printf '\033[38;2;94;129;172m')"
C="$(printf '\033[38;2;136;192;208m')"
W="$(printf '\033[0m')"
BOLD="$(printf '\033[1m')"

# --- Non-interactive options -------------------------------------------
# All of these are optional: run the script with no flags at all to get
# the original fully-interactive wizard, unchanged.
ASSUME_YES=0
CLI_USER=""
CLI_PASSWORD=""
CLI_AUTOSTART_X11=""     # "y" / "n" / "" (unset -> ask interactively)
CLI_AUTOSTART_DEBIAN=""  # "y" / "n" / "" (unset -> ask interactively)
CLI_BASHRC_THEME=""      # "y" / "n" / "" (unset -> ask interactively)

# Decisions gathered by configure_wizard() (see below), applied later.
CFG_CREATE_USER=""
CFG_USERNAME=""
CFG_PASS_TYPE=""
CFG_PASSWORD=""
CFG_AUTOSTART_X11=""
CFG_AUTOSTART_DEBIAN=""
CFG_BASHRC_THEME=""

print_usage() {
    cat <<EOF
Usage: ./install-x11.sh [options]

  -u, --user NAME            Username to create inside Debian. Skips the
                              interactive account setup prompts.
  -p, --password PASS        Password for that user (omit for a
                              passwordless/NOPASSWD sudo account).
      --autostart-x11        Auto-start Termux:X11 with Termux (skips prompt).
      --no-autostart-x11     Do not auto-start Termux:X11 (skips prompt).
      --autostart-debian     Auto-start Debian with Termux (skips prompt).
      --no-autostart-debian  Do not auto-start Debian (skips prompt).
      --bashrc-theme         Apply the Nord+ theme to Debian's bash prompt,
                              ls/grep/less colors (skips prompt).
      --no-bashrc-theme      Do not apply the Nord+ bash theme (skips prompt).
  -y, --yes                  Accept all defaults, skip every confirmation
                              and pacing pause (fully unattended install).
                              Implies --autostart-x11 --autostart-debian
                              --bashrc-theme and username "debian" unless
                              -u is also given.
  -h, --help                 Show this help and exit.

Examples:
  ./install-x11.sh --yes
  ./install-x11.sh -u brian -p hunter2 --autostart-x11 --autostart-debian
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--user) CLI_USER="$2"; shift 2 ;;
        --user=*) CLI_USER="${1#*=}"; shift ;;
        -p|--password) CLI_PASSWORD="$2"; shift 2 ;;
        --password=*) CLI_PASSWORD="${1#*=}"; shift ;;
        --autostart-x11) CLI_AUTOSTART_X11="y"; shift ;;
        --no-autostart-x11) CLI_AUTOSTART_X11="n"; shift ;;
        --autostart-debian) CLI_AUTOSTART_DEBIAN="y"; shift ;;
        --no-autostart-debian) CLI_AUTOSTART_DEBIAN="n"; shift ;;
        --bashrc-theme) CLI_BASHRC_THEME="y"; shift ;;
        --no-bashrc-theme) CLI_BASHRC_THEME="n"; shift ;;
        -y|--yes) ASSUME_YES=1; shift ;;
        -h|--help) print_usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; print_usage; exit 1 ;;
    esac
done

if [[ "$ASSUME_YES" == "1" ]]; then
    CLI_USER="${CLI_USER:-debian}"
    CLI_AUTOSTART_X11="${CLI_AUTOSTART_X11:-y}"
    CLI_AUTOSTART_DEBIAN="${CLI_AUTOSTART_DEBIAN:-y}"
    CLI_BASHRC_THEME="${CLI_BASHRC_THEME:-y}"
fi
# -------------------------------------------------------------------------

function banner() {
clear
echo "${Y}██▄   ▀██▀  █  █   ▄█   ▄█${W}"
echo "${Y}█  █   ██    ██ ${W}${B}▒${W}${Y}   █${W}${B}▒${W}${Y}   █${W}${B}▒${W}"
echo "${Y}█▄▄▀${W}${B}▒${W}${Y}  ██${W}${B}▒${W}${Y}  █  █   ▄█▄  ▄█▄ ${W}"
echo "${B} ▒▒▒    ▒▒   ▒  ▒   ▒▒▒  ▒▒▒${W}"
echo
echo "${C}${BOLD} Install Proot-Distro Debian"${W}
echo "${C}${BOLD} with XFCE4/Termux X11 in Termux"${W}
echo
}

function confirmation_y_or_n() {
	 local __resultvar="$2" preset="$3"
	 if [[ -n "$preset" ]]; then
	     eval "$__resultvar='$preset'"
	     echo "${R}[${W}-${R}]${G}Using answer: $preset (from flags)"${W}
	     return
	 fi
	 if [[ "$ASSUME_YES" == "1" ]]; then
	     eval "$__resultvar='y'"
	     echo "${R}[${W}-${R}]${G}Using answer: y (--yes)"${W}
	     return
	 fi
	 while true; do
        read -p "${R}[${W}-${R}]${Y}${BOLD} $1 ${Y}(y/n) "${W} response
        response="${response:-y}"
        eval "$2='$response'"
        case $response in
            [yY]* )
                echo "${R}[${W}-${R}]${G}Continuing with answer: $response"${W}
				sleep 0.2
                break;;
            [nN]* )
                echo "${R}[${W}-${R}]${C}Skipping this setp"${W}
				sleep 0.2
                break;;
            * )
               	echo "${R}[${W}-${R}]${R}Invalid input. Please enter 'y' or 'n'."${W}
                ;;
        esac
    done

}

function wait_for_key() {
  if [[ "$ASSUME_YES" == "1" ]]; then
    return
  fi
  echo "${C}Press any key to continue"${W}
  while [ true ] ; do
    read -t 3 -n 1
    if [ $? = 0 ] ; then
      break ;
    fi
  done
}

function setup_tx11autostart() {
    #if [[ "$zsh_answer" == "y" ]]; then
    #    rc_file=~/.zshrc
    #else
        rc_file=~/.bashrc
    #fi
    if [[ "$CFG_AUTOSTART_X11" == "y" ]]; then
        # check if already configured
        if grep -q "# Start Termux:X11" $rc_file; then
            echo "Termux:X11 start already appended"
        else
            echo '# Start Termux:X11' >> $rc_file
            #echo 'if [ $( ps aux | grep -c "termux.x11" ) -gt 1 ]; then echo "X server is already running." ; else startxfce4-pd.sh ; fi' >> $rc_file
            echo '~/startxfce4-pd.sh &' >> $rc_file
            echo '# End Termux:X11' >> $rc_file
            echo "Termux:X11 start add to $rc_file"
        fi
    else
        # check if already configured
        if grep -q "# Start Termux:X11" $rc_file; then
            sed -i "/# Start Termux:X11/,/# End Termux:X11/d" $rc_file
            echo "Termux:X11 start removed from $rc_file"
        fi
    fi
}

function setup_debautostart() {
    #if [[ "$zsh_answer" == "y" ]]; then
    #    rc_file=~/.zshrc
    #else
        rc_file=~/.bashrc
    #fi
    if [[ "$CFG_AUTOSTART_DEBIAN" == "y" ]]; then
        # check if already configured
        if grep -q "# Start Debian" $rc_file; then
            echo "Debian start already appended"
        else
            # 3 second interruptible countdown: pressing any key stays in
            # Termux, otherwise Debian is auto-started after the timeout.
            echo '# Start Debian' >> $rc_file
            echo 'if [ -t 0 ]; then' >> $rc_file
            echo '    echo -n "Starting Debian in 3s (press any key to stay in Termux)... "' >> $rc_file
            echo '    if read -r -t 3 -n 1 -s; then' >> $rc_file
            echo '        echo' >> $rc_file
            echo '        echo "Staying in Termux."' >> $rc_file
            echo '    else' >> $rc_file
            echo '        echo' >> $rc_file
            echo '        ~/startpd.sh' >> $rc_file
            echo '    fi' >> $rc_file
            echo 'fi' >> $rc_file
            echo '# End Debian' >> $rc_file
            echo "Debian start add to $rc_file"
        fi
    else
        # check if already configured
        if grep -q "# Start Debian" $rc_file; then
            sed -i "/# Start Debian/,/# End Debian/d" $rc_file
            echo "Debian start removed from $rc_file"
        fi
    fi
}

function setup_bashrc_theme() {
    # This edits ~/.bashrc *inside* the Debian proot, not Termux's -- so it
    # has to go through `proot-distro login`, unlike the two functions above.
    if proot-distro login debian --user "$user_name" -- bash -c 'grep -q "# Start Nord+ theme" ~/.bashrc 2>/dev/null'; then
        already_themed="y"
    else
        already_themed="n"
    fi
    if [[ "$CFG_BASHRC_THEME" == "y" ]]; then
        if [[ "$already_themed" == "y" ]]; then
            echo "Nord+ bash theme already applied"
        else
            cat > "${TMPDIR:-$HOME}/nordplus-bashrc-block.sh" <<'EOF'
# Start Nord+ theme
# Prompt: user (cyan) @ host (blue) : cwd (yellow), prompt symbol green on
# success / red on failure -- same readable red/green pairing as the
# installer banners.
__nordplus_prompt_symbol() {
    local status=$?
    if [ $status -eq 0 ]; then
        printf '\[\e[38;2;148;199;88m\]\$\[\e[0m\]'
    else
        printf '\[\e[38;2;163;66;76m\]\$\[\e[0m\]'
    fi
}
PS1='\[\e[38;2;136;192;208m\]\u\[\e[0m\]@\[\e[38;2;94;129;172m\]\h\[\e[0m\]:\[\e[38;2;235;203;139m\]\w\[\e[0m\] $(__nordplus_prompt_symbol) '

# ls / dir colors (dark-background Nord palette).
export LS_COLORS="rs=0:di=1;38;2;94;129;172:ln=1;38;2;136;192;208:mh=00:pi=40;38;2;235;203;139:so=1;38;2;180;142;173:do=1;38;2;180;142;173:bd=40;38;2;235;203;139;01:cd=40;38;2;235;203;139;01:or=40;38;2;163;66;76;01:mi=00:su=0;38;2;236;239;244;41;38;2;163;66;76:sg=0;38;2;46;52;64;43;38;2;235;203;139:ca=30;41:tw=0;38;2;236;239;244;42;38;2;94;129;172:ow=0;38;2;236;239;244;43;38;2;94;129;172:st=0;38;2;236;239;244;44;38;2;94;129;172:ex=1;38;2;148;199;88:*.tar=1;38;2;191;97;106:*.gz=1;38;2;191;97;106:*.zip=1;38;2;191;97;106:*.deb=1;38;2;191;97;106:*.jpg=1;38;2;180;142;173:*.png=1;38;2;180;142;173:*.mp4=1;38;2;180;142;173:*.md=1;38;2;235;203;139:*.sh=1;38;2;148;199;88"

# grep: yellow match highlight, cyan filename, green line number.
export GREP_COLORS='sl=0:cx=0:mt=1;38;2;235;203;139:fn=1;38;2;136;192;208:ln=1;38;2;148;199;88:se=0'

# man pages via less: soft frost-blue headings/underline instead of the
# harsh reverse-video/blink defaults.
export LESS_TERMCAP_md=$'\e[1;38;2;136;192;208m'
export LESS_TERMCAP_us=$'\e[4;38;2;94;129;172m'
export LESS_TERMCAP_so=$'\e[38;2;46;52;64;48;2;235;203;139m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
# End Nord+ theme
EOF
            proot-distro login debian --user "$user_name" -- bash -c 'cat >> ~/.bashrc' < "${TMPDIR:-$HOME}/nordplus-bashrc-block.sh"
            rm -f "${TMPDIR:-$HOME}/nordplus-bashrc-block.sh"
            echo "Nord+ bash theme added to Debian's ~/.bashrc"
        fi
    else
        if [[ "$already_themed" == "y" ]]; then
            proot-distro login debian --user "$user_name" -- sed -i "/# Start Nord+ theme/,/# End Nord+ theme/d" ~/.bashrc
            echo "Nord+ bash theme removed from Debian's ~/.bashrc"
        fi
    fi
}

function configure_user() {
    if [[ -n "$CLI_USER" ]]; then
        CFG_CREATE_USER="y"
        CFG_USERNAME="$(echo "$CLI_USER" | tr '[:upper:]' '[:lower:]')"
        if [[ -n "$CLI_PASSWORD" ]]; then
            CFG_PASS_TYPE=2
            CFG_PASSWORD="$CLI_PASSWORD"
        else
            CFG_PASS_TYPE=1
            CFG_PASSWORD=""
        fi
        echo "${R}[${W}-${R}]${G}Using username ${C}$CFG_USERNAME${G} from --user flag"${W}
        return
    fi

    confirmation_y_or_n "Do you want to create a normal user account ${C}(Recomended)" CFG_CREATE_USER
    echo
    if [[ "$CFG_CREATE_USER" == "n" ]]; then
        echo "${R}[${W}-${R}]${G}Skiping User Account Setup"${W}
        return
    fi

    echo "${R}[${W}-${R}]${G}${BOLD} Select user account type"${W}
    echo
    echo "${Y}1. User with no password confirmation"${W}
    echo
    echo "${Y}2. User with password confirmation"${W}
    echo 
    while true; do
        read -p "${Y}select an option (Default 1): "${W} CFG_PASS_TYPE
        CFG_PASS_TYPE=${CFG_PASS_TYPE:-1}
        if [[ "$CFG_PASS_TYPE" == "1" || "$CFG_PASS_TYPE" == "2" ]]; then
            break
        fi
        echo "${R}Invalid input. Please enter '1' or '2'."${W}
    done
    echo
    echo "${R}[${W}-${R}]${G}Continuing with answer: $CFG_PASS_TYPE"${W}
    echo
    sleep 0.2
    if [[ "$CFG_PASS_TYPE" == "1" ]]; then
        CFG_PASSWORD=""
        while true; do
            read -p "${R}[${W}-${R}]${G}Input username [Lowercase]: "${W} CFG_USERNAME
            echo
            read -p "${R}[${W}-${R}]${Y}Do you want to continue with username ${C}$CFG_USERNAME ${Y}? (y/n) : "${W} choice
            echo
            choice="${choice:-y}"
            echo
            echo "${R}[${W}-${R}]${G}Continuing with answer: $choice"${W}
            sleep 0.2
            case $choice in
                [yY]* )
                    echo "${R}[${W}-${R}]${G}Continuing with username ${C}$CFG_USERNAME "${W}
                    break;;
                [nN]* )
                     echo "${G}Please provide username again."${W}
                    echo
                    ;;
                * )
                    echo "${R}Invalid input. Please enter 'y' or 'n'."${W}
                    ;;
            esac
        done
    elif [[ "$CFG_PASS_TYPE" == "2" ]]; then
        echo
        echo "${R}[${W}-${R}]${G}${BOLD} Create user account"${W}
        echo
        while true; do
            read -p "${R}[${W}-${R}]${G}Input username [Lowercase]: "${W} CFG_USERNAME
            echo
            read -p "${R}[${W}-${R}]${G}Input Password: "${W} CFG_PASSWORD
            echo
            read -p "${R}[${W}-${R}]${Y}Do you want to continue with username ${C}$CFG_USERNAME ${Y}and password ${C}$CFG_PASSWORD${Y} ? (y/n) : "${W} choice
            echo
            choice="${choice:-y}"
            echo
            echo "${R}[${W}-${R}]${G}Continuing with answer: $choice"${W}
            echo ""
            sleep 0.2
            case $choice in
                [yY]* )
                    echo "${R}[${W}-${R}]${G}Continuing with username ${C}$CFG_USERNAME ${G}and password ${C}$CFG_PASSWORD"${W}
                    break;;
                [nN]* )
                     echo "${G}Please provide username and password again."${W}
                    echo
                    ;;
                * )
                    echo "${R}Invalid input. Please enter 'y' or 'n'."${W}
                    ;;
            esac
        done
    fi
}

function configure_wizard() {
    while true; do
        banner
        echo "${G}${BOLD} Configuration${W}"
        echo

        configure_user
        echo
        confirmation_y_or_n "Do you want to start Termux X11 automatically with Termux?" CFG_AUTOSTART_X11 "$CLI_AUTOSTART_X11"
        confirmation_y_or_n "Do you want to start Debian automatically with Termux?" CFG_AUTOSTART_DEBIAN "$CLI_AUTOSTART_DEBIAN"
        confirmation_y_or_n "Do you want to apply the Nord+ color theme to Debian's bash (prompt/ls/grep/less)?" CFG_BASHRC_THEME "$CLI_BASHRC_THEME"

        banner
        echo "${G}${BOLD} Configuration summary${W}"
        echo
        if [[ "$CFG_CREATE_USER" == "y" ]]; then
            echo "${Y}User account:         ${C}$CFG_USERNAME"${W}
            if [[ "$CFG_PASS_TYPE" == "2" ]]; then
                echo "${Y}Password:             ${C}set"${W}
            else
                echo "${Y}Password:             ${C}none (passwordless sudo)"${W}
            fi
        else
            echo "${Y}User account:         ${C}skipped"${W}
        fi
        echo "${Y}Termux:X11 autostart: ${C}$CFG_AUTOSTART_X11"${W}
        echo "${Y}Debian autostart:     ${C}$CFG_AUTOSTART_DEBIAN"${W}
        echo "${Y}Nord+ bash theme:     ${C}$CFG_BASHRC_THEME"${W}
        echo

        if [[ "$ASSUME_YES" == "1" ]]; then
            echo "${R}[${W}-${R}]${G}Using answer: ok (--yes)"${W}
            break
        fi

        read -p "${R}[${W}-${R}]${Y}${BOLD} Proceed with this configuration? ${Y}(ok/reconfigure/quit) [ok] "${W} cfg_choice
        cfg_choice="${cfg_choice:-ok}"
        case "$cfg_choice" in
            [oO][kK]* )
                break ;;
            [qQ]* )
                echo "${R}Aborted by user."${W}
                exit 0 ;;
            * )
                echo "${C}Restarting configuration...${W}"
                sleep 0.5
                ;;
        esac
    done

    # All decisions are made: proceed unattended from here on. This also
    # makes wait_for_key a no-op for the rest of the install.
    ASSUME_YES=1
}

function setup_user() {
    banner
    echo "${G}${BOLD} Setting up User account..."${W}
    proot-distro login debian -- apt update -y
    proot-distro login debian -- apt install -y sudo nano adduser
    if [[ "$CFG_CREATE_USER" != "y" ]]; then
        user_name="root"
        echo "${R}[${W}-${R}]${G}Skiping User Account Setup -- using ${C}root${G} for the rest of the install"${W}
        return
    fi
    user_name="$CFG_USERNAME"
    pd_pass_type="$CFG_PASS_TYPE"
    pass="$CFG_PASSWORD"

    echo "${G}${BOLD} Setting up User $user_name..."${W}
    if proot-distro login debian -- id -u "$user_name" >/dev/null 2>&1; then
        echo "${R}[${W}-${R}]${C}User $user_name already exists -- skipping adduser"${W}
        return
    fi
    # Fully non-interactive account creation: the configuration decisions
    # were already gathered up-front, so nothing here should prompt.
    proot-distro login debian -- adduser --disabled-password --gecos '' $user_name
    if [[ "$pd_pass_type" == "2" ]]; then
        proot-distro login debian -- bash -c "echo '$user_name:$pass' | chpasswd"
    else
        proot-distro login debian -- passwd -d $user_name
    fi
    proot-distro login debian -- sed -i "$ a # Add $user_name to sudoers" /etc/sudoers
    if [[ "$pd_pass_type" == "1" ]]; then
        proot-distro login debian -- sed -i "$ a $user_name ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
    else
        proot-distro login debian -- sed -i "$ a $user_name ALL=(ALL:ALL) ALL" /etc/sudoers
    fi
}

# Gather all configuration decisions up-front, with a final
# ok/reconfigure/quit confirmation before anything is installed.
configure_wizard

# Install Termux (and Termux X11)
banner
echo "${G}${BOLD} Setting up Termux..."${W}
pkg update -y
termux-setup-storage
pkg update -y
pkg upgrade -y
pkg install -y x11-repo
pkg install -y termux-x11-nightly
pkg install -y tur-repo
pkg install -y pulseaudio
pkg install -y proot-distro
pkg install -y wget
pkg install -y git
wait_for_key

## Setup nerd fonts
#banner
#echo "${G}${BOLD} Setting up nerd fonts..."${W}
#cd ~
#pkg install -y clang git make
#git clone https://github.com/notflawffles/termux-nerd-installer.git
#cd termux-nerd-installer
#rm -rf termux-nerd-installer
#make install
#cd ~
#termux-nerd-installer i jetbrains-mono-ligatures
#termux-nerd-installer s jetbrains-mono-ligatures
##termux-nerd-installer l i

# Setup Debian
banner
echo "${G}${BOLD} Setting up Proot-Distro Debian..."${W}
proot-distro install debian
wait_for_key

# Setup user
setup_user
wait_for_key

# Install Debian launch script
banner
echo "${G}${BOLD} Setting up Proot-Distro Debian launch script..."${W}
proot-distro login debian --user $user_name -- sudo apt update -y
curl -Lf https://raw.githubusercontent.com/brian200508/debtx11/main/startpd-x11.sh -o ~/startpd.sh
sed -i "s@\%USER_NAME\%@$user_name@g" ~/startpd.sh
chmod +x ~/startpd.sh
wait_for_key

# Install XFCE4
banner
echo "${G}${BOLD} Setting up Proot-Distro XFCE4..."${W}
proot-distro login debian --user $user_name -- sudo apt install -y xfce4
curl -Lf https://raw.githubusercontent.com/brian200508/debtx11/main/startxfce4-pd.sh -o ~/startxfce4-pd.sh
sed -i "s@\%USER_NAME\%@$user_name@g" ~/startxfce4-pd.sh
chmod +x ~/startxfce4-pd.sh
wait_for_key

## Customize XFCE4
#banner
#echo "${G}${BOLD} Customizing Proot-Distro XFCE4..."${W}
#proot-distro login debian --user $user_name -- sudo apt install -y xfce4-whiskermenu-plugin
#proot-distro login debian --user $user_name -- sudo apt install -y mugshot
#proot-distro login debian --user $user_name -- apt search icon-theme
#proot-distro login debian --user $user_name -- sudo apt install -y papirus-icon-theme moka-icon-theme
#proot-distro login debian --user $user_name -- apt search gtk-themes
#proot-distro login debian --user $user_name -- sudo apt install -y numix-gtk-theme greybird-gtk-theme
#proot-distro login debian --user $user_name -- sudo apt install -y plank
#proot-distro login debian --user $user_name -- plank --preferences
#proot-distro login debian --user $user_name -- sudo apt install -y conky-all

## Fix vscode.list: Use signed Microsoft Repo
#banner
#echo "${G}${BOLD} Signing VSCode repository..."${W}
#proot-distro login debian -- sudo apt install -y wget gpg apt-transport-https
#proot-distro login debian -- wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
#proot-distro login debian -- sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
#proot-distro login debian -- sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
#proot-distro login debian -- rm -f packages.microsoft.gpg
#proot-distro login debian -- sudo apt update -y
#wait_for_key

# Intall latest VSCode
banner
echo "${G}${BOLD} Setting up latest VSCode..."${W}
proot-distro login debian --user $user_name -- wget -O ~/code_stable_arm64.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64'
proot-distro login debian --user $user_name -- sudo apt install -y ~/code_stable_arm64.deb
proot-distro login debian --user $user_name -- rm ~/code_stable_arm64.deb
proot-distro login debian --user $user_name -- sudo apt update -y
#proot-distro login debian --user $user_name -- code --no-sandbox 
#proot-distro login debian --user $user_name -- sed -i 's@code --new-window \%F@code --no-sandbox --new-window \%F@g' /usr/share/applications/code.desktop
#proot-distro login debian --user $user_name -- sed -i 's@code \%F@code --no-sandbox \%F@g' /usr/share/applications/code.desktop
wait_for_key

# Install Chromium Browser
banner
echo "${G}${BOLD} Setting up Chromium browser..."${W}
proot-distro login debian --user $user_name -- sudo apt update -y
#proot-distro login debian --user $user_name -- sudo apt install -y software-properties-common
#proot-distro login debian --user $user_name -- sudo add-apt-repository ppa:xtradeb/apps -y
#vsudo apt update -y
proot-distro login debian --user $user_name -- sudo apt install -y chromium
proot-distro login debian --user $user_name -- sudo apt update -y
#proot-distro login debian --user $user_name -- sed -i 's@chromium \%U@chromium --no-sandbox \%U@g' /usr/share/applications/chromium.desktop
#proot-distro login debian --user $user_name -- chromium --no-sandbox
wait_for_key

# Git, Python3 and essentials
banner
echo "${G}${BOLD} Setting up Git, Python3 and essentials..."${W}
proot-distro login debian --user $user_name -- sudo apt update -y
proot-distro login debian --user $user_name -- sudo apt install -y build-essential curl gh git lsb-release wget pgp python-is-python3 python3-venv python3-pip
wait_for_key

# locales
banner
echo "${G}${BOLD} Setting up locales..."${W}
proot-distro login debian --user $user_name -- sudo apt update -y
proot-distro login debian --user $user_name -- sudo apt install -y debconf locales
# Fully non-interactive locale generation (default: en_US.UTF-8) instead of
# the interactive dpkg-reconfigure dialog.
proot-distro login debian --user $user_name -- bash -c "echo 'locales locales/default_environment_locale select en_US.UTF-8' | sudo debconf-set-selections"
proot-distro login debian --user $user_name -- bash -c "echo 'locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8' | sudo debconf-set-selections"
proot-distro login debian --user $user_name -- sudo bash -c "DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales"
wait_for_key

# bundled Node.js
banner
echo "${G}${BOLD} Setting up bundled Node.js..."${W}
proot-distro login debian --user $user_name -- sudo apt update -y
proot-distro login debian --user $user_name -- sudo apt install -y nodejs npm
wait_for_key

# latest LTS Node.js
banner
echo "${G}${BOLD} Setting up latest LTS Node.js..."${W}
proot-distro login debian --user $user_name -- sudo apt update -y
proot-distro login debian --user $user_name -- curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
proot-distro login debian --user $user_name -- \. "$HOME/.nvm/nvm.sh"
proot-distro login debian --user $user_name -- nvm install 24
proot-distro login debian --user $user_name -- node -v # Should print "v24.18.0".
proot-distro login debian --user $user_name -- npm -v # Should print "11.16.0"
wait_for_key

# Fresh
banner
echo "${G}${BOLD} Setting up Fresh..."${W}
proot-distro login debian --user $user_name -- npm install -g @fresh-editor/fresh-editor
wait_for_key

# Nord+ bash theme (Debian)
banner
echo "${G}${BOLD} Setting up Nord+ bash theme..."${W}
setup_bashrc_theme
wait_for_key

# fix desktop links
banner
echo "${G}${BOLD} Fixing desktop links..."${W}
proot-distro login debian --user $user_name -- curl -Lf https://raw.githubusercontent.com/brian200508/debtx11/main/fix-links-pd.sh -o ~/fix-links-pd.sh
proot-distro login debian --user $user_name -- chmod +x ~/fix-links-pd.sh
wait_for_key

# Termux X11 autostart
banner
echo "${G}${BOLD} Setting up X11 autostart..."${W}
setup_tx11autostart

# Debian autostart
banner
echo "${G}${BOLD} Setting up Debian autostart..."${W}
setup_debautostart

echo ""
echo "${G}${BOLD} Removing installer script..."${W}
rm -f ~/install-x11.sh
wait_for_key

# Summary
banner
echo "${G}${BOLD} Setting up Proot-Distro Debian ${Y}done${G}."${W}
cd ~
echo "${G}Installed versions:"${W}
proot-distro login debian --user $user_name -- lsb_release -a
proot-distro login debian --user $user_name -- chromium --version
proot-distro login debian --user $user_name -- code --version
proot-distro login debian --user $user_name -- fresh --version
proot-distro login debian --user $user_name -- git --version
proot-distro login debian --user $user_name -- node --version
proot-distro login debian --user $user_name -- npm --version
proot-distro login debian --user $user_name -- python --version
echo ""
echo "${G}Don't forget Your Git config:"${W}
echo "    ${Y}git config --global user.name \"Your Name\""${W}
echo "    ${Y}git config --global user.email \"your.email-address@domain.com\""${W}
echo ""
echo "${G}After Chromium or VSCode update You can fix the desktop application links"${W}
echo "${G}by running this command (in Proot-Distro):"${W}
echo "    ${C}curl -Lf https://raw.githubusercontent.com/brian200508/debtx11/main/fix-links-pd.sh -o ~/fix-links-pd.sh${G} once"${W}
echo "    ${C}chmod +x ~/fix-links-pd.sh${G} once"${W}
echo "    ${Y}~/fix-links-pd.sh"${W}
echo ""
echo "${G}Start XFCE manually (in Termux - ${Y}not in Proot-Distro!!!${G})"${W}
echo "    ${Y}~/startxfce4-pd.sh"${W}
echo ""
echo "${G}You should ${Y}restart Termux${G} right now${Y}!!!"${W}
echo "${G}Run the command below, close Termux App and open Termux App again"${W}
echo "    ${Y}exit"${W}
echo ""
cd ~
