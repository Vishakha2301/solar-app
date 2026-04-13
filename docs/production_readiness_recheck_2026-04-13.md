# Production Readiness Recheck (2026-04-13)

## Overall status

**Not production-ready yet.**

The repository still contains release-blocking configuration issues, and this environment cannot execute Flutter/Dart validation commands.

## What was checked

### 1) Build and test toolchain availability

- `flutter --version` → `command not found`
- `dart --version` → `command not found`

Because of this, static analysis, widget tests, and release builds were not runnable in this environment.

### 2) Release configuration

- Android release build is configured to sign with the debug signing key.
  - File: `android/app/build.gradle.kts`
  - Current setting: `signingConfig = signingConfigs.getByName("debug")`
- Android build file still contains TODOs for production app identity/signing setup.

### 3) Runtime API endpoint safety

- Default API base URL is plain HTTP and localhost:
  - File: `lib/core/config/app_config.dart`
  - Current default: `http://localhost:8080`

This is acceptable for local development, but not safe as a production default.

### 4) Codebase hygiene indicators

- A stale TODO remains in an effectively deprecated file:
  - File: `lib/features/costing/domain/config/initial_calculator_state.dart`
  - TODO says the file should be deleted.

### 5) Project quality gates

- No CI workflow directory (`.github/workflows`) is present in this repository snapshot.
- Existing test coverage appears minimal (single widget smoke test in `test/widget_test.dart`).

## Release blockers

1. **Android release signing is using debug key** (hard blocker).
2. **Production-safe API endpoint defaults are not enforced** (hard blocker unless guaranteed by build-time environment injection).
3. **No runnable verification in current environment** (`flutter analyze`, `flutter test`, and release build checks unavailable here).

## Recommended next steps

1. Configure proper release signing for Android (keystore + `signingConfigs.release`).
2. Make `API_BASE_URL` required for release builds and enforce HTTPS in production.
3. Remove deprecated dead file(s) and TODO markers before release cut.
4. Add CI checks at minimum:
   - `flutter format --set-exit-if-changed .`
   - `flutter analyze`
   - `flutter test`
5. Run platform release checks in a Flutter-enabled environment:
   - `flutter build appbundle --release`
   - `flutter build ipa --release` (or Xcode archive pipeline)
