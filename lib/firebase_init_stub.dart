/// Stub Firebase init for non-mobile platforms (Windows, Linux, macOS).
/// On desktop we skip Firebase entirely — auth defaults to unauthenticated.
Future<void> init() async {
  // No-op on Windows desktop
}
