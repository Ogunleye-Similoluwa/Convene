import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCustomizationService {
  static const String _colorKey = 'accent_color';
  final _prefs = SharedPreferences.getInstance();

  Future<Color> getAccentColor() async {
    final prefs = await _prefs;
    final colorValue = prefs.getInt(_colorKey);
    return Color(colorValue ?? 0xFF2196F3); // Default blue
  }

  Future<void> setAccentColor(Color color) async {
    final prefs = await _prefs;
    await prefs.setInt(_colorKey, color.value);
  }

  ThemeData getCustomTheme(ThemeData baseTheme, Color accentColor) {
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: accentColor,
        secondary: accentColor,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: accentColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
      ), checkboxTheme: CheckboxThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return accentColor; }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return accentColor; }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return accentColor; }
 return null;
 }),
 trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return accentColor; }
 return null;
 }),
 ),
    );
  }
} 