import 'package:flutter/material.dart';

import '../../../app/app_state.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/avatars.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/pressable_card.dart';
import '../../../core/widgets/sheets.dart';
import '../../../core/widgets/status_badges.dart';
import '../../work_details/widgets/detail_widgets.dart';
import '../../work_discovery/widgets/work_listing_card.dart';
import '../widgets/settings_widgets.dart';

/// Profile summary, prototype role switch, preferences, help and about.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _pickDistrict(BuildContext context, AppState state) async {
    final picked = await showSelectionSheet<String>(
      context,
      title: 'Preferred location',
      options: state.workRepository.districts,
      labelOf: (d) => d,
      iconOf: (_) => Icons.place_outlined,
      selected: state.district,
    );
    if (picked != null) state.district = picked;
  }

  void _showPosts(BuildContext context, AppState state) {
    final posts = state.postedThisSession;
    showInfoSheet(
      context,
      title: 'Your prototype posts',
      icon: Icons.post_add_rounded,
      children: [
        if (posts.isEmpty)
          Text(
            'You have not created any drafts in this session.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          for (final p in posts) ...[
            WorkListingCard(
              listing: p,
              isSaved: state.isSaved(p.id),
              onSaveToggle: () => state.toggleSaved(p.id),
              onTap: () {
                Navigator.of(context).pop();
                AppNavigator.openWork(context, p);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Post work',
          icon: Icons.add_rounded,
          expand: true,
          onPressed: () {
            Navigator.of(context).pop();
            AppNavigator.openPostWork(context);
          },
        ),
      ],
    );
  }

  void _showSafety(BuildContext context) {
    showInfoSheet(
      context,
      title: 'Safety tips',
      icon: Icons.shield_outlined,
      children: const [
        StepRow(number: 1, text: 'Never pay a fee to get work or to book a worker.'),
        StepRow(number: 2, text: 'Agree on the rate, timing and scope before work starts.'),
        StepRow(number: 3, text: 'Meet at the work site in daylight for first visits.'),
        StepRow(number: 4, text: 'Use proper safety gear when working at height or with electricity.'),
        StepRow(number: 5, text: 'Do not share bank PINs, OTPs or ID photos in chat.'),
      ],
    );
  }

  void _showHelp(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    Widget qa(String q, String a) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: theme.titleSmall),
          const SizedBox(height: 2),
          Text(a, style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
    showInfoSheet(
      context,
      title: 'Help centre',
      icon: Icons.help_outline_rounded,
      children: [
        qa('How do I find work?', 'Open Find Work, choose your trade and district, then tap a listing.'),
        qa(
          'How do I hire someone?',
          'Post your requirement or browse Find Workers and contact a professional.',
        ),
        qa(
          'What does "Verified (demo)" mean?',
          'In this prototype it is sample data only. No identity checks have been carried out.',
        ),
        const PrototypeNote(text: 'Support chat is not available in this prototype.'),
      ],
    );
  }

  void _showAbout(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    showInfoSheet(
      context,
      title: 'About KoshurWorks',
      icon: Icons.info_outline_rounded,
      children: [
        const BrandLockup(markSize: 40),
        const SizedBox(height: AppSpacing.md),
        Text(
          'KoshurWorks is a local work-discovery and skilled-trades marketplace, starting in '
          'Jammu & Kashmir. It helps masons, carpenters, electricians, plumbers, painters and '
          'labourers find work, and helps households, contractors and businesses find them.',
          style: theme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        const PrototypeNote(
          text:
              'This is a UI prototype. There is no backend, no real accounts, and all '
              'people, listings and ratings are sample data.',
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Prototype version 0.1.0', style: theme.bodySmall),
      ],
    );
  }

  Future<void> _signOut(BuildContext context, AppState state) async {
    final confirmed = await showConfirmationSheet(
      context,
      title: 'Sign out?',
      message: 'This returns you to the welcome screen and clears saved items from this session.',
      confirmLabel: 'Sign out',
      icon: Icons.logout_rounded,
      destructive: true,
      footnote: 'There is no real account in this prototype.',
    );
    if (confirmed && context.mounted) {
      state.resetSession();
      AppNavigator.signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context).textTheme;
    final profile = state.profile;

    final sections = <Widget>[
      PressableCard(
        onTap: () => AppNavigator.openMyProfile(context),
        semanticLabel: 'View my profile',
        child: Row(
          children: [
            AppAvatar(name: profile.name, size: 60),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: theme.titleLarge),
                  Text(
                    '${profile.category.name} · ${profile.headline}',
                    style: theme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  AvailabilityIndicator(availability: profile.availability, pill: true),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
      _RoleSwitcher(role: state.role, onChanged: (r) => state.role = r),
      SettingsGroup(
        title: 'Your activity',
        children: [
          SettingsTile(
            icon: Icons.bookmark_border_rounded,
            title: 'Saved work',
            subtitle: '${state.savedIds.length} saved',
            onTap: () => AppNavigator.openSaved(context),
          ),
          SettingsTile(
            icon: Icons.handshake_outlined,
            title: 'Interest sent',
            subtitle: '${state.interestedCount} listings this session',
          ),
          SettingsTile(
            icon: Icons.post_add_rounded,
            title: 'Your posts',
            subtitle: '${state.postedThisSession.length} prototype drafts',
            onTap: () => _showPosts(context, state),
          ),
        ],
      ),
      SettingsGroup(
        title: 'Personal information',
        children: [
          SettingsTile(
            icon: Icons.badge_outlined,
            title: 'Name',
            subtitle: profile.name,
            onTap: () => AppNavigator.openMyProfile(context),
          ),
          const SettingsTile(
            icon: Icons.phone_outlined,
            title: 'Phone number',
            subtitle: 'Not added in prototype',
          ),
          SettingsTile(
            icon: Icons.translate_rounded,
            title: 'Languages',
            subtitle: profile.languages.join(', '),
          ),
          SettingsTile(
            icon: Icons.place_outlined,
            title: 'Preferred location',
            subtitle: '${state.district}, Jammu & Kashmir',
            onTap: () => _pickDistrict(context, state),
          ),
        ],
      ),
      SettingsGroup(
        title: 'Notifications',
        children: [
          for (final pref in NotificationPref.values)
            SettingsTile(
              icon: switch (pref) {
                NotificationPref.nearbyWork => Icons.near_me_outlined,
                NotificationPref.messages => Icons.chat_bubble_outline_rounded,
                NotificationPref.updates => Icons.update_rounded,
                NotificationPref.safetyTips => Icons.tips_and_updates_outlined,
              },
              title: pref.title,
              subtitle: pref.description,
              onTap: () => state.setNotification(pref, !state.notificationEnabled(pref)),
              trailing: Switch(
                value: state.notificationEnabled(pref),
                onChanged: (v) => state.setNotification(pref, v),
              ),
            ),
        ],
      ),
      SettingsGroup(
        title: 'Help and safety',
        children: [
          SettingsTile(
            icon: Icons.shield_outlined,
            title: 'Safety tips',
            subtitle: 'Work safely and avoid scams',
            onTap: () => _showSafety(context),
          ),
          SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help centre',
            onTap: () => _showHelp(context),
          ),
          SettingsTile(
            icon: Icons.flag_outlined,
            title: 'Report a problem',
            onTap: () => showAppSnack(context, 'Reporting is not connected in this prototype.'),
          ),
        ],
      ),
      SettingsGroup(
        title: 'About',
        children: [
          SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About KoshurWorks',
            subtitle: 'Prototype version 0.1.0',
            onTap: () => _showAbout(context),
          ),
        ],
      ),
      SettingsGroup(
        title: 'Session',
        children: [
          SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Sign out',
            subtitle: 'Placeholder, no real account',
            destructive: true,
            onTap: () => _signOut(context, state),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.screen,
        toolbarHeight: 72,
        title: const HeaderTitle(title: 'Account', subtitle: 'Profile, preferences and help'),
      ),
      body: SafeArea(
        bottom: false,
        child: ContentWidth(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              for (var i = 0; i < sections.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.lg),
                FadeSlideIn(delay: FadeSlideIn.stagger(i, stepMs: 40), child: sections[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleSwitcher extends StatelessWidget {
  const _RoleSwitcher({required this.role, required this.onChanged});

  final UserRole role;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(color: AppColors.sage, borderRadius: AppRadii.lgAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Using KoshurWorks as', style: theme.titleSmall)),
              const SampleDataTag(label: 'Prototype mode'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<UserRole>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: UserRole.worker,
                  icon: Icon(Icons.construction_rounded, size: 18),
                  label: Text('Worker'),
                ),
                ButtonSegment(
                  value: UserRole.hirer,
                  icon: Icon(Icons.home_work_outlined, size: 18),
                  label: Text('Hirer'),
                ),
              ],
              selected: {role},
              onSelectionChanged: (s) => onChanged(s.first),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.medium),
            child: Text(
              role == UserRole.worker
                  ? 'Home shows work near you first.'
                  : 'Home shows professionals and posting tools first.',
              key: ValueKey(role),
              style: theme.bodySmall?.copyWith(color: AppColors.forestDark),
            ),
          ),
        ],
      ),
    );
  }
}
