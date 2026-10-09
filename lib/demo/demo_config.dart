/// Offline demo switch: `flutter build apk --dart-define=DEMO=true`.
///
/// When on, Dio's HTTP adapter is replaced by [DemoBackendAdapter], which
/// answers every Parallax API endpoint (including the Director SSE stream)
/// from seeded in-memory sample data. Nothing touches the network.
const bool kDemoMode = bool.fromEnvironment('DEMO', defaultValue: false);

const String kDemoBaseUrl = 'https://demo.invalid';
const String kDemoDisclaimer = 'Demo build with sample data';

/// Thumbnails in the demo are generated gradients, addressed with this
/// scheme (`demo-thumb:<seed>:<kind>`), instead of network images.
const String kDemoThumbScheme = 'demo-thumb:';
