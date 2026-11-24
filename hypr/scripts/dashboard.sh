#!/bin/bash

kitty kew &
sleep 0.3
kitty btop &
sleep 0.3
kitty sh -c "fastfetch; exec bash" &
