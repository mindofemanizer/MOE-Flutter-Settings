import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration for MOE Settings package.
class MoeSettingsConfig {
  final String settingsEndpoint;
  final bool enableRemoteSync;
  final Duration cacheExpiry;

  const MoeSettingsConfig({
    this.settingsEndpoint = '/settings',
    this.enableRemoteSync = true,
    this.cacheExpiry = const Duration(hours: 1),
  });
}

/// Provider for settings config.
final settingsConfigProvider = Provider<MoeSettingsConfig>((ref) {
  return MoeSettings.config;
});

/// Setup function — call in main() before runApp().
class MoeSettings {
  static late MoeSettingsConfig _config;

  static void setup({required MoeSettingsConfig config}) {
    _config = config;
  }

  static MoeSettingsConfig get config => _config;
}
