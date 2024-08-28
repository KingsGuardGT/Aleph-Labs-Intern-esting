import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:my_project/repositories/image_repository.dart';
import 'package:my_project/notifiers/image_notifier.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton<ImageRepository>(() => ImageRepository());
  getIt.registerSingleton<ImageNotifier>(ImageNotifier(getIt<ImageRepository>()));
}

class ImageScroll extends StatelessWidget {
  const ImageScroll({super.key});

  @override
  Widget build(BuildContext context) {
    final imageNotifier = getIt<ImageNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Scroll Project (ALL LENNOX)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: imageNotifier,
                builder: (context, imageIndex, child) {
                  return Image.asset(
                    imageNotifier.images[imageIndex].path,
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    imageNotifier.previousImage();
                  },
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    imageNotifier.nextImage();
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  setup();
  runApp(
    const MaterialApp(
      home: ImageScroll(),
    ),
  );
}