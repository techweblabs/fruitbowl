// lib/checkout/components/start_date.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../utils/brutal_decoration.dart';
import 'section_title.dart';

class StartDate extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const StartDate({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<StartDate> createState() => _StartDateState();
}

class _StartDateState extends State<StartDate> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BrutalDecoration.brutalBox(color: Colors.white),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Select Start Date"),
          const SizedBox(height: 16),
          _buildCalendar(),
          const SizedBox(height: 20),
          _buildSelectedDateSummary(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstAvailableDay = DateTime.now().add(const Duration(days: 2));

    // Ensure _selectedDate is within valid range
    if (_selectedDate.isBefore(firstAvailableDay)) {
      _selectedDate = firstAvailableDay;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
      ),
      child: Column(
        children: [
          // Calendar header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: const Center(
              child: Text(
                "PICK A START DATE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          // Calendar widget
          TableCalendar(
            firstDay: firstAvailableDay,
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
              widget.onDateChanged(selectedDay);
            },
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              leftChevronIcon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BrutalDecoration.miniButton(),
                child: const Icon(Icons.chevron_left, size: 18),
              ),
              rightChevronIcon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BrutalDecoration.miniButton(),
                child: const Icon(Icons.chevron_right, size: 18),
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: const [
                  BoxShadow(offset: Offset(1, 1), color: Colors.black),
                ],
              ),
              weekendTextStyle: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateSummary() {
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
          const Icon(Icons.calendar_today),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Subscription Will Start On:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
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
}
