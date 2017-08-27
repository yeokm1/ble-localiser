# Pi broadcaster

Swift program that runs on the RPi that broadcasts via BLE and listens to port 55555 for LED details to be passed to `pi-led-changer`. Path obtained via the `SOCKET` environment variable.

## Swift setup steps on RPi

Download [swift-3.0.2-RPi23-RaspbianNov16.tgz](https://www.dropbox.com/s/kmu5p6j0otz3jyr/swift-3.0.2-RPi23-RaspbianNov16.tgz) and upload it to the RPi like so: `scp swift-3.0.2-RPi23-RaspbianNov16.tgz pi@X.X.X.X:/home/pi/`

```bash
sudo tar -xvf swift-3.0.2-RPi23-RaspbianNov16.tgz -C /
sudo nano /etc/ld.so.conf.d/swift.conf

# Add the following lines to the `swift.conf`
/usr/lib/swift/linux
/usr/lib/swift/clang/lib/linux
/usr/lib/swift/pm
#

sudo ldconfig
```

## Swift Toolchain Setup
Look at [swift-toolchain-setup.md](swift-toolchain-setup.md)

## App Compilation and Setup Steps

On host machine

```bash
/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2017-05-09-a.xctoolchain/usr/bin/swift build --destination ~/swift-toolchain/cross-toolchain/rpi-ubuntu-xenial-destination.json
scp brc-startup.sh brc.service .build/debug/PiBrc  pi@X.X.X.X:/home/pi/
```

On Pi
```bash
# Make program start on boot
chmod +x brc-startup.sh
sudo mv brc.service /etc/systemd/system/
sudo systemctl enable brc.service
```
