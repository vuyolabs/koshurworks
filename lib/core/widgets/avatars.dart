import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

/// Initials avatar placeholder with a stable tone per name.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.name, this.size = 48, this.ring = false});

  final String name;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final tones = AppColors.avatarTones;
    final tone = tones[name.codeUnits.fold<int>(0, (a, b) => a + b) % tones.length];
    return Semantics(
      label: 'Avatar for $name',
      image: true,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tone,
          shape: BoxShape.circle,
          border: ring ? Border.all(color: AppColors.white, width: 3) : null,
        ),
        child: Text(
          Formatters.initials(name),
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            color: AppColors.forestDark,
          ),
        ),
      ),
    );
  }
}

/// Tasteful placeholder for photos that do not exist in the prototype.
class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({
    super.key,
    this.label,
    this.icon = Icons.image_outlined,
    this.tone = AppColors.sage,
    this.borderRadius = AppRadii.mdAll,
  });

  final String? label;
  final IconData icon;
  final Color tone;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label == null ? 'Image placeholder' : 'Placeholder image: $label',
      image: true,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tone, Color.lerp(tone, AppColors.white, 0.55) ?? tone],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _LatticePainter(Color.lerp(tone, AppColors.forest, 0.12) ?? tone)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.forest.withValues(alpha: 0.55), size: 26),
                  if (label != null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        label!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AppColors.forestDark.withValues(alpha: 0.75)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Faint diagonal lattice inspired by Kashmiri woodwork.
class _LatticePainter extends CustomPainter {
  _LatticePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 18.0;
    for (var x = -size.height; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
      canvas.drawLine(Offset(x + size.height, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_LatticePainter old) => old.color != color;
}
