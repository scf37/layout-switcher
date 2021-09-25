#!/bin/bash

ps ax | grep '[l]ayout_switcher.py' > /dev/null 2>&1
if [ "$?" = "0"  ]; then
  echo "already running"
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR
LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH

# https://unix.stackexchange.com/questions/316998/how-to-change-keyboard-layout-in-gnome-3-from-command-line/508510

LAYOUT0='/usr/bin/gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval  "imports.ui.status.keyboard.getInputSourceManager().inputSources[0].activate()" >/dev/null'
LAYOUT1='/usr/bin/gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval  "imports.ui.status.keyboard.getInputSourceManager().inputSources[1].activate()" >/dev/null'


python3 ./layout_switcher.py "$LAYOUT1" "$LAYOUT0" &
