import 'package:flutter_test/flutter_test.dart';
import 'package:moe_flutter_settings/moe_flutter_settings.dart';

void main() {
  group('SettingValue', () {
    test('asString returns string value', () {
      const setting = SettingValue(key: 'name', value: 'Test');
      expect(setting.asString, equals('Test'));
    });

    test('asInt returns int value', () {
      const setting = SettingValue(key: 'count', value: 42);
      expect(setting.asInt, equals(42));
    });

    test('asBool returns bool value', () {
      const setting = SettingValue(key: 'enabled', value: true);
      expect(setting.asBool, isTrue);
    });

    test('asDouble returns double value', () {
      const setting = SettingValue(key: 'rate', value: 3.14);
      expect(setting.asDouble, equals(3.14));
    });

    test('asString returns null for non-string', () {
      const setting = SettingValue(key: 'count', value: 42);
      expect(setting.asString, isNull);
    });

    test('fromJson parses correctly', () {
      final json = {'key': 'name', 'value': 'Test'};
      final setting = SettingValue.fromJson(json);
      expect(setting.key, equals('name'));
      expect(setting.value, equals('Test'));
    });

    test('toJson round-trips', () {
      const setting = SettingValue(key: 'name', value: 'Test');
      final json = setting.toJson();
      expect(json['key'], equals('name'));
      expect(json['value'], equals('Test'));
    });
  });

  group('SettingsCollection', () {
    test('get returns setting by key', () {
      const collection = SettingsCollection({
        'name': SettingValue(key: 'name', value: 'Test'),
      });
      expect(collection.get('name')?.asString, equals('Test'));
    });

    test('getString returns string', () {
      const collection = SettingsCollection({
        'name': SettingValue(key: 'name', value: 'Test'),
      });
      expect(collection.getString('name'), equals('Test'));
    });

    test('getBool returns bool', () {
      const collection = SettingsCollection({
        'enabled': SettingValue(key: 'enabled', value: true),
      });
      expect(collection.getBool('enabled'), isTrue);
    });

    test('getInt returns int', () {
      const collection = SettingsCollection({
        'count': SettingValue(key: 'count', value: 42),
      });
      expect(collection.getInt('count'), equals(42));
    });

    test('keys returns all keys', () {
      const collection = SettingsCollection({
        'a': SettingValue(key: 'a', value: 1),
        'b': SettingValue(key: 'b', value: 2),
      });
      expect(collection.keys, containsAll(['a', 'b']));
      expect(collection.length, equals(2));
    });

    test('isEmpty / isNotEmpty', () {
      const empty = SettingsCollection({});
      const nonEmpty = SettingsCollection({
        'a': SettingValue(key: 'a', value: 1),
      });
      expect(empty.isEmpty, isTrue);
      expect(nonEmpty.isNotEmpty, isTrue);
    });

    test('fromJson parses flat map', () {
      final json = {
        'name': 'Test',
        'count': 42,
        'enabled': true,
      };
      final collection = SettingsCollection.fromJson(json);
      expect(collection.getString('name'), equals('Test'));
      expect(collection.getInt('count'), equals(42));
      expect(collection.getBool('enabled'), isTrue);
    });
  });

  group('MoeSettingsConfig', () {
    test('default values', () {
      const config = MoeSettingsConfig();
      expect(config.settingsEndpoint, equals('/settings'));
      expect(config.enableRemoteSync, isTrue);
      expect(config.cacheExpiry, equals(const Duration(hours: 1)));
    });
  });
}
