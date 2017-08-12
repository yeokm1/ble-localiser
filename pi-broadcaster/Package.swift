import PackageDescription

let package = Package(
    name: "PiBrc",
    targets: [
        Target(name: "PiBrc")
    ],
    dependencies: [
        .Package(url: "https://github.com/PureSwift/BluetoothLinux", majorVersion: 2),
        .Package(url: "https://github.com/IBM-Swift/BlueSignals", majorVersion: 0)
    ]
)
