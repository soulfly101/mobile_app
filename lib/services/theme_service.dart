import 'package:flutter/material.dart';

import 'secure_storage_service.dart';

class ThemeService {
  ThemeService._();

  static final ThemeService instance = ThemeService._();

  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  Future<void> loadThemeMode() async {
    final stored = await SecureStorageService.loadThemeMode();
    themeMode.value = stored == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final nextMode =
        themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    themeMode.value = nextMode;
    await SecureStorageService.saveThemeMode(
      nextMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
