import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../components/loaders/shimmer_loading.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({Key? key}) : super(key: key);

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('explore'.tr),
        centerTitle: true,
      ),
      body: _isLoading ? _buildLoadingContent() : _buildContent(),
    );
  }

  Widget _buildLoadingContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer header
          ShimmerWidgets.text(width: 60.w, height: 3.h),
          SizedBox(height: 2.h),

          // Shimmer featured
          ShimmerWidgets.card(height: 25.h),
          SizedBox(height: 4.h),

          // Shimmer section title
          ShimmerWidgets.text(width: 40.w, height: 2.5.h),
          SizedBox(height: 2.h),

          // Shimmer items grid
          ShimmerWidgets.grid(
            crossAxisCount: 2,
            itemCount: 4,
            childAspectRatio: 0.8,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Content',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),

          // Featured card
          _buildFeaturedCard(),
          SizedBox(height: 4.h),

          Text(
            'Popular Items',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),

          // Grid of items
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 0.8,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => _buildGridItem(index),
          ),
          SizedBox(
            height: 10.h,
          )
        ],
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      height: 25.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.w),
        color: Theme.of(context).primaryColor,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3.w),
              child: Opacity(
                opacity: 0.2,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/placeholder.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Special Feature',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Discover our special feature with amazing functionalities',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    'Explore Now',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(int index) {
    final List<String> titles = [
      'Item One',
      'Item Two',
      'Item Three',
      'Item Four',
    ];

    final List<IconData> icons = [
      Icons.favorite,
      Icons.star,
      Icons.access_time,
      Icons.local_offer,
    ];

    final List<Color> colors = [
      Colors.red,
      Colors.amber,
      Colors.blue,
      Colors.green,
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(2.w),
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: colors[index].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icons[index],
                  color: colors[index],
                  size: 8.w,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                titles[index],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Sample description for this item',
                style: TextStyle(
                  fontSize: 8.sp,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 2.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.w,
                    vertical: 1.h,
                  ),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(fontSize: 9.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
