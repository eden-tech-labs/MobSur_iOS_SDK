# MobSur iOS SDK

## Table of contents
* [Requirements](#requirements) (public)
* [Setup](#setup) (public)
* [Usage](#usage) (public)
* [Building SDK](#building) (private)

## Requirements
- Platform: iOS (version >= 12)
- Supported Destinations: iPhone and iPad
- Minimum version of Swift: 4.0

## Install the SDK
### Using Swift Package Manager
1. In Xcode, go to File > Add Packages...
2. In the search bar on the top right corner of the newly opned window enter
```
https://github.com/eden-tech-labs/MobSur_iOS_SDK
```
3. Select MobSur-iOS-SDK from the list
4. Select your Target if there is more than one
5. Click Add Package button
6. Proceed to the **Usage** section of this document

### Using Cocoapods
If this is your first pod dependency, follow the instructions on [cocoapods.org](https://cocoapods.org)
If you already have `Podfile` in your project you should add the following:
```
target 'YourAppTarget' do

    #Other Pod related information

    pod 'MobSurSDK', '~> 1.0.3'
end
```

After that open the console, navigate to the project directory and run `pod install`
The pod should be installed and you can proceed to the **Usage** section of this document.

### Without package manager (offline)
This type of installation is suitable if you want to keep everything related to your project local and do not depend on the network traffic.

1. Download the SDK from [https://github.com/eden-tech-labs/MobSur_iOS_SDK](https://github.com/eden-tech-labs/MobSur_iOS_SDK)
2. Open your project or workspace in XCode
3. In the **Project Navigator** (shortcut **⌘** + 1) select the project.
4. In the newly opened project preview, select your **target.**
5. Then in **general** tab scroll to Frameworks, **Libraries, and Embedded Content** and click the + button under the list
6. In the drop down, on the bottom left corner of the popup select **Add files**.
7. Locate the downloaded (unarchived) SDK and select **MobSur_iOS_SDK.xcframework**
8. Then proceed to the **Usage** section of this document.
  
## Usage
### Import the Package (required)
```swift
import MobSur_iOS_SDK
```

### Initialize the SDK (required)

**For UIKit:**

```swift
import UIKit
import MobSur_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: 
	[UIApplication.LaunchOptionsKey: Any]?) -> Bool {
	  
		// userID and debug are optional parameters
		// If you do not know the user id at this point your can pass nil and set it later
		MobSurSDK.shared.setup(appID: "YourAppID", userID: "123", debug: true)
	  
		// Remaining contents of didFinishLaunchingWithOptions method  
	  
	  return true
	}
  
// Remaining contents of your AppDelegate Class
}

```

**For Swift UI:**


```swift
import SwiftUI
import MobSur_iOS_SDK


// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        MobSurSDK.shared.setup(appID: "YourAppID", userID: "123", debug: true)
        return true
    }
}

@main
struct MyAppName: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

```


> :warning: **If you do not provide userID**: In this case, to receive surveys, somewhere in the user flow you should call `MobSurSDK.shared.updateUser(id: newUserId)`

> If you want to check if everything works as expected, you can use the `debug` parameter on the `setup` function. This will print information about the received surveys and tracked events.  
> `MobSurSDK.shared.setup(appID: appID, userID: userID, debug: true)`

### Trigger an event

```swift
MobSurSDK.shared.event(name: eventName)
```

### Change user identifier

```swift
MobSurSDK.shared.updateUser(id: newUserId)
```

## FAQ

- My surveys do not appear on the first event:

This may happen if you fire the `event` method too soon after the `setup` or `updateUser` methods.
After the SDK receives the userID, it requests the surveys from the server.
If you fire an event before you have survey for this event, it's ignored.
    
## More info

The user id is required to distinguish the users and in the future you will be able to make user specific surveys, mainly for testing.
