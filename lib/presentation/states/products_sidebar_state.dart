import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/notifiers/sidebar_controller_provider.dart';
import '../screen/products_sidebar_screen.dart';
import '../widgets/products_sidebar.dart';

class SidebarXExampleApp extends ConsumerWidget {
  SidebarXExampleApp({super.key});

  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the SidebarXController using Riverpod
    final controller = ref.watch(sidebarControllerProvider);

    return MaterialApp(
      title: 'SidebarX Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        canvasColor: canvasColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            key: _key,
            appBar: isSmallScreen
                ? AppBar(
              backgroundColor: canvasColor,
              title: Text(_getTitleByIndex(controller.selectedIndex)),
              leading: IconButton(
                onPressed: () {
                  _key.currentState?.openDrawer();
                },
                icon: const Icon(Icons.menu),
              ),
            )
                : null,
            drawer: const ExampleSidebarX(),  // Controller is no longer passed
            body: Row(
              children: [
                if (!isSmallScreen) const ExampleSidebarX(),  // Controller is no longer passed
                const Expanded(
                  child: Center(
                    child: ScreensExample(),  // Controller is no longer passed
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Helper function to get title by index
String _getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return 'Home';
    case 1:
      return 'Search';
    case 2:
      return 'Table';
    case 3:
      return 'Favorites';
    case 4:
      return 'Custom iconWidget';
    default:
      return 'Not found page';
  }
}

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: Colors.white.withOpacity(0.3), height: 1);
