// lib/checkout/utils/brutal_decoration.dart
import 'package:flutter/material.dart';

class BrutalDecoration {
  // Main brutal box decoration
  static BoxDecoration brutalBox({Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
    );
  }

  // Section title decoration
  static BoxDecoration sectionTitle() {
    return BoxDecoration(
      color: Colors.yellow[600],
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [BoxShadow(offset: Offset(2, 2), color: Colors.black)],
    );
  }

  // Calendar button decoration
  static BoxDecoration miniButton() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 1),
      borderRadius: BorderRadius.circular(4),
      boxShadow: const [BoxShadow(offset: Offset(1, 1), color: Colors.black)],
    );
  }

  // Selected option decoration
  static BoxDecoration selectedOption({
    required bool isSelected,
    required Color selectedColor,
  }) {
    return BoxDecoration(
      color: isSelected ? selectedColor : Colors.white,
      border: Border.all(
        color: isSelected ? Colors.black : Colors.grey[400]!,
        width: isSelected ? 2 : 1,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: isSelected
          ? const [BoxShadow(offset: Offset(4, 4), color: Colors.black)]
          : const [BoxShadow(offset: Offset(2, 2), color: Colors.black26)],
    );
  }

  // Radio button/circle selector
  static BoxDecoration radioButton({required bool isSelected}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: isSelected ? Colors.black : Colors.grey[400]!,
        width: 2,
      ),
      color: isSelected ? Colors.black : Colors.transparent,
    );
  }

  // Text field decoration
  static BoxDecoration textField() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [BoxShadow(offset: Offset(2, 2), color: Colors.black)],
    );
  }

  // Checkbox decoration
  static BoxDecoration checkbox({required bool isChecked}) {
    return BoxDecoration(
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(4),
      color: isChecked ? Colors.black : Colors.white,
      boxShadow: const [BoxShadow(offset: Offset(1, 1), color: Colors.black)],
    );
  }

  // Bottom navigation buttons
  static BoxDecoration bottomButton({required bool isPrimary}) {
    return BoxDecoration(
      color: isPrimary ? Colors.yellow[600] : Colors.grey[200],
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [BoxShadow(offset: Offset(2, 2), color: Colors.black)],
    );
  }
}
