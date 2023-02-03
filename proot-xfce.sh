#!/data/data/com.termux/files/usr/bin/bash

# From https://github.com/termux/termux-packages/issues/14039#issuecomment-1362460223. Thanks!

if [ -z "$1" ]; then
	echo "Usage: $(basename $0) distro username(optional, falls back to root)"
	exit 1
fi

DISTRO="$1"
PROOT_USER="$2"

# Check for specific user to login else fallback to root
if [ -z "$2" ]; then
	PROOT_USER="root"
fi

# Enable PulseAudio over Network (pkg install pulseaudio on termux)
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

# Prepare termux-x11 session
export XDG_RUNTIME_DIR=${TMPDIR}
termux-x11 :0 >/dev/null &

# Wait a bit until termux-x11 gets started.
sleep 3

# Login in PRoot Environment. Do some initialization for PulseAudio, /tmp directory
# and run xfce as your non-root user.
# See also: https://github.com/termux/proot-distro
# Argument -- acts as terminator of proot-distro login options processing.
# All arguments behind it would not be treated as options of PRoot Distro.
proot-distro login "$DISTRO" --shared-tmp --bind /dev/null:/proc/sys/kernel/cap_last_cap -- /bin/bash -c 'export PULSE_SERVER=127.0.0.1 && export XDG_RUNTIME_DIR=${TMPDIR} && su - '"$PROOT_USER"' -c "env DISPLAY=:0 xfce4-session"'

exit 0