import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_theme/json_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:my_project/presentation/screen/products_list_screen.dart';
import 'package:my_project/presentation/screen/products_sidebar_screen.dart';
import 'package:my_project/table/screens/data_table2_fixed_nm.dart';
import 'package:my_project/table/screens/paginated_data_table.dart';
import 'package:my_project/table/table.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeStr = await rootBundle.loadString('lib/theme/appainter_theme.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  runApp(
    ProviderScope(
      overrides: [
        themeProvider.overrideWith((ref) => theme),
      ],
      child: const MyApp(),
    ),
  );
}

final themeProvider = StateProvider<ThemeData>((ref) => ThemeData.light());

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ref.watch(themeProvider),
      initialRoute: '/',
      routes: {
        '/': (context) => const ProductListScreen(),
        '/screens_example': (context) => const ScreensExample(),
        '/datatable2': (context) => const TablePage(),
        '/datatable2fixedmn': (context) => const DataTable2FixedNMDemo(),
        '/paginated': (context) => const PaginatedDataTableDemo(),
      },
    );
  }
}