# Changelog

## 1.0.0 — 2026-08-10

### Added
- Initial release
- `SettingValue` — typed setting value (string, int, double, bool, JSON, list)
- `SettingsCollection` — key-value collection with typed access
- `SettingsRepository` — local-first (SharedPreferences) + remote sync (API)
- `SettingsNotifier` — state management (initial/loading/loaded/error)
- `MoeSettingsConfig` — configurable endpoint, remote sync, cache expiry
- `MoeSettings.setup()` — entry point
- Riverpod providers: `settingsProvider`, `settingsRepositoryProvider`, `sharedPreferencesProvider`
