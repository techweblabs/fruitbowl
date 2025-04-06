// lib/checkout/components/time_slots.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/brutal_decoration.dart';
import 'section_title.dart';

class TimeSlots extends StatefulWidget {
  final String selectedSlot;
  final Function(String) onSlotChanged;

  const TimeSlots({
    super.key,
    required this.selectedSlot,
    required this.onSlotChanged,
  });

  @override
  State<TimeSlots> createState() => _TimeSlotsState();
}

class _TimeSlotsState extends State<TimeSlots> {
  late String _selectedSlot;

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.selectedSlot;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BrutalDecoration.brutalBox(color: Colors.white),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Select Delivery Time"),
          const SizedBox(height: 16),

          // First row of time slots
          Row(
            children: [
              Expanded(
                child: _buildTimeSlotOption(
                  'morning',
                  '6 AM - 9 AM',
                  Icons.wb_sunny_outlined,
                  Colors.orange[50]!,
                  Colors.orange[200]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeSlotOption(
                  'afternoon',
                  '12 PM - 3 PM',
                  Icons.wb_sunny,
                  Colors.yellow[50]!,
                  Colors.yellow[200]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Second row of time slots
          Row(
            children: [
              Expanded(
                child: _buildTimeSlotOption(
                  'evening',
                  '5 PM - 8 PM',
                  Icons.nights_stay_outlined,
                  Colors.blue[50]!,
                  Colors.blue[200]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeSlotOption(
                  'night',
                  '9 PM - 11 PM',
                  Icons.nightlight_round,
                  Colors.indigo[50]!,
                  Colors.indigo[200]!,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Delivery information
          _buildDeliveryInfo(),

          const SizedBox(height: 20),

          // Selected slot confirmation
          _buildSelectedSlotConfirmation(),
        ],
      ),
    );
  }

  Widget _buildTimeSlotOption(
    String value,
    String timeRange,
    IconData icon,
    Color bgColor,
    Color iconBgColor,
  ) {
    final isSelected = _selectedSlot == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSlot = value;
        });
        widget.onSlotChanged(value);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BrutalDecoration.selectedOption(
          isSelected: isSelected,
          selectedColor: bgColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? iconBgColor : Colors.grey[200]!,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(offset: Offset(2, 2), color: Colors.black)
                      ]
                    : null,
              ),
              child: Icon(icon, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              timeRange,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
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
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text(
                "DELIVERY INFORMATION",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "• Delivery times are approximate and may vary by ±30 minutes",
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            "• You'll receive an SMS when your delivery is on the way",
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            "• Please ensure someone is available to receive the delivery",
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            "• Our delivery partner will wait for a maximum of 5 minutes",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSlotConfirmation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(offset: Offset(3, 3), color: Colors.black)],
      ),
      child: Row(
        children: [
          Icon(
            _getTimeSlotIcon(_selectedSlot),
            size: 24,
            color: Colors.black,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Selected Delivery Time:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getTimeSlotLabel(_selectedSlot),
                style: GoogleFonts.bangers(
                  fontSize: 20,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper to get time slot icon
  IconData _getTimeSlotIcon(String slot) {
    switch (slot) {
      case 'morning':
        return Icons.wb_sunny_outlined;
      case 'afternoon':
        return Icons.wb_sunny;
      case 'evening':
        return Icons.nights_stay_outlined;
      case 'night':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  // Helper to get time slot label
  String _getTimeSlotLabel(String slot) {
    switch (slot) {
      case 'morning':
        return '6 AM - 9 AM';
      case 'afternoon':
        return '12 PM - 3 PM';
      case 'evening':
        return '5 PM - 8 PM';
      case 'night':
        return '9 PM - 11 PM';
      default:
        return '';
    }
  }
}
