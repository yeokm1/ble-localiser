# Pi LED Changer

A Python program that controls the LEDs on the Unicorn Hat. LED data is obtained via the Unix Domain Socket. Path obtained via the `SOCKET` environment variable.

## Setup Steps

### On host machine

```bash
scp led-changer.py pi@X.X.X.X:/home/pi/
```

### On Pi

One time dependency setup:

```bash
sudo apt update
sudo apt install python-pip python-dev
sudo pip install unicornhat
```

To just run:

```bash
# Can omit SOCKET environment variable if it is already set
sudo SOCKET=/home/pi/socket.sock python led-changer.py
```
