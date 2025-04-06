// lib/orders/order_calendar_view.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../utils/brutal_decoration.dart';
import 'models/order.dart';
import 'order_details_page.dart';

class OrderCalendarView extends StatefulWidget {
  final List<Order> orders;

  const OrderCalendarView({
    super.key,
    required this.orders,
  });

  @override
  State<OrderCalendarView> createState() => _OrderCalendarViewState();
}

class _OrderCalendarViewState extends State<OrderCalendarView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<Order>> _deliveryEvents;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _deliveryEvents = _generateDeliveryEvents();
  }

  // Generate a map of dates to orders for each delivery day
  Map<DateTime, List<Order>> _generateDeliveryEvents() {
    final Map<DateTime, List<Order>> events = {};

    // Only consider active and upcoming orders
    final activeOrders = widget.orders
        .where(
            (order) => order.status == 'Active' || order.status == 'Upcoming')
        .toList();

    for (final order in activeOrders) {
      // Generate delivery days for this order
      final deliveryDays = _generateOrderDeliveryDays(order);

      // Add order to each delivery day
      for (final day in deliveryDays) {
        final key = DateTime(day.year, day.month, day.day);
        events[key] = [...(events[key] ?? []), order];
      }
    }

    return events;
  }

  // Generate delivery days for a specific order
  Set<DateTime> _generateOrderDeliveryDays(Order order) {
    final Set<DateTime> days = {};

    // Skip if order is not active or upcoming
    if (order.status != 'Active' && order.status != 'Upcoming') {
      return days;
    }

    final start = order.startDate;
    final end = order.endDate;

    // Create a function to check if a day is a delivery day
    bool isDeliveryDay(DateTime day) {
      switch (order.deliveryDays) {
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

  List<Order> _getDeliveriesForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _deliveryEvents[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: Text(
          "DELIVERY CALENDAR",
          style: GoogleFonts.bangers(
            fontSize: 28,
            color: Colors.black,
            letterSpacing: 2,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BrutalDecoration.brutalBox(),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildSelectedDayDeliveries(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BrutalDecoration.brutalBox(),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 30)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: GoogleFonts.bangers(
            fontSize: 18,
            letterSpacing: 1.2,
          ),
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
          selectedDecoration: BoxDecoration(
            color: Colors.purple[600],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
            boxShadow: const [
              BoxShadow(offset: Offset(1, 1), color: Colors.black)
            ],
          ),
          todayDecoration: BoxDecoration(
            color: Colors.blue[600],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          todayTextStyle: const TextStyle(color: Colors.white),
          weekendTextStyle: const TextStyle(color: Colors.red),
          markersMaxCount: 3,
          outsideDaysVisible: false,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: _buildDeliveryMarker(events.length),
              );
            }
            return null;
          },
        ),
        eventLoader: _getDeliveriesForDay,
      ),
    );
  }

  Widget _buildDeliveryMarker(int count) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.green[600],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayDeliveries() {
    final deliveries = _getDeliveriesForDay(_selectedDay);

    if (deliveries.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(16),
          decoration: BrutalDecoration.brutalBox(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                "No deliveries on ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Deliveries on ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deliveries.length,
            itemBuilder: (context, index) {
              final order = deliveries[index];
              return _buildDeliveryItem(order);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryItem(Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BrutalDecoration.brutalBox(),
        child: Column(
          children: [
            // Header with image and product name
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                image: DecorationImage(
                  image: AssetImage(order.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      order.gradientColors[0].withOpacity(0.7),
                      order.gradientColors[2].withOpacity(0.9),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    order.productName,
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
              ),
            ),

            // Delivery details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildDeliveryDetail("Time:", order.deliveryTime),
                  const SizedBox(height: 4),
                  _buildDeliveryDetail("Status:", order.status),
                  const SizedBox(height: 4),
                  _buildDeliveryDetail("Order ID:", order.id),
                ],
              ),
            ),

            // View details button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "View Details",
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.blue[700],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDetail(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: label == "Status:" ? _getStatusColor(value) : Colors.black,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
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
}
