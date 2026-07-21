#!/data/data/com.termux/files/usr/bin/bash

# DebTX11: PID-tracked, idempotent XFCE4/Termux:X11 launcher.
#
# The upstream project this was forked from always ran
# `kill -9 $(pgrep -f "termux.x11")` unconditionally at the top -- so *any*
# re-invocation (re-tapping a launcher shortcut, or opening a brand-new
# Termux session/tab while `~/startxfce4-pd.sh &` is on the autostart
# path in .bashrc) killed the already-running Termux:X11 server, taking
# every open app in the live XFCE4 session down with it, before starting a
# fresh one.
#
# Fix: track the termux-x11 PID in a lock file. If it's still alive, just
# refocus the Termux:X11 activity and exit -- no kill, no restart. Only fall
# through to a real (re)start when no live session is found, and clean the
# lock up again once XFCE4 itself exits.

X11_LOCK=$HOME/.termux-x11.pid

is_x11_running() {
  [ -f "$X11_LOCK" ] && kill -0 "$(cat "$X11_LOCK" 2>/dev/null)" 2>/dev/null
}

if is_x11_running; then
  # A session is already up -- bring it to the foreground instead of
  # tearing it down and losing every open app.
  am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
  exit 0
fi

# No live session tracked: safe to clean up any stale process and start fresh.
kill -9 $(pgrep -f "termux-x11 :0") 2>/dev/null
rm -f "$X11_LOCK"

# Enable PulseAudio over Network
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

# Prepare termux-x11 session
export XDG_RUNTIME_DIR=${TMPDIR}
termux-x11 :0 >/dev/null &
echo $! > "$X11_LOCK"

# Wait a bit until termux-x11 gets started.
sleep 3

# Launch Termux X11 main activity
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

# Login in PRoot Environment. Do some initialization for PulseAudio, /tmp directory
# and run XFCE4 as user %USER_NAME%. Blocks until XFCE4 exits.
# See also: https://github.com/termux/proot-distro
# Argument -- acts as terminator of proot-distro login options processing.
# All arguments behind it would not be treated as options of PRoot Distro.
proot-distro login debian --shared-tmp -- /bin/bash -c  'export PULSE_SERVER=127.0.0.1 && export XDG_RUNTIME_DIR=${TMPDIR} && su - %USER_NAME% -c "env DISPLAY=:0 startxfce4"'

# XFCE4 session ended (user logged out) -- tear down the now-unused server.
kill -9 $(cat "$X11_LOCK" 2>/dev/null) 2>/dev/null
rm -f "$X11_LOCK"

exit 0
