// lib/orders/order_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/MyOrdersScreen/order_calendar_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_starter_kit/services/subscription_service.dart';

import '../../utils/brutal_decoration.dart';
import 'components/delivery_calendar.dart';
import 'components/action_button.dart';
import 'components/detail_section.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  String _pauseReason = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get a color based on status
  Color get statusColor {
    final String status = widget.order['status'] ?? 'Active';
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

  // Calculate progress percentage
  double get progressPercentage {
    final int totalDays = widget.order['totalDays'] ?? 0;
    final int remainingDays = widget.order['remainingDays'] ?? 0;
    if (totalDays == 0) return 0;
    return (totalDays - remainingDays) / totalDays;
  }

  // Format date as string
  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // Get formatted duration string
  String get durationText {
    final int totalDays = widget.order['totalDays'] ?? 0;

    final DateTime startDate = widget.order['startDate'] is Timestamp
        ? (widget.order['startDate'] as Timestamp).toDate()
        : DateTime.now();

    final DateTime endDate = widget.order['endDate'] is Timestamp
        ? (widget.order['endDate'] as Timestamp).toDate()
        : DateTime.now().add(const Duration(days: 30));

    return "$totalDays days (${formatDate(startDate)} - ${formatDate(endDate)})";
  }

  // Get delivery schedule text
  String get deliveryScheduleText {
    final String deliveryDays = widget.order['deliveryDays'] ?? 'Weekdays';
    final String deliveryTime = widget.order['deliveryTime'] ?? '9 AM - 11 AM';
    return "$deliveryDays • $deliveryTime";
  }

  // Get gradient colors from the order
  List<Color> get gradientColors {
    List<Color> colors = [];
    if (widget.order['gradientColors'] != null) {
      for (var colorData in widget.order['gradientColors']) {
        if (colorData is Map) {
          colors.add(
            Color.fromRGBO(
              colorData['red'] ?? 0,
              colorData['green'] ?? 0,
              colorData['blue'] ?? 0,
              colorData['alpha'] != null ? colorData['alpha'] / 255 : 1.0,
            ),
          );
        }
      }
    }

    // If no valid colors were found, use defaults
    if (colors.isEmpty) {
      colors = [
        const Color(0xFF8ECAE6),
        const Color(0xFF219EBC),
        const Color(0xFF023047),
      ];
    }

    return colors;
  }

  // Get pause details formatted text
  String? get pauseDetailsText {
    if (widget.order['status'] != 'Paused' ||
        widget.order['pauseDetails'] == null) {
      return null;
    }

    final pauseDetails = widget.order['pauseDetails'] as Map<String, dynamic>;
    final pauseDuration = pauseDetails['pauseDuration'] ?? '1 week';

    if (pauseDetails['isPauseIndefinite'] == true) {
      return "Paused indefinitely until you resume";
    }

    final resumeDate = pauseDetails['resumeDate'] is Timestamp
        ? (pauseDetails['resumeDate'] as Timestamp).toDate()
        : null;

    if (resumeDate != null) {
      return "Paused for $pauseDuration until ${formatDate(resumeDate)}";
    }

    return "Paused for $pauseDuration";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeaderBackground(),
                    ),
                    leading: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(offset: Offset(2, 2), color: Colors.black)
                          ],
                        ),
                        child:
                            const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(offset: Offset(2, 2), color: Colors.black)
                          ],
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.black),
                          onPressed: () {
                            _showOptionsMenu(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: _buildOrderSummary(),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: Colors.yellow[600],
                        indicatorWeight: 3.0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        tabs: const [
                          Tab(text: "DETAILS"),
                          Tab(text: "CALENDAR"),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: Container(
                color: Colors.grey[100],
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDetailsTab(),
                    // DeliveryCalendar expects a Map<String, dynamic>
                    DeliveryCalendar(order: widget.order),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeaderBackground() {
    final String imageUrl =
        widget.order['imageUrl'] ?? 'assets/images/fruits.png';
    final String productName = widget.order['productName'] ?? 'Product';
    final String status = widget.order['status'] ?? 'Active';

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientColors[0].withOpacity(0.6),
              gradientColors.length > 2
                  ? gradientColors[2].withOpacity(0.9)
                  : gradientColors.last.withOpacity(0.9),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: GoogleFonts.bangers(
                  fontSize: 36,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    const Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(offset: Offset(1, 1), color: Colors.black),
                  ],
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final String id = widget.order['id'] ?? '';
    final String price = widget.order['price'] ?? '₹0';
    final String status = widget.order['status'] ?? 'Active';
    final int remainingDays = widget.order['remainingDays'] ?? 0;

    final DateTime orderDate = widget.order['orderDate'] is Timestamp
        ? (widget.order['orderDate'] as Timestamp).toDate()
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Order ID",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(id),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Order Date",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(formatDate(orderDate)),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          // Pause details if subscription is paused
          if (status == 'Paused' && pauseDetailsText != null) ...[
            const Divider(height: 24, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pause Status",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    pauseDetailsText!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Progress bar for active orders
          if (status == 'Active') ...[
            const Divider(height: 24, thickness: 1),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Progress",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${(progressPercentage * 100).toInt()}% ($remainingDays days left)",
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressPercentage.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    final String productName = widget.order['productName'] ?? 'Product';

    // Extract address data
    final Map<String, dynamic>? addressData = widget.order['address'];
    String formattedAddress = "No address provided";

    if (addressData != null && addressData.isNotEmpty) {
      final List<String> addressParts = [];

      if (addressData['fullAddress'] != null)
        addressParts.add(addressData['fullAddress'].toString());
      if (addressData['addressLine2'] != null)
        addressParts.add(addressData['addressLine2'].toString());
      if (addressData['city'] != null)
        addressParts.add(addressData['city'].toString());
      if (addressData['state'] != null)
        addressParts.add(addressData['state'].toString());
      if (addressData['pincode'] != null)
        addressParts.add(addressData['pincode'].toString());

      formattedAddress = addressParts.join(', ');
    }

    final String price = widget.order['price'] ?? '₹0';

    // Extract product details and ingredients
    Map<String, dynamic> productDetails = {};
    List<dynamic> ingredients = [];

    if (widget.order['productDetails'] != null) {
      productDetails = widget.order['productDetails'];
      if (productDetails['ingredients'] != null) {
        ingredients = productDetails['ingredients'];
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      children: [
        // Subscription details
        DetailSection(
          title: "Subscription Details",
          items: [
            DetailItem(
              icon: Icons.calendar_today,
              label: "Duration",
              value: durationText,
            ),
            DetailItem(
              icon: Icons.schedule,
              label: "Delivery Schedule",
              value: deliveryScheduleText,
            ),
            DetailItem(
              icon: Icons.location_on,
              label: "Delivery Address",
              value: formattedAddress,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Order contents
        DetailSection(
          title: "Order Contents",
          items: [
            DetailItem(
              icon: Icons.shopping_bag,
              label: "Product",
              value: productName,
            ),
            DetailItem(
              icon: Icons.local_fire_department,
              label: "Nutritional Info",
              value: productDetails['calories'] ?? "Not available",
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Order items (ingredients)
        DetailSection(
          title: "Order Items",
          items: [
            ...ingredients
                .map((ingredient) => DetailItem(
                      icon: Icons.food_bank,
                      label: ingredient['name'] ?? 'Ingredient',
                      value:
                          "${ingredient['qty'] ?? ''}, ${ingredient['protein'] ?? '0g'} protein",
                    ))
                .toList(),
            if (ingredients.isEmpty)
              DetailItem(
                icon: Icons.food_bank,
                label: "No ingredients found",
                value: "",
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Payment details
        DetailSection(
          title: "Payment Details",
          items: [
            DetailItem(
              icon: Icons.payment,
              label: "Payment Method",
              value: widget.order['paymentMethod'] ??
                  "Credit Card (XXXX-XXXX-XXXX-1234)",
            ),
            DetailItem(
              icon: Icons.monetization_on,
              label: "Amount",
              value: price,
            ),
            DetailItem(
              icon: Icons.receipt,
              label: "Invoice",
              value: "Download Invoice",
              isAction: true,
              action: () {
                // Download invoice action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Downloading invoice...")),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Support section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(offset: Offset(3, 3), color: Colors.black)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.support_agent, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  const Text(
                    "Need Help?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ActionButton(
                icon: Icons.chat,
                label: "Contact Support",
                onTap: () {
                  // Contact support action
                },
              ),
              const SizedBox(height: 8),
              ActionButton(
                icon: Icons.help,
                label: "FAQs",
                onTap: () {
                  // Open FAQs
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final String status = widget.order['status'] ?? 'Active';

    // Different action buttons based on order status
    Widget actionButton;

    switch (status) {
      case 'Active':
        actionButton = ActionButton(
          icon: Icons.pause_circle,
          label: "Pause Subscription",
          onTap: () {
            _showPauseDialog(context);
          },
          color: Colors.orange[600]!,
        );
        break;
      case 'Upcoming':
        actionButton = ActionButton(
          icon: Icons.edit,
          label: "Edit Subscription",
          onTap: () {
            // Navigate to edit screen
          },
          color: Colors.blue[600]!,
        );
        break;
      case 'Completed':
        actionButton = ActionButton(
          icon: Icons.replay,
          label: "Order Again",
          onTap: () {
            // Navigate to reorder screen
          },
          color: Colors.green[600]!,
        );
        break;
      case 'Paused':
        actionButton = ActionButton(
          icon: Icons.play_circle,
          label: "Resume Subscription",
          onTap: () {
            _resumeSubscription();
          },
          color: Colors.green[600]!,
        );
        break;
      default:
        actionButton = Container();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: actionButton,
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BrutalDecoration.brutalBox(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Order Details'),
              onTap: () {
                Navigator.pop(context);
                // Share action
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.support),
              title: const Text('Contact Support'),
              onTap: () {
                Navigator.pop(context);
                // Contact support action
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red[700]),
              title: Text('Cancel Order',
                  style: TextStyle(color: Colors.red[700])),
              onTap: () {
                Navigator.pop(context);
                _showCancelDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          title: const Text('Pause Subscription'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your subscription will be paused starting tomorrow until you decide to resume it.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                const Text('Reason for pausing (optional)'),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Tell us why you\'re pausing...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _pauseReason = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Pause Subscription'),
              onPressed: () {
                Navigator.pop(context);
                _pauseSubscription();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseOption(String duration, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _pauseSubscription();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
          color: Colors.orange[50],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(duration),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

// Update the _pauseSubscription method in OrderDetailsPage to handle end date extension:

  Future<void> _pauseSubscription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the user ID from the order
      final String userId = widget.order['userId'] ?? "10";
      final String orderId = widget.order['id'] ?? "";

      // Calculate next day (pause starts tomorrow)
      final DateTime now = DateTime.now();
      final DateTime pauseStartDate =
          DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

      // Call the subscription service to pause the subscription
      await _subscriptionService.pauseSubscriptionIndefinite(
        userId: userId,
        orderId: orderId,
        pauseStartDate: pauseStartDate,
        reason: _pauseReason,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription paused starting tomorrow'),
          backgroundColor: Colors.green,
        ),
      );

      // Create pause details for local state update
      final pauseDetails = {
        'pausedAt': Timestamp.fromDate(pauseStartDate),
        'reason': _pauseReason,
        'isPauseIndefinite': true,
      };

      // Update local state to show paused status immediately
      setState(() {
        // Create a new map to avoid modifying the original one
        final updatedOrder = Map<String, dynamic>.from(widget.order);

        // Store original end date if not already stored
        if (updatedOrder['originalEndDate'] == null) {
          updatedOrder['originalEndDate'] = updatedOrder['endDate'];
        }

        updatedOrder['status'] = 'Paused';
        updatedOrder['pauseDetails'] = pauseDetails;

        // Update the widget.order reference
        widget.order.addAll(updatedOrder);

        _isLoading = false;
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pause subscription: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

// Similarly update the _resumeSubscription method:

  Future<void> _resumeSubscription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the user ID from the order
      final String userId = widget.order['userId'] ?? "10";
      final String orderId = widget.order['id'] ?? "";

      // Call the subscription service to resume the subscription
      await _subscriptionService.resumeSubscription(
        userId: userId,
        orderId: orderId,
      );

      // Calculate new end date based on actual pause duration
      final pauseDetails =
          widget.order['pauseDetails'] as Map<String, dynamic>?;
      if (pauseDetails == null) {
        throw Exception('No pause details found');
      }

      final DateTime originalEndDate =
          widget.order['originalEndDate'] is Timestamp
              ? (widget.order['originalEndDate'] as Timestamp).toDate()
              : (widget.order['endDate'] is Timestamp
                  ? (widget.order['endDate'] as Timestamp).toDate()
                  : DateTime.now().add(const Duration(days: 30)));

      final DateTime pausedAt = pauseDetails['pausedAt'] is Timestamp
          ? (pauseDetails['pausedAt'] as Timestamp).toDate()
          : DateTime.now().subtract(const Duration(days: 1));

      final int pausedDays = DateTime.now().difference(pausedAt).inDays;
      final DateTime newEndDate =
          originalEndDate.add(Duration(days: pausedDays));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription resumed'),
          backgroundColor: Colors.green,
        ),
      );

      // Update local state to show active status immediately
      setState(() {
        // Create a new map to avoid modifying the original one
        final updatedOrder = Map<String, dynamic>.from(widget.order);

        // Create or update pause history
        List<Map<String, dynamic>> pauseHistory = [];
        if (updatedOrder['pauseHistory'] != null) {
          pauseHistory =
              List<Map<String, dynamic>>.from(updatedOrder['pauseHistory']);
        }

        pauseHistory.add({
          ...pauseDetails,
          'resumedAt': Timestamp.now(),
          'actualPauseDays': pausedDays,
        });

        updatedOrder['status'] = 'Active';
        updatedOrder['resumedAt'] = Timestamp.now();
        updatedOrder['endDate'] = Timestamp.fromDate(newEndDate);
        updatedOrder['pauseHistory'] = pauseHistory;

        // Remove active pause details
        updatedOrder.remove('pauseDetails');

        // Update the widget.order reference
        widget.order.addAll(updatedOrder);

        _isLoading = false;
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resume subscription: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

// Helper method to calculate resume date based on duration
  DateTime _calculateResumeDate(String pauseDuration) {
    final DateTime now = DateTime.now();

    switch (pauseDuration) {
      case '1 week':
        return now.add(const Duration(days: 7));
      case '2 weeks':
        return now.add(const Duration(days: 14));
      case '1 month':
        return now.add(const Duration(days: 30));
      case 'Until I resume':
        return DateTime(2099, 12, 31); // Far future date for indefinite pause
      default:
        return now.add(const Duration(days: 7)); // Default to 1 week
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: const Text('No, Keep Order'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[700],
            ),
            child: const Text('Yes, Cancel Order'),
            onPressed: () {
              Navigator.pop(context);
              _cancelSubscription();
            },
          ),
        ],
      ),
    );
  }

  // Method to handle cancelling a subscription
  Future<void> _cancelSubscription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the user ID from the order
      final String userId = widget.order['userId'] ?? "10";
      final String orderId = widget.order['id'] ?? "";

      // Update the order status to Cancelled in Firebase
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Find the order document
      final querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .where('id', isEqualTo: orderId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        // Update the order in user's orders collection
        await firestore
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(docId)
            .update({
          'status': 'Cancelled',
          'cancelledAt': Timestamp.now(),
        });

        // Also update the order in the general orders collection
        final generalOrderQuery = await firestore
            .collection('orders')
            .where('id', isEqualTo: orderId)
            .get();

        if (generalOrderQuery.docs.isNotEmpty) {
          await firestore
              .collection('orders')
              .doc(generalOrderQuery.docs.first.id)
              .update({
            'status': 'Cancelled',
            'cancelledAt': Timestamp.now(),
          });
        }
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to the previous screen
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Delegate for the tab bar in SliverPersistentHeader
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
