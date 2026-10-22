import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/motion.dart';

/// One slot in the floating bar. [tab] is null for the central Post action.
class _Slot {
  const _Slot(this.tab, this.icon, this.selectedIcon, this.label);
  final AppTab? tab;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _slots = <_Slot>[
  _Slot(AppTab.home, Icons.home_outlined, Icons.home_rounded, 'Home'),
  _Slot(AppTab.findWork, Icons.work_outline_rounded, Icons.work_rounded, 'Find Work'),
  _Slot(null, Icons.add_rounded, Icons.add_rounded, 'Post work'),
  _Slot(AppTab.findWorkers, Icons.person_search_outlined, Icons.person_search_rounded, 'Find Workers'),
  _Slot(AppTab.account, Icons.account_circle_outlined, Icons.account_circle_rounded, 'Account'),
];

/// Bar geometry.
abstract final class _Geo {
  static const double barHeight = 64;
  static const double postSize = 60;

  /// Gap between the Post button and the notch edge.
  static const double notchMargin = 6;

  /// How far the Post button's centre sits below the bar's top edge.
  static const double postDrop = 6;

  /// Space above the bar taken by the raised Post button.
  static const double overhang = postSize / 2 - postDrop;

  static const double indicatorSize = 48;
}

/// Floating, fully rounded navigation bar. Icon-only tabs with a circular
/// selected highlight, and a raised Post button sitting in a curved notch cut
/// into the top of the bar. Use with `Scaffold(extendBody: true)`.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.current, required this.onSelect, required this.onPost});

  final AppTab current;
  final ValueChanged<AppTab> onSelect;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    final selectedSlot = _slots.indexWhere((s) => s.tab == current);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SizedBox(
              height: _Geo.overhang + _Geo.barHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final slotWidth = width / _slots.length;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Notched bar background.
                      const Positioned(
                        left: 0,
                        right: 0,
                        top: _Geo.overhang,
                        height: _Geo.barHeight,
                        child: CustomPaint(painter: _NotchedBarPainter()),
                      ),
                      // Selected circle.
                      Positioned(
                        left: 0,
                        right: 0,
                        top: _Geo.overhang,
                        height: _Geo.barHeight,
                        child: ClipPath(
                          clipper: const _NotchedBarClipper(),
                          child: _LiquidIndicator(slot: selectedSlot, slotWidth: slotWidth),
                        ),
                      ),
                      // Tab icons.
                      Positioned(
                        left: 0,
                        right: 0,
                        top: _Geo.overhang,
                        height: _Geo.barHeight,
                        child: Row(
                          children: [
                            for (var i = 0; i < _slots.length; i++)
                              SizedBox(
                                width: slotWidth,
                                child: _slots[i].tab == null
                                    ? const SizedBox.shrink()
                                    : _NavItem(
                                        slot: _slots[i],
                                        selected: i == selectedSlot,
                                        onTap: () => onSelect(_slots[i].tab ?? AppTab.home),
                                      ),
                              ),
                          ],
                        ),
                      ),
                      // Raised Post button sitting in the notch.
                      Positioned(
                        left: width / 2 - _Geo.postSize / 2,
                        top: 0,
                        child: _PostButton(onTap: onPost),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill outline with a smooth circular notch cut into the top centre.
Path _notchedBarShape(Size size) {
  final rect = Offset.zero & size;
  final pill = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2)));
  const radius = _Geo.postSize / 2 + _Geo.notchMargin;
  final guest = Rect.fromCircle(center: Offset(size.width / 2, _Geo.postDrop), radius: radius);
  final notched = const CircularNotchedRectangle().getOuterPath(rect, guest);
  return Path.combine(PathOperation.intersect, pill, notched);
}

/// Clips children (the moving highlight) to the notched bar outline.
class _NotchedBarClipper extends CustomClipper<Path> {
  const _NotchedBarClipper();

