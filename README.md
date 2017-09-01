# ble-localiser

Lightning talk meant for iOSConf

## Setup Instructions

### For Raspberry Pi

1. Download [Raspbian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/) and burn to SD card.

2. Connect RPi to LAN, HDMI to screen and boot from SD card

3. Fully update Pi

```bash
sudo apt update
sudo apt upgrade
sudo reboot
```

4. Configure settings

`sudo raspi-config`

Change all relevant settings but the most important is to enlarge file system and enable SSH. Change password if you need to.

5. Follow instructions to setup for [pi-led-changer](pi-led-changer/README.md)

6. Follow instructions to setup for [pi-broadcaster](pi-broadcaster/README.md)

7. `reboot`
