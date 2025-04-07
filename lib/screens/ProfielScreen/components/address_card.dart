// lib/profile/components/address_card.dart
import 'package:flutter/material.dart';

import '../../../utils/brutal_decoration.dart';
import '../models/user_profile.dart';

class AddressCard extends StatelessWidget {
  final UserAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        children: [
          // Address header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: address.isDefault ? Colors.green[50] : Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              border: const Border(
                bottom: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Address type icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: address.isDefault ? Colors.green[100] : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                  child: _getAddressTypeIcon(),
                ),
                const SizedBox(width: 12),

                // Address type and default indicator
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.type,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (address.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "Default",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (!address.isDefault)
                        GestureDetector(
                          onTap: onSetDefault,
                          child: Text(
                            "Set as default",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Action menu
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: () {
                    _showAddressOptions(context);
                  },
                ),
              ],
            ),
          ),

          // Address details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full address
                Text(
                  address.fullAddress,
                  style: const TextStyle(
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Edit button
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 14, color: Colors.grey[700]),
                            const SizedBox(width: 4),
                            Text(
                              "Edit",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Delete button
                    GestureDetector(
                      onTap: () {
                        _showDeleteConfirmation(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                size: 14, color: Colors.red[700]),
                            const SizedBox(width: 4),
                            Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Icon _getAddressTypeIcon() {
    switch (address.type.toLowerCase()) {
      case 'home':
        return const Icon(Icons.home, size: 16);
      case 'office':
      case 'work':
        return const Icon(Icons.work, size: 16);
      default:
        return const Icon(Icons.place, size: 16);
    }
  }

  void _showAddressOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BrutalDecoration.brutalBox(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Address'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            const Divider(),
            if (!address.isDefault)
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Set as Default'),
                onTap: () {
                  Navigator.pop(context);
                  onSetDefault();
                },
              ),
            if (!address.isDefault) const Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red[700]),
              title: Text('Delete Address',
                  style: TextStyle(color: Colors.red[700])),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Container(
          decoration: BrutalDecoration.brutalBox(), // main card style
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Delete Address',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to delete this address?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // CANCEL
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BrutalDecoration.brutalBox(
                          color: const Color(0xFFD0D0D0),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // DELETE
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        // ← your delete logic here:
                        // e.g. deleteAddress(addressId);
                        //    setState(() { ... });
                        //    ScaffoldMessenger.of(context).showSnackBar(...);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BrutalDecoration.brutalBox(
                          color: const Color(0xFFFF5C5C),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
