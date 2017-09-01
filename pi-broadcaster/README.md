# Pi broadcaster

Swift program that runs on the RPi that broadcasts via BLE and listens to port 55555 for LED details to be passed to `pi-led-changer`. Path obtained via the `SOCKET` environment variable.

## Swift setup steps on RPi

```bash
wget https://www.dropbox.com/s/kmu5p6j0otz3jyr/swift-3.0.2-RPi23-RaspbianNov16.tgz
sudo tar -xvf swift-3.0.2-RPi23-RaspbianNov16.tgz -C /
sudo nano /etc/ld.so.conf.d/swift.conf

# Add the following lines to the `swift.conf`
/usr/lib/swift/linux
/usr/lib/swift/clang/lib/linux
/usr/lib/swift/pm
#

sudo ldconfig

# Install extra dependency
wget http://ftp.us.debian.org/debian/pool/main/i/icu/libicu52_52.1-8+deb8u5_armhf.deb
sudo dpkg -i libicu52_52.1-8+deb8u5_armhf.deb
```

## Swift Toolchain Setup
Look at [swift-toolchain-setup.md](swift-toolchain-setup.md)

## App Compilation and Setup Steps

### Add Bluetooth headers on host machine (one-time step)

We need to add headers to the `/usr/include` but this directory is protected by System Integrity Protection (SIP). We have to disable that first

1. Boot to recovery mode by pressing CMD+R on startup
2. OS X Utilities > Terminal
3. Type `csrutil disable`
4. Reboot the machine
5. Open terminal and run the following
```bash
# Change to any working directory
git clone https://github.com/PureSwift/CSwiftBluetoothLinux
sudo mkdir -p /usr/include/swiftbluetooth
cd CSwiftBluetoothLinux
sudo cp -r swiftbluetooth /usr/include/swiftbluetooth
```
6. Enable SIP by repeating steps 1-4 except with `csrutil enable`

### Build on host machine

```bash
swift build --destination ~/swift-toolchain/cross-toolchain/rpi-ubuntu-xenial-destination.json
scp brc-startup.sh brc.service .build/debug/PiBrc  pi@X.X.X.X:/home/pi/
```

### On Pi

To just run:
```bash
sudo SOCKET=/home/pi/socket.sock ./PiBrc
```

Make program start on boot:
```bash
chmod +x brc-startup.sh
sudo mv brc.service /etc/systemd/system/
sudo systemctl enable brc.service
```
