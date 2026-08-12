import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

Uint8List? decodeBase64Image(String? data) {
  if (data == null || data.trim().isEmpty) return null;
  try {
    final cleaned = data.contains(',') ? data.split(',').last : data;
    return base64Decode(cleaned);
  } catch (_) {
    return null;
  }
}

Future<String> encodeFileToBase64(File file, {String mime = 'image/jpeg'}) async {
  final bytes = await file.readAsBytes();
  return 'data:$mime;base64,${base64Encode(bytes)}';
}

String encodeBytesToBase64(Uint8List bytes, {String mime = 'image/jpeg'}) {
  return 'data:$mime;base64,${base64Encode(bytes)}';
}

ImageProvider? imageProviderFromBase64(String? data) {
  final bytes = decodeBase64Image(data);
  if (bytes == null) return null;
  return MemoryImage(bytes);
}

Widget base64Avatar({
  required String? base64,
  required double radius,
  required String fallbackInitials,
  Color? backgroundColor,
  TextStyle? textStyle,
}) {
  final provider = imageProviderFromBase64(base64);
  return CircleAvatar(
    radius: radius,
    backgroundColor: backgroundColor,
    backgroundImage: provider,
    child: provider == null
        ? Text(fallbackInitials, style: textStyle)
        : null,
  );
}
