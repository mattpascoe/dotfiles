#!/bin/bash

# Funny enough Linux platforms dont really need much beyond the COMMON profile
# but we have this stubbed out just in case

# Set the console log level to 6 on arch
[[ "$ID" == arch* ]] && sudo dmesg -n 6
