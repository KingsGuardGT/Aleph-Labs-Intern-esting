import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/table/screens/data_table2_fixed_nm.dart';

import '../presentation/widgets/products_sidebar.dart';
import 'nav_helper.dart';
import 'screens/async_paginated_data_table2.dart';
import 'screens/data_table.dart';
import 'screens/data_table2.dart';
import 'screens/data_table2_rounded.dart';
import 'screens/data_table2_scrollup.dart';
import 'screens/data_table2_simple.dart';
import 'screens/data_table2_tests.dart';
import 'screens/paginated_data_table.dart';
import 'screens/paginated_data_table2.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


const String initialRoute = '/';

Scaffold _getScaffold(BuildContext context, Widget body,
    [List<String>? options]) {
  var defaultOption = getCurrentRouteOption(context);
  if (defaultOption.isEmpty && options != null && options.isNotEmpty) {
    defaultOption = options[0];
  }
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.grey[200],
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            color: Colors.grey[850],
            //screen selection
            child: DropdownButton<String>(
              icon: const Icon(Icons.arrow_forward),
              dropdownColor: Colors.grey[800],
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Colors.white),
              value: _getCurrentRoute(context),
              onChanged: (v) {
                Navigator.of(context).pushNamed(v!);
              },
              items: const [
                DropdownMenuItem(
                  value: '/datatable2',
                  child: Text('DataTable2'),
                ),
                DropdownMenuItem(
                  value: '/datatable2simple',
                  child: Text('Simple'),
                ),
                DropdownMenuItem(
                  value: '/datatable2scrollup',
                  child: Text('Scroll-up/Scroll-left'),
                ),
                DropdownMenuItem(
                  value: '/datatable2fixedmn',
                  child: Text('Fixed Rows/Cols'),
                ),
                DropdownMenuItem(
                  value: '/paginated2',
                  child: Text('PaginatedDataTable2'),
                ),
                DropdownMenuItem(
                  value: '/asyncpaginated2',
                  child: Text('AsyncPaginatedDataTable2'),
                ),
                DropdownMenuItem(
                  value: '/datatable',
                  child: Text('DataTable'),
                ),
                DropdownMenuItem(
                  value: '/paginated',
                  child: Text('PaginatedDataTable'),
                ),
                if (kDebugMode)
                  DropdownMenuItem(
                    value: '/datatable2tests',
                    child: Text('Unit Tests Preview'),
                  ),
              ],
            )),
        options != null && options.isNotEmpty
            ? Flexible(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 0, 4),
                        child: DropdownButton<String>(
                            icon: const SizedBox(),
                            dropdownColor: Colors.grey[300],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: Colors.black),
                            value: defaultOption,
                            onChanged: (v) {
                              var r = _getCurrentRoute(context);
                              Navigator.of(context).pushNamed(r, arguments: v);
                            },
                            items: options
                                .map<DropdownMenuItem<String>>(
                                    (v) => DropdownMenuItem<String>(
                                          value: v,
                                          child: Text(v),
                                        ))
                                .toList()))))
            : const SizedBox()
      ]),
    ),
    body: body,
  );
}

String _getCurrentRoute(BuildContext context) {
  return ModalRoute.of(context) != null &&
          ModalRoute.of(context)!.settings.name != null
      ? ModalRoute.of(context)!.settings.name!
      : initialRoute;
}

// ignore: use_key_in_widget_constructors
class TablePage extends ConsumerWidget {
  const TablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      restorationScopeId: 'main',
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.grey[300],
      ),
      initialRoute: '/datatable2', // Set initial route
      routes: {
        '/datatable2': (context) => _getPageWithDrawer(
          context,
          const DataTable2Demo(),  // Reference your demo page
          'DataTable2',
        ),
        '/datatable2simple': (context) => _getPageWithDrawer(
          context,
          const DataTable2SimpleDemo(),
          'DataTable2 Simple',
        ),
        '/datatable2scrollup': (context) => _getPageWithDrawer(
          context,
          const DataTable2ScrollupDemo(),
          'Scroll-up Table',
        ),
        '/datatable2fixedmn': (context) => _getPageWithDrawer(
          context,
          const DataTable2FixedNMDemo(),
          'Fixed Rows/Cols',
        ),
        '/paginated2': (context) => _getPageWithDrawer(
          context,
          const PaginatedDataTable2Demo(),
          'Paginated Table',
        ),
        '/asyncpaginated2': (context) => _getPageWithDrawer(
          context,
          const AsyncPaginatedDataTable2Demo(),
          'Async Paginated Table',
        ),
        '/datatable': (context) => _getPageWithDrawer(
          context,
          const DataTableDemo(),
          'DataTable',
        ),
        '/paginated': (context) => _getPageWithDrawer(
          context,
          const PaginatedDataTableDemo(),
          'Paginated DataTable',
        ),
        '/datatable2tests': (context) => _getPageWithDrawer(
          context,
          const DataTable2Tests(),
          'Unit Tests Preview',
        ),
      },
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      supportedLocales: const [
        Locale('en', ''),
        Locale('be', ''),
        Locale('ru', ''),
        Locale('fr', ''),
      ],
      locale: const Locale('en', ''),
    );
  }

  // Helper method to get the Scaffold with Sidebar Drawer for any page
  Scaffold _getPageWithDrawer(BuildContext context, Widget body, String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.grey[200],
        actions: [
          PopupMenuButton<String>(
            onSelected: (route) {
              Navigator.pushNamed(context, route);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: '/datatable2',
                  child: Text('DataTable2'),
                ),
                const PopupMenuItem<String>(
                  value: '/datatable2simple',
                  child: Text('DataTable2 Simple'),
                ),
                const PopupMenuItem<String>(
                  value: '/datatable2scrollup',
                  child: Text('Scroll-up Table'),
                ),
                const PopupMenuItem<String>(
                  value: '/datatable2fixedmn',
                  child: Text('Fixed Rows/Cols'),
                ),
                const PopupMenuItem<String>(
                  value: '/paginated2',
                  child: Text('Paginated Table'),
                ),
                const PopupMenuItem<String>(
                  value: '/asyncpaginated2',
                  child: Text('Async Paginated Table'),
                ),
                const PopupMenuItem<String>(
                  value: '/datatable',
                  child: Text('DataTable'),
                ),
                const PopupMenuItem<String>(
                  value: '/paginated',
                  child: Text('Paginated DataTable'),
                ),
                const PopupMenuItem<String>(
                  value: '/datatable2tests',
                  child: Text('Unit Tests Preview'),
                ),
              ];
            },
          ),
        ],
      ),
      drawer: const ExampleSidebarX(),  // Integrating your sidebar as drawer
      body: body,
    );
  }
}

