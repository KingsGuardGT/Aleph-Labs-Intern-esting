import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:my_project/models/image_model.dart';
import 'package:my_project/repositories/image_repository.dart';
import 'package:flutter/material.dart';


class ImageNotifier extends ValueNotifier<int> {
  final ImageRepository _imageRepository;
  final List<ImageModel> _images;

  ImageNotifier(this._imageRepository) :
        _images = _imageRepository.fetchImages(),
        super(0);

  List<ImageModel> get images => _images;

  void nextImage() {
    value = (value + 1) % _images.length;
  }

  void previousImage() {
    value = (value - 1 + _images.length) % _images.length;
  }
}