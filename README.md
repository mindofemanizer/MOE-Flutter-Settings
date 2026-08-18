# MOE-Flutter-Settings

Settings package for MOE Flutter ecosystem â€” global key-value settings, cached, typed.

## Installation

```yaml
dependencies:
  moe_flutter_settings:
    git:
      url: https://github.com/mindofemanizer/MOE-Flutter-Settings.git
      ref: v1.0.0
```

## Usage

### Setup

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  MoeCore.setup(envConfig: EnvConfig.fromEnvironment());
  MoeSettings.setup(config: MoeSettingsConfig());

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MyApp(),
  ));
}
```

### Read Settings

```dart
final state = ref.watch(settingsProvider);

switch (state) {
  case SettingsLoaded(:final settings):
    final appName = settings.getString('app_name');
    final maxItems = settings.getInt('max_items');
    final enabled = settings.getBool('feature_enabled');
  case SettingsLoading():
    // loading
  case SettingsError(:final failure):
    // error
}

// load
ref.read(settingsProvider.notifier).loadAll();
```

### Update Setting

```dart
await ref.read(settingsProvider.notifier).update('app_name', 'New Name');
```

## What's Included

| Module | Description |
|--------|-------------|
| `SettingValue` | Typed value (string, int, double, bool, JSON) |
| `SettingsCollection` | Key-value collection with typed access |
| `SettingsRepository` | Local-first + remote sync |
| `SettingsNotifier` | State management |
| `MoeSettingsConfig` | Configurable |
