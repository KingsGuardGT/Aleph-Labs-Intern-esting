import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define the available pages as an enum for better clarity
enum PageType {
  home,
  products,
  table,
  favorites,
  search,
}

// Create a StateNotifier to manage the current page state
class PageControllerNotifier extends StateNotifier<PageType> {
  PageControllerNotifier() : super(PageType.home);

  // Function to change the page
  void setPage(PageType page) {
    state = page;
  }
}

// Create a Riverpod provider for the PageControllerNotifier
final pageControllerProvider =
StateNotifierProvider<PageControllerNotifier, PageType>(
        (ref) => PageControllerNotifier());
