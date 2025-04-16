import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/brutal_decoration.dart';
import 'order_details_page.dart';

class OrderCalendarView extends StatefulWidget {
  final List<Map<String, dynamic>> orders;

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
  late Map<DateTime, List<Map<String, dynamic>>> _deliveryEvents;
  late Map<DateTime, List<Map<String, dynamic>>> _resumeEvents;
  // Store paused periods for each order
  late Map<String, List<DateTimeRange>> _orderPausedPeriods;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _refreshEvents();
  }

  // Refresh all event collections
  void _refreshEvents() {
    _orderPausedPeriods = _generateOrderPausedPeriods();
    _deliveryEvents = _generateDeliveryEvents();
    _resumeEvents = _generateResumeEvents();

    // Print for debugging
    print("Generated ${_orderPausedPeriods.length} orders with paused periods");
    print("Generated ${_deliveryEvents.length} delivery days");
    print("Generated ${_resumeEvents.length} resume days");
  }

  // Generate paused periods for each order
  Map<String, List<DateTimeRange>> _generateOrderPausedPeriods() {
    final Map<String, List<DateTimeRange>> pausedPeriods = {};

    for (final order in widget.orders) {
      // Skip orders that aren't paused
      if (order['status'] != 'Paused') {
        continue;
      }

      final orderId = order['id']?.toString() ?? '';
      if (orderId.isEmpty) continue;

      // Get pause details
      final pauseDetails = order['pauseDetails'] as Map<String, dynamic>?;
      if (pauseDetails == null) continue;

      // Get pause start date
      final pausedAt = pauseDetails['pausedAt'] is Timestamp
          ? (pauseDetails['pausedAt'] as Timestamp).toDate()
          : null;
      if (pausedAt == null) continue;

      // Determine pause end date
      DateTime pauseEndDate;

      if (pauseDetails['isPauseIndefinite'] == true) {
        // For indefinite pauses, use a far future date
        pauseEndDate = DateTime(2099, 12, 31);
      } else if (pauseDetails['resumeDate'] is Timestamp) {
        // Use the specified resume date
        pauseEndDate = (pauseDetails['resumeDate'] as Timestamp).toDate();
      } else {
        // Calculate based on pauseDuration
        final pauseDuration = pauseDetails['pauseDuration'] ?? '1 week';
        switch (pauseDuration) {
          case '1 week':
            pauseEndDate = pausedAt.add(const Duration(days: 7));
            break;
          case '2 weeks':
            pauseEndDate = pausedAt.add(const Duration(days: 14));
            break;
          case '1 month':
            pauseEndDate = pausedAt.add(const Duration(days: 30));
            break;
          default:
            pauseEndDate = pausedAt.add(const Duration(days: 7));
        }
      }

      // Add the paused period for this order
      pausedPeriods[orderId] = [
        DateTimeRange(start: pausedAt, end: pauseEndDate)
      ];
    }

    return pausedPeriods;
  }

  // Generate a map of dates to orders for each delivery day
  Map<DateTime, List<Map<String, dynamic>>> _generateDeliveryEvents() {
    final Map<DateTime, List<Map<String, dynamic>>> events = {};

    // Only consider active and upcoming orders
    final relevantOrders = widget.orders
        .where((order) =>
            order['status'] == 'Active' || order['status'] == 'Upcoming')
        .toList();

    for (final order in relevantOrders) {
      // Generate delivery days for this order
      final deliveryDays = _generateOrderDeliveryDays(order);

      // Add order to each delivery day
      for (final day in deliveryDays) {
        final key = day;
        if (events[key] == null) {
          events[key] = [];
        }
        events[key]!.add(order);
      }
    }

    return events;
  }

  // Generate a map of dates to paused orders that will resume on that date
  Map<DateTime, List<Map<String, dynamic>>> _generateResumeEvents() {
    final Map<DateTime, List<Map<String, dynamic>>> events = {};

    // Only consider paused orders with a resume date
    final pausedOrders = widget.orders
        .where((order) =>
            order['status'] == 'Paused' && order['pauseDetails'] != null)
        .toList();

    for (final order in pausedOrders) {
      // Get the resume date if it exists and isn't indefinite
      final pauseDetails = order['pauseDetails'] as Map<String, dynamic>?;
      if (pauseDetails != null &&
          pauseDetails['isPauseIndefinite'] != true &&
          pauseDetails['resumeDate'] != null) {
        // Convert Timestamp to DateTime
        final resumeDate = pauseDetails['resumeDate'] is Timestamp
            ? (pauseDetails['resumeDate'] as Timestamp).toDate()
            : null;

        if (resumeDate != null) {
          final key =
              DateTime(resumeDate.year, resumeDate.month, resumeDate.day);
          if (events[key] == null) {
            events[key] = [];
          }
          events[key]!.add(order);
        }
      }
    }

    return events;
  }

  // Generate delivery days for a specific order
  Set<DateTime> _generateOrderDeliveryDays(Map<String, dynamic> order) {
    final Set<DateTime> days = {};

    // Skip if order is not active or upcoming
    if (order['status'] != 'Active' && order['status'] != 'Upcoming') {
      return days;
    }

    // Convert Timestamps to DateTime
    final start = order['startDate'] is Timestamp
        ? (order['startDate'] as Timestamp).toDate()
        : DateTime.now();

    final end = order['endDate'] is Timestamp
        ? (order['endDate'] as Timestamp).toDate()
        : DateTime.now().add(const Duration(days: 30));

    // Get the delivery days option
    final deliveryDaysOption = order['deliveryDays'] ?? 'Everyday';

    // Create a function to check if a day is a delivery day
    bool isDeliveryDay(DateTime day) {
      switch (deliveryDaysOption) {
        case 'Weekdays':
        case 'weekdays':
          return day.weekday >= 1 && day.weekday <= 5;
        case 'Weekends':
        case 'weekends':
          return day.weekday == 6 || day.weekday == 7;
        case 'Everyday':
        case 'everyday':
          return true;
        case 'Custom':
          // For this example, let's say Monday, Wednesday, Friday
          return day.weekday == 1 || day.weekday == 3 || day.weekday == 5;
        default:
          return true; // Default to everyday
      }
    }

    // For upcoming orders, only include days starting from today
    DateTime today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime actualStartDate = start.isBefore(today) ? today : start;

    // Add all delivery days between adjusted start and end dates
    DateTime current = actualStartDate;
    while (current.isBefore(end) || isSameDay(current, end)) {
      if (isDeliveryDay(current)) {
        days.add(DateTime(current.year, current.month, current.day));
      }
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  // Helper function to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Check if an order is paused on a specific day
  bool _isOrderPausedOnDay(String orderId, DateTime day) {
    final pausedPeriods = _orderPausedPeriods[orderId];
    if (pausedPeriods == null || pausedPeriods.isEmpty) {
      return false;
    }

    final normalizedDay = DateTime(day.year, day.month, day.day);

    for (final period in pausedPeriods) {
      final start = DateTime(
        period.start.year,
        period.start.month,
        period.start.day,
      );
      final end = DateTime(
        period.end.year,
        period.end.month,
        period.end.day,
      );

      if (normalizedDay.isAfter(start.subtract(const Duration(days: 1))) &&
          normalizedDay.isBefore(end.add(const Duration(days: 1)))) {
        return true;
      }
    }

    return false;
  }

  // Get all events for a specific day
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final List<Map<String, dynamic>> events = [];

    // Add delivery events
    final deliveries = _deliveryEvents[normalizedDay] ?? [];
    for (final order in deliveries) {
      final orderId = order['id']?.toString() ?? '';
      if (orderId.isNotEmpty && _isOrderPausedOnDay(orderId, normalizedDay)) {
        // Skip paused orders
        continue;
      }
      events.add({
        ...order,
        '_eventType': 'delivery',
      });
    }

    // Add resume events
    final resumes = _resumeEvents[normalizedDay] ?? [];
    events.addAll(resumes.map((order) => {
          ...order,
          '_eventType': 'resume',
        }));

    return events;
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
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BrutalDecoration.brutalBox(),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () {
                setState(() {
                  _refreshEvents();
                });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarLegend(),
          _buildCalendar(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildSelectedDayEvents(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem("Delivery", Colors.green),
          _buildLegendItem("Resume", Colors.orange),
          _buildLegendItem("Paused", Colors.grey[300]!),
          _buildLegendItem("Today", Colors.blue),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BrutalDecoration.brutalBox(),
      child: TableCalendar<Map<String, dynamic>>(
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
        calendarBuilders: CalendarBuilders<Map<String, dynamic>>(
          // Custom marker builder
          markerBuilder: (context, date, events) {
            if (events.isEmpty) {
              return null;
            }

            // Count deliveries and resumes
            int deliveryCount = 0;
            int resumeCount = 0;

            for (final event in events) {
              final orderId = event['id']?.toString() ?? '';
              if (event['_eventType'] == 'delivery') {
                if (!_isOrderPausedOnDay(orderId, date)) {
                  deliveryCount++;
                }
              } else if (event['_eventType'] == 'resume') {
                resumeCount++;
              }
            }

            // For non-paused days, show both delivery and resume markers
            final List<Widget> markers = [];

            if (deliveryCount > 0) {
              markers
                  .add(_buildDeliveryMarker(deliveryCount, Colors.green[600]!));
            }

            if (resumeCount > 0) {
              markers
                  .add(_buildDeliveryMarker(resumeCount, Colors.orange[600]!));
            }

            if (markers.isEmpty) {
              return null;
            }

            return Positioned(
              right: 1,
              bottom: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(markers.length, (index) {
                  if (index == 0) {
                    return markers[index];
                  }
                  return Row(
                    children: [
                      const SizedBox(width: 2),
                      markers[index],
                    ],
                  );
                }),
              ),
            );
          },
        ),
        eventLoader: _getEventsForDay,
      ),
    );
  }

  Widget _buildDeliveryMarker(int count, Color color) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
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

  Widget _buildSelectedDayEvents() {
    final events = _getEventsForDay(_selectedDay);
    final hasPausedOrders = _hasPausedOrdersOnDay(_selectedDay);

    if (events.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(16),
          decoration: BrutalDecoration.brutalBox(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasPausedOrders
                    ? Icons.pause_circle_filled
                    : Icons.calendar_today,
                size: 48,
                color: hasPausedOrders ? Colors.grey[400] : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                hasPausedOrders
                    ? "No active deliveries on this day (some orders are paused)"
                    : "No events on ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
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

    // Deliveries (filtered to exclude paused orders)
    final deliveries =
        events.where((e) => e['_eventType'] == 'delivery').toList();

    // Resumes that happen on this day
    final resumes = events.where((e) => e['_eventType'] == 'resume').toList();

    // Paused orders that would have been delivered today
    final pausedDeliveries = _getPausedDeliveriesForDay(_selectedDay);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Paused notice (if applicable)
        if (pausedDeliveries.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.pause_circle_filled, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      "Paused Orders (${pausedDeliveries.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "These orders would have been delivered today but are paused:",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...pausedDeliveries.map((order) => _buildPausedItem(order)),
              ],
            ),
          ),
        ],

        // Deliveries section
        if (deliveries.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Active Deliveries (${deliveries.length}):",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ...deliveries.map((order) => _buildDeliveryItem(order)),
          const SizedBox(height: 20),
        ],

        // Resuming subscriptions section
        if (resumes.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Resuming Today (${resumes.length}):",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.orange[800],
              ),
            ),
          ),
          ...resumes.map((order) => _buildResumeItem(order)),
        ],
      ],
    );
  }

  // Check if there are any paused orders on a given day
  bool _hasPausedOrdersOnDay(DateTime day) {
    for (final order in widget.orders) {
      if (order['status'] == 'Paused') {
        final orderId = order['id']?.toString() ?? '';
        if (orderId.isNotEmpty && _isOrderPausedOnDay(orderId, day)) {
          return true;
        }
      }
    }
    return false;
  }

  // Get paused deliveries that would have been delivered on this day
  List<Map<String, dynamic>> _getPausedDeliveriesForDay(DateTime day) {
    final List<Map<String, dynamic>> pausedDeliveries = [];
    final normalizedDay = DateTime(day.year, day.month, day.day);

    for (final order in widget.orders) {
      if (order['status'] == 'Paused') {
        final orderId = order['id']?.toString() ?? '';
        if (orderId.isEmpty) continue;

        // Check if this order would have been delivered today if not paused
        final deliveryDays = _generateOrderDeliveryDays(order);
        if (deliveryDays.contains(normalizedDay)) {
          pausedDeliveries.add(order);
        }
      }
    }

    return pausedDeliveries;
  }

  // Build a delivery item card
  Widget _buildDeliveryItem(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: const [BoxShadow(offset: Offset(2, 2), color: Colors.black)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green[600]!, width: 1),
          ),
          child: Icon(Icons.local_shipping, color: Colors.green[600], size: 20),
        ),
        title: Text(
          order['productName'] ?? 'Unknown Product',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              order['deliveryTime'] ?? 'No delivery time specified',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Order ID: ${order['id'] ?? 'Unknown'}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage(order: order),
              ),
            );
          },
        ),
      ),
    );
  }

  // Build a resume item card
  Widget _buildResumeItem(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: const [BoxShadow(offset: Offset(2, 2), color: Colors.black)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange[100],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange[600]!, width: 1),
          ),
          child:
              Icon(Icons.play_circle_fill, color: Colors.orange[600], size: 20),
        ),
        title: Text(
          order['productName'] ?? 'Unknown Product',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            const Text(
              'Subscription resumes today',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Order ID: ${order['id'] ?? 'Unknown'}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage(order: order),
              ),
            );
          },
        ),
      ),
    );
  }

  // Build a paused item card
  Widget _buildPausedItem(Map<String, dynamic> order) {
    final pauseDetails = order['pauseDetails'] as Map<String, dynamic>?;
    String pauseStatus = 'Paused';

    if (pauseDetails != null) {
      if (pauseDetails['isPauseIndefinite'] == true) {
        pauseStatus = 'Paused Indefinitely';
      } else if (pauseDetails['resumeDate'] != null) {
        final resumeDate = pauseDetails['resumeDate'] is Timestamp
            ? (pauseDetails['resumeDate'] as Timestamp).toDate()
            : null;
        if (resumeDate != null) {
          pauseStatus =
              'Paused until ${resumeDate.day}/${resumeDate.month}/${resumeDate.year}';
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[600]!, width: 1),
          ),
          child: Icon(Icons.pause, color: Colors.grey[600], size: 16),
        ),
        title: Text(
          order['productName'] ?? 'Unknown Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        subtitle: Text(
          pauseStatus,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage(order: order),
              ),
            );
          },
        ),
      ),
    );
  }
}
