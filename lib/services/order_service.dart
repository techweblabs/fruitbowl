// lib/services/order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  // Hardcoded user ID - replace with your actual user ID mechanism
  final String _userId = "10";
  final String _userEmail =
      "user@example.com"; // Replace with actual email if needed

  // Calculate end date based on start date, total days, and delivery option
  DateTime calculateEndDate(
      DateTime startDate, int totalDays, String deliveryOption) {
    // Initialize counters
    int deliveryDaysFound = 0;

    // Start with the startDate itself
    DateTime currentDate = startDate;

    // Check if a day is a delivery day based on the delivery option
    bool isDeliveryDay(DateTime day) {
      int weekday = day.weekday; // 1-7 where 1 is Monday and 7 is Sunday

      switch (deliveryOption.toLowerCase()) {
        case 'weekdays':
          // Count Monday to Friday
          return weekday >= 1 && weekday <= 5;
        case 'weekends':
          // Count Saturday and Sunday
          return weekday == 6 || weekday == 7;
        case 'everyday':
          // Count all days
          return true;
        case 'custom':
          // Example for custom: Monday, Wednesday, Friday
          return weekday == 1 || weekday == 3 || weekday == 5;
        default:
          // Default to everyday if not recognized
          return true;
      }
    }

    // Count the start date if it's a delivery day
    if (isDeliveryDay(currentDate)) {
      deliveryDaysFound++;
    }

    // Keep adding days until we find enough delivery days
    while (deliveryDaysFound < totalDays) {
      // Move to the next day
      currentDate = currentDate.add(const Duration(days: 1));

      // Check if this day should be counted
      if (isDeliveryDay(currentDate)) {
        deliveryDaysFound++;
      }
    }

    // Return the last delivery day as the end date
    return currentDate;
  }

  // Convert Color objects to a format that can be stored in Firestore
  List<Map<String, dynamic>> _convertColorsForFirestore(List<dynamic> colors) {
    return colors.map((color) {
      if (color is Color) {
        return {
          'red': color.red,
          'green': color.green,
          'blue': color.blue,
          'alpha': color.alpha,
        };
      } else if (color is Map) {
        // If it's already a map, ensure it has the right format
        return {
          'red': color['red'] is double
              ? (color['red'] * 255).round()
              : color['red'],
          'green': color['green'] is double
              ? (color['green'] * 255).round()
              : color['green'],
          'blue': color['blue'] is double
              ? (color['blue'] * 255).round()
              : color['blue'],
          'alpha': color['alpha'] ?? 255,
        };
      }
      // Default fallback color (black)
      return {
        'red': 0,
        'green': 0,
        'blue': 0,
        'alpha': 255,
      };
    }).toList();
  }

  // Create and store a new order in Firebase
  Future<Map<String, dynamic>> submitOrder({
    required Map<String, dynamic> product,
    required int selectedPlanIndex,
    required String deliveryOption,
    required DateTime startDate,
    required String timeSlot,
    required Map<String, String> addressData,
    required String paymentMethod,
  }) async {
    try {
      // Get the selected plan details
      final selectedPlan = product['plans'][selectedPlanIndex];
      final int totalDays = selectedPlan['days'];
      final String price = selectedPlan['price'];

      // Calculate end date based on delivery preference
      final DateTime endDate =
          calculateEndDate(startDate, totalDays, deliveryOption);

      // Format time slot for display
      String formattedTimeSlot = '';
      switch (timeSlot) {
        case 'morning':
          formattedTimeSlot = '9 AM - 11 AM';
          break;
        case 'afternoon':
          formattedTimeSlot = '1 PM - 3 PM';
          break;
        case 'evening':
          formattedTimeSlot = '5 PM - 7 PM';
          break;
        case 'night':
          formattedTimeSlot = '9 PM - 11 PM';
          break;
        default:
          formattedTimeSlot = timeSlot;
      }

      // Generate a unique order ID
      final String orderId = 'ORD${uuid.v4().substring(0, 6).toUpperCase()}';

      // Make a copy of the product to avoid modifying the original
      final productCopy = Map<String, dynamic>.from(product);

      // Convert gradient colors to a Firestore-friendly format
      if (product['gradientColors'] != null) {
        productCopy['gradientColors'] =
            _convertColorsForFirestore(product['gradientColors']);
      }

      // Prepare the order data
      final orderData = {
        'id': orderId,
        'userId': _userId,
        'userEmail': _userEmail,
        'orderDate': Timestamp.now(),
        'productDetails': productCopy,
        'productName': product['name'],
        'price': price,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'imageUrl': product['backgroundImage'],
        'status': 'Active',
        'deliveryDays': deliveryOption,
        'deliveryTime': formattedTimeSlot,
        'totalDays': totalDays,
        'remainingDays': totalDays,
        'gradientColors': product['gradientColors'] != null
            ? _convertColorsForFirestore(product['gradientColors'])
            : [
                {'red': 0, 'green': 0, 'blue': 0, 'alpha': 255}
              ],
        'address': addressData,
        'paymentMethod': paymentMethod,
        'planIndex': selectedPlanIndex,
        'planSavings': selectedPlan['savings'],
      };

      // Add the order to Firestore
      final DocumentReference orderRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .add(orderData);

      // Also store in a general orders collection for admin access
      await _firestore.collection('orders').doc(orderRef.id).set({
        ...orderData,
        'firestoreId': orderRef.id,
      });

      // Return the created order data with the Firestore ID
      return {
        ...orderData,
        'firestoreId': orderRef.id,
      };
    } catch (e) {
      print('Error submitting order: $e');
      rethrow;
    }
  }

  // Get all orders for the current user
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'firestoreId': doc.id,
              })
          .toList();
    } catch (e) {
      print('Error getting user orders: $e');
      rethrow;
    }
  }

  // Get a specific order by ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .where('id', isEqualTo: orderId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return {
          ...querySnapshot.docs.first.data(),
          'firestoreId': querySnapshot.docs.first.id,
        };
      }

      return null;
    } catch (e) {
      print('Error getting order: $e');
      rethrow;
    }
  }

  // Update the status of an order
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      // Query to find the document with the matching orderId
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .where('id', isEqualTo: orderId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        // Update both collections
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('orders')
            .doc(docId)
            .update({'status': status});

        // Also update in the general orders collection
        final generalOrderQuery = await _firestore
            .collection('orders')
            .where('id', isEqualTo: orderId)
            .get();

        if (generalOrderQuery.docs.isNotEmpty) {
          await _firestore
              .collection('orders')
              .doc(generalOrderQuery.docs.first.id)
              .update({'status': status});
        }
      }
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  // Update the remaining days count for an order
  Future<void> updateRemainingDays(String orderId, int remainingDays) async {
    try {
      // Query to find the document with the matching orderId
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .where('id', isEqualTo: orderId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        // Update both collections
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('orders')
            .doc(docId)
            .update({'remainingDays': remainingDays});

        // Also update in the general orders collection
        final generalOrderQuery = await _firestore
            .collection('orders')
            .where('id', isEqualTo: orderId)
            .get();

        if (generalOrderQuery.docs.isNotEmpty) {
          await _firestore
              .collection('orders')
              .doc(generalOrderQuery.docs.first.id)
              .update({'remainingDays': remainingDays});
        }
      }
    } catch (e) {
      print('Error updating remaining days: $e');
      rethrow;
    }
  }
}
