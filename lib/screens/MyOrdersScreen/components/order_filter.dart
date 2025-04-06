// lib/orders/components/order_filter.dart
import 'package:flutter/material.dart';

import '../../../utils/brutal_decoration.dart';

class OrderFilter extends StatelessWidget {
  final String activeFilter;
  final Function(String) onFilterChanged;

  const OrderFilter({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BrutalDecoration.brutalBox(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterOption('All', context),
          _buildFilterOption('Active', context),
          _buildFilterOption('Upcoming', context),
          _buildFilterOption('Completed', context),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String filter, BuildContext context) {
    final isActive = activeFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(filter),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.yellow[600] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? Colors.black : Colors.grey[400]!,
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? const [BoxShadow(offset: Offset(2, 2), color: Colors.black)]
                : null,
          ),
          child: Center(
            child: Text(
              filter,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
