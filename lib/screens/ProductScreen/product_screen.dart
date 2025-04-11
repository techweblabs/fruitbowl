import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/providers/firestore_api_provider.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../CheckoutScreen/checkout_screen.dart';

class ProductScreen extends StatefulWidget {
  final int initialPage;

  const ProductScreen({super.key, this.initialPage = 0});

  @override
  State<ProductScreen> createState() => _HorizontalProductScreenState();
}

class _HorizontalProductScreenState extends State<ProductScreen> {
  // Declare _pageController as late so it can be initialized in initState
  late final PageController _pageController;

  bool _showSwipeHint = true;
  int _currentPage = 0;
  int _selectedPlanIndex = 0;
  bool _isLoading = true; // Added loading flag
  // Sample product data remains unchanged.
  List<Map<String, dynamic>> _products = [];

  initializeData() async {
    var pro = Provider.of<FirestoreApiProvider>(context, listen: false);
    setState(() {
      if (pro.products != null || pro.products != '') {
        _products = pro.products;
      }
    });
    setState(() {
      _isLoading = false;
    });
    // await fetchFruitBowls();
    // Update the loading flag once data is ready
  }

  @override
  void initState() {
    super.initState();
    // Initialize PageController using the widget's initialPage
    _pageController = PageController(
      viewportFraction: 1.0,
      initialPage: widget.initialPage,
    );
    // Set the current page to match the initialPage provided in the constructor.
    _currentPage = widget.initialPage;

    initializeData();

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
    // Show a loading indicator until Firestore data is loaded.
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _products.length,
            itemBuilder: (context, index) {
              return _buildProductPage(_products[index]);
            },
          ),
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
                    style: const TextStyle(fontSize: 16, color: Colors.white),
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
                        const Shadow(
                          offset: Offset(1.5, 1.5),
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
                        const Shadow(
                          offset: Offset(1.5, 1.5),
                          blurRadius: 0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Ingredients List with Header Integrated
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _brutalDecoration(),
                    child: Column(
                      children: [
                        _tableHeader(),
                        const Divider(
                          color: Colors.black,
                          thickness: 1,
                        ),
                        ...product['ingredients']
                            .map<Widget>((ingredient) => _foodRow(
                                ingredient['name'],
                                ingredient['qty'],
                                ingredient['protein'],
                                ingredient['calories']))
                            .toList(),
                      ],
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
        if (_showSwipeHint)
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: _brutalDecoration().copyWith(
                  color: Colors.yellow[50],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.swipe, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Swipe to see more products",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showSwipeHint = false;
                        });
                      },
                      child: const Icon(Icons.close, size: 20),
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

  // Header for the Ingredients table
  Widget _tableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Ingredients',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Qty',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Protein',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Calories',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Updated Food Row with aligned columns
  Widget _foodRow(String food, String qty, String protein, String calories) {
    const textStyle = TextStyle(
      shadows: [
        Shadow(
          offset: Offset(0.5, 0.5),
          blurRadius: 0,
          color: Color(0x66000000),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              food,
              style: textStyle.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              qty,
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              protein,
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              calories,
              style: textStyle,
              textAlign: TextAlign.center,
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




 // int _customSizeOrder(String sizeName) {
  //   final lowerName = sizeName.toLowerCase();
  //   if (lowerName.contains('large')) return 0;
  //   if (lowerName.contains('medium')) return 1;
  //   if (lowerName.contains('small')) return 2;
  //   return 99;
  // }

  // Future<void> fetchFruitBowls() async {
  //   if (_bmiString.isEmpty) {
  //     print("BMI string is empty, skipping Firestore query");
  //     return;
  //   }

  //   print("Using BMI: $_bmiString");
  //   final sizesSnapshot = await FirebaseFirestore.instance
  //       .collection('fruitBowls')
  //       .doc(_bmiString)
  //       .collection('sizes')
  //       .get();

  //   for (final sizeDoc in sizesSnapshot.docs) {
  //     final sizeData = sizeDoc.data() as Map<String, dynamic>;
  //     final sizeName = sizeDoc.id.toLowerCase();

  //     final dailyPrice = (sizeData['dailyPrice'] is num)
  //         ? (sizeData['dailyPrice'] as num).toDouble()
  //         : double.tryParse(sizeData['dailyPrice']?.toString() ?? '0') ?? 0.0;
  //     final weight = (sizeData['weight'] is num)
  //         ? (sizeData['weight'] as num).toDouble()
  //         : double.tryParse(sizeData['weight']?.toString() ?? '0') ?? 0.0;

  //     final discountMap = (sizeData['discount'] as Map<dynamic, dynamic>?)
  //             ?.map<String, int>(
  //           (key, value) =>
  //               MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0),
  //         ) ??
  //         <String, int>{};

  //     final itemsSnapshot = await sizeDoc.reference.collection('items').get();
  //     int totalCalories = 0;
  //     List<Map<String, dynamic>> ingredients = [];

  //     for (final itemDoc in itemsSnapshot.docs) {
  //       final itemData = itemDoc.data();
  //       final itemCalories = (itemData['calories'] is num)
  //           ? (itemData['calories'] as num).toInt()
  //           : int.tryParse(itemData['calories']?.toString() ?? '0') ?? 0;
  //       totalCalories += itemCalories;

  //       final ingredientName = itemData['name']?.toString() ?? "Unknown";
  //       final ingredientQty =
  //           itemData['qty'] != null ? "${itemData['qty'].toString()}g" : "0g";
  //       final ingredientProtein = itemData['protein'] != null
  //           ? "${itemData['protein'].toString()}g"
  //           : "0g";
  //       final ingredientcalories = itemData['calories'] != null
  //           ? "${itemData['calories'].toString()} kcal"
  //           : "0 kcal";

  //       ingredients.add({
  //         'name': ingredientName,
  //         'qty': ingredientQty,
  //         'protein': ingredientProtein,
  //         'calories': ingredientcalories
  //       });
  //     }

  //     setState(() {
  //       for (var product in _products) {
  //         if (product['description'] != null &&
  //             product['description']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(sizeName)) {
  //           product['calories'] = '$totalCalories kcal';
  //           product['price'] = '₹${dailyPrice.round()}';
  //           product['weight'] = '${weight.round()}g';
  //           product['name'] = '$sizeName Bowl';
  //           print("size name >>>$sizeName");
  //           product['ingredients'] = ingredients;

  //           List<Map<String, dynamic>> newPlans = [];
  //           discountMap.forEach((daysStr, discountPercent) {
  //             int days = int.tryParse(daysStr) ?? 0;
  //             if (days > 0 && discountPercent > 0) {
  //               double total = dailyPrice * days;
  //               double discountedPrice = total * (1 - discountPercent / 100);
  //               newPlans.add({
  //                 'days': days,
  //                 'price': '₹${discountedPrice.round()}',
  //                 'savings': '$discountPercent%',
  //               });
  //             }
  //           });
  //           newPlans.sort((a, b) => a['days'].compareTo(b['days']));
  //           if (newPlans.isNotEmpty) {
  //             product['plans'] = newPlans;
  //           }
  //           product['description'] = sizeData['description']?.toString() ?? '';
  //           break;
  //         }
  //       }
  //     });
  //   }
  //   setState(() {
  //     _products.sort((a, b) {
  //       return _customSizeOrder(a['name'])
  //           .compareTo(_customSizeOrder(b['name']));
  //     });
  //   });
  // }
