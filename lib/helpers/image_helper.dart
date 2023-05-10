import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
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

  Future<CroppedFile?> crop({
    required XFile file,
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
}
