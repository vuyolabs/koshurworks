import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Cross-fades (with a slight rise) whenever [switchKey] changes, for example
/// from a loading skeleton to results, or between filtered result sets.
class CrossFadeSwitch extends StatelessWidget {
  const CrossFadeSwitch({super.key, required this.switchKey, required this.child});

  final Object switchKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.of(context, const Duration(milliseconds: 380)),
      reverseDuration: AppMotion.of(context, const Duration(milliseconds: 200)),
      switchInCurve: AppMotion.emphasized,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(switchKey), child: child),
    );
  }
}
