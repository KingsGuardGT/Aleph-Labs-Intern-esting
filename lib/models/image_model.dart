import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_model.freezed.dart';
part 'image_model.g.dart';

@freezed
class ImageModel with _$ImageModel {
  const factory ImageModel({
    required String path,
    required String description,
  }) = _ImageModel;

  factory ImageModel.fromJson(Map<String, dynamic> json) => _$ImageModelFromJson(json);
}

// class ImageModel {
//   String? path;
//   String? description;
//
//   ImageModel({this.path, this.description});
//
//   ImageModel.fromJson(Map<String, dynamic> json) {
//     path = json['path'];
//     description = json['description'];
//   }
// }