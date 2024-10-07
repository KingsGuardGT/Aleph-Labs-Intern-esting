import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/notifiers/sidebar_controller_provider.dart';

class ScreensExample extends ConsumerWidget {
  const ScreensExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the SidebarXController via Riverpod
    final sidebarController = ref.watch(sidebarControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleByIndex(sidebarController.selectedIndex)),
      ),
      body: AnimatedBuilder(
        animation: sidebarController,
        builder: (context, child) {
          final pageTitle = _getTitleByIndex(sidebarController.selectedIndex);
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    pageTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 18,  // Fixed font size
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to ProductListScreen
                    Navigator.pop(context);
                  },
                  child: const Text('Back to Product List'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper function to get page titles by index
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
}