// lib/checkout/components/delivery_days.dart
import 'package:flutter/material.dart';

import '../../../utils/brutal_decoration.dart';
import 'section_title.dart';

class DeliveryDays extends StatefulWidget {
  final String initialDeliveryOption;
  final Function(String) onDeliveryOptionChanged;

  const DeliveryDays({
    super.key,
    required this.initialDeliveryOption,
    required this.onDeliveryOptionChanged,
  });

  @override
  State<DeliveryDays> createState() => _DeliveryDaysState();
}

class _DeliveryDaysState extends State<DeliveryDays> {
  late String _deliveryOption;

  @override
  void initState() {
    super.initState();
    _deliveryOption = widget.initialDeliveryOption;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BrutalDecoration.brutalBox(color: Colors.white),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Select Delivery Days"),
          const SizedBox(height: 16),

          _buildDeliveryOption(
            'weekdays',
            'Weekdays Only',
            'Mon-Fri (5 days a week)',
            Icons.work,
          ),
          const SizedBox(height: 12),
          _buildDeliveryOption(
            'weekends',
            'Weekends Only',
            'Sat-Sun (2 days a week)',
            Icons.weekend,
          ),
          const SizedBox(height: 12),
          _buildDeliveryOption(
            'everyday',
            'Everyday',
            'Mon-Sun (7 days a week)',
            Icons.calendar_today,
          ),
          const SizedBox(height: 12),
          _buildDeliveryOption(
            'custom',
            'Custom',
            'Pick your own days',
            Icons.tune,
          ),

          // Custom day selector (only visible if custom is selected)
          if (_deliveryOption == 'custom') _buildCustomDaySelector(),
        ],
      ),
    );
  }

  Widget _buildDeliveryOption(
      String value, String title, String subtitle, IconData icon) {
    final isSelected = _deliveryOption == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _deliveryOption = value;
        });
        widget.onDeliveryOptionChanged(value);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BrutalDecoration.selectedOption(
          isSelected: isSelected,
          selectedColor: Colors.yellow[50]!,
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
                color: isSelected ? Colors.yellow[200] : Colors.grey[200],
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

  Widget _buildCustomDaySelector() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(offset: Offset(3, 3), color: Colors.black)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select days:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Days of week checkboxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDaySelector('M', true),
              _buildDaySelector('T', false),
              _buildDaySelector('W', true),
              _buildDaySelector('T', false),
              _buildDaySelector('F', true),
              _buildDaySelector('S', false),
              _buildDaySelector('S', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(String day, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Would toggle selection in a real app
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow[600] : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: isSelected
              ? const [BoxShadow(offset: Offset(2, 2), color: Colors.black)]
              : null,
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
