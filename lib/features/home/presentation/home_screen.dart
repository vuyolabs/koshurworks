import 'package:flutter/material.dart';

import '../../../app/app_state.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/avatars.dart';
import '../../../core/widgets/carousel.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/sheets.dart';
import '../../../data/models/work_category.dart';
import '../../../data/models/work_listing.dart';
import '../../../data/models/worker_profile.dart';
import '../../work_discovery/widgets/work_listing_card.dart';
import '../../worker_discovery/widgets/worker_card.dart';
import '../widgets/home_widgets.dart';

/// Main dashboard. Section order adapts to worker or hirer mode.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickDistrict(BuildContext context) async {
    final state = AppScope.read(context);
    final picked = await showSelectionSheet<String>(
      context,
      title: 'Choose your area',
      subtitle: 'Used to show nearby work and workers',
      options: state.workRepository.districts,
      labelOf: (d) => d,
      iconOf: (_) => Icons.place_outlined,
      selected: state.district,
    );
    if (picked != null) state.district = picked;
  }

  void _openCategory(AppState state, WorkCategory category) {
    if (state.role == UserRole.worker) {
      state.openFindWork(category: category);
    } else {
      state.openFindWorkers(category: category);
    }
  }

  void _search(AppState state, String query) {
    final q = query.trim();
    if (state.role == UserRole.worker) {
      state.openFindWork(query: q);
    } else {
      state.openFindWorkers(query: q);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isWorker = state.role == UserRole.worker;

    final workSections = <Widget>[
      _NearbyWorkSection(state: state),
      const SizedBox(height: AppSpacing.xl),
      _RecentWorkSection(state: state),
    ];
    final workerSections = <Widget>[_RecommendedWorkersSection(state: state)];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.screen,
        toolbarHeight: 68,
        title: _Header(state: state),
        actions: [
          CircleIconButton.onDark(
            icon: Icons.bookmark_border_rounded,
            tooltip: 'Saved work',
            badgeCount: state.savedIds.length,
            onPressed: () => AppNavigator.openSaved(context),
          ),
          const SizedBox(width: AppSpacing.xs),
          CircleIconButton.onDark(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            onPressed: () =>
                showAppSnack(context, 'No notifications yet. Alerts are not connected in this prototype.'),
          ),
          const SizedBox(width: AppSpacing.screen - AppSpacing.xxs),
        ],
        bottom: HeaderBottom(
          height: 112,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocationSelector(district: state.district, onTap: () => _pickDistrict(context), onDark: true),
              const SizedBox(height: AppSpacing.xs),
              AppSearchField(
                hintText: isWorker ? 'Search work, skills or places' : 'Search workers or skills',
                onSubmitted: (q) => _search(state, q),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ContentWidth(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.lg, AppSpacing.screen, 0),
                  child: FadeSlideIn(
                    child: isWorker
                        ? _WorkerHero(state: state)
                        : PromoBanner(
                            eyebrow: 'For hirers',
                            title: 'Need skilled hands?',
                            message:
                                'Describe your work once and let local tradespeople '
                                'express interest.',
                            actionLabel: 'Post a requirement',
                            onAction: () => AppNavigator.openPostWork(context),
                          ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: isWorker ? 'Browse by trade' : 'Hire by trade',
                        subtitle: isWorker
                            ? 'Tap a trade to see open work'
                            : 'Tap a trade to see professionals',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      CategoryShortcuts(
                        categories: state.workRepository.categories,
                        onSelected: (c) => _openCategory(state, c),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      if (isWorker) ...[
                        ...workSections,
                        const SizedBox(height: AppSpacing.xl),
                        ...workerSections,
                      ] else ...[
                        ...workerSections,
                        const SizedBox(height: AppSpacing.xl),
                        ...workSections,
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      if (isWorker)
                        Padding(
                          padding: AppSpacing.screenPadding,
                          child: PromoBanner(
                            eyebrow: 'Hiring too?',
                            title: 'Post your own work',
                            message:
                                'Need a plumber at home or helpers for a site? '
                                'Post a requirement in a couple of minutes.',
                            actionLabel: 'Post Work',
                            onAction: () => AppNavigator.openPostWork(context),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          AppSpacing.xl,
                          AppSpacing.screen,
                          AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
                        ),
                        child: const PrototypeNote(
                          text:
                              'All listings, people and ratings in this preview are sample data '
                              'for demonstration.',
                        ),
                      ),
                    ],
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

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final firstName = state.profile.name.split(' ').first;
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Open account',
          excludeSemantics: true,
          child: GestureDetector(
            onTap: () => state.selectTab(AppTab.account),
            child: AppAvatar(name: state.profile.name, size: 44, ring: true),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Formatters.greeting(),
                style: theme.bodySmall?.copyWith(color: AppColors.white.withValues(alpha: 0.75)),
              ),
              Text(
                firstName,
                style: theme.titleLarge?.copyWith(color: AppColors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkerHero extends StatelessWidget {
  const _WorkerHero({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WorkListing>>(
      future: state.listings,
      builder: (context, snapshot) {
        final count = snapshot.data?.where((l) => l.district == state.district).length;
        final total = snapshot.data?.length;
        final title = count == null
            ? 'Finding work near you'
            : count == 0
            ? '${total ?? 0} jobs across J&K'
            : '${Formatters.plural(count, 'job')} in ${state.district}';
        return PromoBanner(
          eyebrow: 'Work near you',
          title: title,
          message: 'Daily-wage and project work from homeowners and contractors.',
          actionLabel: 'Browse work',
          icon: Icons.arrow_forward_rounded,
          onAction: () => state.openFindWork(),
        );
      },
    );
  }
}

class _NearbyWorkSection extends StatelessWidget {
  const _NearbyWorkSection({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Nearby opportunities',
          subtitle: 'In and around ${state.district}',
          actionLabel: 'See all',
          onAction: () => state.openFindWork(),
        ),
        const SizedBox(height: AppSpacing.sm),
        FutureBuilder<List<WorkListing>>(
          future: state.listings,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyState.error(onAction: state.reloadListings);
            }
            final all = snapshot.data;
            if (all == null) {
              return const CardCarousel(
                itemWidth: 290,
                animate: false,
                children: [WorkListingCardSkeleton(), WorkListingCardSkeleton()],
              );
            }
            final nearby = all.where((l) => l.district == state.district).toList();
            final items = nearby.isEmpty ? all.take(5).toList() : nearby;
            return CardCarousel(
              itemWidth: 290,
              children: [
                for (final listing in items)
                  WorkListingCard(
                    listing: listing,
                    compact: true,
                    isSaved: state.isSaved(listing.id),
                    onSaveToggle: () => state.toggleSaved(listing.id),
                    onTap: () => AppNavigator.openWork(context, listing),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RecentWorkSection extends StatelessWidget {
  const _RecentWorkSection({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recently posted',
          subtitle: 'Fresh work across Jammu & Kashmir',
          actionLabel: 'See all',
          onAction: () => state.openFindWork(),
        ),
        const SizedBox(height: AppSpacing.sm),
        FutureBuilder<List<WorkListing>>(
          future: state.listings,
          builder: (context, snapshot) {
            final all = snapshot.data;
            final recent = all == null
                ? const <WorkListing>[]
                : ([...all]..sort((a, b) => b.postedAt.compareTo(a.postedAt))).take(3).toList();
            return Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  if (all == null)
                    for (var i = 0; i < 2; i++) ...[
                      const WorkListingCardSkeleton(),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  for (var i = 0; i < recent.length; i++) ...[
                    FadeSlideIn(
                      delay: FadeSlideIn.stagger(i),
                      child: WorkListingCard(
                        listing: recent[i],
                        isSaved: state.isSaved(recent[i].id),
                        onSaveToggle: () => state.toggleSaved(recent[i].id),
                        onTap: () => AppNavigator.openWork(context, recent[i]),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RecommendedWorkersSection extends StatelessWidget {
  const _RecommendedWorkersSection({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Top professionals',
          subtitle: 'Highly rated sample profiles',
          actionLabel: 'See all',
          onAction: () => state.openFindWorkers(),
        ),
        const SizedBox(height: AppSpacing.sm),
        FutureBuilder<List<WorkerProfile>>(
          future: state.workers,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyState.error(onAction: state.reloadWorkers);
            }
            final data = snapshot.data;
            if (data == null) {
              return const CardCarousel(
                itemWidth: 170,
                animate: false,
                children: [
                  SkeletonBox(height: 190, radius: AppRadii.lg),
                  SkeletonBox(height: 190, radius: AppRadii.lg),
                  SkeletonBox(height: 190, radius: AppRadii.lg),
                ],
              );
            }
            final ranked = [...data]
              ..sort((a, b) {
                final avail = a.availability.index.compareTo(b.availability.index);
                return avail != 0 ? avail : b.rating.compareTo(a.rating);
              });
            return CardCarousel(
              itemWidth: 170,
              children: [
                for (final worker in ranked.take(6))
                  WorkerCard(
                    worker: worker,
                    compact: true,
                    onTap: () => AppNavigator.openWorker(context, worker),
                  ),
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, 0),
          child: Text(
            'Ratings shown are sample data.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          ),
        ),
      ],
    );
  }
}
