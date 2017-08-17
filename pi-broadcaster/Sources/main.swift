import BluetoothLinux
import Glibc
import Signals
import Socket

import Foundation


/// Well known iBeacon UUID
let iBeaconUUID = Foundation.UUID(rawValue: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!

var adapter: Adapter?
var listenSocket: Socket?

var colour: String
let portNumber: Int = 55555

func cleanupBeforeExit(){
	do {
			listenSocket?.close()
			try adapter?.enableAdvertising(false)
	} catch {
			print("Error disabling advertising")
	}
}

Signals.trap(signal: .int) { signal in
	print("Got Signal \(signal). Stop advertising before quit")
	cleanupBeforeExit()
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
    let output = String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
		let trimmed = output?.trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmed
}

if let valueRead = ProcessInfo.processInfo.environment["PIB-COLOUR"] {
    colour = valueRead
		print("Provided colour code is \(colour)")
} else {
		print("Colour code not provided in PIB-COLOUR environment variable")
		exit(1)
}

print("Adjusting device name...")

let ipAddr: String? = run("hostname -I")

//Reset BLE state in case there are issues
run("hciconfig hci0 down")
run("hciconfig hci0 up")

//TODO: Don't force unwrap ipAddr
let localName = "pib-" + colour + "-" + ipAddr!
print("Local name: " + localName)

run("hciconfig hci0 name " + localName)

//Reset again to let the new device name take effec
run("hciconfig hci0 down")
run("hciconfig hci0 up")


do {
    adapter = try Adapter()

    print("Found Bluetooth adapter with device ID: \(adapter!.identifier)")
    print("Address: \(adapter!.address!)")

    try adapter!.enableBeacon(UUID: iBeaconUUID, major: 1, minor: 1, RSSI: -63, interval: 100)

} catch {
    print("Error in bluetooth \(error)")
		exit(2)
}


do {
	listenSocket = try Socket.create(family: Socket.ProtocolFamily.inet, type: Socket.SocketType.datagram, proto: Socket.SocketProtocol.udp)

	while true {
		var incomingData: Data = Data()

		let (_, address) = try listenSocket!.listen(forMessage: &incomingData, on: portNumber)
		let (remoteHost, remotePort) = Socket.hostnameAndPort(from: address!)!

    if let incomingStr = String(data: incomingData, encoding: String.Encoding.ascii) {
			print("From \(remoteHost):\(remotePort), data \(incomingStr)")
		}

	}


} catch {
	cleanupBeforeExit()
	exit(3)
}
