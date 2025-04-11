// lib/orders/orders_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/home/home_screen.dart';
import 'package:flutter_starter_kit/screens/home/tabs/home_tab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';

import '../../utils/brutal_decoration.dart';
import 'components/order_card.dart';
import 'components/order_filter.dart';
import 'order_details_page.dart';
import 'models/order.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _activeFilter = 'All';

  // Sample orders data
  final List<Order> _orders = [
    Order(
      id: 'ORD123456',
      productName: 'Healthy Fruit Bowl',
      price: '₹2,314',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 31)),
      imageUrl: 'assets/images/fruits.png',
      status: 'Active',
      deliveryDays: 'Weekdays',
      deliveryTime: '6 AM - 9 AM',
      totalDays: 30,
      remainingDays: 30,
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      gradientColors: [
        const Color(0xFF8ECAE6),
        const Color(0xFF219EBC),
        const Color(0xFF023047),
      ],
    ),
    Order(
      id: 'ORD123457',
      productName: 'Energy Protein Bowl',
      price: '₹3,094',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 32)),
      imageUrl: 'assets/images/fruits.png',
      status: 'Upcoming',
      deliveryDays: 'Weekends',
      deliveryTime: '12 PM - 3 PM',
      totalDays: 30,
      remainingDays: 30,
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      gradientColors: [
        const Color(0xFFF4A261),
        const Color(0xFFE76F51),
        const Color(0xFF264653),
      ],
    ),
    Order(
      id: 'ORD123458',
      productName: 'Detox Green Bowl',
      price: '₹693',
      startDate: DateTime.now().subtract(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      imageUrl: 'assets/images/fruits.png',
      status: 'Active',
      deliveryDays: 'Custom',
      deliveryTime: '5 PM - 8 PM',
      totalDays: 7,
      remainingDays: 4,
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      gradientColors: [
        const Color(0xFF2A9D8F),
        const Color(0xFF43AA8B),
        const Color(0xFF264653),
      ],
    ),
    Order(
      id: 'ORD123459',
      productName: 'Healthy Fruit Bowl',
      price: '₹1,246',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: 'assets/images/comic_fruits.png',
      status: 'Completed',
      deliveryDays: 'Everyday',
      deliveryTime: '9 PM - 11 PM',
      totalDays: 15,
      remainingDays: 0,
      orderDate: DateTime.now().subtract(const Duration(days: 12)),
      gradientColors: [
        const Color(0xFF8ECAE6),
        const Color(0xFF219EBC),
        const Color(0xFF023047),
      ],
    ),
  ];

  List<Order> get _filteredOrders {
    if (_activeFilter == 'All') {
      return _orders;
    }
    return _orders.where((order) => order.status == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Twl.navigateToScreenClearStack(const HomeScreen(
              initialIndex: 0,
            ));
          },
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
        title: Text(
          "MY ORDERS",
          style: GoogleFonts.bangers(
            fontSize: 28,
            color: Colors.black,
            letterSpacing: 2,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BrutalDecoration.brutalBox(),
            child: IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.black),
              onPressed: () {
                // Navigate to calendar view
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          OrderFilter(
            activeFilter: _activeFilter,
            onFilterChanged: (filter) {
              setState(() {
                _activeFilter = filter;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredOrders.isEmpty
                ? _buildEmptyState()
                : _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: OrderCard(
            order: order,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsPage(order: order),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BrutalDecoration.brutalBox(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              "No orders found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You don't have any ${_activeFilter.toLowerCase()} orders yet",
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                elevation: 4,
              ),
              onPressed: () {
                // Navigate to product page
              },
              child: const Text(
                "Browse Products",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
