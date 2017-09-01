import BluetoothLinux
import Glibc
import Signals
import Socket

import Foundation


/// Well known iBeacon UUID
let iBeaconUUID = Foundation.UUID(rawValue: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!

var adapter: Adapter?
var listenSocket: Socket?
var outUnixSocket: Socket?

var unixSocketPath: String?

let portNumber: Int = 55555

unixSocketPath = ProcessInfo.processInfo.environment["SOCKET"]

if unixSocketPath == nil {
	print("Missing SOCKET environment variable")
} else {
	print("Unix socket to connect to LED changer is " + unixSocketPath!)
}



func cleanupBeforeExit(){
	do {
			listenSocket?.close()
			outUnixSocket?.close()
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
func run(_ cmd: String) -> String{
		 var outstr = ""
		 let task = Task()
		 task.launchPath = "/bin/sh"
		 task.arguments = ["-c", cmd]

		 let pipe = Pipe()
		 task.standardOutput = pipe
		 task.launch()

		 let data = pipe.fileHandleForReading.readDataToEndOfFile()
		 if let output = String(data: data, encoding: String.Encoding.utf8) {
				 outstr = output as String
		 }

		 task.waitUntilExit()
		//  let status = task.terminationStatus
		//  print(status)

		 return outstr.trimmingCharacters(in: .whitespacesAndNewlines)
 }

print("Adjusting device name...")

let ipAddr: String? = run("hostname -I")

//Reset BLE state in case there are issues
run("hciconfig hci0 down")
run("hciconfig hci0 up")

//TODO: Don't force unwrap ipAddr
print("IP address is " + ipAddr!)

let addressComponents: [String] = ipAddr!.components(separatedBy: ".")
let lastOctet: String = addressComponents[addressComponents.count - 1]


let hcitoolDevOutput: String? = run("hcitool dev")

let macAddrComponents: [String] = hcitoolDevOutput!.components(separatedBy: ":")
let maclastOctet: String = macAddrComponents[macAddrComponents.count - 1]


let localName = "pib-" + maclastOctet + "-" + lastOctet


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

if unixSocketPath != nil {

	do{
		outUnixSocket = try Socket.create(family: Socket.ProtocolFamily.unix, type: Socket.SocketType.stream, proto: Socket.SocketProtocol.unix)
		try outUnixSocket!.connect(to: unixSocketPath!)
	} catch {
	    print("Error in creating/connecting to Unix Socket \(error)")
	}
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

		try outUnixSocket?.write(from: incomingData)

	}


} catch {
  print("Error in getting data \(error)")
	cleanupBeforeExit()
	exit(3)
}
