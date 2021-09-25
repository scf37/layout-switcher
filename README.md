## What is this

Script that runs in background allowng change of keyboard layout by Ctrl+Shift *the right way* - with lots of tiny but important details implemented on Windows but missing on Linux.

There are two implementations:
- `layout_switcher.sh` for generic Linux distributions utilizing `xkb-switch`
- `layout_switcher_ubuntu20_gnome.sh` - specific for gnome and the only option for Ubuntu 20 where xkb-switch does not work

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

### layout_switcher_ubuntu20_gnome.sh

Simple bash script that uses `gdbus` to switch layouts

## Usage (for xkb-switch version)

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

## Usage (without xkb-switch, gnome specific)

Just run `layout_switcher_ubuntu20_gnome.sh`


## Test

Tested with Python 3.8.10
Tested in Linux Mint 19.1 Cinnamon, Ubuntu 18.0.4, Ubuntu 20.0.4 (w/o xkb-switch)
