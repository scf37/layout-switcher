#!/bin/bash

ps ax | grep '[l]ayout_switcher.py' > /dev/null 2>&1
if [ "$?" = "0"  ]; then
  echo "already running"
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR

fail=0
if ! python3 -c 'import evdev' >/dev/null 2>&1; then
  echo "missing python3-evdev: sudo apt install python3-evdev"; fail=1
fi
if ! id -nG | tr ' ' '\n' | grep -qx input; then
  echo "user $USER is not in the 'input' group: sudo usermod -aG input $USER (then log out and in)"; fail=1
fi

EXT=layout-switcher@keyboard-layout-switcher
EXT_SRC=$SCRIPT_DIR/gnome-extension/$EXT
EXT_DST=${XDG_DATA_HOME:-$HOME/.local/share}/gnome-shell/extensions/$EXT
relogin=0

if [ "$(gsettings get org.gnome.shell disable-user-extensions)" = "true" ]; then
  gsettings set org.gnome.shell disable-user-extensions false
  echo "enabled user extensions in GNOME settings"
fi
if ! diff -rq "$EXT_SRC" "$EXT_DST" >/dev/null 2>&1; then
  rm -rf "$EXT_DST"
  mkdir -p "$(dirname "$EXT_DST")"
  cp -r "$EXT_SRC" "$EXT_DST"
  echo "installed GNOME Shell extension $EXT to $EXT_DST"
  relogin=1
fi
python3 - "$EXT" <<'EOF'
import ast, subprocess, sys
ext = sys.argv[1]
value = subprocess.check_output(['gsettings', 'get', 'org.gnome.shell', 'enabled-extensions'], text=True).strip()
enabled = ast.literal_eval(value.removeprefix('@as '))
if ext not in enabled:
    subprocess.check_call(['gsettings', 'set', 'org.gnome.shell', 'enabled-extensions', str(enabled + [ext])])
EOF

if [ "$relogin" = "0" ]; then
  state=$(gnome-extensions info $EXT 2>/dev/null | sed -n 's/^ *State: *//p')
  case "$state" in
    ACTIVE) ;;
    "") relogin=1 ;;  # files are there but this GNOME session has not loaded them yet
    *)
      gnome-extensions enable $EXT 2>/dev/null
      sleep 1
      state=$(gnome-extensions info $EXT 2>/dev/null | sed -n 's/^ *State: *//p')
      if [ "$state" != "ACTIVE" ]; then
        echo "GNOME Shell extension $EXT is in state '$state', see: journalctl --user -b | grep -i $EXT"; fail=1
      fi
      ;;
  esac
fi
if [ "$relogin" = "1" ]; then
  echo "GNOME Shell must load extension $EXT: log out and log in (or reboot), then run this script again"; fail=1
fi
[ "$fail" = "0" ] || exit 1

SWITCH="/usr/bin/gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Extensions/LayoutSwitcher --method org.gnome.Shell.Extensions.LayoutSwitcher.Next >/dev/null"

python3 ./layout_switcher.py "$SWITCH" "" &
