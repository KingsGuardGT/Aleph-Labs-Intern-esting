import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/presentation/screen/products_list_screen.dart';
import '../../data/notifiers/sidebar_controller_provider.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../table/table.dart'; // Import the new Table page (we'll create this next)

class ExampleSidebarX extends ConsumerWidget {
  const ExampleSidebarX({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarController = ref.watch(sidebarControllerProvider);

    return SidebarX(
      controller: sidebarController,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: const Color(0xFF464667),
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2E2E48)),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF5F5FA7).withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFF3E3E61), Color(0xFF2E2E48)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: Color(0xFF2E2E48),
        ),
      ),
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: 'Home',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductListScreen()),
            );
            // Handle Home Navigation (Optional)
          },
        ),
        SidebarXItem(
          icon: Icons.table_view,
          label: 'Products',
          onTap: () {
            // Push a new page to display the DataTableDemo
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductListScreen()),
            );
          },
        ),
        SidebarXItem(
          icon: Icons.table_chart_outlined,
          label: 'Table',
          onTap: () {
            // Push a new page to display the DataTableDemo
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TablePage()),
            );
          },
        ),
        SidebarXItem(
          icon: Icons.favorite,
          label: 'Favorites',
          onTap: () {
            // Handle Favorites Navigation (Optional)
          },
        ),
        SidebarXItem(
          icon: Icons.search,
          label: 'Search',
          onTap: () {
            // Handle Search Navigation (Optional)
          },
        ),
      ],
    );
  }
}
