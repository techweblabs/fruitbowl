import 'package:flutter/material.dart';

class AddressScreenBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Code for Basic screen body with four blocks
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // First Block
              Container(
                height: 100,
                color: Colors.blue,
                child: const Center(
                  child: Text('Block 1'),
                ),
              ),
              const SizedBox(height: 20),
              // Second Block
              Container(
                height: 100,
                color: Colors.green,
                child: const Center(
                  child: Text('Block 2'),
                ),
              ),
              const SizedBox(height: 20),
              // Third Block
              Container(
                height: 100,
                color: Colors.orange,
                child: const Center(
                  child: Text('Block 3'),
                ),
              ),
              const SizedBox(height: 20),
              // Fourth Block
              Container(
                height: 100,
                color: Colors.purple,
                child: const Center(
                  child: Text('Block 4'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
