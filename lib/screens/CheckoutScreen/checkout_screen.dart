// lib/checkout/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';

import '../../utils/brutal_decoration.dart';
import 'components/checkout_progress.dart';
import 'components/product_confirmation.dart';
import 'components/select_days.dart';
import 'components/delivery_days.dart';
import 'components/start_date.dart';
import 'components/time_slots.dart';
import 'components/address_form.dart';
import 'components/payment_options.dart';
import 'components/bottom_nav.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> selectedProduct;
  final int selectedPlanIndex;

  const CheckoutScreen({
    super.key,
    required this.selectedProduct,
    required this.selectedPlanIndex,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Current step in the checkout process
  int _currentStep = 0;

  // Selected delivery days
  String _deliveryOption = 'weekdays';

  // Selected start date
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  // Selected time slot
  String _selectedSlot = 'morning';

  // Selected plan index
  late int _selectedPlanIndex;

  // Scroll controller for the stepper
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedPlanIndex = widget.selectedPlanIndex;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Get plan days
  int get _planDays =>
      widget.selectedProduct['plans'][_selectedPlanIndex]['days'];

  // Get plan price
  String get _planPrice =>
      widget.selectedProduct['plans'][_selectedPlanIndex]['price'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckoutProgress(currentStep: _currentStep),
            const SizedBox(height: 24),
            _buildCurrentStepContent(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentStep: _currentStep,
        onBack: _goToPreviousStep,
        onNext: _goToNextStep,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[100],
      elevation: 0,
      title: const Text(
        "CHECKOUT",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
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
    );
  }

  // Current step content
  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return ProductConfirmation(
          product: widget.selectedProduct,
          planIndex: _selectedPlanIndex,
        );
      case 1:
        return SelectDays(
          product: widget.selectedProduct,
          selectedPlanIndex: _selectedPlanIndex,
          onPlanChanged: (index) {
            setState(() {
              _selectedPlanIndex = index;
            });
          },
        );
      case 2:
        return DeliveryDays(
          initialDeliveryOption: _deliveryOption,
          onDeliveryOptionChanged: (option) {
            setState(() {
              _deliveryOption = option;
            });
          },
        );
      case 3:
        return StartDate(
          selectedDate: _selectedDate,
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        );
      case 4:
        return TimeSlots(
          selectedSlot: _selectedSlot,
          onSlotChanged: (slot) {
            setState(() {
              _selectedSlot = slot;
            });
          },
        );
      case 5:
        return const AddressForm();
      case 6:
        return PaymentOptions(
          planPrice: _planPrice,
        );
      default:
        return Container();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _scrollToTop();
    }
  }

  void _goToNextStep() {
    if (_currentStep < 6) {
      setState(() {
        _currentStep++;
      });
      _scrollToTop();
    } else {
      // Final step - process payment
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Processing payment..."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
