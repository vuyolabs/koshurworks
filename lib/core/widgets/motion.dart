import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Tells [FadeSlideIn] descendants whether their tab is visible and how many
/// times it has been opened, so entrance animations replay on each visit
/// instead of running unseen in background tabs.
class TabVisitScope extends InheritedWidget {
  const TabVisitScope({super.key, required this.active, required this.visit, required super.child});

  final bool active;
  final int visit;

  static TabVisitScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabVisitScope>();

  @override
  bool updateShouldNotify(TabVisitScope old) => old.active != active || old.visit != visit;
}

/// Fades its child in while sliding it by [offset] logical pixels, after an
/// optional [delay]. Replays when the enclosing [TabVisitScope] is revisited.
/// Shows the child immediately when reduced motion is requested.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 28),
    this.duration = const Duration(milliseconds: 520),
  });

  final Widget child;
  final Duration delay;

  /// Starting offset in logical pixels.
  final Offset offset;
  final Duration duration;

  /// Convenience for staggering items in a list.
  /// Items past [maxSteps] (usually built later while scrolling) animate
  /// immediately so they never lag behind the user's finger.
  static Duration stagger(int index, {int stepMs = 70, int maxSteps = 6}) =>
      index > maxSteps ? Duration.zero : Duration(milliseconds: stepMs * index);

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  Timer? _timer;
  int? _playedVisit;
  bool _playedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = TabVisitScope.maybeOf(context);
    if (AppMotion.reduced(context)) {
      _timer?.cancel();
      _controller.value = 1;
      return;
    }
    if (scope == null) {
      if (!_playedOnce) _play();
      return;
    }
    if (!scope.active) return; // Wait until the tab is on screen.
    if (_playedVisit != scope.visit) {
      _playedVisit = scope.visit;
      _play();
    }
  }

  void _play() {
    _playedOnce = true;
    _timer?.cancel();
    _controller.value = 0;
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) {
        final t = _curve.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: widget.offset * (1 - t), child: child),
        );
      },
    );
  }
}

/// Scales its child down slightly while pressed, for tactile feedback.
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.enabled = true, this.scale = 0.97});

  final Widget child;
  final bool enabled;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: AppMotion.of(context, AppMotion.fast),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A bookmark toggle with a springy icon swap.
class AnimatedBookmarkButton extends StatelessWidget {
  const AnimatedBookmarkButton({
    super.key,
    required this.isSaved,
    required this.onPressed,
    this.size = 22,
    this.color,
    this.background,
  });

  final bool isSaved;
  final VoidCallback onPressed;
  final double size;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);
    return Semantics(
      button: true,
      toggled: isSaved,
      label: isSaved ? 'Remove from saved' : 'Save',
      excludeSemantics: true,
      child: Material(
        color: background ?? Colors.transparent,
        shape: const CircleBorder(),
        child: InkResponse(
          onTap: onPressed,
          radius: 24,
          child: SizedBox.square(
            dimension: 44,
            child: Center(
              child: AnimatedSwitcher(
                duration: duration,
                switchInCurve: Curves.elasticOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  key: ValueKey(isSaved),
                  size: size,
                  color: isSaved ? AppColors.amber : (color ?? AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gently pulsing placeholder block used for skeleton loading.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = AppRadii.sm});

  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_controller),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.neutralSoft,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
