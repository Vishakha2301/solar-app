# Production Readiness Review

Date: 2026-04-13

## Verdict

**For public production launch: Not ready.**  
**For first-client pilot APK: Feasible with a controlled UAT setup.**

You can ship an APK to your first client **without final DNS** by hosting backend on cloud and passing a temporary backend URL at build time.

## What changed to support your rollout idea

- Added compile-time API base URL support using `--dart-define=API_BASE_URL=...`.
- Network clients now read `AppConfig.apiBaseUrl` instead of hardcoding `http://localhost:8080`.

## How to run pilot without final DNS

1. Deploy backend to cloud with a reachable URL (temporary domain or public IP).
2. Build APK with backend URL embedded:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR_TEMP_BACKEND_URL
```

3. Share APK with your client for UAT.
4. Keep DNS/domain finalization for later; when ready, rebuild APK with the final URL.

## Remaining launch blockers (for real production)

1. **Android app id is still template**
   - `applicationId = "com.example.solar_app"` must be replaced.

2. **Android release signing is debug**
   - Release build is still signed with debug key.

3. **Default metadata/branding remains**
   - Android label and iOS bundle name still show scaffold defaults.

4. **Automated tests are scaffold-level**
   - Widget test is the default counter test and not aligned with current app flows.

5. **Cleanup TODO remains**
   - `initial_calculator_state.dart` still contains deletion TODO.

## Recommended next steps (priority order)

- [ ] Set real Android application id and iOS bundle id.
- [ ] Configure proper release signing for Android.
- [ ] Replace scaffold metadata/icons with client-facing branding.
- [ ] Add at least smoke tests for login + quotation creation flows.
- [ ] Remove release-impact TODOs.
- [ ] Add CI to run analyze + test before every release.

## Environment note

Flutter is not installed in this container, so I could not run `flutter analyze`, `flutter test`, or generate an APK here. This assessment is based on source inspection and configuration updates.
