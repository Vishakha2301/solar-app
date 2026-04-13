# Release Versioning and Notes Policy

Date: 2026-04-13

This policy applies to **all production artifacts** from this repository:
- Android APK/AAB
- iOS app builds
- Web release deployments

## 1) Semantic versioning model

Use `MAJOR.MINOR.PATCH` with optional pre-release suffixes.

- **MAJOR**: breaking changes (API contract changes, incompatible data flows, or major UX restructuring requiring migration notes).
- **MINOR**: backward-compatible feature additions (new module, new workflow, non-breaking endpoint additions).
- **PATCH**: backward-compatible fixes (bug fixes, performance improvements, copy/UI fixes without behavior breakage).

### Pre-release channels

- `-alpha.N`: internal development milestone.
- `-beta.N`: feature-complete test candidate.
- `-rc.N`: release candidate for final validation.

Examples:
- `1.4.0-beta.2`
- `1.4.0-rc.1`
- `1.4.0`

## 2) Version bump decision matrix

- Breaking API/client behavior change: bump **MAJOR**.
- New user-facing capability without breakage: bump **MINOR**.
- Bugfix/refactor-only release: bump **PATCH**.
- If uncertain, choose the higher impact bump and document rationale.

## 3) Release notes standard

Every production release must include release notes with these sections:

1. **Summary** (1–3 lines)
2. **User-facing changes**
3. **Fixes**
4. **Operational/infra changes** (API URL, auth, config, caching, rollout controls)
5. **Risk & rollback** (known risks + rollback trigger)

### Template

```md
## vX.Y.Z - YYYY-MM-DD

### Summary
- ...

### User-facing changes
- ...

### Fixes
- ...

### Operational/infra changes
- ...

### Risk & rollback
- Risk: ...
- Rollback trigger: ...
- Rollback plan: redeploy previous stable vA.B.C and restore prior runtime config.
```

## 4) Platform tagging guidance

- Create git tag `vX.Y.Z` for production releases.
- Include artifact mapping in notes:
  - Android: versionName/versionCode
  - iOS: CFBundleShortVersionString/CFBundleVersion
  - Web: deployed commit SHA + environment URL

## 5) Minimum release checklist

Before release approval:
- `flutter analyze` passes.
- `flutter test` passes.
- Build succeeds for target platform(s).
- Release notes completed and reviewed.
- Rollback target (previous stable tag) identified.
