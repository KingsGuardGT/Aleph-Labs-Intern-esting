import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/presentation/screen/products_list_screen.dart';
import 'package:my_project/theme/app_theme.dart';  // Import the theme provider

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the theme from the Riverpod provider
    final theme = ref.watch(appThemeProvider);

    return MaterialApp(
      theme: theme,  // Apply the theme to MaterialApp
      home: const ProductListScreen(),
    );
  }
}
