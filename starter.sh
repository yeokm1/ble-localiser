#!/bin/sh
SOCKET=/home/pi/socket.sock /usr/bin/python /home/pi/led-changer.py &
sleep 5
SOCKET=/home/pi/socket.sock /home/pi/PiBrc &
