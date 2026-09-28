# MobSur iOS SDK

Show [MobSur](https://mobsur.com) in-app surveys when events in your app match the rules your team sets
in the MobSur dashboard.

> **Release status:** 1.1.0 is prepared on the `sdk-contract-1.1` branch but has **not been tagged,
> pushed or published to CocoaPods trunk yet**. Until it is, install it from a local checkout (see below).
> The `from: "1.1.0"` / `~> 1.1` lines only work once the release exists.

## Table of contents
* [Requirements](#requirements)
* [Install](#install)
* [Usage](#usage)
* [How surveys are chosen](#how-surveys-are-chosen)
* [Identity and monthly tracked users](#identity-and-monthly-tracked-users)
* [Privacy](#privacy)
* [Migrating from 1.0.x](#migrating-from-10x)
* [FAQ](#faq)

## Requirements
- iOS 12.0 or later, iPhone and iPad
- Xcode 26 or later. The binary is built with Xcode 26.6 (Swift 6.3, Swift 5 language mode, library
  evolution enabled); Xcode 26.6 is the version it has been verified with.

## Install

### Swift Package Manager
Once 1.1.0 is tagged:
1. In Xcode, choose **File > Add Package Dependencies…**
2. Enter `https://github.com/eden-tech-labs/MobSur_iOS_SDK` and pick **Up to Next Major Version** from `1.1.0`.
3. Add the **MobSur_iOS_SDK** library to your app target.

Or in `Package.swift`:
```swift
.package(url: "https://github.com/eden-tech-labs/MobSur_iOS_SDK", from: "1.1.0")
```

Until then, clone this repository and use **File > Add Package Dependencies… > Add Local…**, or
`.package(path: "../MobSur_iOS_SDK")`.

### CocoaPods
Once 1.1.0 is on CocoaPods trunk:
```ruby
pod 'MobSurSDK', '~> 1.1'
```
Until then, point at a local checkout:
```ruby
pod 'MobSurSDK', :path => '../MobSur_iOS_SDK'
```
Then run `pod install`.

### Manually
Drag `MobSur_iOS_SDK.xcframework` into your project, and under your target's **General > Frameworks,
Libraries, and Embedded Content** set it to **Embed & Sign**.

## Usage

### Set up the SDK

```swift
import MobSur_iOS_SDK
```

Call `setup` once at launch. **UIKit:**

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    MobSurSDK.shared.setup(appID: "YourAppID", userID: currentUser?.id, debug: false)
    return true
}
```

**SwiftUI:**

```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        MobSurSDK.shared.setup(appID: "YourAppID", userID: currentUser?.id, debug: false)
        return true
    }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene { WindowGroup { ContentView() } }
}
```

- `appID`: the App ID from the MobSur dashboard.
- `userID` (optional): a stable identifier for the person. Read
  [Identity](#identity-and-monthly-tracked-users) before passing `nil`.
- `debug` (optional): logs what the SDK does (requests, received surveys, rule decisions) to the
  console with a `MobSur:` prefix. Nothing is logged when it is `false`.

Every method can be called from any thread and never throws. Calls made before `setup` are ignored.

### Send events

```swift
MobSurSDK.shared.event(name: "negative_id_feedback")
```

Use the same event names as the dashboard rules; matching is exact and case-sensitive.

### Change the user

```swift
MobSurSDK.shared.updateUser(id: newUserID)
```

When the ID differs from the current one, the SDK forgets the previous person's cached surveys,
occurrence counters and completed surveys, and fetches surveys for the new person.

### Point at another server (local testing)

```swift
MobSurSDK.shared.setup(appID: "YourAppID", userID: "tester-1", debug: true,
                       baseURL: URL(string: "http://localhost:8000"))
```

The SDK requests `<baseURL>/api/surveys`. `nil` (the default) uses `https://api.mobsur.com`. Plain-HTTP
hosts need an App Transport Security exception in your app's Info.plist, e.g. `NSAllowsLocalNetworking`.

## How surveys are chosen

A survey's launch settings in the dashboard map to one rule: an **event name**, **From occurrence**
(minimum, default 1), **Through occurrence** (maximum, optional) and **Delay after event** (0–5 s).

When `event(name:)` is called:

1. If a survey is already waiting for its delay, is on screen, or has been shown since the app was
   launched, nothing happens and nothing is counted. **At most one survey is shown per app session.**
2. Otherwise the SDK walks the surveys in the order the server sent them (priority order). A survey is
   skipped if the current time is outside its start/end dates, if it was completed on this device, or if
   it has no rule for this event name.
3. For each remaining survey, the counter for *(that survey, this event)* goes up by one. The survey is
   eligible when **From occurrence ≤ count ≤ Through occurrence**. For example "from 3" asks on the third
   and every later occurrence; "from 1 through 2" asks on the first two only.
4. The first eligible survey is shown after its delay; surveys further down the list are not counted.
   If the app cannot present it when the delay elapses (app in the background, an alert or a transition
   on screen), it is dropped and a later event may try again.

Counters are stored on the device, survive app restarts, and are dropped for surveys the server stops
returning.

The survey opens in a sheet with a close button. It counts as **completed** when the person finishes it
(the sheet closes on its own, or they tap Finish on the thank-you page). A completed survey is not shown
again on that device, and the server stops sending surveys a person has answered. Closing the sheet
early does not complete it: a later session can show it again while the occurrence window allows it, so
use **Through occurrence** to limit repeats.

### When the SDK talks to the server
- On `setup`, when the user ID changes, and on an `event` call when no request has been attempted for
  6 hours in this app session. The refresh never delays the event that triggered it.
- If the server says there is nothing to show (a `4xx` such as `403` when the MobSur plan's monthly
  tracked user limit is reached), the cached surveys are cleared. On network errors, timeouts, `408`,
  `429` or `5xx`, the SDK keeps using the surveys it already has.

## Identity and monthly tracked users

Pass a stable ID for the person (your account ID, for example). MobSur uses it for sampling,
"already answered" and cooldowns, and **each distinct ID counts as one monthly tracked user**.

If you pass `nil`, the SDK reuses the ID it stored earlier; only if it has never had one does it generate
a random UUID, once, and keep it. It never generates a new ID per launch.

## Privacy

The framework ships a privacy manifest (`PrivacyInfo.xcprivacy`), which Xcode includes in your app's
privacy report:

- **Tracking:** no; no tracking domains.
- **Required-reason API:** `UserDefaults` (reason `CA92.1`). The SDK stores only the cached survey list,
  the occurrence counters, completed survey ids and the user ID, under keys prefixed `MobSur_`.
- **Collected data** (all linked to the user ID, none used for tracking):
  - *User ID*: the ID you pass (or the generated one) is sent with every request and stored by MobSur.
  - *Other User Content*: the answers people give in surveys.
  - *Product Interaction*: when a survey was received, opened, started and completed.
  - *Coarse Location*: MobSur derives the country from the request IP for targeting and reporting.

Each request also sends your app's version, the platform (`ios`), the SDK version and the device's
preferred languages. Event names and counts stay on the device. Use this list when you fill in your
App Store privacy details.

## Migrating from 1.0.x

1.1.0 is source-compatible: `setup(appID:userID:debug:)`, `updateUser(id:)` and `event(name:)` are
unchanged. Things to know:

- **Minimum iOS is 12.0** in the binary, `Package.swift` and the podspec (1.0.3's binary required 13.0
  and its podspec said 14.0).
- **`platform` is always `ios`**, including on iPad (1.0.x sent `UIDevice.systemName`, which is `iPadOS`
  there). Review dashboard targeting that relied on it.
- **No user ID?** 1.0.x fetched nothing until a user ID was set. 1.1.0 generates a random ID once and
  keeps it; that ID counts as a monthly tracked user. If you call `updateUser(id:)` later, switching from
  the generated ID to yours resets the occurrence counters.
- **Changing the user resets** the cached surveys, occurrence counters and completed surveys.
- **Server rejections clear the cache**: a `4xx` (for example `403` at the tracked-user limit) empties the
  survey list instead of leaving old surveys live.
- **Completed surveys are remembered**, so a stale cache cannot show them again.
- **Nothing is counted while a survey is waiting or on screen**, and after a survey was shown in the
  session (1.0.x kept counting).
- **Several rules for the same event**: a survey is eligible if any of them matches (1.0.x gave up on the
  survey when the first rule did not match).
- **Start and end dates are inclusive.**
- **Unknown rule types or bad entries** no longer break the whole list; only that rule or survey is
  skipped.
- **Stored data is migrated**: the user ID and occurrence counters saved by 1.0.x are kept on upgrade,
  so no new tracked user is created and occurrence windows continue.
- **Staging builds are gone.** Use `setup(appID:userID:debug:baseURL:)` to point at another server.
- The SDK now ships a privacy manifest (see [Privacy](#privacy)).

See [CHANGELOG.md](CHANGELOG.md) for the full list.

## FAQ

**My survey does not appear on the first event.**
The SDK can only match events against surveys it has already received. If you call `event` right after
`setup` or `updateUser`, the request may not have finished yet. Turn on `debug: true` to see when surveys
arrive and why an event did or did not match.

**A survey appeared once and never again in the same session.**
That is the one-survey-per-session rule. Relaunch the app to start a new session.
