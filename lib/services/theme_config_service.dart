import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConfig {
  final double cornerRadius;
  final String fontFamily;
  final double spacing;
  final bool useMaterial3;

  const ThemeConfig({
    this.cornerRadius = 12.0,
    this.fontFamily = 'Inter',
    this.spacing = 16.0,
    this.useMaterial3 = true,
  });

  Map<String, dynamic> toJson() => {
        'cornerRadius': cornerRadius,
        'fontFamily': fontFamily,
        'spacing': spacing,
        'useMaterial3': useMaterial3,
      };

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      cornerRadius: json['cornerRadius'] ?? 12.0,
      fontFamily: json['fontFamily'] ?? 'Inter',
      spacing: json['spacing'] ?? 16.0,
      useMaterial3: json['useMaterial3'] ?? true,
    );
  }
}

class ThemeConfigService {
  static const String _configKey = 'theme_config';
  final _prefs = SharedPreferences.getInstance();

  Future<ThemeConfig> getConfig() async {
    final prefs = await _prefs;
    final configStr = prefs.getString(_configKey);
    if (configStr == null) return ThemeConfig();

    try {
      final Map<String, dynamic> json = Map<String, dynamic>.from(
        jsonDecode(configStr),
      );
      return ThemeConfig.fromJson(json);
    } catch (e) {
      return ThemeConfig();
    }
  }

  Future<void> saveConfig(ThemeConfig config) async {
    final prefs = await _prefs;
    await prefs.setString(_configKey, jsonEncode(config.toJson()));
  }

  TextTheme getTextTheme(String fontFamily) {
    final baseTextTheme = GoogleFonts.getTextTheme(fontFamily);
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
} 