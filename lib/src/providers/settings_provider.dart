import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_settings/src/config/settings_config.dart';
import 'package:moe_flutter_settings/src/models/setting_model.dart';
import 'package:moe_flutter_settings/src/services/settings_repository.dart';

/// State for settings.
sealed class SettingsState {
  const SettingsState();
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class SettingsLoaded extends SettingsState {
  final SettingsCollection settings;
  const SettingsLoaded(this.settings);
}

final class SettingsError extends SettingsState {
  final AppFailure failure;
  const SettingsError(this.failure);
}

/// Notifier for settings data.
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const SettingsInitial());

  /// Load all settings.
  Future<void> loadAll() async {
    state = const SettingsLoading();

    final result = await _repository.getAll();

    switch (result) {
      case Ok(:final data):
        state = SettingsLoaded(data);
      case Err(:final failure):
        state = SettingsError(failure);
    }
  }

  /// Get single setting.
  Future<SettingValue?> get(String key) async {
    final result = await _repository.get(key);
    return switch (result) {
      Ok(:final data) => data,
      Err() => null,
    };
  }

  /// Update setting.
  Future<void> update(String key, dynamic value) async {
    final result = await _repository.update(key, value);

    switch (result) {
      case Ok():
        await loadAll();
      case Err(:final failure):
        state = SettingsError(failure);
    }
  }

  /// Delete setting.
  Future<void> delete(String key) async {
    final result = await _repository.delete(key);

    switch (result) {
      case Ok():
        await loadAll();
      case Err(:final failure):
        state = SettingsError(failure);
    }
  }
}

/// Provider for SharedPreferences.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized before use.');
});

/// Provider for SettingsRepository.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final config = ref.watch(settingsConfigProvider);
  return SettingsRepository(dio, prefs, config);
});

/// Provider for SettingsNotifier.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});
