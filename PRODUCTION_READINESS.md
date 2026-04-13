# Production Readiness Review

Date: 2026-04-13

## Verdict

- **Public production launch**: Not ready yet.
- **First-customer pilot release (mobile/web UAT)**: Feasible with controlled rollout after the **must-do** items below are completed.

## Must-do before first customer release

These are the minimum blockers to clear before handing this to a first paying customer:

1. Configure production Android signing key (avoid debug-signed release artifact).
2. Enforce quality gate execution in CI (`flutter analyze`, `flutter test`, release build).
3. Ensure production backend URL is HTTPS for all clients (mobile + web).
4. Prepare a rollback runbook (owner + trigger + rollback steps).

If these four items are done, you can proceed with a controlled first-customer rollout.

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

## How to build release artifacts (without final DNS)

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR_TEMP_BACKEND_URL
flutter build web --release --dart-define=API_BASE_URL=https://YOUR_TEMP_BACKEND_URL
```

Use temporary cloud URL for UAT, then rebuild with final DNS later.

## Remaining items needed for production readiness

### 1) Release engineering
- [x] Replace Android `applicationId`/namespace and iOS bundle id with non-template identifiers (`com.solarerp.app`).
- [ ] Configure production signing key (do not ship debug-signed release). (still pending)
- [x] Define semantic versioning + release notes policy (`RELEASE_POLICY.md`).

### 2) Quality gates
- [ ] Fix/replace scaffold widget tests with feature tests (auth, costing, quotation).
- [ ] Add CI pipeline for `flutter analyze`, `flutter test`, and release build checks.
- [ ] Add basic API contract/integration checks before release.

### 3) Security and operations
- [ ] Ensure HTTPS backend for production clients (mobile + web).
- [ ] Add crash reporting and structured logging.
- [ ] Document incident rollback plan for UAT/prod.

### 4) Architecture consistency (next)
- [ ] Add common error model and shared API error mapper.
- [ ] Add shared dialog/snackbar helper widgets for UX consistency.
- [ ] Add shared form validators to reduce duplication.

## Environment note

Flutter is not installed in this container, so I could not run `flutter analyze`, `flutter test`, or produce APK artifacts here.
