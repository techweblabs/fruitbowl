// lib/orders/components/delivery_calendar.dart - fixed version
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/brutal_decoration.dart';

class DeliveryCalendar extends StatefulWidget {
  final Map<String, dynamic> order;

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
  late Set<DateTime>
      _pausedDeliveryDays; // Set to track paused delivery days (only)
  late DateTime _startDate;
  late DateTime _endDate;
  DateTime? _resumeDate; // Date when subscription resumes after pause
  late DateTime _originalEndDate; // Original end date before any pauses

  @override
  void initState() {
    super.initState();

    // Get start and end dates
    _startDate = widget.order['startDate'] is Timestamp
        ? (widget.order['startDate'] as Timestamp).toDate()
        : DateTime.now();

    _endDate = widget.order['endDate'] is Timestamp
        ? (widget.order['endDate'] as Timestamp).toDate()
        : DateTime.now().add(const Duration(days: 30));

    // Get original end date (if exists)
    _originalEndDate = widget.order['originalEndDate'] is Timestamp
        ? (widget.order['originalEndDate'] as Timestamp).toDate()
        : _endDate;

    // Set focused day to start date
    _focusedDay = _startDate;

    // Generate all necessary days
    _pausedDeliveryDays = _generatePausedDeliveryDays();
    _deliveryDays = _generateDeliveryDays();
    _resumeDate = _getResumeDate();
  }

  // Generate delivery days that are paused
  Set<DateTime> _generatePausedDeliveryDays() {
    final Set<DateTime> pausedDays = {};

    // Only generate paused days if the order is paused
    if (widget.order['status'] != 'Paused') {
      return pausedDays;
    }

    // Get pause details
    final pauseDetails = widget.order['pauseDetails'] as Map<String, dynamic>?;
    if (pauseDetails == null) {
      return pausedDays;
    }

    // Get pause start date
    final pausedAt = pauseDetails['pausedAt'] is Timestamp
        ? (pauseDetails['pausedAt'] as Timestamp).toDate()
        : null;
    if (pausedAt == null) {
      return pausedDays;
    }

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

    // Get delivery days option
    final deliveryDaysOption = widget.order['deliveryDays'] ?? 'Everyday';

    // Function to check if a day is a delivery day
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

    // Add all DELIVERY days in the pause period to the set
    // Start from the day after pause start
    DateTime current = pausedAt.add(const Duration(days: 1));
    while (current.isBefore(pauseEndDate)) {
      // Only add if it's an actual delivery day according to the schedule
      if (isDeliveryDay(current)) {
        pausedDays.add(DateTime(current.year, current.month, current.day));
      }
      current = current.add(const Duration(days: 1));
    }

    return pausedDays;
  }

  // Get the resume date if it exists
  DateTime? _getResumeDate() {
    // Only relevant if the order is paused
    if (widget.order['status'] != 'Paused') {
      return null;
    }

    // Get pause details
    final pauseDetails = widget.order['pauseDetails'] as Map<String, dynamic>?;
    if (pauseDetails == null) {
      return null;
    }

    // Skip if indefinite pause
    if (pauseDetails['isPauseIndefinite'] == true) {
      return null;
    }

    // Get resume date if it exists
    if (pauseDetails['resumeDate'] is Timestamp) {
      final resumeDate = (pauseDetails['resumeDate'] as Timestamp).toDate();
      return DateTime(resumeDate.year, resumeDate.month, resumeDate.day);
    }

    return null;
  }

  // Generate delivery days based on order delivery frequency
  Set<DateTime> _generateDeliveryDays() {
    final Set<DateTime> days = {};

    // Get the delivery days option
    final deliveryDaysOption = widget.order['deliveryDays'] ?? 'Everyday';

    // Create a function to check if a day is a delivery day based on schedule
    bool isDeliveryDay(DateTime day) {
      switch (deliveryDaysOption.toLowerCase()) {
        case 'weekdays':
          return day.weekday >= 1 && day.weekday <= 5;
        case 'weekends':
          return day.weekday == 6 || day.weekday == 7;
        case 'everyday':
          return true;
        case 'custom':
          // For this example, let's say Monday, Wednesday, Friday
          return day.weekday == 1 || day.weekday == 3 || day.weekday == 5;
        default:
          return true; // Default to everyday if option not recognized
      }
    }

    // Get total days from the order
    final int totalDays = widget.order['totalDays'] ?? 0;

    // For active and paused orders, calculate based on total days
    if (widget.order['status'] == 'Active' ||
        widget.order['status'] == 'Paused') {
      // Start with the start date itself
      DateTime current = _startDate;
      int deliveryDaysFound = 0;

      // Count the start date if it's a delivery day
      if (isDeliveryDay(current) && !_isPausedDeliveryDay(current)) {
        days.add(DateTime(current.year, current.month, current.day));
        deliveryDaysFound++;
      }

      // Find the exact number of delivery days (up to totalDays)
      while (deliveryDaysFound < totalDays) {
        // Move to the next day
        current = current.add(const Duration(days: 1));

        final normalizedDay =
            DateTime(current.year, current.month, current.day);

        // Check if this is a delivery day and not paused
        if (isDeliveryDay(current) && !_isPausedDeliveryDay(normalizedDay)) {
          days.add(normalizedDay);
          deliveryDaysFound++;
        }

        // Stop if we've reached the end date (important to prevent extra days)
        if (isSameDay(current, _endDate)) {
          break;
        }
      }
    }
    // For other statuses, use basic calculation
    else {
      // Add all delivery days between start and end dates (inclusive of start, exclusive of end)
      DateTime current = _startDate;

      // Include the start date if it's a delivery day
      if (isDeliveryDay(current)) {
        days.add(DateTime(current.year, current.month, current.day));
      }

      // Add all delivery days up to but not including the end date
      current = current.add(const Duration(days: 1));
      while (current.isBefore(_endDate)) {
        if (isDeliveryDay(current)) {
          days.add(DateTime(current.year, current.month, current.day));
        }
        current = current.add(const Duration(days: 1));
      }

      // Include the end date if it's a delivery day
      if (isDeliveryDay(_endDate)) {
        days.add(DateTime(_endDate.year, _endDate.month, _endDate.day));
      }
    }

    return days;
  }

