# parallax_flutter

Flutter mobile client for Parallax (BLoC, go_router, dio). Project-wide docs are in `../docs/`.

**Status: broken against the current backend.** No Supabase login, uploads to a removed
route, and an old timeline model. See `../docs/AUDIT.md` B1–B4. The fix is planned in roadmap
task 1.4.

## Commands

```bash
flutter pub get
flutter analyze
flutter test          # 1 known failure: widget_test.dart (app starts network calls on launch)
flutter run           # backend default: http://10.0.2.2:8080 on Android emulator, else localhost:8080
```

## Architecture

- `lib/main.dart` creates the dio client and the global BLoCs. `lib/config/router.dart` has the
  routes (`/`, `/settings`, `/project/:id/{media,timeline,history,export,chat/:chatId}`).
- `lib/data/parallax_api.dart` is the only HTTP/SSE client. `lib/data/models.dart` is
  hand-written and out of date with backend timeline v3 (to be replaced by generated models).
- One BLoC per feature in `lib/blocs/`. The main UI is `screens/project_workspace_screen.dart`.
- The pubspec package is still named `parallax_mobile` (imports use
  `package:parallax_mobile/...`).

## Conventions

- Branch `demo-ui` (remote) has an offline demo mode and a CI APK workflow, not yet merged.
