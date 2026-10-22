import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'motion.dart';

/// Horizontally scrolling row of equal-height cards.
///
/// Height comes from the tallest card, so content never clips at larger
/// text sizes. Meant for short lists (under ~10 items).
class CardCarousel extends StatelessWidget {
  const CardCarousel({super.key, required this.itemWidth, required this.children, this.animate = true});

  final double itemWidth;
  final List<Widget> children;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.screenPadding,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: itemWidth,
                child: animate
                    ? FadeSlideIn(
                        delay: FadeSlideIn.stagger(i),
                        offset: const Offset(40, 0),
                        child: children[i],
                      )
                    : children[i],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
