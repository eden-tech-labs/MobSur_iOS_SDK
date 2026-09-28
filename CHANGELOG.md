# Changelog

## 1.1.0 (unreleased)

Implements the shared MobSur mobile SDK contract, so iOS, Android and Flutter behave the same way.
The public API is source-compatible with 1.0.x.

### Added
- `setup(appID:userID:debug:baseURL:)` to point the SDK at another server (local testing). Replaces the
  separate staging build.
- `MobSurSDK.sdkVersion`.
- Privacy manifest (`PrivacyInfo.xcprivacy`) in the framework: no tracking; `UserDefaults` accessed for
  reason `CA92.1`; collected data declared (user ID, survey answers, survey interactions, country
  derived from IP), all linked to the user and none used for tracking.
- Requests now send `sdk=ios-1.1.0`, `Accept: application/json` and always an `Accept-Language` header
  (falls back to `en`), and `app_version=0.0` when the host app has no marketing version.
- Without a user ID the SDK generates a random UUID once, persists it and reuses it.
- Surveys are refreshed on an `event` call when no request has been attempted for 6 hours in the app
  session. Only one request runs at a time.
- Completion is also detected when the survey reaches `/survey/success/…` (the sheet stays open until
  the person taps Finish or close), and completed survey ids are remembered.

### Changed
- `platform` is always `ios` (1.0.x sent `UIDevice.systemName`: `iOS`, or `iPadOS` on iPad).
- Minimum iOS is 12.0 in the binary, `Package.swift` and the podspec (binary was 13.0, podspec 14.0).
  Podspec `swift_version` is 5.0.
- Occurrence counting follows the contract: counters are per (survey, event), persisted, walked in
  server order, and only surveys up to the first eligible one are counted. Events are not evaluated or
  counted while a survey is waiting for its delay, is on screen, or has been shown in this session.
- A survey with several rules for the same event is eligible if any of them matches.
- Start and end dates are inclusive; a `null` bound is open.
- Changing the user ID clears the cached surveys, counters and completed ids, then fetches for the new
  person. A response still in flight for the previous user is discarded.
- `4xx` responses other than `408`/`429` clear the cached surveys. `408`, `429`, `5xx`, network errors,
  timeouts and non-JSON `200` bodies keep them.
- Counters and completed ids are pruned to the surveys the server still returns.
- The survey sheet is presented from the key window of the foreground scene instead of the deprecated
  `UIApplication.windows`, and is dropped (so a later event can retry) when no presenter is available.
- The user ID is percent-encoded strictly, so IDs containing `+` reach the server unchanged.
- Debug output goes to the unified log (`com.mobsur.sdk`) with a `MobSur:` prefix.
- Storage keys moved from `MobSur_106_*` to `MobSur_*`. The 1.0.x user ID and counters are migrated.

### Fixed
- One survey with an unknown rule type, a malformed field or an unexpected date format no longer
  empties the whole survey list.
- A `403` at the tracked-user limit no longer leaves previously cached surveys live.
- A completed survey could reappear after a refetch; its id is now remembered.

### Removed
- The `MobSur_iOS_SDK_Staging` framework and the `STAGING` build flag (the staging server no longer
  exists).

## 1.0.3

Last release before the 1.1.0 rewrite.
