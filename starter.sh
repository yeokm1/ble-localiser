#!/bin/sh
SOCKET=/home/pi/socket.sock /usr/bin/python /home/pi/ble-localiser/pi-led-changer/led-changer.py &
sleep 5
SOCKET=/home/pi/socket.sock /home/pi/ble-localiser/pi-broadcaster/.build/debug/PiBrc &
