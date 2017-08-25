#!/usr/bin/env python

import socket
import sys
import os

import unicornhat as unicorn

socketEnvVar = "SOCKET"

server_address = os.environ.get(socketEnvVar)

unicorn.set_layout(unicorn.AUTO)
unicorn.rotation(0)
width,height = unicorn.get_shape()

if not server_address:
    print("Environment variable " + socketEnvVar + " not set")
    exit()

def changeAllLEDState(brightness, red, green, blue):
    for y in range(height):
        for x in range(width):
            unicorn.set_pixel(x, y, red, green, blue)

    if brightness < 0.0 or brightness > 1.0:
        print("Brightness level {0} out of range".format(brightness))
        return

    unicorn.brightness(brightness)
    unicorn.show()

# Make sure the socket does not already exist
try:
    os.unlink(server_address)
except OSError:
    if os.path.exists(server_address):
        raise

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

print ("LED changer started")
changeAllLEDState(0.2, 255, 255, 255)

sock.bind(server_address)

# Listen for incoming connections
sock.listen(1)
print ("Socket listening at %s" % server_address)


while True:
    # Wait for a connection
    print ('waiting for a connection')
    connection, client_address = sock.accept()
    print ('connection from %s' % client_address)
    try:

        while True:
            data = connection.recv(64)

            if data:
                strData = str(data).strip()
                components = strData.split()

                if len(components) == 4:
                    brightness = components[0]
                    red = components[1]
                    green = components[2]
                    blue = components[3]
                    try:
                        print("Received brightness={0}, red={1}, green={2}, red={3} ".format(brightness, red, green, blue))
                        changeAllLEDState(float(brightness), int(red), int(green), int(blue))
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
