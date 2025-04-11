import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/ProductScreen/product_screen.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:sizer/sizer.dart';
import '../cards/fruit_bowl_card.dart';
import '../../models/fruit_bowl_item.dart';

class RecommendedSection extends StatelessWidget {
  final List<FruitBowlItem> fruitBowls;
  final String title;

  const RecommendedSection({
    Key? key,
    required this.fruitBowls,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with simple neo-brutalist style
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 24.0, bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSimpleTitle(),
                _buildViewAllButton(context),
              ],
            ),
          ),

          // Horizontal scrollable list of fruit bowl cards
          SizedBox(
            height: 400,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: fruitBowls.length,
              itemBuilder: (context, index) {
                return FruitBowlCard(
                  bowl: fruitBowls[index],
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTitle() {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: Colors.black,
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Twl.navigateToScreenAnimated(const ProductScreen(), context: context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F7FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Text(
          'View All',
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
