#!/usr/bin/env bash
# Offline demo APK: every API call (incl. the Director SSE stream) is served
# from seeded sample data by DemoBackendAdapter. No backend or network needed.
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
flutter build apk --release --dart-define=DEMO=true
cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/parallax-demo.apk
echo "Built build/app/outputs/flutter-apk/parallax-demo.apk"
