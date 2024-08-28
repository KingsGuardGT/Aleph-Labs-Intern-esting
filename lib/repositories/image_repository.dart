import 'package:my_project/models/image_model.dart';



class ImageRepository {
  List<ImageModel> fetchImages() {
    return [
      const ImageModel(path: 'lib/images/image1.jpg', description: 'Image 1'),
      const ImageModel(path: 'lib/images/image2.jpg', description: 'Image 2'),
      const ImageModel(path: 'lib/images/image3.jpg', description: 'Image 3'),
      const ImageModel(path: 'lib/images/image4.jpg', description: 'Image 4'),
      const ImageModel(path: 'lib/images/image5.jpg', description: 'Image 5'),
      const ImageModel(path: 'lib/images/image6.jpg', description: 'Image 6'),
      const ImageModel(path: 'lib/images/image7.jpg', description: 'Image 7'),
      const ImageModel(path: 'lib/images/image8.jpg', description: 'Image 8'),
      const ImageModel(path: 'lib/images/image9.jpg', description: 'Image 9'),
      const ImageModel(path: 'lib/images/image10.jpg', description: 'Image 10'),
    ];
  }
}