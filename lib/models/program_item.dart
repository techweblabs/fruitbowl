import 'package:flutter/material.dart';

class ProgramItem {
  final String title;
  final String description;
  final String coverImage;
  final Color color;
  final double progress;

  ProgramItem({
    required this.title,
    required this.description,
    required this.coverImage,
    required this.color,
    required this.progress,
  });
}
