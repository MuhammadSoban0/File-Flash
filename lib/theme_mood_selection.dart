import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart';



final themeTypeProvider = ThemeProviderSelection._();

class ThemeProviderSelection extends ValueNotifier<ThemeMode> {

  ThemeProviderSelection._() : super(ThemeProviderSelection.fromPrefs());

  void setTheme(ThemeMode value) {
    this.value = value;
    unawaited(prefs.setInt('theme_mode', value.index));
    notifyListeners();
  }

  static ThemeMode fromPrefs(){
    final index = prefs.getInt('theme_mode') ?? 1;
    return ThemeMode.values[index];
  }
}