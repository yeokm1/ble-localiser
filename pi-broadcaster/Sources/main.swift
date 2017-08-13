import BluetoothLinux
import Glibc
import Signals

import Foundation


/// Well known iBeacon UUID
let iBeaconUUID = Foundation.UUID(rawValue: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!

var adapter: Adapter?
var colour: String


Signals.trap(signal: .int) { signal in
	print("Got Signal \(signal). Stop advertising before quit")

    do {
        try adapter?.enableAdvertising(false)
        sleep(1)
    } catch {
        print("Error disabling advertising")
    }
}

@discardableResult
func run(_ cmd: String) -> String? {
    let pipe = Pipe()
    let process = Process()
    process.launchPath = "/bin/sh"
    process.arguments = ["-c", cmd]
    process.standardOutput = pipe
    let fileHandle = pipe.fileHandleForReading
    process.launch()
    return String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
}

if let valueRead = ProcessInfo.processInfo.environment["PIB-COLOUR"] {
    colour = valueRead
		print("Provided colour code is \(colour)")
} else {
		print("Colour code not provided in PIB-COLOUR environment variable")
		exit(1)
}


print("Adjusting device name")


let ipAddr: String? = run("hostname -I")

if ipAddr != nil {
  print(ipAddr!)
}

//Reset BLE state in case there are issues
run("hciconfig hci0 down")
run("hciconfig hci0 up")

//TODO: Don't force unwrap ipAddr
let localName = "pib-" + colour + "-" + ipAddr!
print("Localname: " + localName)

run("hciconfig hci0 name " + localName)

//Reset again to let the new device name take effec
run("hciconfig hci0 down")
run("hciconfig hci0 up")




do {
    let adapter = try Adapter()


    print("Found Bluetooth adapter with device ID: \(adapter.identifier)")


    print("Address: \(adapter.address!)")


    try adapter.enableBeacon(UUID: iBeaconUUID, major: 1, minor: 1, RSSI: -63, interval: 50)

    //Pause forever
    select(0, nil, nil, nil, nil)

} catch {
    print("Error in bluetooth \(error)")

}
