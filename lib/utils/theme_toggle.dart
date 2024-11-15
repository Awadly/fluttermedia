import 'package:flutter/material.dart';

class ThemeToggle extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggle;

  const ThemeToggle({
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isDarkMode,
      onChanged: onToggle,
    );
  }
}
