import 'package:flutter/material.dart';

import '../utils/image_base64.dart';
import '../../theme/app_theme.dart';

Future<void> showBase64ImagePreview(
  BuildContext context, {
  required String? imageBase64,
  String? caption,
}) {
  final bytes = decodeBase64Image(imageBase64);

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          if (bytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: AppColors.outline,
              ),
            ),
          if (caption != null && caption.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ],
      ),
    ),
  );
}
