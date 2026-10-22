import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_state.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/status_badges.dart';
import '../widgets/craft_illustration.dart';

/// First screen: introduces KoshurWorks and lets the user pick a path.
/// No registration happens here.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _enter(BuildContext context, UserRole role) {
    final state = AppScope.read(context);
    state.role = role;
    if (role == UserRole.worker) {
      state.openFindWork();
    } else {
      state.selectTab(AppTab.home);
    }
    AppNavigator.enterApp(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - AppSpacing.xxl),
                child: ContentWidth(
                  maxWidth: 520,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FadeSlideIn(
                        child: Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(fit: BoxFit.scaleDown, child: BrandLockup(markSize: 34)),
                              ),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            SampleDataTag(label: 'Prototype'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const FadeSlideIn(delay: Duration(milliseconds: 120), child: CraftIllustration()),
                      const SizedBox(height: AppSpacing.xl),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 220),
                        child: Text.rich(
                          TextSpan(
                            text: 'Local work.\n',
                            children: const [
                              TextSpan(
                                text: 'Skilled hands.',
                                style: TextStyle(color: AppColors.forest),
                              ),
                            ],
                          ),
                          style: theme.displaySmall,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 300),
                        child: Text(
                          'Find daily-wage and project work near you, or hire masons, '
                          'carpenters, electricians and more across Jammu & Kashmir.',
                          style: theme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 380),
                        child: Column(
                          children: [
                            AppButton(
                              label: 'Find Work',
                              icon: Icons.work_outline_rounded,
                              expand: true,
                              onPressed: () => _enter(context, UserRole.worker),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppButton.secondary(
                              label: 'Hire Workers',
                              icon: Icons.person_search_outlined,
                              expand: true,
                              onPressed: () => _enter(context, UserRole.hirer),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: Text('Preview build · No account or sign-up needed', style: theme.bodySmall),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
