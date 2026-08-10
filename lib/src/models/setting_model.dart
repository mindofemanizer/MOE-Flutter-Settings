/// Typed setting value — supports string, int, double, bool, and JSON.
class SettingValue {
  final String key;
  final dynamic value;

  const SettingValue({required this.key, required this.value});

  String? get asString => value is String ? value as String : null;
  int? get asInt => value is int ? value as int : null;
  double? get asDouble => value is double ? value as double : null;
  bool? get asBool => value is bool ? value as bool : null;
  Map<String, dynamic>? get asJson =>
      value is Map<String, dynamic> ? value as Map<String, dynamic> : null;
  List<dynamic>? get asList => value is List ? value as List : null;

  factory SettingValue.fromJson(Map<String, dynamic> json) {
    return SettingValue(
      key: json['key'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };
}

/// Collection of settings — key-value map with typed access.
class SettingsCollection {
  final Map<String, SettingValue> _settings;

  const SettingsCollection(this._settings);

  /// Get typed setting value.
  SettingValue? get(String key) => _settings[key];

  /// Get string value.
  String? getString(String key) => _settings[key]?.asString;

  /// Get int value.
  int? getInt(String key) => _settings[key]?.asInt;

  /// Get double value.
  double? getDouble(String key) => _settings[key]?.asDouble;

  /// Get bool value.
  bool? getBool(String key) => _settings[key]?.asBool;

  /// Get JSON value.
  Map<String, dynamic>? getJson(String key) => _settings[key]?.asJson;

  /// Get list value.
  List<dynamic>? getList(String key) => _settings[key]?.asList;

  /// All keys.
  Iterable<String> get keys => _settings.keys;

  /// Number of settings.
  int get length => _settings.length;

  /// Whether settings is empty.
  bool get isEmpty => _settings.isEmpty;

  /// Whether settings is not empty.
  bool get isNotEmpty => _settings.isNotEmpty;

  factory SettingsCollection.fromJson(Map<String, dynamic> json) {
    final settings = <String, SettingValue>{};
    json.forEach((key, value) {
      if (value is Map<String, dynamic> && value.containsKey('value')) {
        settings[key] = SettingValue.fromJson(value);
      } else {
        settings[key] = SettingValue(key: key, value: value);
      }
    });
    return SettingsCollection(settings);
  }

  Map<String, dynamic> toJson() => _settings.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
}
