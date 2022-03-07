# MobSur-iOS-SDK

---
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
https://github.com/eden-tech-labs/MobSur-iOS-SDK
```
3. Select MobSur-iOS-SDK from the list
4. Select your Target if there is more than one
5. Click Add Package button
    
## Usage
- Import the Package (required)
```swift
import MobSur_iOS_SDK
```

- Initialize the SDK (required)

```swift
MobSurSDK.shared.setup(appID: appID, userID: userID)
// OR
MobSurSDK.shared.setup(appID: appID) // In case you do not have the user id
```

- Trigger an event

```swift
MobSurSDK.shared.event(name: eventName)
```

- Change user identifier

```swift
MobSurSDK.shared.updateUser(id: newUserId)
```
    
## More info

The user id is required to distinguish the users and in the future you will be able to make user specific surveys, mainly for testing.
