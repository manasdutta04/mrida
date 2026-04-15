import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_storage_service.dart';

final settingsStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final appThemeModeProvider =
    StateNotifierProvider<AppThemeModeNotifier, ThemeMode>((ref) {
  return AppThemeModeNotifier(ref.read(settingsStorageServiceProvider));
});

final measurementUnitsProvider =
    StateNotifierProvider<MeasurementUnitsNotifier, String>((ref) {
  return MeasurementUnitsNotifier(ref.read(settingsStorageServiceProvider));
});

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsEnabledNotifier, bool>((ref) {
  return NotificationsEnabledNotifier(ref.read(settingsStorageServiceProvider));
});

final offlineAccessProvider =
    StateNotifierProvider<OfflineAccessNotifier, bool>((ref) {
  return OfflineAccessNotifier(ref.read(settingsStorageServiceProvider));
});

class AppThemeModeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorageService _storage;

  AppThemeModeNotifier(this._storage)
      : super(_loadThemeMode(_storage.getString('app_theme')));

  static ThemeMode _loadThemeMode(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _storage.setString('app_theme', _saveValue(mode));
  }

  static String _saveValue(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
      default:
        return 'light';
    }
  }
}

class MeasurementUnitsNotifier extends StateNotifier<String> {
  final LocalStorageService _storage;

  MeasurementUnitsNotifier(this._storage)
      : super(_storage.getString('measurement_units') ?? 'Metric');

  void setUnits(String units) {
    state = units;
    _storage.setString('measurement_units', units);
  }
}

class NotificationsEnabledNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;

  NotificationsEnabledNotifier(this._storage)
      : super(_storage.getBool('notifications_enabled') ?? true);

  void setEnabled(bool enabled) {
    state = enabled;
    _storage.setBool('notifications_enabled', enabled);
  }
}

class OfflineAccessNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;

  OfflineAccessNotifier(this._storage)
      : super(_storage.getBool('offline_access_enabled') ?? true);

  void setEnabled(bool enabled) {
    state = enabled;
    _storage.setBool('offline_access_enabled', enabled);
  }
}
