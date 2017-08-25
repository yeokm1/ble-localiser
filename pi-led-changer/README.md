# Pi LED Changer

A Python program that controls the LEDs on the Unicorn Hat. LED data is obtained via the Unix Domain Socket. Path obtained via the `SOCKET` environment variable.

## Setup Steps

On host machine

```bash
scp led-changer.py led-changer.service led-changer-startup.sh pi@X.X.X.X:/home/pi/
```

On Pi
```bash
# Install Unicorn hat dependencies
sudo apt-get install python-pip python-dev
sudo pip install unicornhat

chmod +x led-changer-startup.sh
sudo mv led-changer.service /etc/systemd/system/
sudo systemctl enable led-changer.service
```
