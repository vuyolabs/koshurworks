import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

/// Keeps every tab alive (like an IndexedStack) but animates between them:
/// the outgoing tab slides away and fades while the incoming tab slides in
/// from the direction of travel, so switching tabs feels like changing screens.
class TabSwitcher extends StatefulWidget {
  const TabSwitcher({super.key, required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<TabSwitcher> createState() => _TabSwitcherState();
}

class _TabSwitcherState extends State<TabSwitcher> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
    value: 1,
  );
  late final Animation<double> _curve = CurvedAnimation(parent: _controller, curve: AppMotion.emphasized);
  int? _previous;

  /// +1 when moving to a tab on the right, -1 when moving left.
  double _direction = 1;

  @override
  void didUpdateWidget(TabSwitcher old) {
    super.didUpdateWidget(old);
    if (old.index == widget.index) return;
    _previous = old.index;
    _direction = widget.index > old.index ? 1 : -1;
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _curve.value;
        final animating = _controller.isAnimating;
        final width = MediaQuery.sizeOf(context).width;
        return Stack(
          fit: StackFit.expand,
          children: [for (var i = 0; i < widget.children.length; i++) _buildTab(i, t, animating, width)],
        );
      },
    );
  }

  /// Every tab always gets the same wrapper structure so its state is kept;
  /// only the wrapper's values change.
  Widget _buildTab(int i, double t, bool animating, double width) {
    final isCurrent = i == widget.index;
    final isOutgoing = animating && i == _previous;
    final visible = isCurrent || isOutgoing;

    double opacity = 1;
    double dx = 0;
    double scale = 1;
    if (isCurrent && animating) {
      opacity = Curves.easeOut.transform(t);
      dx = _direction * width * 0.18 * (1 - t);
    } else if (isOutgoing) {
      opacity = 1 - Curves.easeIn.transform((t * 1.6).clamp(0.0, 1.0));
      dx = -_direction * width * 0.12 * t;
      scale = 1 - 0.03 * t;
    }

    return Offstage(
      offstage: !visible,
      child: TickerMode(
        enabled: visible,
        child: IgnorePointer(
          ignoring: !isCurrent,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: Transform.scale(scale: scale, child: widget.children[i]),
            ),
          ),
        ),
      ),
    );
  }
}
