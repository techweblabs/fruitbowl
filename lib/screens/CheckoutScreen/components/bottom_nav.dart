// lib/checkout/components/bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/MyOrdersScreen/my_orders_screen.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/brutal_decoration.dart';

class BottomNav extends StatelessWidget {
  final int currentStep;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback? onPaymentSubmit; // New callback for payment submission

  const BottomNav({
    super.key,
    required this.currentStep,
    required this.onBack,
    required this.onNext,
    this.onPaymentSubmit, // Add this optional callback
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button (if not on first step)
          if (currentStep > 0)
            GestureDetector(
              onTap: onBack,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BrutalDecoration.bottomButton(isPrimary: false),
                child: const Text(
                  "Back",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Spacer
          const Spacer(),

          // Next/Pay button
          GestureDetector(
            onTap: () {
              if (currentStep == 6) {
                // Call the payment callback if provided
                if (onPaymentSubmit != null) {
                  onPaymentSubmit!();
                }

                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                // Simulate payment processing
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pop(context); // Close loading dialog
                  _onPaymentSuccess(context);
                });
              } else {
                onNext();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color:
                    currentStep == 6 ? Colors.green[500] : Colors.yellow[600],
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(offset: Offset(3, 3), color: Colors.black)
                ],
              ),
              child: Text(
                currentStep == 6 ? "Pay Now" : "Continue",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPaymentSuccess(BuildContext context) {
    // Show success message
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600]),
              const SizedBox(width: 8),
              Text(
                'Payment Successful',
                style: TextStyle(fontSize: 10.sp),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your order has been placed successfully!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                  boxShadow: const [
                    BoxShadow(offset: Offset(2, 2), color: Colors.black)
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Order ID:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('View Orders'),
              onPressed: () {
                // Navigate to orders page, replacing the entire stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersPage()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
