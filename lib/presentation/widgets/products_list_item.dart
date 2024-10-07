import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Required for responsive utilities

import '../../core/utils/responsive_utils.dart';
import '../../data/notifiers/product_notifier.dart';
import '../../main.dart';
import '../../presentation/widgets/products_list_expanded_item.dart';

// StateProvider for managing individual product expansion state based on index
final isExpandedProvider = StateProvider.family<bool, int>((ref, index) => false);


class ProductListItem extends ConsumerWidget {
  final int index;

  const ProductListItem({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productNotifier = ref.watch(productNotifierProvider);
    final product = productNotifier.products[index];
    final isExpanded = ref.watch(isExpandedProvider(index).select((state) => state));
    final theme = ref.watch(themeProvider);
    final isLargeScreen = ResponsiveUtils.isDesktop(context);

    final String? imageUrl = (product.images != null && product.images!.isNotEmpty)
        ? product.images!.first
        : null;

    Widget buildImage() {
      return imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: imageUrl,
        width: isLargeScreen ? 150 : double.infinity,
        height: isLargeScreen ? 150: 200,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      )
          : SizedBox(
        width: isLargeScreen ? 150 : double.infinity,
        height: isLargeScreen ? 150: 200,
        child: const Icon(Icons.image_not_supported),
      );
    }

    Widget buildContent() {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: ResponsiveUtils.fontSize(context),
              ),
            ),
            SizedBox(height: ResponsiveUtils.verticalPadding(context)),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.green,
                fontSize: ResponsiveUtils.fontSize(context),
              ),
            ),
            SizedBox(height: ResponsiveUtils.verticalPadding(context)),
            Text(
              isExpanded
                  ? product.description ?? ''
                  : (product.description != null && product.description!.length > 50
                  ? '${product.description!.substring(0, 50)}...'
                  : product.description ?? ''),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: ResponsiveUtils.fontSize(context),
              ),
            ),
            SizedBox(height: ResponsiveUtils.verticalPadding(context)),
            IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                ref.read(isExpandedProvider(index).notifier).update((state) => !state);
              },
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ProductListExpandedItem(product: product),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.verticalPadding(context),
        horizontal: ResponsiveUtils.horizontalPadding(context),
      ),
      child: Card(
        elevation: 4,
        child: SizedBox(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.horizontalPadding(context)),
            child: isLargeScreen
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildImage(),
                SizedBox(width: ResponsiveUtils.horizontalPadding(context)),
                Expanded(
                  child: buildContent(),
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildImage(),
                SizedBox(height: ResponsiveUtils.verticalPadding(context)),
                Expanded(
                  child: SingleChildScrollView(
                    child: buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}