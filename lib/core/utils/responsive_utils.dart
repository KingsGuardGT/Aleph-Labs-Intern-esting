import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Define breakpoints
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  // Helper to get spacing based on screen size
  static double horizontalPadding(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 24;
    return 32; // for desktop
  }

  static double verticalPadding(BuildContext context) {
    if (isMobile(context)) return 12;
    if (isTablet(context)) return 20;
    return 24; // for desktop
  }

  // Helper for font size
  static double fontSize(BuildContext context) {
    if (isMobile(context)) return 14;
    if (isTablet(context)) return 16;
    return 18; // for desktop
  }

  // Helper for container height (for DataRow)
  static double containerHeight(BuildContext context) {
    if (isMobile(context)) return 80;
    if (isTablet(context)) return 100;
    return 120; // for desktop
  }

  // Helper for container width
  static double containerWidth(BuildContext context) {
    if (isMobile(context)) return 700;
    if (isTablet(context)) return 800;
    return 900; // for desktop
  }
}