import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../CheckoutScreen/checkout_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _HorizontalProductScreenState();
}

class _HorizontalProductScreenState extends State<ProductScreen> {
  // Page controller for the horizontal PageView
  final PageController _pageController = PageController(
    viewportFraction: 1.0, // Full width pages
    initialPage: 0,
  );

  // Current page indicator
  int _currentPage = 0;

  // Selected plan index (default: 1 - the middle plan)
  int _selectedPlanIndex = 1;

  // Sample product data
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Healthy Fruit Bowl',
      'description': 'Medium Bowl • 400g',
      'price': '₹89',
      'plans': [
        {'days': 7, 'price': '₹623', 'savings': '0%'},
        {'days': 15, 'price': '₹1,246', 'savings': '7%'},
        {'days': 30, 'price': '₹2,314', 'savings': '13%'},
      ],
      'backgroundImage': 'assets/images/fruits.png',
      'calories': '320 kcal',
      'weight': '400g',
      'ingredients': [
        {'name': '🍍 Pineapple', 'qty': '120g'},
        {'name': '🫐 Blueberries', 'qty': '60g'},
        {'name': '🥝 Kiwi', 'qty': '50g'},
        {'name': '🍓 Raspberries', 'qty': '70g'},
        {'name': '🍈 Papaya Cubes', 'qty': '100g'},
      ],
      'benefits': [
        'Low in calories, high in fiber',
        'Boosts metabolism',
        'Keeps you full longer',
        'Packed with antioxidants',
        'No added sugar or preservatives',
      ],
      'gradientColors': [
        Color(0xFF8ECAE6),
        Color(0xFF219EBC),
        Color(0xFF023047),
      ],
    },
    {
      'name': 'Energy Protein Bowl',
      'description': 'Large Bowl • 450g',
      'price': '₹119',
      'plans': [
        {'days': 7, 'price': '₹833', 'savings': '0%'},
        {'days': 15, 'price': '₹1,666', 'savings': '7%'},
        {'days': 30, 'price': '₹3,094', 'savings': '13%'},
      ],
      'backgroundImage': 'assets/images/protein.png',
      'calories': '450 kcal',
      'weight': '450g',
      'ingredients': [
        {'name': '🥜 Mixed Nuts', 'qty': '100g'},
        {'name': '🥣 Greek Yogurt', 'qty': '150g'},
        {'name': '🍌 Banana', 'qty': '80g'},
        {'name': '🍯 Honey', 'qty': '20g'},
        {'name': '🫐 Berries', 'qty': '100g'},
      ],
      'benefits': [
        'High protein content',
        'Sustained energy release',
        'Muscle recovery support',
        'Rich in healthy fats',
        'Natural sweetness',
      ],
      'gradientColors': [
        Color(0xFFF4A261),
        Color(0xFFE76F51),
        Color(0xFF264653),
      ],
    },
    {
      'name': 'Detox Green Bowl',
      'description': 'Small Bowl • 350g',
      'price': '₹99',
      'plans': [
        {'days': 7, 'price': '₹693', 'savings': '0%'},
        {'days': 15, 'price': '₹1,386', 'savings': '7%'},
        {'days': 30, 'price': '₹2,574', 'savings': '13%'},
      ],
      'backgroundImage': 'assets/images/greens.png',
      'calories': '210 kcal',
      'weight': '350g',
      'ingredients': [
        {'name': '🥬 Kale', 'qty': '80g'},
        {'name': '🥒 Cucumber', 'qty': '70g'},
        {'name': '🍏 Green Apple', 'qty': '100g'},
        {'name': '🥑 Avocado', 'qty': '50g'},
        {'name': '🍋 Lemon Juice', 'qty': '15ml'},
      ],
      'benefits': [
        'Detoxifies the body',
        'Improves digestion',
        'Rich in vitamins and minerals',
        'Hydrating ingredients',
        'Supports immune system',
      ],
      'gradientColors': [
        Color(0xFF2A9D8F),
        Color(0xFF43AA8B),
        Color(0xFF264653),
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view for horizontal scrolling
          PageView.builder(
            controller: _pageController,
            itemCount: _products.length,
            itemBuilder: (context, index) {
              return _buildProductPage(_products[index]);
            },
          ),

          // Page indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _products.length,
                (index) => _buildPageIndicator(index == _currentPage),
              ),
            ),
          ),
        ],
      ),

      // Fixed Subscription Button at bottom
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: _brutalDecoration(),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[600],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 18),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutScreen(
                  selectedProduct: _products[_currentPage],
                  selectedPlanIndex: _selectedPlanIndex,
                ),
              ),
            );
          },
          child: Text(
            "Subscribe Now - ${_products[_currentPage]['plans'][_selectedPlanIndex]['days']} Days for ${_products[_currentPage]['plans'][_selectedPlanIndex]['price']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Build a single product page
  Widget _buildProductPage(Map<String, dynamic> product) {
    return Stack(
      children: [
        // Full Screen Background Image
        Positioned.fill(
          child: Image.asset(
            product['backgroundImage'],
            fit: BoxFit.cover,
          ),
        ),

        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  product['gradientColors'][0].withOpacity(0.85),
                  product['gradientColors'][1].withOpacity(0.95),
                  product['gradientColors'][2].withOpacity(0.9)
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Diagonal Price Tag
        Positioned(
          top: 60,
          right: 20,
          child: Transform.rotate(
            angle: -0.4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.yellow[600],
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(offset: Offset(8, 8), color: Colors.black)
                ],
              ),
              child: Text(
                "${product['price']} / day",
                style: GoogleFonts.bangers(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),

        // Main Content
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 24),
                  child: _brutalIcon(Icons.arrow_back),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: _brutalDecoration().copyWith(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue[50]!,
                          Colors.blueGrey[50]!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Text(
                      product['name'],
                      style: GoogleFonts.bangers(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    product['description'],
                    style: TextStyle(fontSize: 16, color: Colors.grey[900]),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _brutalStatBoxWithIcon(
                        context,
                        icon: Icons.local_fire_department,
                        title: "Calories",
                        value: product['calories'],
                        gradient: [Colors.orange[100]!, Colors.orange[50]!],
                      ),
                      _brutalStatBoxWithIcon(
                        context,
                        icon: Icons.monitor_weight,
                        title: "Weight",
                        value: product['weight'],
                        gradient: [Colors.green[100]!, Colors.green[50]!],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Choose Your Plan",
                    style: GoogleFonts.bangers(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          offset: const Offset(1.5, 1.5),
                          blurRadius: 0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildPricingOptions(product),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "What's inside?",
                    style: GoogleFonts.bangers(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          offset: const Offset(1.5, 1.5),
                          blurRadius: 0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _brutalDecoration(),
                    child: Column(
                      children: product['ingredients']
                          .map<Widget>((ingredient) =>
                              _fruitRow(ingredient['name'], ingredient['qty']))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _brutalDescriptionCard(product),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),

        // Swipe Instructions
        Positioned(
          bottom: 90,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: _brutalDecoration().copyWith(
                color: Colors.yellow[50],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.swipe, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Swipe to see more products",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Page indicator dots
  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 12.0,
      width: 12.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey,
        border: Border.all(color: Colors.black, width: 1),
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [const BoxShadow(offset: Offset(1, 1), color: Colors.black)]
            : null,
      ),
    );
  }

  // Brutalist Icon
  Widget _brutalIcon(IconData icon) {
    return GestureDetector(
      onTap: () {
        Twl.navigateBack();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: _brutalDecoration(),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }

  // Stat Box
  Widget _brutalStatBoxWithIcon(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // Fruit Row
  Widget _fruitRow(String fruit, String qty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            fruit,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(0.5, 0.5),
                  blurRadius: 0,
                  color: Color(0x66000000),
                ),
              ],
            ),
          ),
          Text(
            qty,
            style: const TextStyle(
              shadows: [
                Shadow(
                  offset: Offset(0.5, 0.5),
                  blurRadius: 0,
                  color: Color(0x66000000),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Decoration
  BoxDecoration _brutalDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
    );
  }

  // Pricing Options
  Widget _buildPricingOptions(Map<String, dynamic> product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        product['plans'].length,
        (index) => _buildPlanCard(
            product['plans'][index], index == _selectedPlanIndex, index),
      ),
    );
  }

  // Individual Plan Card
  Widget _buildPlanCard(
      Map<String, dynamic> plan, bool isSelected, int planIndex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = planIndex;
        });
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 56) /
            3, // Accounting for padding and gap
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow[50] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[400]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? const [BoxShadow(offset: Offset(4, 4), color: Colors.black)]
              : const [BoxShadow(offset: Offset(2, 2), color: Colors.black26)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Selection indicator
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected ? Colors.black : Colors.transparent,
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            Text(
              "${plan['days']} Days",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSelected ? 16 : 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan['price'],
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: isSelected ? 18 : 16,
                color: isSelected ? Colors.black : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: plan['savings'] != '0%'
                    ? Colors.green[100]
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                plan['savings'] != '0%' ? "Save ${plan['savings']}" : "",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Description
  Widget _brutalDescriptionCard(Map<String, dynamic> product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _brutalDecoration().copyWith(
        gradient: LinearGradient(
          colors: [
            Colors.purple[50]!,
            Colors.blueGrey[50]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Why this bowl?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 0,
                  color: Color(0x88000000),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Designed specifically for individuals with a high BMI (Obese category), this bowl serves as a healthy and satisfying breakfast option.",
            style: TextStyle(
              fontSize: 14,
              shadows: [
                Shadow(
                  offset: Offset(0.5, 0.5),
                  blurRadius: 0,
                  color: Color(0x66000000),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text("✨ Key Benefits:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 0,
                    color: Color(0x88000000),
                  ),
                ],
              )),
          const SizedBox(height: 6),
          // Benefits list
          ...product['benefits']
              .map((benefit) => Text(
                    "• $benefit",
                    style: const TextStyle(
                      shadows: [
                        Shadow(
                          offset: Offset(0.5, 0.5),
                          blurRadius: 0,
                          color: Color(0x66000000),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
