import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_settings/src/config/settings_config.dart';
import 'package:moe_flutter_settings/src/models/setting_model.dart';

/// Repository for settings — local (SharedPreferences) + remote (API).
///
/// Local-first: reads from cache, then syncs with remote if enabled.
class SettingsRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  final MoeSettingsConfig _config;

  static const _cachePrefix = 'moe_setting_';

  SettingsRepository(this._dio, this._prefs, this._config);

  /// Get all settings — local cache first, then remote sync.
  Future<AppResult<SettingsCollection>> getAll() async {
    try {
      // Try remote first if enabled
      if (_config.enableRemoteSync) {
        final response = await _dio.get(_config.settingsEndpoint);
        final data = response.data as Map<String, dynamic>;
        final collection = SettingsCollection.fromJson(
          data.containsKey('settings')
              ? data['settings'] as Map<String, dynamic>
              : data,
        );
        // Cache locally
        await _cacheAll(collection);
        return Ok(collection);
      }

      // Fallback to local cache
      final cached = _readAllFromCache();
      return Ok(cached);
    } on DioException catch (e) {
      // Network error — fallback to cache
      final cached = _readAllFromCache();
      if (cached.isNotEmpty) {
        return Ok(cached);
      }
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  /// Get single setting by key.
  Future<AppResult<SettingValue>> get(String key) async {
    try {
      if (_config.enableRemoteSync) {
        final response = await _dio.get('${_config.settingsEndpoint}/$key');
        final data = response.data as Map<String, dynamic>;
        final value = data['value'] ?? data[key];
        final setting = SettingValue(key: key, value: value);
        await _cache(key, value);
        return Ok(setting);
      }

      final cached = _readFromCache(key);
      return Ok(SettingValue(key: key, value: cached));
    } on DioException {
      final cached = _readFromCache(key);
      return Ok(SettingValue(key: key, value: cached));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  /// Update setting on remote.
  Future<AppResult<SettingValue>> update(String key, dynamic value) async {
    try {
      await _dio.put(
        _config.settingsEndpoint,
        data: {'key': key, 'value': value},
      );
      final setting = SettingValue(key: key, value: value);
      await _cache(key, value);
      return Ok(setting);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  /// Delete setting.
  Future<AppResult<void>> delete(String key) async {
    try {
      await _dio.delete('${_config.settingsEndpoint}/$key');
      await _prefs.remove('$_cachePrefix$key');
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  // ── Cache helpers ──────────────────────────────────────────

  Future<void> _cache(String key, dynamic value) async {
    await _prefs.setString('$_cachePrefix$key', value.toString());
  }

  Future<void> _cacheAll(SettingsCollection collection) async {
    for (final key in collection.keys) {
      final setting = collection.get(key);
      if (setting != null) {
        await _cache(key, setting.value);
      }
    }
  }

  String? _readFromCache(String key) {
    return _prefs.getString('$_cachePrefix$key');
  }

  SettingsCollection _readAllFromCache() {
    final settings = <String, SettingValue>{};
    final keys = _prefs.getKeys().where((k) => k.startsWith(_cachePrefix));
    for (final key in keys) {
      final cleanKey = key.substring(_cachePrefix.length);
      settings[cleanKey] = SettingValue(
        key: cleanKey,
        value: _prefs.getString(key),
      );
    }
    return SettingsCollection(settings);
  }
}
