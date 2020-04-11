#!/usr/bin/python

from pynput import keyboard
import sys
import os

# The key combination to check
# More than one combination of keys can be added here 
key_combinations = [
    {keyboard.Key.shift, keyboard.Key.ctrl}
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
        current.clear()
        execute_cmd = False

def on_release(key):
    global execute_cmd

    if any([key in combo for combo in key_combinations]):
            if key in current:
                current.remove(key)
            if len(current) == 0 and execute_cmd:
                execute()
                execute_cmd = False

with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
    listener.join()
