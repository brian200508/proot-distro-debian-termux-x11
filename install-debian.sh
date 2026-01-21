#!/bin/bash

R="$(printf '\033[1;31m')"                    
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
B="$(printf '\033[1;34m')"
C="$(printf '\033[1;36m')"                             
W="$(printf '\033[0m')"
BOLD="$(printf '\033[1m')"

function banner() {
clear
echo "${Y} █▀▄ █▀▀ █▄   ▀ ▄▀▄  ▄     ▀▄▀ ▄▀█ ▄▀█  "${W}
echo "${Y} █▄▀ ██▄ █▄▀ ░█ █▀█ █░█    █░█  ░█  ░█  "${W}
echo
echo "${C}${BOLD} Install Proot-Distro Debian with XFCE4/Termux X11 in Termux"${W}
echo
}

function confirmation_y_or_n() {
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
    #banner
    confirmation_y_or_n "Do you want to start Termux X11 automatically with Termux?" tx11_autostart
    if [[ "$tx11_autostart" == "y" ]]; then
        # check if already configured
        if grep -q "^startxfce4-debian.sh" $rc_file; then
            echo "Termux:X11 start already appended"
        else
            echo '# Start Termux:X11' >> $rc_file
            #echo 'if [ $( ps aux | grep -c "termux.x11" ) -gt 1 ]; then echo "X server is already running." ; else startxfce4-debian.sh ; fi' >> $rc_file
            echo '~/startxfce4-debian.sh &' >> $rc_file
            echo "Termux:X11 start add to $rc_file"
        fi
    else
        # check if already configured
        if grep -q "^startxfce4-debian.sh" $rc_file; then
            sed -i "" "/Start Termux:X11/d" $rc_file
            sed -i "" "/startxfce4-debian.sh/d" $rc_file
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
    #banner
    confirmation_y_or_n "Do you want to start Debian automatically with Termux?" deb_autostart
    if [[ "$deb_autostart" == "y" ]]; then
        # check if already configured
        if grep -q "^startprootdistro-debian.sh" $rc_file; then
            echo "Debian start already appended"
        else
            echo '# Start Debian' >> $rc_file
            echo '~/startprootdistro-debian.sh' >> $rc_file
            echo "Debian start add to $rc_file"
        fi
    else
        # check if already configured
        if grep -q "^startprootdistro-debian.sh" $rc_file; then
            sed -i "" "/Start Debian/d" $rc_file
            sed -i "" "/startprootdistro-debian.sh/d" $rc_file
            echo "Debian start removed from $rc_file"
        fi
    fi
}

