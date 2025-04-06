import 'package:flutter/material.dart';

class FruitBowlItem {
  final String title;
  final String description;
  final String coverImage;
  final Color color;
  final int calories;
  final double price;

  FruitBowlItem({
    required this.title,
    required this.description,
    required this.coverImage,
    required this.color,
    required this.calories,
    required this.price,
  });
}
