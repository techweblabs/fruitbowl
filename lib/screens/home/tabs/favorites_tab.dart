import 'package:flutter/material.dart';
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
        itemCount: 10,
        itemBuilder: (context, index) => _buildFavoriteItem(context, index),
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
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Remove Favorite'),
            content: Text('Are you sure you want to remove this item from favorites?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Remove'),
              ),
            ],
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
