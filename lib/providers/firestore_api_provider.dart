import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fruit_bowl_item.dart';

class FirestoreApiProvider extends ChangeNotifier {
  // Sample product data remains unchanged.

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Large Bowl',
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
        {
          'name': '🍍 Pineapple',
          'qty': '120g',
          'protein': "0g",
          'calories': '0 kcal'
        },
        {
          'name': '🫐 Blueberries',
          'qty': '60g',
          'protein': "0g",
          'calories': '0 kcal'
        },
        {
          'name': '🥝 Kiwi',
          'qty': '50g',
          'protein': "0g",
          'calories': '0 kcal'
        },
        {
          'name': '🍓 Raspberries',
          'qty': '70g',
          'protein': "0g",
          'calories': '0 kcal'
        },
        {
          'name': '🍈 Papaya Cubes',
          'qty': '100g',
          'protein': "0g",
          'calories': '0 kcal'
        },
      ],
      'benefits': [
        'Low in calories, high in fiber',
        'Boosts metabolism',
        'Keeps you full longer',
        'Packed with antioxidants',
        'No added sugar or preservatives',
      ],
      'gradientColors': [
        const Color(0xFF8ECAE6),
        const Color(0xFF219EBC),
        const Color(0xFF023047),
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
      'backgroundImage': 'assets/images/fruits.png',
      'calories': '450 kcal',
      'weight': '450g',
      'ingredients': [
        {
          'name': '🥜 Mixed Nuts',
          'qty': '100g',
          'protein': "0g",
          'calories': '0 kcal'
        },
        {
          'name': '🥣 Greek Yogurt',
          'qty': '150g',
          'protein': "0g",
          'calories': '0 kcal'
        },
        {
          'name': '🍌 Banana',
          'qty': '80g',
          'protein': "0g",
          'calories': '0 kcal'
        },
        {
          'name': '🍯 Honey',
          'qty': '20g',
          'protein': "0g",
          'calories': '0 kcal'
        },
        {
          'name': '🫐 Berries',
          'qty': '100g',
          'protein': "0g",
          'calories': '0 kcal'
        },
      ],
      'benefits': [
        'High protein content',
        'Sustained energy release',
        'Muscle recovery support',
        'Rich in healthy fats',
        'Natural sweetness',
      ],
      'gradientColors': [
        const Color(0xFFF4A261),
        const Color(0xFFE76F51),
        const Color(0xFF264653),
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
      'backgroundImage': 'assets/images/fruits.png',
      'calories': '210 kcal',
      'weight': '350g',
      'ingredients': [
        {
          'name': '🥬 Kale',
          'qty': '80g',
          'protein': "0g",
          'calories': '0 kcal'
        },
        {
          'name': '🥒 Cucumber',
          'qty': '70g',
          'protein': "0g",
          'calories': '0 kcal'
        },
        {
          'name': '🍏 Green Apple',
          'qty': '100g',
          'protein': "0g",
          'calories': '0 kcal'
        },
        {
          'name': '🥑 Avocado',
          'qty': '50g',
          'protein': "0g",
          'calories': '0 kcal'
        },
        {
          'name': '🍋 Lemon Juice',
          'qty': '15ml',
          'protein': "0g",
          'calories': '0 kcal'
        },
      ],
      'benefits': [
        'Detoxifies the body',
        'Improves digestion',
        'Rich in vitamins and minerals',
        'Hydrating ingredients',
        'Supports immune system',
      ],
      'gradientColors': [
        const Color(0xFF2A9D8F),
        const Color(0xFF43AA8B),
        const Color(0xFF264653),
      ],
    },
  ];

  get products => _products;

  int _customSizeOrder(String sizeName) {
    final lowerName = sizeName.toLowerCase();
    if (lowerName.contains('large')) return 0;
    if (lowerName.contains('medium')) return 1;
    if (lowerName.contains('small')) return 2;
    return 99;
  }

  Future<void> fetchFruitBowls() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String bmiString = prefs.getString('BMIStr') ?? "normal";
    if (bmiString.isEmpty) {
      print("BMI string is empty, skipping Firestore query");
      return;
    }

    print("Using BMI: $bmiString");
    final sizesSnapshot = await FirebaseFirestore.instance
        .collection('fruitBowls')
        .doc(bmiString)
        .collection('sizes')
        .get();

    for (final sizeDoc in sizesSnapshot.docs) {
      final sizeData = sizeDoc.data() as Map<String, dynamic>;
      final sizeName = sizeDoc.id.toLowerCase();

      final dailyPrice = (sizeData['dailyPrice'] is num)
          ? (sizeData['dailyPrice'] as num).toDouble()
          : double.tryParse(sizeData['dailyPrice']?.toString() ?? '0') ?? 0.0;
      final weight = (sizeData['weight'] is num)
          ? (sizeData['weight'] as num).toDouble()
          : double.tryParse(sizeData['weight']?.toString() ?? '0') ?? 0.0;

      final discountMap = (sizeData['discount'] as Map<dynamic, dynamic>?)
              ?.map<String, int>(
            (key, value) =>
                MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0),
          ) ??
          <String, int>{};

      final itemsSnapshot = await sizeDoc.reference.collection('items').get();
      int totalCalories = 0;
      List<Map<String, dynamic>> ingredients = [];

      for (final itemDoc in itemsSnapshot.docs) {
        final itemData = itemDoc.data();
        final itemCalories = (itemData['calories'] is num)
            ? (itemData['calories'] as num).toInt()
            : int.tryParse(itemData['calories']?.toString() ?? '0') ?? 0;
        totalCalories += itemCalories;

        final ingredientName = itemData['name']?.toString() ?? "Unknown";
        final ingredientQty =
            itemData['qty'] != null ? "${itemData['qty'].toString()}g" : "0g";
        final ingredientProtein = itemData['protein'] != null
            ? "${itemData['protein'].toString()}g"
            : "0g";
        final ingredientcalories = itemData['calories'] != null
            ? "${itemData['calories'].toString()} kcal"
            : "0 kcal";

        ingredients.add({
          'name': ingredientName,
          'qty': ingredientQty,
          'protein': ingredientProtein,
          'calories': ingredientcalories
        });
      }
      // setState(() {
      for (var product in _products) {
        if (product['description'] != null &&
            product['description']
                .toString()
                .toLowerCase()
                .contains(sizeName)) {
          product['calories'] = '$totalCalories kcal';
          product['price'] = '₹${dailyPrice.round()}';
          product['weight'] = '${weight.round()}g';
          product['name'] = '$sizeName Bowl';
          print("size name >>>$sizeName");
          product['ingredients'] = ingredients;

          List<Map<String, dynamic>> newPlans = [];
          discountMap.forEach((daysStr, discountPercent) {
            int days = int.tryParse(daysStr) ?? 0;
            if (days > 0 && discountPercent > 0) {
              double total = dailyPrice * days;
              double discountedPrice = total * (1 - discountPercent / 100);
              newPlans.add({
                'days': days,
                'price': '₹${discountedPrice.round()}',
                'savings': '$discountPercent%',
              });
            }
          });
          newPlans.sort((a, b) => a['days'].compareTo(b['days']));
          if (newPlans.isNotEmpty) {
            product['plans'] = newPlans;
          }
          product['description'] = sizeData['description']?.toString() ?? '';
          break;
        }
      }
      // });
    }
    // setState(() {
    _products.sort((a, b) {
      return _customSizeOrder(a['name']).compareTo(_customSizeOrder(b['name']));
    });
    notifyListeners();
  }

  List<FruitBowlItem> _bowls = [];

  get bowls => _bowls;

  Future<List<FruitBowlItem>> fetchrecommededfruitbowls() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String bmiString = prefs.getString('BMIStr') ?? "normal";

    _bowls = [];

    // Ensure _bmiString is valid before performing the query.
    QuerySnapshot sizesSnapshot = await FirebaseFirestore.instance
        .collection('fruitBowls')
        .doc(bmiString)
        .collection('sizes')
        .get();

    for (final sizeDoc in sizesSnapshot.docs) {
      final data = sizeDoc.data() as Map<String, dynamic>;
      final dailyPrice = (data['dailyPrice'] is num)
          ? (data['dailyPrice'] as num).toDouble()
          : double.tryParse(data['dailyPrice']?.toString() ?? '0') ?? 0.0;

      final itemsSnapshot = await sizeDoc.reference.collection('items').get();
      int totalCalories = 0;
      for (final itemDoc in itemsSnapshot.docs) {
        final itemData = itemDoc.data();
        final itemCalories = (itemData['calories'] is num)
            ? (itemData['calories'] as num).toInt()
            : int.tryParse(itemData['calories']?.toString() ?? '0') ?? 0;
        totalCalories += itemCalories;
      }

      String sizeid = sizeDoc.id.toUpperCase();

      _bowls.add(
        FruitBowlItem(
          title: '$sizeid BOWL',
          description: data['description'] ?? 'Healthy fruit bowl',
          coverImage: 'assets/images/medium_bowl.png',
          color: data['color'] != null
              ? Color(int.parse(data['color']))
              : Colors.white,
          calories: totalCalories,
          price: dailyPrice,
        ),
      );
      notifyListeners();
    }

    return _bowls;
  }
}
