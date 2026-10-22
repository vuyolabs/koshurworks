import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Temporary KoshurWorks brand placeholder.
///
/// This is intentionally NOT a final logo. Replace the body of [BrandMark]
/// with the official logo asset once it is approved; every screen uses this
/// widget, so the swap happens in one place.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40, this.inverted = false});

  final double size;

  /// Light mark on dark backgrounds.
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final bg = inverted ? AppColors.offWhite : AppColors.forest;
    final fg = inverted ? AppColors.forest : AppColors.offWhite;
    return Semantics(
      label: 'KoshurWorks',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.28)),
        child: CustomPaint(
          painter: _MonogramPainter(fg: fg, accent: AppColors.amber),
        ),
      ),
    );
  }
}

/// Simple geometric "K" placeholder with an amber accent.
class _MonogramPainter extends CustomPainter {
  _MonogramPainter({required this.fg, required this.accent});

  final Color fg;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = Paint()
      ..color = fg
      ..strokeWidth = s * 0.11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final left = s * 0.32;
    final top = s * 0.26;
    final bottom = s * 0.74;
    final mid = s * 0.5;
    final right = s * 0.70;

    canvas.drawLine(Offset(left, top), Offset(left, bottom), stroke);
    canvas.drawLine(Offset(left + s * 0.04, mid), Offset(right, top), stroke);
    canvas.drawLine(Offset(left + s * 0.04, mid), Offset(right, bottom), stroke);

    final dot = Paint()..color = accent;
    final r = s * 0.075;
    final c = Offset(right + s * 0.02, mid);
    final diamond = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r, c.dy)
      ..close();
    canvas.drawPath(diamond, dot);
  }

  @override
  bool shouldRepaint(_MonogramPainter old) => old.fg != fg || old.accent != accent;
}

/// Mark plus wordmark.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.markSize = 36, this.inverted = false});

  final double markSize;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: markSize * 0.56,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
      color: inverted ? AppColors.offWhite : AppColors.forest,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: markSize, inverted: inverted),
        SizedBox(width: markSize * 0.3),
        ExcludeSemantics(
          child: Text.rich(
            TextSpan(
              text: 'Koshur',
              children: [
                TextSpan(
                  text: 'Works',
                  style: TextStyle(color: inverted ? AppColors.amber : AppColors.forestSoft),
                ),
              ],
            ),
            style: style,
          ),
        ),
      ],
    );
  }
}
