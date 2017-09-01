# Pi LED Changer

A Python program that controls the LEDs on the Unicorn Hat. LED data is obtained via the Unix Domain Socket. Path obtained via the `SOCKET` environment variable.

## Setup Steps

### On host machine

```bash
scp led-changer.py led-changer.service led-changer-startup.sh pi@X.X.X.X:/home/pi/
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

Make program start on boot:
```bash
chmod +x led-changer-startup.sh
sudo mv led-changer.service /etc/systemd/system/
sudo systemctl enable led-changer.service
```
