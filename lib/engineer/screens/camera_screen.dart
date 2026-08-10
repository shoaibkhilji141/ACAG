import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
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
  late AnimationController _flashController;

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
    setState(() => _capturing = true);

    await _flashController.forward();
    await _flashController.reverse();
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() => _capturing = false);

    final project = projectFromRoute(context);
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
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gallery picker (mock)'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: _capture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _capturing
                                  ? AppColors.primaryContainer
                                  : Colors.white,
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
