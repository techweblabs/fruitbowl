// lib/orders/order_details_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';

import '../../utils/brutal_decoration.dart';
import 'models/order.dart';
import 'components/delivery_calendar.dart';
import 'components/action_button.dart';
import 'components/detail_section.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: NestedScrollView(
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
                  child: const Icon(Icons.arrow_back, color: Colors.black),
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
                    icon: const Icon(Icons.more_vert, color: Colors.black),
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
              DeliveryCalendar(order: widget.order),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.order.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.order.gradientColors[0].withOpacity(0.6),
              widget.order.gradientColors[2].withOpacity(0.9),
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
                widget.order.productName,
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
                  color: widget.order.statusColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(offset: Offset(1, 1), color: Colors.black),
                  ],
                ),
                child: Text(
                  widget.order.status,
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
              Text(widget.order.id),
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
              Text(widget.order.formatDate(widget.order.orderDate)),
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
                widget.order.price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          // Progress bar for active orders
          if (widget.order.status == 'Active') ...[
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
                  "${(widget.order.progressPercentage * 100).toInt()}% (${widget.order.remainingDays} days left)",
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
                widthFactor: widget.order.progressPercentage,
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
              value: widget.order.durationText,
            ),
            DetailItem(
              icon: Icons.schedule,
              label: "Delivery Schedule",
              value: widget.order.deliveryScheduleText,
            ),
            DetailItem(
              icon: Icons.location_on,
              label: "Delivery Address",
              value: "123 Main St, Apt 4B, New York, NY 10001",
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
              value: widget.order.productName,
            ),
            DetailItem(
              icon: Icons.inventory_2,
              label: "Contents",
              value: "Fruits, Berries, Yogurt, and more",
            ),
            DetailItem(
              icon: Icons.local_fire_department,
              label: "Nutritional Info",
              value: "320 kcal, 12g protein, 45g carbs",
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
              value: "Credit Card (XXXX-XXXX-XXXX-1234)",
            ),
            DetailItem(
              icon: Icons.monetization_on,
              label: "Amount",
              value: widget.order.price,
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
    // Different action buttons based on order status
    Widget actionButton;

    switch (widget.order.status) {
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
            // Resume action
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        title: const Text('Pause Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How long would you like to pause?'),
            const SizedBox(height: 16),
            _buildPauseOption('1 week'),
            const SizedBox(height: 8),
            _buildPauseOption('2 weeks'),
            const SizedBox(height: 8),
            _buildPauseOption('1 month'),
            const SizedBox(height: 8),
            _buildPauseOption('Until I resume'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOption(String duration) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription paused for $duration')),
        );
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
              Navigator.pop(context); // Return to orders page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order canceled successfully')),
              );
            },
          ),
        ],
      ),
    );
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
