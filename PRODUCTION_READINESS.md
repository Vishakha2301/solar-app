# Production Readiness Review

Date: 2026-04-13

## Verdict

- **Public production launch**: Not ready yet.
- **First-client pilot APK (UAT)**: Feasible with controlled rollout.

## Consistency improvements added now

To support your requirement — "change once, consume everywhere" — this codebase now has centralized reusable config layers:

1. **Shared API endpoint catalog**
   - `lib/core/constants/api_endpoints.dart`
   - All repositories + document download now consume endpoint constants/helpers instead of hardcoded URL paths.

2. **Shared app strings**
   - `lib/core/constants/app_strings.dart`
   - Reused app title and logout-related labels in `main.dart` and `app_shell.dart`.

3. **Shared reusable UI component**
   - `lib/shared/widgets/app_loading_view.dart`
   - Used in auth loading state so future loading-screen updates happen in one place.

4. **Shared environment config**
   - `lib/core/config/app_config.dart`
   - Base URL remains configurable via `--dart-define=API_BASE_URL=...`.

## How to build APK for first client (without final DNS)

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR_TEMP_BACKEND_URL
```

Use temporary cloud URL for UAT, then rebuild with final DNS later.

## Remaining items needed for production readiness

### 1) Release engineering
- [x] Replace Android `applicationId`/namespace and iOS bundle id with non-template identifiers (`com.solarerp.app`).
- [ ] Configure production signing key (do not ship debug-signed release). (still pending)
- [ ] Define semantic versioning + release notes policy.

### 2) Quality gates
- [ ] Fix/replace scaffold widget tests with feature tests (auth, costing, quotation).
- [x] Add CI pipeline for `flutter analyze`, `flutter test`, and release build checks (`.github/workflows/flutter-ci.yml`).
- [ ] Add basic API contract/integration checks before release.

### 3) Security and operations
- [ ] Ensure HTTPS backend for client APKs.
- [ ] Add crash reporting and structured logging.
- [ ] Document incident rollback plan for UAT/prod.

### 4) Architecture consistency (next)
- [ ] Add common error model and shared API error mapper.
- [ ] Add shared dialog/snackbar helper widgets for UX consistency.
- [ ] Add shared form validators to reduce duplication.


### 5) Web release readiness
- [ ] Configure hosting (Firebase Hosting / CloudFront / Netlify / Vercel) with HTTPS and cache headers.
- [ ] Set `API_BASE_URL` secret for web builds in CI.
- [ ] Add smoke checks for core web flows after deploy (login, dashboard, CRUD basics).

## Environment note

Flutter is not installed in this container, so I could not run `flutter analyze`, `flutter test`, or produce APK artifacts here.
