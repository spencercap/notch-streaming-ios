# notch-streaming-ios
realtime streaming of bluetooth notches via OSC

[notch-streaming-android](https://github.com/katsully/relevant-motion/) also available


the helpful [notch api reference](https://wearnotch.com/developers/iosdocs/Classes/NotchVisualiserData.html)

## Installing and Running
1. In terminal, ```sudo gem install cocoapods```
2. Add wear notch credentials to ```~/.netrc``` file
3. In terminal, ```pod install```
4. Open Tutorial.xcworkspace, not Tutorial.xcodeprog
	* Note: you will need Swift 4.1 to run code
5. Change the ip address used to initailize the client variable in VisualiserViewController.swift

	
If you want OSC running the background, go to Settings->capabilities, and select uses Bluetooth LE accessories


