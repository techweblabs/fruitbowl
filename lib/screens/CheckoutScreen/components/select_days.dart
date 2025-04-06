// lib/checkout/components/select_days.dart
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/CheckoutScreen/components/section_title.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/brutal_decoration.dart';

class SelectDays extends StatefulWidget {
  final Map<String, dynamic> product;
  final int selectedPlanIndex;
  final Function(int) onPlanChanged;

  const SelectDays({
    super.key,
    required this.product,
    required this.selectedPlanIndex,
    required this.onPlanChanged,
  });

  @override
  State<SelectDays> createState() => _SelectDaysState();
}

class _SelectDaysState extends State<SelectDays> {
  // Get plan days
  int get _planDays =>
      widget.product['plans'][widget.selectedPlanIndex]['days'];

  // Get plan price
  String get _planPrice =>
      widget.product['plans'][widget.selectedPlanIndex]['price'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BrutalDecoration.brutalBox(color: Colors.white),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Select Number of Days"),
          const SizedBox(height: 16),
          _buildDaySelector(),
          const SizedBox(height: 24),
          _buildPriceBreakdown(),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(offset: Offset(3, 3), color: Colors.black)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$_planDays",
                style: GoogleFonts.bangers(
                  fontSize: 48,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "DAYS",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Days slider in brutalist style
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < widget.product['plans'].length; i++)
                  _buildDayOption(i),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayOption(int planIndex) {
    final days = widget.product['plans'][planIndex]['days'];
    final isSelected = planIndex == widget.selectedPlanIndex;

    return GestureDetector(
      onTap: () => widget.onPlanChanged(planIndex),
      child: Container(
        width: 50,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow[600] : Colors.grey[200],
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [const BoxShadow(offset: Offset(2, 2), color: Colors.black)]
              : null,
        ),
        child: Center(
          child: Text(
            "$days",
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(offset: Offset(3, 3), color: Colors.black)],
      ),
      child: Column(
        children: [
          const Text(
            "Price Breakdown",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Price calculation rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Daily Price:"),
              Text(
                widget.product['price'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Number of Days:"),
              Text(
                "$_planDays days",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Divider
          Container(
            height: 2,
            color: Colors.black,
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _planPrice,
                style: GoogleFonts.bangers(
                  fontSize: 24,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
