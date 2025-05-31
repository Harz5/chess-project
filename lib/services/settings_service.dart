import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Singleton-Instanz
  static final SettingsService _instance = SettingsService._internal();
  
  factory SettingsService() {
    return _instance;
  }
  
  SettingsService._internal();
  
  // Schlüssel für SharedPreferences
  static const String _themeKey = 'theme_mode';
  static const String _boardStyleKey = 'board_style';
  static const String _pieceStyleKey = 'piece_style';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _moveHighlightKey = 'move_highlight';
  static const String _autoPromotionKey = 'auto_promotion';
  static const String _showCoordinatesKey = 'show_coordinates';
  static const String _animationSpeedKey = 'animation_speed';
  
  // Standardwerte
  static const String defaultBoardStyle = 'classic';
  static const String defaultPieceStyle = 'standard';
  static const bool defaultSoundEnabled = true;
  static const bool defaultVibrationEnabled = true;
  static const bool defaultMoveHighlight = true;
  static const bool defaultAutoPromotion = false;
  static const bool defaultShowCoordinates = true;
  static const double defaultAnimationSpeed = 0.3;
  
  // Verfügbare Stile
  final List<String> availableBoardStyles = [
    'classic',
    'wooden',
    'marble',
    'blue',
    'green',
  ];
  
  final List<String> availablePieceStyles = [
    'standard',
    'classic',
    'modern',
    'minimalist',
    '3d',
  ];
  
  // Lade die Einstellungen
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? 'system';
    
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }
    
    await prefs.setString(_themeKey, themeString);
  }
  
  Future<String> getBoardStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_boardStyleKey) ?? defaultBoardStyle;
  }
  
  Future<void> setBoardStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_boardStyleKey, style);
  }
  
  Future<String> getPieceStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pieceStyleKey) ?? defaultPieceStyle;
  }
  
  Future<void> setPieceStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pieceStyleKey, style);
  }
  
  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? defaultSoundEnabled;
  }
  
  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }
  
  Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationEnabledKey) ?? defaultVibrationEnabled;
  }
  
  Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationEnabledKey, enabled);
  }
  
  Future<bool> getMoveHighlight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_moveHighlightKey) ?? defaultMoveHighlight;
  }
  
  Future<void> setMoveHighlight(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_moveHighlightKey, enabled);
  }
  
  Future<bool> getAutoPromotion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoPromotionKey) ?? defaultAutoPromotion;
  }
  
  Future<void> setAutoPromotion(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPromotionKey, enabled);
  }
  
  Future<bool> getShowCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showCoordinatesKey) ?? defaultShowCoordinates;
  }
  
  Future<void> setShowCoordinates(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showCoordinatesKey, enabled);
  }
  
  Future<double> getAnimationSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_animationSpeedKey) ?? defaultAnimationSpeed;
  }
  
  Future<void> setAnimationSpeed(double speed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_animationSpeedKey, speed);
  }
  
  // Zurücksetzen aller Einstellungen auf Standardwerte
  Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_boardStyleKey);
    await prefs.remove(_pieceStyleKey);
    await prefs.remove(_soundEnabledKey);
    await prefs.remove(_vibrationEnabledKey);
    await prefs.remove(_moveHighlightKey);
    await prefs.remove(_autoPromotionKey);
    await prefs.remove(_showCoordinatesKey);
    await prefs.remove(_animationSpeedKey);
  }
}