  // Check if a day is in the paused delivery days set
  bool _isPausedDeliveryDay(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _pausedDeliveryDays.contains(normalized);
  }

  // Check if this is the resume date
  bool _isResumeDay(DateTime date) {
    if (_resumeDate == null) return false;
    return isSameDay(date, _resumeDate!);
  }

  // Helper function to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
          // Show pause information if order is paused
          if (widget.order['status'] == 'Paused') _buildPauseInfo(),

          // Show pause history if it exists
          if (widget.order['pauseHistory'] != null &&
              (widget.order['pauseHistory'] as List).isNotEmpty)
            _buildPauseHistory(),
        ],
      ),
    );
  }

  Widget _buildCalendarLegend() {
    // Add paused and resume days to the legend
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem("Delivery Day", Colors.green[600]!),
              _buildLegendItem("Today", Colors.blue[600]!),
              _buildLegendItem("Start Date", Colors.orange[600]!),
              _buildLegendItem("End Date", Colors.red[600]!),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem("Paused Day", Colors.grey[400]!),
              if (_resumeDate != null)
                _buildLegendItem("Resume Date", Colors.orange[600]!),
              if (widget.order['originalEndDate'] != null &&
                  widget.order['status'] == 'Paused')
                _buildLegendItem("Original End", Colors.purple[400]!),
              if (_resumeDate == null &&
                  widget.order['originalEndDate'] == null)
                const SizedBox(width: 100),
            ],
          ),
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
            // Create a date with just year, month, day for comparison
            final checkDay = DateTime(day.year, day.month, day.day);

            // Only days between start date and end date (inclusive) should be considered
            final isWithinSubscriptionPeriod = (checkDay.isAfter(_startDate) ||
                    isSameDay(checkDay, _startDate)) &&
                (checkDay.isBefore(_endDate) || isSameDay(checkDay, _endDate));

            // Check different day types
            final isDelivery = _deliveryDays
                .any((deliveryDate) => isSameDay(deliveryDate, checkDay));
            final isPaused = _isPausedDeliveryDay(checkDay);
            final isResume = _isResumeDay(checkDay);
            final isStart = isSameDay(checkDay, _startDate);
            final isEnd = isSameDay(checkDay, _endDate);
            final isOriginalEnd = widget.order['originalEndDate'] != null &&
                widget.order['status'] == 'Paused' &&
                isSameDay(checkDay, _originalEndDate);

            // Only show delivery days based on schedule and within the subscription period
            final deliveryDaysOption =
                widget.order['deliveryDays'] ?? 'Everyday';
            bool isScheduledDeliveryDay = false;

            switch (deliveryDaysOption.toLowerCase()) {
              case 'weekdays':
                isScheduledDeliveryDay =
                    checkDay.weekday >= 1 && checkDay.weekday <= 5;
                break;
              case 'weekends':
                isScheduledDeliveryDay =
                    checkDay.weekday == 6 || checkDay.weekday == 7;
                break;
              case 'everyday':
                isScheduledDeliveryDay = true;
                break;
              case 'custom':
                isScheduledDeliveryDay = checkDay.weekday == 1 ||
                    checkDay.weekday == 3 ||
                    checkDay.weekday == 5;
                break;
              default:
                isScheduledDeliveryDay = true;
            }

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
            } else if (isOriginalEnd) {
              // Original end date (for paused orders)
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.purple[400],
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
            } else if (isResume) {
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
            } else if (isPaused &&
                isScheduledDeliveryDay &&
                isWithinSubscriptionPeriod) {
              // Only show paused days that are scheduled delivery days within subscription period
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[400]!, width: 1),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              );
            } else if (isDelivery && isWithinSubscriptionPeriod) {
              // Only show delivery days within the subscription period
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
    final upcomingDeliveries = _deliveryDays
        .where((date) => date.isAfter(today) || isSameDay(date, today))
        .toList();

    // Sort upcoming deliveries by date
    upcomingDeliveries.sort((a, b) => a.compareTo(b));

    // Take the next 3 deliveries
    final nextDeliveries = upcomingDeliveries.take(3).toList();

    if (nextDeliveries.isEmpty) {
      String noDeliveryMessage = "No upcoming deliveries";

      // More specific message if paused
      if (widget.order['status'] == 'Paused') {
        noDeliveryMessage =
            "No upcoming deliveries while subscription is paused";
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(offset: Offset(3, 3), color: Colors.black)
          ],
        ),
        child: Center(
          child: Text(
            noDeliveryMessage,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
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

  // Add a widget to display pause information
  Widget _buildPauseInfo() {
    // Get pause details
    final pauseDetails = widget.order['pauseDetails'] as Map<String, dynamic>?;
    if (pauseDetails == null) {
      return const SizedBox.shrink();
    }

    final pausedAt = pauseDetails['pausedAt'] is Timestamp
        ? (pauseDetails['pausedAt'] as Timestamp).toDate()
        : null;

    String pauseStatus = "";
    String resumeInfo = "";

    if (pauseDetails['isPauseIndefinite'] == true) {
      pauseStatus = "Subscription paused indefinitely";
      resumeInfo = "Will remain paused until manually resumed";
    } else if (_resumeDate != null) {
      pauseStatus = "Subscription temporarily paused";
      resumeInfo =
          "Will automatically resume on ${_resumeDate!.day}/${_resumeDate!.month}/${_resumeDate!.year}";
    }

    // Get pause reason if any
    final reason = pauseDetails['reason'] as String?;

    // Get count of paused delivery days
    final pausedDeliveryDays =
        pauseDetails['pausedDeliveryDays'] ?? _pausedDeliveryDays.length;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(offset: Offset(3, 3), color: Colors.black)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pause_circle_filled, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                pauseStatus,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pause start date
          if (pausedAt != null)
            _buildPauseInfoRow("Paused on",
                "${pausedAt.day}/${pausedAt.month}/${pausedAt.year}"),

          // Resume info
          _buildPauseInfoRow("Status", resumeInfo),

          // Paused delivery days count
          _buildPauseInfoRow("Paused Days",
              "$pausedDeliveryDays delivery ${pausedDeliveryDays == 1 ? 'day' : 'days'}"),

          // Original end date info if available
          if (widget.order['originalEndDate'] != null)
            _buildPauseInfoRow("Original End",
                "${_originalEndDate.day}/${_originalEndDate.month}/${_originalEndDate.year}"),

          // New end date info
          _buildPauseInfoRow("New End Date",
              "${_endDate.day}/${_endDate.month}/${_endDate.year}"),

          // Reason if provided
          if (reason != null && reason.isNotEmpty)
            _buildPauseInfoRow("Reason", reason),

          // Action button for resuming
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // This will navigate back to the details page where user can resume
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
                boxShadow: const [
                  BoxShadow(offset: Offset(2, 2), color: Colors.black)
                ],
              ),
              child: const Center(
                child: Text(
                  "Go Back to Resume Subscription",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add a widget to display pause history
  Widget _buildPauseHistory() {
    final pauseHistory = widget.order['pauseHistory'] as List?;
    if (pauseHistory == null || pauseHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
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
              Icon(Icons.history, color: Colors.grey[700]),
              const SizedBox(width: 8),
              const Text(
                "Pause History",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...pauseHistory
              .map((pause) => _buildPauseHistoryItem(pause))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildPauseHistoryItem(dynamic pause) {
    if (pause is! Map) return const SizedBox.shrink();

    final pausedAt = pause['pausedAt'] is Timestamp
        ? (pause['pausedAt'] as Timestamp).toDate()
        : null;

    final resumedAt = pause['resumedAt'] is Timestamp
        ? (pause['resumedAt'] as Timestamp).toDate()
        : null;

    if (pausedAt == null || resumedAt == null) return const SizedBox.shrink();

    final pauseDuration = pause['pauseDuration'] ?? '';
    // Use actualPausedDeliveryDays for proper counting of paused delivery days
    final actualPausedDeliveryDays = pause['actualPausedDeliveryDays'] ??
        pause['pausedDeliveryDays'] ??
        pause['actualPauseDays'] ??
        0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Paused for $actualPausedDeliveryDays ${actualPausedDeliveryDays == 1 ? 'delivery day' : 'delivery days'}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text("Started: ${pausedAt.day}/${pausedAt.month}/${pausedAt.year}"),
          Text(
              "Resumed: ${resumedAt.day}/${resumedAt.month}/${resumedAt.year}"),
          if (pauseDuration.isNotEmpty)
            Text("Planned duration: $pauseDuration"),
        ],
      ),
    );
  }

  Widget _buildPauseInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryItem(DateTime date) {
    // Get delivery time
    final deliveryTime = widget.order['deliveryTime'] ?? '9 AM - 11 AM';

    // Calculate days from now
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final dateNormalized = DateTime(date.year, date.month, date.day);

    final difference = dateNormalized.difference(todayNormalized).inDays;

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
            deliveryTime,
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
