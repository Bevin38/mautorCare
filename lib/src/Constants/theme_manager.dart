// theme_manager.dart
import 'package:flutter/material.dart';

// Define the ValueNotifier for theme mode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Getter to access the current theme mode
ThemeMode get currentMode => themeNotifier.value;
