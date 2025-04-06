// lib/orders/components/delivery_calendar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../utils/brutal_decoration.dart';
import '../models/order.dart';

class DeliveryCalendar extends StatefulWidget {
  final Order order;

  const DeliveryCalendar({
    super.key,
    required this.order,
  });

  @override
  State<DeliveryCalendar> createState() => _DeliveryCalendarState();
}

class _DeliveryCalendarState extends State<DeliveryCalendar> {
  late DateTime _focusedDay;
  late Set<DateTime> _deliveryDays;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.order.startDate;
    _deliveryDays = _generateDeliveryDays();
  }

  // Generate delivery days based on order delivery frequency
  Set<DateTime> _generateDeliveryDays() {
    final Set<DateTime> days = {};
    final start = widget.order.startDate;
    final end = widget.order.endDate;

    // Create a function to check if a day is a delivery day
    bool isDeliveryDay(DateTime day) {
      switch (widget.order.deliveryDays) {
        case 'Weekdays':
          return day.weekday >= 1 && day.weekday <= 5;
        case 'Weekends':
          return day.weekday >= 6 && day.weekday <= 7;
        case 'Everyday':
          return true;
        case 'Custom':
          // For this example, let's say Monday, Wednesday, Friday
          return day.weekday == 1 || day.weekday == 3 || day.weekday == 5;
        default:
          return false;
      }
    }

    // Add all delivery days between start and end dates
    for (DateTime day = start;
        day.isBefore(end) || day.isAtSameMomentAs(end);
        day = day.add(const Duration(days: 1))) {
      if (isDeliveryDay(day)) {
        days.add(DateTime(day.year, day.month, day.day));
      }
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCalendarLegend(),
          const SizedBox(height: 16),
          _buildCalendar(),
          const SizedBox(height: 20),
          _buildUpcomingDeliveries(),
        ],
      ),
    );
  }

  Widget _buildCalendarLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BrutalDecoration.brutalBox(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem("Delivery Day", Colors.green[600]!),
          _buildLegendItem("Today", Colors.blue[600]!),
          _buildLegendItem("Start Date", Colors.orange[600]!),
          _buildLegendItem("End Date", Colors.red[600]!),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BrutalDecoration.brutalBox(),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 30)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
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
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.blue[600],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          todayTextStyle: const TextStyle(color: Colors.white),
          weekendTextStyle: const TextStyle(color: Colors.red),
          outsideDaysVisible: false,
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            // Check if this is a delivery day
            final isDelivery = _deliveryDays.contains(
              DateTime(day.year, day.month, day.day),
            );

            // Check if this is the start or end date
            final isStart = day.year == widget.order.startDate.year &&
                day.month == widget.order.startDate.month &&
                day.day == widget.order.startDate.day;

            final isEnd = day.year == widget.order.endDate.year &&
                day.month == widget.order.endDate.month &&
                day.day == widget.order.endDate.day;

            // Set appearance based on the type of day
            if (isStart) {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            } else if (isEnd) {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            } else if (isDelivery) {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildUpcomingDeliveries() {
    // Get the next 3 delivery dates from today
    final today = DateTime.now();
    final upcomingDeliveries =
        _deliveryDays.where((date) => date.isAfter(today)).toList()..sort();

    final nextDeliveries = upcomingDeliveries.take(3).toList();

    if (nextDeliveries.isEmpty) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(offset: Offset(3, 3), color: Colors.black)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.green[700]),
              const SizedBox(width: 8),
              const Text(
                "Upcoming Deliveries",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...nextDeliveries.map((date) => _buildDeliveryItem(date)),
        ],
      ),
    );
  }

  Widget _buildDeliveryItem(DateTime date) {
    // Calculate days from now
    final today = DateTime.now();
    final difference = date.difference(today).inDays;

    String timeDescription;
    if (difference == 0) {
      timeDescription = "Today";
    } else if (difference == 1) {
      timeDescription = "Tomorrow";
    } else {
      timeDescription = "In $difference days";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black),
        boxShadow: const [BoxShadow(offset: Offset(2, 2), color: Colors.black)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[600],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${date.day}/${date.month}/${date.year} (${_getDayName(date.weekday)})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeDescription,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            widget.order.deliveryTime,
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}
