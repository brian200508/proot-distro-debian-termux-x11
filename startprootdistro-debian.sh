#!/data/data/com.termux/files/usr/bin/bash

# Login in PRoot Environment. Do some initialization for /tmp directory.
# See also: https://github.com/termux/proot-distro
# Argument -- acts as terminator of proot-distro login options processing.
# All arguments behind it would not be treated as options of PRoot Distro.
proot-distro login debian --shared-tmp -- /bin/bash -c  'su - %USER_NAME%'

exit 0