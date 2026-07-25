import 'package:flutter/material.dart';

/// A faint decorative mihrab-arch outline, echoing the pointed arch shape
/// in the app icon. Used as a subtle watermark behind key screens so the
/// icon's visual language carries through into the app itself, instead of
/// the icon being disconnected from a generic-looking UI.
class ArchMotif extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const ArchMotif({
    super.key,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(width, height),
        painter: _ArchPainter(color: color),
      ),
    );
  }
}

class _ArchPainter extends CustomPainter {
  final Color color;
  _ArchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final path = Path();

    path.moveTo(w * 0.08, h);
    path.lineTo(w * 0.08, h * 0.55);
    path.cubicTo(
      w * 0.08, h * 0.22,
      w * 0.30, h * 0.02,
      w * 0.5, h * 0.0,
    );
    path.cubicTo(
      w * 0.70, h * 0.02,
      w * 0.92, h * 0.22,
      w * 0.92, h * 0.55,
    );
    path.lineTo(w * 0.92, h);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArchPainter oldDelegate) =>
      oldDelegate.color != color;
}
