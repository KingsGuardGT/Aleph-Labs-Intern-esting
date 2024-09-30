// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// // Define colors based on your JSON theme
// const primaryColor = Color(0xFF216036);
// const primaryColorContainer = Color(0xFF164626);
// const secondaryColor = Color(0xFF832B9C);
// const surfaceColor = Color(0xFFDCE6F2);
// const backgroundColor = Color(0xFFDCE6F2);
// const errorColor = Color(0xFFB00020);
// const onPrimaryColor = Color(0xFFFFFFFF);
// const onSecondaryColor = Color(0xFF000000);
// const onSurfaceColor = Color(0xFF000000);
// const onBackgroundColor = Color(0xFF000000);
// const onErrorColor = Color(0xFFFFFFFF);
//
// // Define a provider for the theme data
// final appThemeProvider = Provider<ThemeData>((ref) {
//   return ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.light,
//     primaryColor: primaryColor,
//     primaryColorLight: primaryColorContainer,
//     primaryColorDark: primaryColor,
//     canvasColor: backgroundColor,
//     scaffoldBackgroundColor: backgroundColor,
//     cardColor: surfaceColor,
//     dividerColor: const Color(0x1F000000), // From JSON dividerColor
//     splashColor: const Color(0x66C8C8C8), // From JSON splashColor
//     shadowColor: const Color(0xFF000000), // From JSON shadowColor
//     iconTheme: const IconThemeData(color: Color(0xDD000000)), // From JSON iconTheme
//     indicatorColor: onPrimaryColor,
//
//     buttonTheme: ButtonThemeData(
//       height: 36,
//       minWidth: 88,
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       alignedDropdown: false,
//       layoutBehavior: ButtonBarLayoutBehavior.padded,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(2),
//       ),
//     ),
//
//     inputDecorationTheme: const InputDecorationTheme(
//       filled: false,
//       floatingLabelBehavior: FloatingLabelBehavior.auto,
//       alignLabelWithHint: false,
//       isCollapsed: false,
//       isDense: false,
//     ),
//
//     textTheme: const TextTheme(
//       bodyLarge: TextStyle(
//         fontFamily: 'Roboto_regular',
//         fontSize: 16,
//         fontWeight: FontWeight.w400,
//         letterSpacing: 0.5,
//         color: Color(0xFF000000),
//       ),
//       bodyMedium: TextStyle(
//         fontFamily: 'Roboto_regular',
//         fontSize: 14,
//         fontWeight: FontWeight.w400,
//         letterSpacing: 0.25,
//         color: Color(0xFF000000),
//       ),
//       bodySmall: TextStyle(
//         fontFamily: 'Roboto_regular',
//         fontSize: 12,
//         fontWeight: FontWeight.w400,
//         letterSpacing: 0.4,
//         color: Color(0xFF000000),
//       ),
//       headlineLarge: TextStyle(
//         fontFamily: 'Roboto_regular',
//         fontSize: 40,
//         fontWeight: FontWeight.w400,
//         color: Color(0xFF000000),
//       ),
//       headlineMedium: TextStyle(
//         fontFamily: 'Roboto_regular',
//         fontSize: 34,
//         fontWeight: FontWeight.w400,
//         color: Color(0xFF000000),
//       ),
//       headlineSmall: TextStyle(
//         fontFamily: 'Roboto_regular',
//         fontSize: 24,
//         fontWeight: FontWeight.w400,
//         color: Color(0xFF000000),
//       ),
//       titleLarge: TextStyle(
//         fontFamily: 'Roboto_500',
//         fontSize: 22,
//         fontWeight: FontWeight.w500,
//         color: Color(0xFF000000),
//       ),
//       titleMedium: TextStyle(
//         fontFamily: 'Roboto_regular',
//         fontSize: 16,
//         fontWeight: FontWeight.w400,
//         color: Color(0xFF000000),
//       ),
//       titleSmall: TextStyle(
//         fontFamily: 'Roboto_500',
//         fontSize: 14,
//         fontWeight: FontWeight.w500,
//         color: Color(0xFF000000),
//       ),
//       labelLarge: TextStyle(
//         fontFamily: 'Roboto_500',
//         fontSize: 14,
//         fontWeight: FontWeight.w500,
//         color: Color(0xFF000000),
//       ),
//       labelMedium: TextStyle(
//         fontFamily: 'Roboto_regular',
//         fontSize: 12,
//         fontWeight: FontWeight.w400,
//         color: Color(0xFF000000),
//       ),
//       labelSmall: TextStyle(
//         fontFamily: 'Roboto_regular',
//         fontSize: 11,
//         fontWeight: FontWeight.w400,
//         color: Color(0xFF000000),
//       ),
//     ), colorScheme: const ColorScheme(
//       brightness: Brightness.light,
//       primary: primaryColor,
//       onPrimary: onPrimaryColor,
//       secondary: secondaryColor,
//       onSecondary: onSecondaryColor,
//       error: errorColor,
//       onError: onErrorColor,
//       surface: surfaceColor,
//       onSurface: onSurfaceColor,
//     ).copyWith(surface: backgroundColor),
//   );
// });
