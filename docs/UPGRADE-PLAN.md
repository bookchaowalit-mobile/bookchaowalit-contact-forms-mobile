# Upgrade Plan — Contact Forms Mobile

## Current state

Score: 7.5/10 — validated, persisted contact form with unicode-correct limits, a11y guideline tests and fail-closed signing; no real delivery, icon or E2E flow yet.

## Backlog

### P0
- None open. (Release signing now fails closed without `android/key.properties`.)

### P1
- Optional real delivery: share the message via the platform share sheet or `mailto:` (no backend secrets in the app).
- Replace the template launcher icon with a real app icon (the application ID `com.bookchaowalit.*` is already set).
- Add a Maestro smoke flow for the main journey.
- Add a CI job that builds a signed release bundle from repository secrets (keystore decoded at runtime, never committed).

### P2
- Tablet layout (NavigationRail).
- Localisation (Thai/English) for UI strings.

## Done in this pass (pass 3)

- Bug fix: length limits used `String.length` (UTF-16 code units) while the `TextField` counter counts grapheme clusters, so a name of 41–80 emoji showed e.g. `80/80` but failed with "at most 80 characters" (same for Thai with combining marks, subject and message). Validators now use `visibleLength` (package `characters`, now a direct dependency).
- Bug fix: emails with a leading/trailing dot in the local part (`.ada@x.com`, `ada.@x.com`) or a local part over 64 characters were accepted.
- Edge-case unit tests: emoji/skin-tone/Thai lengths, whitespace-only input, `null`, email local-part rules, JSON round trip with Thai/emoji text.
- Widget tests: 80-emoji name submits, delete empties the list, a11y guidelines (tap target, labels, contrast), 200% text scale.

## Done in pass 2

- Release builds no longer sign with the debug key: `android/app/build.gradle.kts` reads the ignored `android/key.properties` and a Gradle guard fails any release assemble/bundle without it (pattern from `bookchaowalit-goal-tracker-mobile`). Root `.gitignore` also ignores `key.properties`, `*.jks`, `*.keystore`; README documents the setup. Not build-verified here (no Android SDK/Gradle in this environment).
- Submitted messages now persist on device via `lib/data/list_repository.dart` (`ListRepository` interface, `shared_preferences` JSON store that skips malformed records, in-memory store for tests); the "saved on this device" SnackBar is now true. Added a delete button per message and an error line when storage fails.
- Added repository tests (round trip, empty, malformed records, non-list payload) and widget tests for restore/delete and load failure.

## Done in pass 1

- Replaced the Expo/npm CI (which could never fail) with fail-closed Flutter CI: `dart format` check, `flutter analyze`, `flutter test`, debug APK on `main`.
- Implemented the core feature (build and validate a contact message, then review what you submitted) with pure-Dart logic in `lib/logic/`.
- Replaced placeholder Explore/Profile tabs with an About screen describing features and privacy.
- Added unit tests for the logic and widget tests for the main journey.
- Removed unused `go_router` / `flutter_riverpod` dependencies; README now matches the code.
