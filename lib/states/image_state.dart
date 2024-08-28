import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/image_model.dart';
import 'package:my_project/models/image_model.dart';

part 'image_state.freezed.dart';

@freezed
class ImageState with _$ImageState {
  const factory ImageState.initial() = _Initial;
  const factory ImageState.loading() = _Loading;
  const factory ImageState.loaded(List<ImageModel> images) = _Loaded;
  const factory ImageState.error(String message) = _Error;
}