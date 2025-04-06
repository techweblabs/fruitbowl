import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;
  final Color baseColor;
  final Color highlightColor;
  
  const ShimmerLoading({
    Key? key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.baseColor = const Color(0xFFEEEEEE),
    this.highlightColor = const Color(0xFFFFFFFF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[300]!,
          shape: shapeBorder,
        ),
      ),
    );
  }
}

/// A collection of pre-built shimmer loading widgets
class ShimmerWidgets {
  /// Private constructor to prevent instantiation
  ShimmerWidgets._();
  
  /// Creates a shimmer card
  static Widget card({
    double? width,
    double? height,
    double borderRadius = 8.0,
  }) {
    return ShimmerLoading(
      width: width ?? double.infinity,
      height: height ?? 20.h,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
    );
  }
  
  /// Creates a shimmer circle, useful for avatars
  static Widget circle({
    double? size,
  }) {
    return ShimmerLoading(
      width: size ?? 12.w,
      height: size ?? 12.w,
      shapeBorder: const CircleBorder(),
    );
  }
  
  /// Creates a shimmer text line
  static Widget text({
    double? width,
    double? height,
    double borderRadius = 2.0,
  }) {
    return ShimmerLoading(
      width: width ?? double.infinity,
      height: height ?? 2.h,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
    );
  }
  
  /// Creates a shimmer list item with an avatar and text lines
  static Widget listItem({
    double? height,
    double borderRadius = 8.0,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          circle(size: 12.w),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text(width: 35.w),
                SizedBox(height: 1.h),
                text(width: 50.w),
                SizedBox(height: 0.5.h),
                text(width: 25.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Creates a shimmer grid
  static Widget grid({
    required int crossAxisCount,
    required int itemCount,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    double childAspectRatio = 1,
    EdgeInsets? padding,
  }) {
    return GridView.builder(
      padding: padding ?? EdgeInsets.all(2.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing ?? 2.w,
        crossAxisSpacing: crossAxisSpacing ?? 2.w,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => card(),
    );
  }
  
  /// Creates a profile shimmer
  static Widget profileHeader() {
    return Column(
      children: [
        SizedBox(height: 2.h),
        circle(size: 20.w),
        SizedBox(height: 2.h),
        text(width: 40.w),
        SizedBox(height: 1.h),
        text(width: 50.w),
        SizedBox(height: 2.h),
      ],
    );
  }
}
