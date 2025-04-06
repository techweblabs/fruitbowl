// lib/orders/models/order.dart
import 'package:flutter/material.dart';

class Order {
  final String id;
  final String productName;
  final String price;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;
  final String status; // Active, Upcoming, Completed, Paused
  final String deliveryDays;
  final String deliveryTime;
  final int totalDays;
  final int remainingDays;
  final DateTime orderDate;
  final List<Color> gradientColors;

  Order({
    required this.id,
    required this.productName,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    required this.status,
    required this.deliveryDays,
    required this.deliveryTime,
    required this.totalDays,
    required this.remainingDays,
    required this.orderDate,
    required this.gradientColors,
  });

  // Get a color based on status
  Color get statusColor {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Upcoming':
        return Colors.blue;
      case 'Completed':
        return Colors.grey;
      case 'Paused':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  // Calculate progress percentage
  double get progressPercentage {
    if (totalDays == 0) return 0;
    return (totalDays - remainingDays) / totalDays;
  }

  // Format date as string
  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // Get formatted duration string
  String get durationText {
    return "$totalDays days (${formatDate(startDate)} - ${formatDate(endDate)})";
  }

  // Get delivery schedule text
  String get deliveryScheduleText {
    return "$deliveryDays • $deliveryTime";
  }
}