function setup_user() {
    banner
	confirmation_y_or_n "Do you want to create a normal user account ${C}(Recomended)" pd_useradd_answer
	echo
    if [[ "$pd_useradd_answer" == "n" ]]; then
    echo "${R}[${W}-${R}]${G}Skiping User Account Setup"${W}
    else
	echo "${R}[${W}-${R}]${G}${BOLD} Select user account type"${W}
    echo
	echo "${Y}1. User with no password confirmation"${W}
	echo
	echo "${Y}2. User with password confirmation"${W}
	echo 
	read -p "${Y}select an option (Default 1): "${W} pd_pass_type
	pd_pass_type=${pd_pass_type:-1}
	echo
	echo "${R}[${W}-${R}]${G}Continuing with answer: $pd_pass_type"${W}
	echo
	sleep 0.2
if [[ "$pd_pass_type" == "1" ]]; then
	while true; do
    read -p "${R}[${W}-${R}]${G}Input username [Lowercase]: "${W} user_name
    echo
    read -p "${R}[${W}-${R}]${Y}Do you want to continue with username ${C}$user_name ${Y}? (y/n) : "${W} choice
	echo
	choice="${choice:-y}"
	echo
	echo "${R}[${W}-${R}]${G}Continuing with answer: $choice"${W}
	sleep 0.2
    case $choice in
        [yY]* )
            echo "${R}[${W}-${R}]${G}Continuing with username ${C}$user_name "${W}
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
elif [[ "$pd_pass_type" == "2" ]]; then
    echo
    echo "${R}[${W}-${R}]${G}${BOLD} Create user account"${W}
    echo
    while true; do
    read -p "${R}[${W}-${R}]${G}Input username [Lowercase]: "${W} user_name
    echo
    read -p "${R}[${W}-${R}]${G}Input Password: "${W} pass
    echo
    read -p "${R}[${W}-${R}]${Y}Do you want to continue with username ${C}$user_name ${Y}and password ${C}$pass${Y} ? (y/n) : "${W} choice
	echo
	choice="${choice:-y}"
	echo
	echo "${R}[${W}-${R}]${G}Continuing with answer: $choice"${W}
	echo ""
	sleep 0.2
    case $choice in
        [yY]* )
            echo "${R}[${W}-${R}]${G}Continuing with username ${C}$user_name ${G}and password ${C}$pass"${W}
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

    echo "${G}${BOLD} Setting up User $user_name..."${W}
    proot-distro login debian -- apt update -y
    proot-distro login debian -- apt install -y sudo nano adduser
    if [[ "$pd_pass_type" == "1" ]]; then
        proot-distro login debian -- adduser --disabled-password $user_name
        proot-distro login debian -- passwd -d $user_name
    else
        proot-distro login debian -- adduser $user_name
    fi
    proot-distro login debian -- sed -i "$ a # Add $user_name to sudoers" /etc/sudoers
    if [[ "$pd_pass_type" == "1" ]]; then
        proot-distro login debian -- sed -i "$ a $user_name ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
    else
        proot-distro login debian -- sed -i "$ a $user_name ALL=(ALL:ALL) ALL" /etc/sudoers
    fi
    fi
}

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
curl -Lf https://raw.githubusercontent.com/brian200508/proot-distro-debian-termux-x11/main/startprootdistro-debian.sh -o ~/startprootdistro-debian.sh
sed -i "s@\%USER_NAME\%@$user_name@g" ~/startprootdistro-debian.sh
chmod +x ~/startprootdistro-debian.sh
wait_for_key

# Install XFCE4
banner
echo "${G}${BOLD} Setting up Proot-Distro XFCE4..."${W}
proot-distro login debian --user $user_name -- sudo apt install -y xfce4
curl -Lf https://raw.githubusercontent.com/brian200508/proot-distro-debian-termux-x11/main/startxfce4-debian.sh -o ~/startxfce4-debian.sh
sed -i "s@\%USER_NAME\%@$user_name@g" ~/startxfce4-debian.sh
chmod +x ~/startxfce4-debian.sh
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

# Node.js
banner
echo "${G}${BOLD} Setting up Node.js..."${W}
proot-distro login debian --user $user_name -- sudo apt update -y
proot-distro login debian --user $user_name -- sudo apt install -y nodejs npm
wait_for_key

# Fresh
banner
echo "${G}${BOLD} Setting up Fresh..."${W}
proot-distro login debian --user $user_name -- npm install -g @fresh-editor/fresh-editor
wait_for_key

# fix desktop links
banner
echo "${G}${BOLD} Fixing desktop links..."${W}
proot-distro login debian --user $user_name -- curl -Lf https://raw.githubusercontent.com/brian200508/proot-distro-debian-termux-x11/main/fix-desktop-links.sh -o ~/fix-desktop-links.sh
proot-distro login debian --user $user_name -- chmod +x ~/fix-desktop-links.sh
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
rm -f ~/install-debian.sh
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
echo "    ${C}curl -Lf https://raw.githubusercontent.com/brian200508/proot-distro-debian-termux-x11/main/fix-desktop-links.sh -o ~/fix-desktop-links.sh${G} once"${W}
echo "    ${C}chmod +x ~/fix-desktop-links.sh{G} once"${W}
echo "    ${Y}~/fix-desktop-links.sh"${W}
echo ""
echo "${G}Start XFCE manually (in Termux - ${Y}not in Proot-Distro!!!${G})"${W}
echo "    ${Y}~/startxfce4_debian.sh"${W}
echo ""
echo "${G}You should ${Y}restart Termux${G} right now${Y}!!!"${W}
echo "${G}Run the command below, close Termux App and open Termux App again"${W}
echo "    ${Y}exit"${W}
echo ""
cd ~
