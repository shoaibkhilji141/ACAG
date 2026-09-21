import 'package:flutter/material.dart';

class ZoomableImage extends StatelessWidget {
  const ZoomableImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  void _showZoomableDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      barrierDismissible: true,
      barrierLabel: 'Close',
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 1.0,
                  maxScale: 6.0,
                  child: imageUrl.startsWith('data:image/') ? Image.memory(Uri.parse(imageUrl).data!.contentAsBytes(), fit: BoxFit.contain, width: double.infinity, height: double.infinity) : Image.network(imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (c, child, p) => p == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showZoomableDialog(context),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          imageUrl.startsWith('data:image/') ? Image.memory(Uri.parse(imageUrl).data!.contentAsBytes(), fit: fit, width: width, height: height) : Image.network(imageUrl,
            fit: fit,
            width: width,
            height: height,
            loadingBuilder: (c, child, p) => p == null
                ? child
                : SizedBox(
                    height: height ?? 160,
                    width: width ?? double.infinity,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.zoom_out_map,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
