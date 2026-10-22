import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/motion.dart';

/// UI-composed illustration: a Kashmir valley landscape with floating trade
/// cards. Built from shapes so no image asset is required.
class CraftIllustration extends StatelessWidget {
  const CraftIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Illustration of mountains with cards for masons, carpenters and electricians',
      image: true,
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 1.08,
        child: ClipRRect(
          borderRadius: AppRadii.xlAll,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE9EFE6), Color(0xFFF7F1E3)],
                  ),
                ),
              ),
              const CustomPaint(painter: _ValleyPainter()),
              const Positioned(
                left: 18,
                top: 22,
                child: FadeSlideIn(
                  delay: Duration(milliseconds: 350),
                  child: _TradeCard(icon: Icons.foundation, title: 'Mason', subtitle: '3 needed · Budgam'),
                ),
              ),
              const Positioned(
                right: 16,
                top: 92,
                child: FadeSlideIn(
                  delay: Duration(milliseconds: 500),
                  child: _TradeCard(
                    icon: Icons.carpenter,
                    title: 'Carpenter',
                    subtitle: 'Available now',
                    dotColor: AppColors.success,
                  ),
                ),
              ),
              const Positioned(
                left: 34,
                bottom: 30,
                child: FadeSlideIn(
                  delay: Duration(milliseconds: 650),
                  child: _TradeCard(
                    icon: Icons.electrical_services,
                    title: 'Electrician',
                    subtitle: '₹800 / day',
                    accent: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TradeCard extends StatelessWidget {
  const _TradeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.dotColor,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? dotColor;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.mdAll,
        boxShadow: AppShadows.raised,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent ? AppColors.amberSoft : AppColors.sage,
              borderRadius: AppRadii.smAll,
            ),
            child: Icon(icon, size: 20, color: accent ? AppColors.amberDark : AppColors.forest),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.labelLarge),
              Row(
                children: [
                  if (dotColor != null) ...[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(subtitle, style: theme.bodySmall),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Layered mountains, a low sun and a chinar-leaf accent.
class _ValleyPainter extends CustomPainter {
  const _ValleyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawCircle(
      Offset(w * 0.74, h * 0.30),
      w * 0.10,
      Paint()..color = AppColors.amber.withValues(alpha: 0.55),
    );

    Path ridge(List<Offset> points) {
      final path = Path()..moveTo(0, h);
      for (final p in points) {
        path.lineTo(p.dx * w, p.dy * h);
      }
      return path
        ..lineTo(w, h)
        ..close();
    }

    // Far range with snow caps.
    final far = ridge(const [
      Offset(0, 0.62),
      Offset(0.16, 0.46),
      Offset(0.28, 0.54),
      Offset(0.45, 0.36),
      Offset(0.6, 0.5),
      Offset(0.78, 0.4),
      Offset(1, 0.56),
    ]);
    canvas.drawPath(far, Paint()..color = const Color(0xFFBFD3C6));

    final snow = Paint()..color = AppColors.white.withValues(alpha: 0.85);
    canvas.drawPath(
      Path()
        ..moveTo(0.40 * w, 0.405 * h)
        ..lineTo(0.45 * w, 0.36 * h)
        ..lineTo(0.505 * w, 0.42 * h)
        ..lineTo(0.47 * w, 0.40 * h)
        ..lineTo(0.44 * w, 0.43 * h)
        ..close(),
      snow,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0.735 * w, 0.43 * h)
        ..lineTo(0.78 * w, 0.40 * h)
        ..lineTo(0.83 * w, 0.44 * h)
        ..lineTo(0.79 * w, 0.43 * h)
        ..close(),
      snow,
    );

    final mid = ridge(const [
      Offset(0, 0.72),
      Offset(0.2, 0.6),
      Offset(0.38, 0.7),
      Offset(0.58, 0.58),
      Offset(0.8, 0.7),
      Offset(1, 0.62),
    ]);
    canvas.drawPath(mid, Paint()..color = AppColors.forestSoft.withValues(alpha: 0.85));

    final near = ridge(const [Offset(0, 0.84), Offset(0.3, 0.76), Offset(0.62, 0.86), Offset(1, 0.78)]);
    canvas.drawPath(near, Paint()..color = AppColors.forest);

    // Lake reflection line.
    final lake = Paint()
      ..color = AppColors.white.withValues(alpha: 0.18)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.55, h * 0.93), Offset(w * 0.86, h * 0.93), lake);
    canvas.drawLine(Offset(w * 0.62, h * 0.96), Offset(w * 0.80, h * 0.96), lake);
  }

  @override
  bool shouldRepaint(_ValleyPainter oldDelegate) => false;
}
