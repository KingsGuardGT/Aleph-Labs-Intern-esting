import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveUtils {
  // Define breakpoints
  static bool isMobile(BuildContext context) => ScreenUtil().screenWidth < 904;
  static bool isTablet(BuildContext context) => ScreenUtil().screenWidth >= 904 && ScreenUtil().screenWidth < 1280;
  static bool isDesktop(BuildContext context) => ScreenUtil().screenWidth >= 1280;

  // Helper to get spacing based on screen size
  static double horizontalPadding(BuildContext context) {
    if (isMobile(context)) return 16.w;
    if (isTablet(context)) return 24.w;
    return 32.w; // for desktop
  }

  static double verticalPadding(BuildContext context) {
    if (isMobile(context)) return 12.h;
    if (isTablet(context)) return 20.h;
    return 24.h; // for desktop
  }

  // Helper for font size
  static double fontSize(BuildContext context) {
    if (isMobile(context)) return 14.sp;
    if (isTablet(context)) return 16.sp;
    return 18.sp; // for desktop
  }

  // Helper for container height (for DataRow)
  static double containerHeight(BuildContext context) {
    if (isMobile(context)) return 80.h;
    if (isTablet(context)) return 100.h;
    return 120.h; // for desktop
  }

  // Helper for container width
  static double containerWidth(BuildContext context) {
    if (isMobile(context)) return 700.w;
    if (isTablet(context)) return 800.w;
    return 900.w; // for desktop
  }
}
