import 'package:image_picker/image_picker.dart';

class ImagePicker2 {
  final ImagePicker picker = ImagePicker();

  //get Image From Gallery

  Future<XFile?> getImageFromGallery() async {
    return await picker.pickImage(source: ImageSource.gallery);
  }

  Future<XFile?> getImageFromCamera() async {
    return await picker.pickImage(source: ImageSource.camera);
  }
}