  @override
  Path getClip(Size size) => _notchedBarShape(size);

  @override
  bool shouldReclip(_NotchedBarClipper oldClipper) => false;
}

/// Paints the notched bar with a soft shadow.
class _NotchedBarPainter extends CustomPainter {
  const _NotchedBarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = _notchedBarShape(size);
    canvas.drawShadow(path.shift(const Offset(0, 3)), const Color(0xFF174D3B), 8, false);
    canvas.drawPath(path, Paint()..color = AppColors.forest);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.white.withValues(alpha: 0.08),
    );
  }

  @override
  bool shouldRepaint(_NotchedBarPainter oldDelegate) => false;
}

/// Circular highlight behind the selected tab. It glides between tabs,
/// stretching into a pill mid-flight and settling back into a circle with a
/// small overshoot.
class _LiquidIndicator extends StatefulWidget {
  const _LiquidIndicator({required this.slot, required this.slotWidth});

  final int slot;
  final double slotWidth;

  @override
  State<_LiquidIndicator> createState() => _LiquidIndicatorState();
}

class _LiquidIndicatorState extends State<_LiquidIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
    value: 1,
  );
  late double _from = widget.slot.toDouble();
  late double _to = widget.slot.toDouble();

  double get _position {
    final t = Curves.easeOutBack.transform(_controller.value);
    return _from + (_to - _from) * t;
  }

  @override
  void didUpdateWidget(_LiquidIndicator old) {
    super.didUpdateWidget(old);
    if (old.slot == widget.slot) return;
    _from = _position;
    _to = widget.slot.toDouble();
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
        const size = _Geo.indicatorSize;
        final travel = (_to - _from).abs().clamp(0.0, 4.0);
        final pulse = math.sin(math.pi * _controller.value);
        final width = size * (1 + 0.45 * travel * pulse);
        final height = size * (1 - 0.12 * pulse);
        final centre = widget.slotWidth * (_position + 0.5);
        final total = widget.slotWidth * _slots.length;
        final inset = (_Geo.barHeight - size) / 2;
        final left = (centre - width / 2).clamp(inset, total - inset);
        final right = (centre + width / 2).clamp(inset, total - inset);
        return Stack(
          children: [
            Positioned(
              left: left,
              top: (_Geo.barHeight - height) / 2,
              width: math.max(right - left, height),
              height: height,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadii.pillAll,
                  boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 3))],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.slot, required this.selected, required this.onTap});

  final _Slot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, const Duration(milliseconds: 380));
    return Tooltip(
      message: slot.label,
      child: Semantics(
        selected: selected,
        button: true,
        label: slot.label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 28,
          highlightColor: Colors.transparent,
          splashColor: AppColors.white.withValues(alpha: 0.14),
          child: Center(
            child: AnimatedScale(
              scale: selected ? 1.1 : 1,
              duration: duration,
              curve: Curves.easeOutBack,
              child: AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(scale: Tween(begin: 0.6, end: 1.0).animate(anim), child: child),
                ),
                child: Icon(
                  selected ? slot.selectedIcon : slot.icon,
                  key: ValueKey(selected),
                  color: selected ? AppColors.forest : AppColors.white.withValues(alpha: 0.8),
                  size: 25,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Raised circular Post Work action that sits in the bar's notch.
class _PostButton extends StatelessWidget {
  const _PostButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Post work',
      child: Semantics(
        button: true,
        label: 'Post work',
        excludeSemantics: true,
        child: PressScale(
          scale: 0.9,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x4D174D3B), blurRadius: 16, offset: Offset(0, 6))],
            ),
            child: Material(
              color: AppColors.amber,
              shape: const CircleBorder(side: BorderSide(color: AppColors.forest, width: 3)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: const SizedBox.square(
                  dimension: _Geo.postSize,
                  child: Icon(Icons.add_rounded, color: AppColors.forestDark, size: 32),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
