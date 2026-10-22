import 'package:flutter/material.dart';

import '../core/theme/app_tokens.dart';
import '../data/models/work_listing.dart';
import '../data/models/worker_profile.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/post_work/presentation/post_work_screen.dart';
import '../features/saved_work/presentation/saved_work_screen.dart';
import '../features/shell/presentation/main_shell.dart';
import '../features/work_details/presentation/work_details_screen.dart';
import '../features/worker_profile/presentation/worker_profile_screen.dart';

/// Central route table and typed navigation helpers.
abstract final class AppRoutes {
  static const welcome = '/';
  static const shell = '/app';
  static const workDetails = '/work';
  static const workerProfile = '/worker';
  static const myProfile = '/me';
  static const postWork = '/post';
  static const savedWork = '/saved';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    return switch (settings.name) {
      welcome => _FadeThroughRoute(settings: settings, child: const WelcomeScreen()),
      shell => _FadeThroughRoute(settings: settings, child: const MainShell()),
      workDetails when args is WorkListing => _SlideRoute(
        settings: settings,
        child: WorkDetailsScreen(listing: args),
      ),
      workerProfile when args is WorkerProfile => _SlideRoute(
        settings: settings,
        child: WorkerProfileScreen(worker: args),
      ),
      myProfile => _SlideRoute(settings: settings, child: const WorkerProfileScreen.own()),
      postWork => _SlideRoute(settings: settings, vertical: true, child: const PostWorkScreen()),
      savedWork => _SlideRoute(settings: settings, child: const SavedWorkScreen()),
      _ => null,
    };
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) =>
      _FadeThroughRoute(settings: settings, child: const WelcomeScreen());
}

/// Typed navigation entry points so screens never build route names by hand.
abstract final class AppNavigator {
  static Future<void> openWork(BuildContext context, WorkListing listing) =>
      Navigator.of(context).pushNamed(AppRoutes.workDetails, arguments: listing);

  static Future<void> openWorker(BuildContext context, WorkerProfile worker) =>
      Navigator.of(context).pushNamed(AppRoutes.workerProfile, arguments: worker);

  static Future<void> openMyProfile(BuildContext context) =>
      Navigator.of(context).pushNamed(AppRoutes.myProfile);

  static Future<void> openPostWork(BuildContext context) =>
      Navigator.of(context).pushNamed(AppRoutes.postWork);

  static Future<void> openSaved(BuildContext context) => Navigator.of(context).pushNamed(AppRoutes.savedWork);

  static void enterApp(BuildContext context) =>
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false);

  static void signOut(BuildContext context) =>
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);

  /// Returns to the main shell from any pushed page.
  static void backToShell(BuildContext context) =>
      Navigator.of(context).popUntil((r) => r.settings.name == AppRoutes.shell || r.isFirst);
}

bool _reducedMotion(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// How a page reacts while another page is pushed on top of it: it eases
/// back, dims slightly and drifts left, so the new page feels layered above.
Widget _coveredTransition(Animation<double> secondary, Widget child) {
  final curved = CurvedAnimation(
    parent: secondary,
    curve: AppMotion.emphasized,
    reverseCurve: AppMotion.emphasizedAccelerate,
  );
  return AnimatedBuilder(
    animation: curved,
    child: child,
    builder: (context, child) {
      final t = curved.value;
      return Transform.translate(
        offset: Offset(-36 * t, 0),
        child: Transform.scale(
          scale: 1 - 0.04 * t,
          child: Opacity(opacity: 1 - 0.25 * t, child: child),
        ),
      );
    },
  );
}

/// Detail pages slide in from the right; Post Work rises from the bottom.
class _SlideRoute<T> extends PageRouteBuilder<T> {
  _SlideRoute({required RouteSettings settings, required Widget child, bool vertical = false})
    : super(
        settings: settings,
        fullscreenDialog: vertical,
        transitionDuration: AppMotion.page,
        reverseTransitionDuration: AppMotion.pageReverse,
        pageBuilder: (_, _, _) => child,
        transitionsBuilder: (context, animation, secondary, page) {
          if (_reducedMotion(context)) return page;
          final slide = CurvedAnimation(
            parent: animation,
            curve: AppMotion.emphasized,
            reverseCurve: AppMotion.emphasizedAccelerate,
          );
          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0, 0.5, curve: Curves.easeOut),
            reverseCurve: const Interval(0.3, 1, curve: Curves.easeIn),
          );
          final begin = vertical ? const Offset(0, 0.35) : const Offset(0.3, 0);
          return _coveredTransition(
            secondary,
            FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: Tween(begin: begin, end: Offset.zero).animate(slide),
                child: page,
              ),
            ),
          );
        },
      );
}

/// Top-level transitions between onboarding and the app: fade through with
/// a gentle zoom.
class _FadeThroughRoute<T> extends PageRouteBuilder<T> {
  _FadeThroughRoute({required RouteSettings settings, required Widget child})
    : super(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: AppMotion.pageReverse,
        pageBuilder: (_, _, _) => child,
        transitionsBuilder: (context, animation, secondary, page) {
          if (_reducedMotion(context)) return page;
          final curved = CurvedAnimation(parent: animation, curve: AppMotion.emphasized);
          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.15, 0.7, curve: Curves.easeOut),
          );
          return _coveredTransition(
            secondary,
            FadeTransition(
              opacity: fade,
              child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(curved), child: page),
            ),
          );
        },
      );
}
