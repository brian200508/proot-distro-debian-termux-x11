#!/bin/bash

# Nord+ palette (Nord, with red darkened / green brightened for contrast)
G="$(printf '\033[38;2;148;199;88m')"
C="$(printf '\033[38;2;136;192;208m')"
W="$(printf '\033[0m')"
BOLD="$(printf '\033[1m')"

echo "${G}${BOLD}Fix desktop links${W}"
echo "${C}Updating...${W}"
sudo apt update -y

echo "${C}Fixing VSCode desktop links...${W}"
sed -i 's@code --new-window \%F@code --no-sandbox --new-window \%F@g' /usr/share/applications/code.desktop
sed -i 's@code --new-window \%f@code --no-sandbox --new-window \%f@g' /usr/share/applications/code.desktop
sed -i 's@code \%F@code --no-sandbox \%F@g' /usr/share/applications/code.desktop
sed -i 's@code \%f@code --no-sandbox \%f@g' /usr/share/applications/code.desktop

echo "${C}Fixing Chromium desktop links...${W}"
sed -i 's@chromium \%U@chromium --no-sandbox \%U@g' /usr/share/applications/chromium.desktop
sed -i 's@chromium \%u@chromium --no-sandbox \%u@g' /usr/share/applications/chromium.desktop

echo "${C}Fixing Web Browser desktop links...${W}"
sed -i 's@WebBrowser \%U@WebBrowser --no-sandbox \%U@g' /usr/share/applications/xfce4-web-browser.desktop
sed -i 's@WebBrowser \%u@WebBrowser --no-sandbox \%u@g' /usr/share/applications/xfce4-web-browser.desktop

echo "${G}${BOLD}Done.${W}"
