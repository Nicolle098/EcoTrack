import 'dart:async';
import 'dart:html' as html;

class ImagePickerService {
  Future<html.File?> pickImage() async {
    final completer = Completer<html.File?>();
    final input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();
    input.onChange.listen((e) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        completer.complete(files.first);
      } else {
        completer.complete(null);
      }
    });
    return completer.future;
  }
}