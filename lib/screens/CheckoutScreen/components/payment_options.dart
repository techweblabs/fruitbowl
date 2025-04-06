// lib/checkout/components/payment_options.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/brutal_decoration.dart';
import 'section_title.dart';

class PaymentOptions extends StatefulWidget {
  final String planPrice;

  const PaymentOptions({
    super.key,
    required this.planPrice,
  });

  @override
  State<PaymentOptions> createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  String _selectedPaymentMethod = 'creditCard';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BrutalDecoration.brutalBox(color: Colors.white),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Payment Method"),
          const SizedBox(height: 16),

          // Payment methods
          _buildPaymentMethod(
            'creditCard',
            'Credit/Debit Card',
            'Pay with Visa, Mastercard, etc.',
            Icons.credit_card,
            Colors.blue[50]!,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethod(
            'upi',
            'UPI',
            'Pay using any UPI app',
            Icons.account_balance,
            Colors.green[50]!,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethod(
            'cod',
            'Cash on Delivery',
            'Pay when you receive your order',
            Icons.money,
            Colors.orange[50]!,
          ),

          const SizedBox(height: 24),

          // Order summary
          _buildOrderSummary(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color bgColor,
  ) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BrutalDecoration.selectedOption(
          isSelected: isSelected,
          selectedColor: bgColor,
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 24,
              height: 24,
              decoration: BrutalDecoration.radioButton(isSelected: isSelected),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isSelected ? bgColor.withOpacity(0.7) : Colors.grey[200]!,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
              ),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSelected ? 16 : 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
      ),
      child: Column(
        children: [
          const Text(
            "ORDER SUMMARY",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 2,
            color: Colors.black,
          ),

          // Summary rows
          _buildSummaryRow(
            "Plan Cost",
            widget.planPrice,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            "Delivery Fee",
            "Free",
            isHighlight: true,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            "Taxes",
            "₹149",
          ),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 2,
            color: Colors.black,
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.planPrice,
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

  Widget _buildSummaryRow(String label, String value,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          padding: isHighlight
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
              : null,
          decoration: isHighlight
              ? BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[800]!),
                )
              : null,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.green[800] : null,
            ),
          ),
        ),
      ],
    );
  }
}
