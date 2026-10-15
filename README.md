## What is this

Script that runs in background allowng change of keyboard layout by Ctrl+Shift *the right way* - with lots of tiny but important details implemented on Windows but missing on Linux.

There are two implementations:
- `layout_switcher.sh` for generic Linux distributions utilizing `xkb-switch`
- `layout_switcher_ubuntu20_gnome.sh` - specific for gnome and the only option for Ubuntu 20 where xkb-switch does not work
- `layout_switcher_ubuntu26_gnome.sh` - for GNOME on Wayland (Ubuntu 26), reads keys from `/dev/input`

## Prerequisites

Requres pynput python lib to be installed

Run: pip install --user pynput

On Wayland (Ubuntu 26) `pynput` is not used, see "Usage (Ubuntu 26, GNOME on Wayland)" below.

## Components

### xkb-switch

C++ application allowing to switch Keyboard Layout in Ubuntu Linux
Compiled form GitHub repo https://github.com/ierton/xkb-switch
All credits goes to J. Bromley, S. Mironov, Alexei Rad'kov

Run 'LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH; xkb-switch -h' for additional info

### layout_switcher.py

Simple python script waiting for Ctrl+Shift key combination to be pressed and then released on the keyboard.
Specific combination can be changed by editing 'key_combinations' list inside layout_switcher.py
On X11 keys are read with `pynput`. On Wayland (`XDG_SESSION_TYPE=wayland`) applications cannot see global
key events, so keys are read directly from `/dev/input` with `python-evdev`; this requires the user to be in the `input` group.
Scripts receive 2 sh commands as command line arguments and execute them one after another on every Ctrl+Shift release

Created based on this guide https://nitratine.net/blog/post/how-to-make-hotkeys-in-python/

### layout_switcher.sh

Simple bash script which joins all parts together and make it work.

### layout_switcher_ubuntu20_gnome.sh

Simple bash script that uses `gdbus` to switch layouts

### layout_switcher_ubuntu26_gnome.sh

Simple bash script for GNOME on Wayland. Switches layout by calling a D-Bus method of the bundled GNOME Shell extension
(`gnome-extension/layout-switcher@keyboard-layout-switcher`), no key presses are synthesized. Installs and enables the
extension itself when needed.

### gnome-extension/layout-switcher@keyboard-layout-switcher

GNOME Shell (45+) extension exporting `org.gnome.Shell.Extensions.LayoutSwitcher` at `/org/gnome/Shell/Extensions/LayoutSwitcher`
on the session bus. GNOME has no public API to change the input source and `org.gnome.Shell.Eval` is disabled, so the
extension calls GNOME's own input source manager (same thing Super+Space does). Methods:

- `Next()` - switch to the next input source, returns its index
- `Activate(u index)` - switch to input source by index (order of `org.gnome.desktop.input-sources sources`)
- `List()` - input source ids, e.g. `['us', 'ru']`
- property `Current` - index of the active input source

Example:

    gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Extensions/LayoutSwitcher \
      --method org.gnome.Shell.Extensions.LayoutSwitcher.Next

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

## Usage (Ubuntu 26, GNOME on Wayland)

Prerequisites:

    sudo apt install python3-evdev
    sudo usermod -aG input $USER

Then run `layout_switcher_ubuntu26_gnome.sh`. On the first run it installs the GNOME Shell extension
to `~/.local/share/gnome-shell/extensions/`, enables it and asks to log out and log in (or reboot), because GNOME on
Wayland only loads new extensions on login. Log in again (this also applies the `input` group) and run the script once
more. It also re-enables the extension if it was turned off, and reinstalls it (asking to log in again) when
the copy in `gnome-extension/` changes. If something is missing the script says what and exits.

Note: `pynput` and `gsettings set ... current` do not work on Wayland - the first does not see keys of native Wayland
windows, the second does not change the layout. Sending Super+Space (e.g. with `ydotool`) works but is merged with
physically held keys, e.g. becomes Ctrl+Super+Space while Ctrl is still down.


## Test

Tested with Python 3.8.10

Tested in Linux Mint 19.1 Cinnamon, Ubuntu 18.0.4, Ubuntu 20.0.4 (w/o xkb-switch)

Ubuntu 26 (GNOME 50, Wayland)
