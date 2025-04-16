// lib/orders/components/order_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/brutal_decoration.dart';

class OrderCard extends StatelessWidget {
  final order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BrutalDecoration.brutalBox(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(),
            _buildCardBody(),
            _buildCardFooter(),
          ],
        ),
      ),
    );
  }

  // Get a color based on status
  Color get statusColor {
    final String status = order['status'] ?? 'Active';
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
    final int totalDays = order['totalDays'] ?? 0;
    final int remainingDays = order['remainingDays'] ?? 0;
    if (totalDays == 0) return 0;
    return (totalDays - remainingDays) / totalDays;
  }

  // Format date as string
  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // Get formatted duration string
  String get durationText {
    final int totalDays = order['totalDays'] ?? 0;

    final DateTime startDate = order['startDate'] is Timestamp
        ? (order['startDate'] as Timestamp).toDate()
        : DateTime.now();

    final DateTime endDate = order['endDate'] is Timestamp
        ? (order['endDate'] as Timestamp).toDate()
        : DateTime.now().add(const Duration(days: 30));

    return "$totalDays days (${formatDate(startDate)} - ${formatDate(endDate)})";
  }

  // Get delivery schedule text
  String get deliveryScheduleText {
    final String deliveryDays = order['deliveryDays'] ?? 'Weekdays';
    final String deliveryTime = order['deliveryTime'] ?? '9 AM - 11 AM';
    return "$deliveryDays • $deliveryTime";
  }

  // Get gradient colors from the order
  List<Color> get gradientColors {
    List<Color> colors = [];
    if (order['gradientColors'] != null) {
      for (var colorData in order['gradientColors']) {
        if (colorData is Map) {
          colors.add(
            Color.fromRGBO(
              colorData['red'] ?? 0,
              colorData['green'] ?? 0,
              colorData['blue'] ?? 0,
              colorData['alpha'] != null ? colorData['alpha'] / 255 : 1.0,
            ),
          );
        }
      }
    }

    // If no valid colors were found, use defaults
    if (colors.isEmpty) {
      colors = [
        const Color(0xFF8ECAE6),
        const Color(0xFF219EBC),
        const Color(0xFF023047),
      ];
    }

    return colors;
  }

  Widget _buildCardHeader() {
    final String imageUrl = order['imageUrl'] ?? 'assets/images/fruits.png';
    final String productName = order['productName'] ?? 'Product';
    final String id = order['id'] ?? '';
    final String status = order['status'] ?? 'Active';

    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        image: DecorationImage(
          image: AssetImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientColors[0].withOpacity(0.7),
              gradientColors.length > 2
                  ? gradientColors[2].withOpacity(0.9)
                  : gradientColors.last.withOpacity(0.9),
            ],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            // Status badge
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black, width: 1),
                  boxShadow: const [
                    BoxShadow(offset: Offset(1, 1), color: Colors.black),
                  ],
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // Order ID
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "ID: $id",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 10,
                  ),
                ),
              ),
            ),

            // Product name
            Positioned(
              bottom: 0,
              left: 0,
              child: Text(
                productName,
                style: GoogleFonts.bangers(
                  fontSize: 24,
                  color: Colors.white,
                  letterSpacing: 1,
                  shadows: [
                    const Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBody() {
    final String status = order['status'] ?? 'Active';
    final int remainingDays = order['remainingDays'] ?? 0;
    final DateTime orderDate = order['orderDate'] is Timestamp
        ? (order['orderDate'] as Timestamp).toDate()
        : DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order details rows
          _buildDetailRow("Duration:", durationText),
          const SizedBox(height: 4),
          _buildDetailRow("Delivery:", deliveryScheduleText),
          const SizedBox(height: 4),
          _buildDetailRow("Order Date:", formatDate(orderDate)),

          const SizedBox(height: 12),

          // Progress bar for active orders
          if (status == 'Active')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Subscription Progress",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "$remainingDays days left",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressPercentage.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCardFooter() {
    final String price = order['price'] ?? '₹0';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(10),
        ),
        border: const Border(
          top: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Order total
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          // View details button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.yellow[600],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: const [
                BoxShadow(offset: Offset(2, 2), color: Colors.black),
              ],
            ),
            child: const Row(
              children: [
                Text(
                  "View Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
