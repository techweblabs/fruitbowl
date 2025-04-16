// Updated SubscriptionService with indefinite pause functionality starting next day

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // New method for indefinite pause starting next day
  Future<void> pauseSubscriptionIndefinite({
    required String userId,
    required String orderId,
    required DateTime pauseStartDate, // Pause start date (next day)
    required String reason,
  }) async {
    try {
      // Find the order document
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .where('id', isEqualTo: orderId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Order not found');
      }

      final docId = querySnapshot.docs.first.id;
      final orderData = querySnapshot.docs.first.data();

      // Store original end date if not already stored
      if (orderData['originalEndDate'] == null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(docId)
            .update({
          'originalEndDate': orderData['endDate'],
        });

        // Also update in general orders
        final generalOrderQuery = await _firestore
            .collection('orders')
            .where('id', isEqualTo: orderId)
            .get();

        if (generalOrderQuery.docs.isNotEmpty) {
          await _firestore
              .collection('orders')
              .doc(generalOrderQuery.docs.first.id)
              .update({
            'originalEndDate': orderData['endDate'],
          });
        }
      }

      // Create pause details object
      final pauseDetails = {
        'pausedAt':
            Timestamp.fromDate(pauseStartDate), // Use next day as pause start
        'reason': reason,
        'isPauseIndefinite': true,
      };

      // Update the order in user's orders collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(docId)
          .update({
        'status': 'Paused',
        'pauseDetails': pauseDetails,
      });

      // Also update the order in the general orders collection
      final generalOrderQuery = await _firestore
          .collection('orders')
          .where('id', isEqualTo: orderId)
          .get();

      if (generalOrderQuery.docs.isNotEmpty) {
        await _firestore
            .collection('orders')
            .doc(generalOrderQuery.docs.first.id)
            .update({
          'status': 'Paused',
          'pauseDetails': pauseDetails,
        });
      }

      // Log the pause action
      await _firestore.collection('subscription_actions').add({
        'userId': userId,
        'orderId': orderId,
        'action': 'pause',
        'timestamp': Timestamp.now(),
        'details': pauseDetails,
        'pauseStartDate': Timestamp.fromDate(pauseStartDate),
      });
    } catch (e) {
      print('Error pausing subscription: $e');
      rethrow;
    }
  }

  // Updated resume subscription method with automatic end date calculation
  Future<Map<String, dynamic>> resumeSubscription({
    required String userId,
    required String orderId,
  }) async {
    try {
      // Find the order document
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .where('id', isEqualTo: orderId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Order not found');
      }

      final docId = querySnapshot.docs.first.id;
      final orderData = querySnapshot.docs.first.data();

      // Get the pause details
      final pauseDetails = orderData['pauseDetails'] as Map<String, dynamic>?;
      if (pauseDetails == null) {
        throw Exception('No pause details found');
      }

      // Get original end date
      final DateTime originalEndDate = orderData['originalEndDate'] is Timestamp
          ? (orderData['originalEndDate'] as Timestamp).toDate()
          : (orderData['endDate'] is Timestamp
              ? (orderData['endDate'] as Timestamp).toDate()
              : DateTime.now().add(const Duration(days: 30)));

      // Get the pause start date
      final DateTime pausedAt = pauseDetails['pausedAt'] is Timestamp
          ? (pauseDetails['pausedAt'] as Timestamp).toDate()
          : DateTime.now().subtract(const Duration(days: 1));

      // Current date for resume
      final DateTime resumeDate = DateTime.now();

      // Get delivery days option
      final String deliveryDaysOption = orderData['deliveryDays'] ?? 'Everyday';

      // Calculate how many delivery days were missed during the pause
      final int missedDeliveryDays = _calculateMissedDeliveryDays(
          pausedAt, resumeDate, deliveryDaysOption);

      // Calculate new end date by extending the original end date
      final DateTime newEndDate = _extendEndDateByDeliveryDays(
          originalEndDate, missedDeliveryDays, deliveryDaysOption);

      // Store pause history
      List<Map<String, dynamic>> pauseHistory = [];
      if (orderData['pauseHistory'] != null) {
        pauseHistory =
            List<Map<String, dynamic>>.from(orderData['pauseHistory']);
      }

      pauseHistory.add({
        ...pauseDetails,
        'resumedAt': Timestamp.now(),
        'missedDeliveryDays': missedDeliveryDays,
      });

      // Update the order with resumed status
      final Map<String, dynamic> updateData = {
        'status': 'Active',
        'resumedAt': Timestamp.now(),
        'endDate': Timestamp.fromDate(newEndDate),
        'pauseHistory': pauseHistory,
      };

      // Remove active pause details
      updateData['pauseDetails'] = FieldValue.delete();

      // Update in user's orders collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(docId)
          .update(updateData);

      // Also update in general orders collection
      final generalOrderQuery = await _firestore
          .collection('orders')
          .where('id', isEqualTo: orderId)
          .get();

      if (generalOrderQuery.docs.isNotEmpty) {
        await _firestore
            .collection('orders')
            .doc(generalOrderQuery.docs.first.id)
            .update(updateData);
      }

      // Log the resume action
      await _firestore.collection('subscription_actions').add({
        'userId': userId,
        'orderId': orderId,
        'action': 'resume',
        'timestamp': Timestamp.now(),
        'missedDeliveryDays': missedDeliveryDays,
        'newEndDate': Timestamp.fromDate(newEndDate),
      });

      // Return the new end date and missed delivery days
      return {
        'newEndDate': newEndDate,
        'missedDeliveryDays': missedDeliveryDays,
      };
    } catch (e) {
      print('Error resuming subscription: $e');
      rethrow;
    }
  }

  // Calculate how many delivery days were missed between two dates
  int _calculateMissedDeliveryDays(
      DateTime pauseStartDate, DateTime resumeDate, String deliveryOption) {
    int missedDays = 0;

    // Function to check if a day is a delivery day
    bool isDeliveryDay(DateTime day) {
      switch (deliveryOption.toLowerCase()) {
        case 'weekdays':
          return day.weekday >= 1 && day.weekday <= 5;
        case 'weekends':
          return day.weekday == 6 || day.weekday == 7;
        case 'everyday':
          return true;
        case 'custom':
          // Example for custom: Monday, Wednesday, Friday
          return day.weekday == 1 || day.weekday == 3 || day.weekday == 5;
        default:
          return true; // Default to everyday
      }
    }

    // Start counting from the pause start date
    DateTime current = pauseStartDate;

    // Count all delivery days between pause start and resume date
    while (current.isBefore(resumeDate)) {
      if (isDeliveryDay(current)) {
        missedDays++;
      }
      current = current.add(const Duration(days: 1));
    }

    return missedDays;
  }

  // Extend an end date by a specific number of delivery days
  DateTime _extendEndDateByDeliveryDays(
      DateTime endDate, int deliveryDaysToAdd, String deliveryOption) {
    // Function to check if a day is a delivery day
    bool isDeliveryDay(DateTime day) {
      switch (deliveryOption.toLowerCase()) {
        case 'weekdays':
          return day.weekday >= 1 && day.weekday <= 5;
        case 'weekends':
          return day.weekday == 6 || day.weekday == 7;
        case 'everyday':
          return true;
        case 'custom':
          // Example for custom: Monday, Wednesday, Friday
          return day.weekday == 1 || day.weekday == 3 || day.weekday == 5;
        default:
          return true; // Default to everyday
      }
    }

    // Start from the day after end date
    DateTime newEndDate = endDate;
    int deliveryDaysAdded = 0;

    // Add exactly the number of missed delivery days
    while (deliveryDaysAdded < deliveryDaysToAdd) {
      // Move to the next day
      newEndDate = newEndDate.add(const Duration(days: 1));

      // Check if this is a delivery day
      if (isDeliveryDay(newEndDate)) {
        deliveryDaysAdded++;
      }
    }

    return newEndDate;
  }

  // Method to check if subscription needs to be auto-resumed
  // No longer needed as all pauses are indefinite

  // Method to calculate remaining days accounting for pauses
  Future<int> calculateRemainingDays(String orderId) async {
    try {
      final orderQuery = await _firestore
          .collection('orders')
          .where('id', isEqualTo: orderId)
          .get();

      if (orderQuery.docs.isEmpty) {
        throw Exception('Order not found');
      }

      final orderData = orderQuery.docs.first.data();

      // Get current status and end date
      final String status = orderData['status'] ?? 'Active';
      final DateTime endDate = orderData['endDate'] is Timestamp
          ? (orderData['endDate'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 30));

      // If the order is paused, remaining days stay the same
      if (status == 'Paused') {
        return orderData['remainingDays'] ?? 0;
      }

      // Get the delivery days option
      final String deliveryDaysOption = orderData['deliveryDays'] ?? 'Everyday';

      // Calculate remaining delivery days between today and end date
      final DateTime today = DateTime.now();
      int remainingDeliveryDays = 0;

      // Function to check if a day is a delivery day
      bool isDeliveryDay(DateTime day) {
        switch (deliveryDaysOption.toLowerCase()) {
          case 'weekdays':
            return day.weekday >= 1 && day.weekday <= 5;
          case 'weekends':
            return day.weekday == 6 || day.weekday == 7;
          case 'everyday':
            return true;
          case 'custom':
            // Example for custom: Monday, Wednesday, Friday
            return day.weekday == 1 || day.weekday == 3 || day.weekday == 5;
          default:
            return true; // Default to everyday
        }
      }

      // Start counting from today (if today is a delivery day) or the next day
      DateTime current = today;

      // Count delivery days until end date
      while (current.isBefore(endDate) || isSameDay(current, endDate)) {
        if (isDeliveryDay(current)) {
          remainingDeliveryDays++;
        }
        current = current.add(const Duration(days: 1));
      }

      // Ensure we don't return negative values
      return remainingDeliveryDays > 0 ? remainingDeliveryDays : 0;
    } catch (e) {
      print('Error calculating remaining days: $e');
      return 0;
    }
  }

  // Helper to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date1.day;
  }
}
