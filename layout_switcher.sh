#!/bin/bash

ps ax | grep '[l]ayout_switcher.py' > /dev/null 2>&1
if [ "$?" = "0"  ]; then
  echo "already running"
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR
LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
python3 ./layout_switcher.py "xkb-switch -s us" "xkb-switch -s ru" &
