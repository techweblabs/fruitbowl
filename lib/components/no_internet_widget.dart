import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../utils/helpers/twl.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;
  
  const NoInternetWidget({
    Key? key,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 20.w,
              color: Colors.grey,
            ),
            SizedBox(height: 3.h),
            Text(
              'noInternet'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'pleaseTryAgain'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text('tryAgain'.tr),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 1.5.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InternetConnectionWrapper extends StatelessWidget {
  final Widget child;
  final Widget? loadingWidget;
  
  const InternetConnectionWrapper({
    Key? key,
    required this.child,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: Twl.connectivityStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
        
        final hasInternet = snapshot.data ?? false;
        if (!hasInternet) {
          return NoInternetWidget(
            onRetry: () {
              // Manually check connectivity again
              Twl.checkConnectivity();
            },
          );
        }
        
        return child;
      },
    );
  }
}
