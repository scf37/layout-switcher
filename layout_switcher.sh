#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR
LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
python ./layout_switcher.py "xkb-switch -s us" "xkb-switch -s ru" &
