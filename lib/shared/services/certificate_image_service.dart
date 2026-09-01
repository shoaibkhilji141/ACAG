import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CertificateImageService {
  CertificateImageService._();

  static Future<Uint8List> captureWidget(
    GlobalKey key, {
    double pixelRatio = 3.0,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 32));

    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Certificate preview is not ready yet.');
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Could not create certificate image.');
    }

    return byteData.buffer.asUint8List();
  }

  static Future<File> _writeTempPng(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final safeName = fileName.replaceAll(RegExp(r'[^\w\-.]'), '_');
    final file = File('${dir.path}/$safeName.png');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> shareImage({
    required GlobalKey key,
    required String fileName,
    String? shareText,
  }) async {
    final bytes = await captureWidget(key);
    final file = await _writeTempPng(bytes, fileName);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png', name: '$fileName.png')],
      text: shareText,
      subject: fileName,
    );
  }

  static Future<void> downloadImage({
    required GlobalKey key,
    required String fileName,
  }) async {
    final bytes = await captureWidget(key);
    final file = await _writeTempPng(bytes, fileName);

    final hasAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAccess) {
      final granted = await Gal.requestAccess(toAlbum: true);
      if (!granted) {
        throw Exception('Photo library permission is required to save the certificate.');
      }
    }

    await Gal.putImage(file.path, album: 'ACAG Certificates');
  }
}
