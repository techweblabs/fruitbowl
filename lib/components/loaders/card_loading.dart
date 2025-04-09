import 'package:flutter/material.dart';

class CardLoading extends StatefulWidget {
  const CardLoading({super.key});

  @override
  State<CardLoading> createState() => _CardLoadingState();
}

class _CardLoadingState extends State<CardLoading> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating container
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (_, double value, __) {
              return Transform.rotate(
                angle: value * 2 * 3.14,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(offset: Offset(4, 4), color: Colors.black),
                    ],
                  ),
                ),
              );
            },
            onEnd: () {
              setState(() {}); // Rebuild to continue animation
            },
          ),
          // Inner rotating container (opposite direction)
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 5),
            builder: (_, double value, __) {
              return Transform.rotate(
                angle: -value * 2 * 3.14,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(offset: Offset(3, 3), color: Colors.black),
                    ],
                  ),
                ),
              );
            },
            onEnd: () {
              setState(() {}); // Rebuild to continue animation
            },
          ),
          // Center dot
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
