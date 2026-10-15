#!/bin/bash

ps ax | grep '[l]ayout_switcher.py' > /dev/null 2>&1
if [ "$?" = "0"  ]; then
  echo "already running"
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR
LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH

# https://www.linux.org.ru/forum/talks/16756369#comments

LAYOUT0='/usr/bin/gsettings set org.gnome.desktop.input-sources sources "[('\''xkb'\'', '\''us'\'')]" >/dev/null'
LAYOUT1='/usr/bin/gsettings set org.gnome.desktop.input-sources sources "[('\''xkb'\'', '\''ru'\'')]" >/dev/null'

python3 ./layout_switcher.py "$LAYOUT1" "$LAYOUT0" &
