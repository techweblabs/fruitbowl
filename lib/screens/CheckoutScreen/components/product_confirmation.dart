// lib/checkout/components/product_confirmation.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/brutal_decoration.dart';

class ProductConfirmation extends StatelessWidget {
  final Map<String, dynamic> product;
  final int planIndex;

  const ProductConfirmation({
    super.key,
    required this.product,
    required this.planIndex,
  });

  // Get plan days
  int get _planDays => product['plans'][planIndex]['days'];

  // Get plan price
  String get _planPrice => product['plans'][planIndex]['price'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BrutalDecoration.brutalBox(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductHeader(),
          _buildProductDetails(),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        image: DecorationImage(
          image: AssetImage(product['backgroundImage']),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              product['gradientColors'][0].withOpacity(0.7),
              product['gradientColors'][2].withOpacity(0.9),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              child: Transform.rotate(
                angle: -0.2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.yellow[600],
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(offset: Offset(3, 3), color: Colors.black)
                    ],
                  ),
                  child: Text(
                    "${product['price']} / day",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                product['name'],
                style: GoogleFonts.bangers(
                  fontSize: 32,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Plan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Plan details with brutalist design
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow[50],
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(offset: Offset(2, 2), color: Colors.black)
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$_planDays Days",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _planPrice,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Total",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            product['description'],
            maxLines: 2,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),

          // Ingredients overview
          const Text(
            "What You'll Get:",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...product['ingredients']
              .take(3)
              .map<Widget>((ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          "• ${ingredient['name']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text("(${ingredient['qty']})"),
                      ],
                    ),
                  ))
              .toList(),
          if (product['ingredients'].length > 3)
            Text(
              "+ ${product['ingredients'].length - 3} more items",
              style: TextStyle(
                  color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}
