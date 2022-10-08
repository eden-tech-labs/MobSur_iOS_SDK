# MobSur iOS SDK

## Table of contents
* [Requirements](#requirements) (public)
* [Setup](#setup) (public)
* [Usage](#usage) (public)
* [Building SDK](#building) (private)

## Requirements
- Platform: iOS (version >= 12)

## Setup
1. In Xcode, go to File > Add Packages...
2. In the search bar on the top right corner of the newly opned window enter
```
https://github.com/eden-tech-labs/MobSur_iOS_SDK
```
3. Select MobSur-iOS-SDK from the list
4. Select your Target if there is more than one
5. Click Add Package button
    
## Usage
### Import the Package (required)
```swift
import MobSur_iOS_SDK
```

### Initialize the SDK (required)

```swift
MobSurSDK.shared.setup(appID: appID, userID: userID)

// --- OR ---

// In case you do not have the user id during the setup
MobSurSDK.shared.setup(appID: appID)
```

> :warning: **If you do not provide userID**: In this case, to receive surveys, somewhere in the user flow you should call `MobSurSDK.shared.updateUser(id: newUserId)`

### Trigger an event

```swift
MobSurSDK.shared.event(name: eventName)
```

### Change user identifier

```swift
MobSurSDK.shared.updateUser(id: newUserId)
```

## FAQ

- My surveys do not appear on the first event
This may happen if you fire the `event` method too soon after the `setup` or `updateUser` methods.
After the SDK receives the userID, it requests the surveys from the server.
If you fire an event before you have survey for this event, it's ignored.
    
## More info

The user id is required to distinguish the users and in the future you will be able to make user specific surveys, mainly for testing.
