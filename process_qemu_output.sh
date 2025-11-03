#!/bin/bash

# Store the result of the command in a variable
result=`ps -eo pid,cmd | grep qemu-system`

# Use sed to replace " -" with a newline + " -" to make the output easier to read
echo "$result" | sed 's/ -/\n -/g'