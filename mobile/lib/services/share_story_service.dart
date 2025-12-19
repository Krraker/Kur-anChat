import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class ShareStoryService {
  ShareStoryService._();

  /// Story dimensions (Instagram story size)
  static const double storyWidth = 1080;
  static const double storyHeight = 1920;

  /// Available background images
  static const List<String> backgrounds = [
    'assets/share_backgrounds/View1.jpg',
    'assets/share_backgrounds/View2.jpg',
    'assets/share_backgrounds/View3.jpg',
    'assets/share_backgrounds/View4.jpg',
    'assets/share_backgrounds/View5.jpg',
    'assets/share_backgrounds/View6.jpg',
    'assets/share_backgrounds/View7.jpg',
    'assets/share_backgrounds/View8.jpg',
  ];

  /// Capture widget to image bytes
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  /// Save image to gallery
  static Future<bool> saveToGallery(Uint8List imageBytes) async {
    try {
      // Request permission
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        // Try storage permission for older Android
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          return false;
        }
      }

      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: 'kuran_chat_${DateTime.now().millisecondsSinceEpoch}',
      );

      return result['isSuccess'] == true;
    } catch (e) {
      debugPrint('Error saving to gallery: $e');
      return false;
    }
  }

  /// Share image to Instagram Stories or other apps
  static Future<void> shareImage(Uint8List imageBytes, {bool toInstagram = false}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/kuran_story_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Kur\'an Chat ile paylaşıldı 🕌',
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }
}





