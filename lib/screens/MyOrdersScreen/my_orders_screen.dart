// lib/orders/orders_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/MyOrdersScreen/order_calendar_view.dart';
import 'package:flutter_starter_kit/screens/home/home_screen.dart';
import 'package:flutter_starter_kit/services/order_service.dart'; // Import the order service
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/brutal_decoration.dart';
import 'components/order_card.dart';
import 'components/order_filter.dart';
import 'order_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _activeFilter = 'All';
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders from Firebase
  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderData = await _orderService.getUserOrders();

      setState(() {
        _orders = orderData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load orders: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_activeFilter == 'All') {
      return _orders;
    }
    return _orders.where((order) => order['status'] == _activeFilter).toList();
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
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _fetchOrders,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BrutalDecoration.brutalBox(),
            child: IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.black),
              onPressed: () {
                Twl.navigateToScreenAnimated(
                    OrderCalendarView(
                      orders: _filteredOrders,
                    ),
                    context: context);
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
            child: _isLoading
                ? _buildLoadingState()
                : _filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Loading your orders..."),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final orderData = _filteredOrders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OrderCard(
              order: orderData,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(order: orderData),
                  ),
                ).then((_) =>
                    _fetchOrders()); // Refresh after returning from details
              },
            ),
          );
        },
      ),
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
                Twl.navigateToScreenClearStack(const HomeScreen(
                  initialIndex: 1, // Assuming 1 is the products tab
                ));
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
