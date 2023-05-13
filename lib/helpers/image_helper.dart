import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:product_manager/helpers/file_helper.dart';

class ImageHelper with FileHelper {
  final ImagePicker _imagePicker;
  final ImageCropper _imageCropper;
  ImageHelper({ImagePicker? imagePicker, ImageCropper? imageCropper})
      : _imagePicker = imagePicker ?? ImagePicker(),
        _imageCropper = imageCropper ?? ImageCropper();

  Future<XFile?> pick({
    ImageSource source = ImageSource.gallery,
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 100,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) =>
      _imagePicker.pickImage(
          source: source,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          imageQuality: imageQuality,
          preferredCameraDevice: preferredCameraDevice,
          requestFullMetadata: requestFullMetadata);

  Future<List<XFile?>> pickMultiple({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 100,
    bool requestFullMetadata = true,
  }) =>
      _imagePicker.pickMultiImage(
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          imageQuality: imageQuality,
          requestFullMetadata: requestFullMetadata);

  Future<CroppedFile?> crop(
    XFile file, {
    int? maxWidth,
    int? maxHeight,
    CropAspectRatio? aspectRatio,
    List<CropAspectRatioPreset> aspectRatioPresets = const [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ],
    CropStyle cropStyle = CropStyle.rectangle,
    ImageCompressFormat compressFormat = ImageCompressFormat.jpg,
    int compressQuality = 90,
    List<PlatformUiSettings>? uiSettings,
  }) =>
      _imageCropper.cropImage(
          sourcePath: file.path,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          aspectRatio: aspectRatio,
          aspectRatioPresets: aspectRatioPresets,
          cropStyle: cropStyle,
          compressFormat: compressFormat,
          compressQuality: compressQuality,
          uiSettings: uiSettings);

  Future<XFile?> compress(
    String path,
    String targetPath, {
    int minWidth = 1920,
    int minHeight = 1080,
    int inSampleSize = 1,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) =>
      FlutterImageCompress.compressAndGetFile(path, targetPath,
          minWidth: minWidth,
          minHeight: minHeight,
          inSampleSize: inSampleSize,
          quality: quality,
          rotate: rotate,
          autoCorrectionAngle: autoCorrectionAngle,
          format: format,
          keepExif: keepExif,
          numberOfRetries: numberOfRetries);
}
