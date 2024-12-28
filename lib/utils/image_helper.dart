import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class ImageHelper {
  static Future<File?> pickAndCropImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? quality,
    CropAspectRatio? aspectRatio,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );

      if (pickedFile == null) return null;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: aspectRatio,
        compressQuality: quality ?? 100,
        maxWidth: maxWidth?.toInt(),
        maxHeight: maxHeight?.toInt(),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪图片',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: aspectRatio != null,
          ),
          IOSUiSettings(
            title: '裁剪图片',
            aspectRatioLockEnabled: aspectRatio != null,
          ),
        ],
      );

      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      print('Image pick and crop error: $e');
      return null;
    }
  }
} 