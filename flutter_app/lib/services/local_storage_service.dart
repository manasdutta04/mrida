import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  final Box _box = Hive.box('settings');

  void setString(String key, String value) {
    _box.put(key, value);
  }

  String? getString(String key) {
    return _box.get(key) as String?;
  }

  void setBool(String key, bool value) {
    _box.put(key, value);
  }

  bool? getBool(String key) {
    return _box.get(key) as bool?;
  }

  void saveProfile({String? name, String? phone, String? language, String? state}) {
    if (name != null) _box.put('displayName', name);
    if (phone != null) _box.put('phoneNumber', phone);
    if (language != null) _box.put('languageCode', language);
    if (state != null) _box.put('state', state);
  }

  Map<String, String?> getProfile() {
    return {
      'displayName': _box.get('displayName') as String?,
      'phoneNumber': _box.get('phoneNumber') as String?,
      'languageCode': _box.get('languageCode') as String?,
      'state': _box.get('state') as String?,
    };
  }
}
