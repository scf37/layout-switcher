#!/usr/bin/python3

import sys
import os
import select

# Backends:
#  - X11:     pynput (XRecord)
#  - Wayland: /dev/input via python-evdev (user must be in the 'input' group),
#             because Wayland gives no application access to global key events.
wayland = os.environ.get('XDG_SESSION_TYPE') == 'wayland'

# The key combination to check
# More than one combination of keys can be added here 
# Keys are normalized to 'shift' / 'ctrl'.
key_combinations = [
    {'shift', 'ctrl'}
]

# The currently active modifiers
current = set()

# Indicates command execute on release
execute_cmd = False

# Commands to execute
path = os.path.dirname(os.path.realpath(__file__))
cmd1 = sys.argv[1]
cmd2 = sys.argv[2]
cmd = cmd1

if len(cmd1) > 0 and cmd1[0] != '/':
    cmd1 = path + '/' + cmd1
    cmd = cmd1
if len(cmd2) > 0 and cmd2[0] != '/':
    cmd2 = path + '/' + cmd2

def execute():
    global cmd

    if len(cmd1) == 0:
        return

    os.system(cmd)    

    if len(cmd2) != 0:
        if cmd == cmd1: cmd = cmd2
        else: cmd = cmd1
    
def on_press(key):
    global execute_cmd

    if any([key in combo for combo in key_combinations]):
        current.add(key)
        if any(all(k in current for k in combo) for combo in key_combinations):
            execute_cmd = True
    else:
        execute_cmd = False

def on_release(key):
    global execute_cmd

    if any([key in combo for combo in key_combinations]):
            if key in current:
                current.remove(key)
            if len(current) == 1 and execute_cmd:
                execute()
                execute_cmd = False

def run_pynput():
    from pynput import keyboard

    def normalize(key):
        if key in (keyboard.Key.shift, keyboard.Key.shift_l, keyboard.Key.shift_r):
            return 'shift'
        if key in (keyboard.Key.ctrl, keyboard.Key.ctrl_l, keyboard.Key.ctrl_r):
            return 'ctrl'
        return key

    with keyboard.Listener(on_press=lambda k: on_press(normalize(k)),
                           on_release=lambda k: on_release(normalize(k))) as listener:
        listener.join()

def run_evdev():
    import evdev
    from evdev import ecodes

    names = {
        ecodes.KEY_LEFTSHIFT: 'shift', ecodes.KEY_RIGHTSHIFT: 'shift',
        ecodes.KEY_LEFTCTRL: 'ctrl', ecodes.KEY_RIGHTCTRL: 'ctrl',
    }
    held = set()  # physical modifier keycodes currently down

    devices = {}
    for path in evdev.list_devices():
        try:
            dev = evdev.InputDevice(path)
        except PermissionError:
            sys.exit("cannot open " + path + ": user must be in the 'input' group")
        keys = dev.capabilities().get(ecodes.EV_KEY, [])
        # real keyboards only (has letters), skips mice, power buttons
        if ecodes.KEY_A in keys and ecodes.KEY_SPACE in keys:
            devices[dev.fd] = dev
    if not devices:
        sys.exit("no keyboard devices found in /dev/input")

    while True:
        ready, _, _ = select.select(list(devices), [], [])
        for fd in ready:
            try:
                events = list(devices[fd].read())
            except OSError:  # device unplugged
                del devices[fd]
                continue
            for ev in events:
                if ev.type != ecodes.EV_KEY or ev.value == 2:  # ignore autorepeat
                    continue
                key = names.get(ev.code, ev.code)
                if ev.value == 1:
                    held.add(ev.code)
                    on_press(key)
                else:
                    held.discard(ev.code)
                    # both shifts / both ctrls: only release the logical key when no side is held
                    if key in ('shift', 'ctrl') and any(names.get(c) == key for c in held):
                        continue
                    on_release(key)
        if not devices:
            sys.exit("all keyboard devices disappeared")

if wayland:
    run_evdev()
else:
    run_pynput()
