import 'package:flutter/material.dart';
import 'package:mautorcare/src/Constants/theme_manager.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier, // Listen for changes in themeNotifier
      builder: (context, ThemeMode mode, _) {
        return IconButton(
          onPressed: () {
            // Toggle between light and dark mode
            themeNotifier.value =
                mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
          },
          icon: Icon(
            mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
          ),
        );
      },
    );
  }
}
