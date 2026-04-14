# Production Readiness Recheck (2026-04-13)

## Overall status

**Partially ready, but release execution prerequisites are still pending.**

Core safeguards have now been implemented in code, but production release cannot be completed until environment/tooling/signing prerequisites are in place and validated.

## What is already completed

1. **Release API safety guardrails are implemented**
   - `API_BASE_URL` validation exists in `lib/core/config/app_config.dart`.
   - In release mode, missing `API_BASE_URL` fails fast.
   - In release mode, non-HTTPS URLs fail fast.
   - Local development fallback (`http://localhost:8080`) remains available outside release mode.

2. **Android debug-key release signing fallback has been removed**
   - `android/app/build.gradle.kts` now loads `android/key.properties`.
   - A `release` signing config is configured from keystore properties.
   - Release tasks fail with a clear `GradleException` if keystore values are missing.

3. **Stale placeholder file has been removed**
   - `lib/features/costing/domain/config/initial_calculator_state.dart` is deleted.

4. **Developer/operator guidance has been updated**
   - `android/key.properties.example` was added.
   - README now documents release API/signing requirements.

## What is still remaining

1. **Provide real Android release signing secrets/artifacts**
   - Create `android/key.properties` from the example.
   - Ensure referenced keystore file exists in the expected location.
   - Validate signed release build output in CI or local release machine.

2. **Run full quality gate in a Flutter-enabled environment**
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`
   - `flutter build apk --release --dart-define=API_BASE_URL=https://...`
   - `flutter build web --release --dart-define=API_BASE_URL=https://...`

3. **Confirm CI secrets/configuration for release build jobs**
   - If CI runs Android release jobs, provide keystore inputs securely.
   - Otherwise, gate/skip release job on secret availability.

4. **Expand test coverage beyond current smoke-level checks**
   - Add feature-level tests for auth/network failure states and critical costing flows.

5. **Perform iOS release readiness validation**
   - Confirm Apple signing/provisioning setup and run release archive validation.

## Direct answer to "Anything else remaining?"

**Yes.** The main remaining items are operational: release signing inputs, CI release configuration, and running the full analyze/test/build pipeline in a Flutter-enabled environment.
