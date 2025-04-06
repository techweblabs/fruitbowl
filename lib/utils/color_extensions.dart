import 'package:flutter/material.dart';

// Extension to make colors darker or lighter
extension ColorExtension on Color {
  Color darker(int percent) {
    assert(1 <= percent && percent <= 100);
    final value = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * value).round(),
      (green * value).round(),
      (blue * value).round(),
    );
  }

  Color lighter(int percent) {
    assert(1 <= percent && percent <= 100);
    final value = percent / 100;
    return Color.fromARGB(
      alpha,
      red + ((255 - red) * value).round(),
      green + ((255 - green) * value).round(),
      blue + ((255 - blue) * value).round(),
    );
  }
}

// Extension for BoxShadow to create BoxDecoration
extension BoxShadowExtension on BoxShadow {
  BoxDecoration toBoxDecoration() {
    return BoxDecoration(
      color: Colors.transparent,
      boxShadow: [this],
    );
  }
}
