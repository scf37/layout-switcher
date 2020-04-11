## Prerequisites

Requres pynput python lib to be installed

Run: pip install --user pynput

## Components

### xkb-switch

C++ application allowing to switch Keyboard Layout in Ubuntu Linux
Compiled form GitHub repo https://github.com/ierton/xkb-switch
All credits goes to J. Bromley, S. Mironov, Alexei Rad'kov

Run 'LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH; xkb-switch -h' for additional info

### layout_switcher.py

Simple python script waiting for Ctrl+Shift key combination to be pressed and then released on the keyboard.
Specific combination can be changed by editing 'key_combinations' list inside layout_switcher.py
Scripts receive 2 sh commands as command line arguments and execute them one after another on every Ctrl+Shift release

Created based on this guide https://nitratine.net/blog/post/how-to-make-hotkeys-in-python/

### layout_switcher.sh

Simple bash script which joins all parts together and make it work.

## Usage

Put layout_switcher.py and xkb-switch in same folder
Run: LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH; xkb-switch -l
You should see all available keyboard layouts. E.g. us, ru

Try to switch between to layouts using xkb-switch
Run: LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH; xkb-switch -s us
Run: LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH; xkb-switch -s ru

If xkb-switch works as expected, you can try layout_switcher.sh
Run layout_switcher.sh and try to switch layout by Ctrl+Shift

Note: If you have layouts different from us/ru, layout_switcher.sh need to be edited to update layouts as necessary.

Script layout_switcher.sh can be added to /etc/profile to start on system boot.

## Test

Tested with Python 2.7.15rc1, 2.7.17
Tested in Linux Mint 19.1 Cinnamon, Ubuntu 18.0.4
