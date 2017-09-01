# Swift 3.0.2 cross-compiling toolchain setup

This is a set of instructions that shows up how to set up a Swift 3.0.2 cross-compilation tool-chain for the Raspbian platform on Mac OS.

## Instructions

### Download and install Swift Snapshot
Download and install this Swift 2017-05-09 snapshot. I tried the newer versions but they don't work.

```bash
wget https://swift.org/builds/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2017-05-09-a/swift-DEVELOPMENT-SNAPSHOT-2017-05-09-a-osx.pkg
```

### Install Swift Env and Swift snapshot

This allows one to switch between versions of Swift.

```bash
brew install kylef/formulae/swiftenv
echo 'if which swiftenv > /dev/null; then eval "$(swiftenv init -)"; fi' >> ~/.bash_profile
eval "$(swiftenv init -)"

# Switch to the downloaded Swift snapshop
swiftenv global DEVELOPMENT-SNAPSHOT-2017-05-09-a
```

### Build the toolchain

```bash
cd ~
mkdir swift-toolchain
cd swift-toolchain

wget https://www.dropbox.com/s/kmu5p6j0otz3jyr/swift-3.0.2-RPi23-RaspbianNov16.tgz

curl https://raw.githubusercontent.com/helje5/dockSwiftOnARM/master/toolchain/build_rpi_ubuntu_cross_compilation_toolchain \
  | sed "s/$(printf '\r')\$//" \
  > build_rpi_ubuntu_cross_compilation_toolchain
chmod +x build_rpi_ubuntu_cross_compilation_toolchain

./build_rpi_ubuntu_cross_compilation_toolchain \
~/swift-toolchain \
~/swift-toolchain/swift-3.0.2-RELEASE-osx.pkg \
~/swift-toolchain/swift-3.0.2-RPi23-RaspbianNov16.tgz
```

### Build Swift Package Manager

```bash
git clone https://github.com/apple/swift-package-manager.git
cd swift-package-manager

## Go the April 30 version as the diff has been tested to be valid for this version
git checkout 09a6bf19b4e31d9348d98efd9db09298da152315

nano file.diff

# Paste the following into the text editor
# We patch the SPM to not call pass the -swift-version parameter as the Swiftc 3.0.2 compiler
diff --git a/Sources/Build/BuildPlan.swift b/Sources/Build/BuildPlan.swift
index 5c48fb57..af50f539 100644
--- a/Sources/Build/BuildPlan.swift
+++ b/Sources/Build/BuildPlan.swift
@@ -260,7 +260,7 @@ public final class SwiftTargetDescription {
     /// The arguments needed to compile this target.
     public func compileArguments() -> [String] {
         var args = [String]()
-        args += ["-swift-version", String(swiftVersion)]
+        //args += ["-swift-version", String(swiftVersion)]
         args += buildParameters.toolchain.extraSwiftCFlags
         args += buildParameters.swiftCompilerFlags
         args += optimizationArguments
diff --git a/Sources/PackageLoading/ManifestLoader.swift b/Sources/PackageLoading/ManifestLoader.swift
index 9f8f3cbd..02cde4be 100644
--- a/Sources/PackageLoading/ManifestLoader.swift
+++ b/Sources/PackageLoading/ManifestLoader.swift
@@ -306,7 +306,7 @@ public final class ManifestLoader: ManifestLoaderProtocol {
     ) -> [String] {
         var cmd = [String]()
         let runtimePath = self.runtimePath(for: manifestVersion)
-        cmd += ["-swift-version", String(manifestVersion.rawValue)]
+        //cmd += ["-swift-version", String(manifestVersion.rawValue)]
         cmd += ["-I", runtimePath.asString]
       #if os(macOS)
         cmd += ["-target", "x86_64-apple-macosx10.10"]
### End

patch -p1 < file.diff
swift build

## U can temporarily replace Swift Build with the one that can cross-compile
cd /Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2017-05-09-a.xctoolchain/usr/bin/
sudo mv swift-build swift-build.old
sudo cp ~/swift-toolchain/swift-package-manager/.build/debug/swift-build /Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2017-05-09-a.xctoolchain/usr/bin/
```

## To cross compile Swift programs for RPi
```bash
cd your-project-directory
swift build --destination /tmp/cross-toolchain/rpi-ubuntu-xenial-destination.json
# or
/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2017-05-09-a.xctoolchain/usr/bin/swift build --destination /tmp/cross-toolchain/rpi-ubuntu-xenial-destination.json
```


## References
1. [Cross compile toolchain for RPi on Ubuntu ](https://github.com/helje5/dockSwiftOnARM/blob/master/toolchain/README.md)
2. [Swift 3.1.1 For Raspberry Pi Zero/1/2/3](https://www.uraimo.com/2017/05/01/An-update-on-Swift-3-1-1-for-raspberry-pi-zero-1-2-3/)
