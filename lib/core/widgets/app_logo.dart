import 'package:flutter/material.dart';

class AppLogoIconPainter extends CustomPainter {
  final Color color;
  const AppLogoIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 24.0;
    final scaleY = size.height / 24.0;

    final path = Path()..fillType = PathFillType.evenOdd;

    // Outer rounded rectangle (matching web AppLogoIcon: x:3..21, y:3..21, r:4.5)
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(3.0 * scaleX, 3.0 * scaleY, 21.0 * scaleX, 21.0 * scaleY),
      Radius.circular(4.5 * scaleX),
    );
    path.addRRect(outerRect);

    // Inner checkmark cutout path
    final checkPath = Path();
    checkPath.moveTo(6.0 * scaleX, 12.0 * scaleY);
    checkPath.lineTo(7.4 * scaleX, 10.6 * scaleY);
    checkPath.lineTo(10.5 * scaleX, 13.7 * scaleY);
    checkPath.lineTo(16.6 * scaleX, 7.6 * scaleY);
    checkPath.lineTo(18.0 * scaleX, 9.0 * scaleY);
    checkPath.lineTo(10.5 * scaleX, 16.5 * scaleY);
    checkPath.close();

    path.addPath(checkPath, Offset.zero);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AppLogoIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class AppLogoIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogoIcon({super.key, this.size = 32.0, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return CustomPaint(
      size: Size(size, size),
      painter: AppLogoIconPainter(color: effectiveColor),
    );
  }
}

class AppLogo extends StatelessWidget {
  final double iconSize;
  final bool showText;
  final String title;

  const AppLogo({
    super.key,
    double? size,
    double? iconSize,
    this.showText = true,
    this.title = 'Track',
  }) : iconSize = size ?? iconSize ?? 32.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconSize + 10,
          height: iconSize + 10,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: AppLogoIcon(
            size: iconSize,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ],
    );
  }
}
