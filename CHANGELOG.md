# Changelog

## 1.2.0

In-app message experiments with a holdout, matching the Flutter SDK 2.1.1. Source-compatible with
1.1.0 apart from the minimum iOS version.

### Added
- **In-app message experiments.** The fetch response's `experiments` list is parsed (unusable entries
  are skipped one by one). `event(name:)` checks experiments before surveys, with the same occurrence
  counting (counters per experiment), and experiments share the one-per-session rule with surveys.
  - `treatment`: after the rule's delay, shows a native bottom sheet (optional image, title, body, call
    to action, dismiss) in system fonts and colors, light and dark, with your app's tint color on the
    call to action. Reports `exposed`.
  - `control`: shows nothing, still reports `exposed`, and uses the session's slot.
  - Each experiment runs at most once per person on the device.
- `setAttributes(_:)`: strings, numbers and booleans, merged into the attributes kept on the device; a
  `nil` value removes a key. They are sent with each fetch as the `attributes` query parameter (JSON).
  A change fetches again without resetting event counts, and no experiment runs until that fetch
  succeeds. Can be called before `setup`.
- `onAction`: receives the call to action (for example `myapp://paywall`) after the sheet has closed.
  Without it, the action is opened with `UIApplication.open(_:)`.
- `canShowOverlay`: checked right before a survey or message would appear. Returning `false` skips it
  without reporting anything or using the session's slot.
- Experiment events (`exposed`, `cta_tapped`, `dismissed`) go to `POST /api/experiments/{id}/events`
  through a persisted, in-order queue. Each event keeps a client-generated `event_id`, so retries are
  idempotent, and the server it was created for, so a later `setup` with another base URL never
  receives it. Failed sends are retried with backoff (5 s doubling up to 1 h, and again at the next
  launch) until the server answers 2xx. Other 4xx answers (except 408/429) drop the event, and so does
  7 days of the server refusing it. Only time between two refusals counts: an attempt that finds the
  device offline ends the streak.

### Changed
- **Minimum iOS is 15.0** in the binary, `Package.swift` and the podspec. Xcode 27 cannot build for
  older targets.
- A survey or experiment that cannot appear when its delay elapses (no host UI, or `canShowOverlay`
  said no) no longer counts the event that selected it, so a rule that matches a single occurrence
  gets another chance.
- Changing the user also clears the cached experiments and their counters, and drops a survey or
  experiment still waiting for its delay. Attributes are kept, and experiments already run are
  remembered per app ID and user ID, so switching accounts and back never runs one twice.
- `canShowOverlay` is app code: after it returns `true`, the SDK checks again that the person, their
  experiments and the pending decision are unchanged, and that the host UI can still show a sheet,
  before showing anything. Both arms go through the same checks, so a gate that changes the screen
  drops control just as it drops treatment.
- Requests send `sdk=ios-1.2.0`.

## 1.1.0

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
