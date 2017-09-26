# Pi broadcaster

Swift program that runs on the RPi that broadcasts via BLE and listens to port 55555 for LED details to be passed to `pi-led-changer`. Path obtained via the `SOCKET` environment variable.

## Swift setup steps on RPi

```bash
sudo apt update
sudo apt install libpython2.7 clang

wget https://www.dropbox.com/s/v6oslfta6u773rj/swift-3.1.1-RPi23-RaspbianStretchAug17.tgz
sudo tar -xvf swift-3.1.1-RPi23-RaspbianStretchAug17.tgz -C /
```

## Swift Cross Compilation Toolchain Setup (Optional)
This is in case you wish to cross compile the binary on the Mac. Look at [swift-toolchain-setup.md](swift-toolchain-setup.md)

## App Compilation and Setup Steps on Pi

```bash
# Install Bluetooth headers
git clone https://github.com/PureSwift/CSwiftBluetoothLinux
cd CSwiftBluetoothLinux
sudo cp -r swiftbluetooth /usr/include/

cd ~
cd ble-localiser/pi-broadcaster
swift build

sudo SOCKET=/home/pi/socket.sock ./.build/debug/PiBrc
```

## References
1. [A Small Update on Swift For Raspberry Pi Zero/1/2/3 ](https://www.uraimo.com/2017/09/06/A-small-update-on-Swift-for-raspberry-pi-zero-1-2-3/)
