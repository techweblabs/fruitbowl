// lib/checkout/components/checkout_progress.dart
import 'package:flutter/material.dart';

import '../../../utils/brutal_decoration.dart';

class CheckoutProgress extends StatelessWidget {
  final int currentStep;

  const CheckoutProgress({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BrutalDecoration.brutalBox(color: Colors.white),
      child: Row(
        children: [
          for (int i = 0; i < 7; i++) _buildStepIndicator(i),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    final isCompleted = currentStep > step;
    final isCurrent = currentStep == step;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : isCurrent
                        ? Colors.yellow[700]
                        : Colors.grey[300],
                border: Border.all(color: Colors.black, width: 2),
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [
                        const BoxShadow(
                            offset: Offset(2, 2), color: Colors.black)
                      ]
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : Text(
                        '${step + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.black : Colors.grey[600],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getStepTitle(step),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Product';
      case 1:
        return 'Days';
      case 2:
        return 'Delivery';
      case 3:
        return 'Start Date';
      case 4:
        return 'Time Slot';
      case 5:
        return 'Address';
      case 6:
        return 'Payment';
      default:
        return '';
    }
  }
}
