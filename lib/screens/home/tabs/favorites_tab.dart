import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/utils/brutal_decoration.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('favorites'.tr),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: 11, // 10 items + 1 extra widget (for spacing)
        itemBuilder: (context, index) {
          if (index == 10) {
            // Last item: just a spacer
            return SizedBox(height: 10.h); // adjust height as needed
          }
          return _buildFavoriteItem(context, index);
        },
      ),
    );
  }

  Widget _buildFavoriteItem(BuildContext context, int index) {
    return Dismissible(
      key: Key('favorite_$index'),
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(2.w),
        ),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 6.w,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {},
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              decoration: BrutalDecoration.brutalBox(),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Remove Favorite',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Are you sure you want to remove this item from favorites?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
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
                        // Remove Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BrutalDecoration.brutalBox(
                                color: const Color(0xFFFF5C5C),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Remove',
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
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.h,
          ),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            radius: 6.w,
            child: Icon(
              Icons.favorite,
              color: Theme.of(context).primaryColor,
              size: 5.w,
            ),
          ),
          title: Text(
            'Favorite Item ${index + 1}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'This is a sample description for favorite item ${index + 1}',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 4.w,
            ),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
