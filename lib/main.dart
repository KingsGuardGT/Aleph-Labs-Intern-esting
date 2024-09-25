import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/presentation/screen/products_list_screen.dart';
import 'package:my_project/presentation/screen/products_sidebar_screen.dart';
import 'package:my_project/table/screens/data_table2_fixed_nm.dart';
import 'package:my_project/table/screens/paginated_data_table.dart';
import 'package:my_project/table/table.dart';
import 'package:my_project/theme/app_theme.dart';

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
      initialRoute: '/',  // Define the initial route
      routes: {
        '/': (context) => const ProductListScreen(),
        '/screens_example': (context) => const ScreensExample(),
        '/datatable2': (context) => const TablePage(),
        '/datatable2fixedmn': (context) => const DataTable2FixedNMDemo(),
        '/paginated': (context) => const PaginatedDataTableDemo(),// Add the Table page route
      },
    );
  }
}
