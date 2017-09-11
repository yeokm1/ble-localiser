#!/usr/bin/env python

import socket
import sys
import os
import thread
import time

import unicornhat as unicorn

socketEnvVar = "SOCKET"

rowLength = 8
maxNumber = 64

server_address = os.environ.get(socketEnvVar)

unicorn.set_layout(unicorn.AUTO)
unicorn.rotation(0)
width,height = unicorn.get_shape()

initialPulseThreadShouldBeActive = True
firstConnectionReceived = False

if not server_address:
    print("Environment variable " + socketEnvVar + " not set")
    exit()

def changeAllLEDState(number, red, green, blue):

    if number < 0 or number > maxNumber:
        print ("Out of range number %d" % number)
        return

    # To convert to zero-based scheme
    number = number - 1

    for y in range(height):
        for x in range(width):

            oneDNumber = y * rowLength + x

            if oneDNumber <= number:
                unicorn.set_pixel(x, y, red, green, blue)
            else:
                unicorn.set_pixel(x, y, 0, 0, 0)


    unicorn.show()


def pulseThread():

    global initialPulseThreadShouldBeActive
    global firstConnectionReceived
    maxRange = 50

    while initialPulseThreadShouldBeActive:

        if firstConnectionReceived:
            changeAllLEDState(2, maxRange, 0, 0)
            time.sleep(0.5)

            if not initialPulseThreadShouldBeActive:
                break
            changeAllLEDState(0, 0, 0, 0)
            time.sleep(0.5)

            if not initialPulseThreadShouldBeActive:
                break
            changeAllLEDState(2, 0, maxRange, 0)
            time.sleep(0.5)

            if not initialPulseThreadShouldBeActive:
                break
            changeAllLEDState(2, 0, 0, 0)
            time.sleep(0.5)

            if not initialPulseThreadShouldBeActive:
                break
            changeAllLEDState(2, 0, 0, maxRange)
            time.sleep(0.5)

            if not initialPulseThreadShouldBeActive:
                break
            changeAllLEDState(0, 0, 0, 0)
            time.sleep(0.5)

        else:
            changeAllLEDState(1, maxRange, maxRange, maxRange)
            time.sleep(0.5)
            if not initialPulseThreadShouldBeActive:
                break
            changeAllLEDState(0, 0, 0, 0)
            time.sleep(0.5)



# Make sure the socket does not already exist
try:
    os.unlink(server_address)
except OSError:
    if os.path.exists(server_address):
        raise

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

print ("LED changer started")
unicorn.brightness(1)
thread.start_new_thread(pulseThread,())

sock.bind(server_address)

# Listen for incoming connections
sock.listen(1)
print ("Socket listening at %s" % server_address)


while True:
    # Wait for a connection
    print ('waiting for a connection')
    connection, client_address = sock.accept()
    print ('connection from %s' % client_address)
    firstConnectionReceived = True

    try:

        while True:
            data = connection.recv(64)

            if data:
                strData = str(data).strip()
                components = strData.split()

                if len(components) == 4:
                    number = components[0]
                    red = components[1]
                    green = components[2]
                    blue = components[3]
                    try:
                        initialPulseThreadShouldBeActive = False
                        print("LEDs={0}, red={1}, green={2}, red={3} ".format(number, red, green, blue))
                        changeAllLEDState(int(number), int(red), int(green), int(blue))
                    except ValueError as e:
                        print(e)

                else:
                    print("Cannot parse this: %s" % strData)

            else:
                print("no more data from", client_address)
                break

    finally:
        # Clean up the connection
        connection.close()
