import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../theme/app_theme.dart';
import 'project_details_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  bool _capturing = false;
  File? _capturedFile;
  late AnimationController _flashController;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_capturing) return;

    final project = projectFromRoute(context);

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _capturing = true;
      _capturedFile = File(picked.path);
    });

    await _flashController.forward();
    await _flashController.reverse();

    try {
      final base64 = await encodeFileToBase64(File(picked.path));
      await ProjectService.addProjectImageBase64(
        projectCodeOrId: project.id,
        imageBase64: base64,
        caption: 'Inspection photo',
      );
    } catch (_) {}

    if (!mounted) return;
    setState(() => _capturing = false);

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.engineerAi,
      arguments: project,
    );
  }

  Future<void> _pickGallery() async {
    final project = projectFromRoute(context);

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _capturing = true;
      _capturedFile = File(picked.path);
    });

    try {
      final base64 = await encodeFileToBase64(File(picked.path));
      await ProjectService.addProjectImageBase64(
        projectCodeOrId: project.id,
        imageBase64: base64,
        caption: 'Inspection photo',
      );
    } catch (_) {}

    if (!mounted) return;
    setState(() => _capturing = false);

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.engineerAi,
      arguments: project,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = projectFromRoute(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          project.title,
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_capturedFile != null)
            Image.file(_capturedFile!, fit: BoxFit.cover)
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.shade900,
                    Colors.black,
                    Colors.grey.shade800,
                  ],
                ),
              ),
            ),
          if (_capturedFile == null)
            CustomPaint(
              painter: _ViewfinderPainter(),
              size: Size.infinite,
            ),
          AnimatedBuilder(
            animation: _flashController,
            builder: (context, child) {
              return IgnorePointer(
                child: Container(
                  color: Colors.white.withValues(
                    alpha: _flashController.value * 0.6,
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                if (_capturing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Align the construction site within the frame',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CircleButton(
                        icon: Icons.photo_library_outlined,
                        onTap: _pickGallery,
                      ),
                      GestureDetector(
                        onTap: _capture,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _CircleButton(
                        icon: Icons.flip_camera_ios_outlined,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()..color = Colors.black.withValues(alpha: 0.45);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlay);

    final frameWidth = size.width * 0.85;
    final frameHeight = frameWidth * 0.75;
    final left = (size.width - frameWidth) / 2;
    final top = (size.height - frameHeight) / 2 - 40;
    final frameRect = Rect.fromLTWH(left, top, frameWidth, frameHeight);

    canvas.saveLayer(frameRect, Paint());
    canvas.drawRect(frameRect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    final border = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(12)),
      border,
    );

    const cornerLen = 24.0;
    final corner = Paint()
      ..color = AppColors.primaryFixed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(frameRect.left, frameRect.top + cornerLen),
      Offset(frameRect.left, frameRect.top),
      corner,
    );
    canvas.drawLine(
      Offset(frameRect.left, frameRect.top),
      Offset(frameRect.left + cornerLen, frameRect.top),
      corner,
    );
    canvas.drawLine(
      Offset(frameRect.right - cornerLen, frameRect.top),
      Offset(frameRect.right, frameRect.top),
      corner,
    );
    canvas.drawLine(
      Offset(frameRect.right, frameRect.top),
      Offset(frameRect.right, frameRect.top + cornerLen),
      corner,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
