import 'package:flutter/material.dart';

import '../../../app/app_state.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/cross_fade_switch.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_sheet.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/sheets.dart';
import '../../../data/models/work_category.dart';
import '../../../data/models/work_listing.dart';
import '../widgets/work_listing_card.dart';
import '../work_filters.dart';

/// Search, filter and browse work opportunities.
class WorkDiscoveryScreen extends StatefulWidget {
  const WorkDiscoveryScreen({super.key});

  @override
  State<WorkDiscoveryScreen> createState() => _WorkDiscoveryScreenState();
}

class _WorkDiscoveryScreenState extends State<WorkDiscoveryScreen> {
  final _search = TextEditingController();
  String _query = '';
  WorkCategory? _category;
  FilterSelection _filters = const {};
  WorkSort _sort = WorkSort.newest;
  int? _seedToken;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final seed = AppScope.of(context).workSeed;
    if (seed != null && seed.token != _seedToken) {
      _seedToken = seed.token;
      _category = seed.category;
      _query = seed.query ?? '';
      _search.text = _query;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilters(AppState state) async {
    final result = await showFilterSheet(
      context,
      title: 'Filter work',
      groups: workFilterGroups(state.workRepository.districts),
      initial: _filters,
    );
    if (result != null) setState(() => _filters = result);
  }

  Future<void> _openSort() async {
    final picked = await showSelectionSheet<WorkSort>(
      context,
      title: 'Sort by',
      options: WorkSort.values,
      labelOf: (s) => s.label,
      selected: _sort,
    );
    if (picked != null) setState(() => _sort = picked);
  }

  void _removeFilter(String group, String option) {
    setState(() {
      _filters = {
        for (final e in _filters.entries)
          e.key: e.key == group ? ({...e.value}..remove(option)) : {...e.value},
      };
    });
  }

  void _clearAll() {
    setState(() {
      _filters = const {};
      _category = null;
      _query = '';
      _search.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final activeChips = [
      for (final e in _filters.entries)
        for (final option in e.value) (group: e.key, option: option),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.screen,
        toolbarHeight: 72,
        title: const HeaderTitle(
          title: 'Find Work',
          subtitle: 'Daily-wage and project work across Jammu & Kashmir',
        ),
        bottom: HeaderBottom(
          child: AppSearchField(
            controller: _search,
            hintText: 'Search title, skill or place',
            onChanged: (v) => setState(() => _query = v),
            onFilterPressed: () => _openFilters(state),
            activeFilterCount: countActiveFilters(_filters),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              ChipRow(
                children: [
                  CategoryChip(
                    label: 'All',
                    selected: _category == null,
                    onTap: () => setState(() => _category = null),
                  ),
                  for (final c in state.workRepository.categories)
                    CategoryChip(
                      label: c.name,
                      icon: c.icon,
                      selected: _category == c,
                      onTap: () => setState(() => _category = _category == c ? null : c),
                    ),
                ],
              ),
              AnimatedSize(
                duration: AppMotion.size(context, AppMotion.medium),
                curve: AppMotion.curve,
                alignment: Alignment.topCenter,
                child: activeChips.isEmpty
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: ChipRow(
                          children: [
                            for (final chip in activeChips)
                              CategoryChip(
                                label: chip.option,
                                selected: true,
                                onTap: () {},
                                onRemove: () => _removeFilter(chip.group, chip.option),
                              ),
                          ],
                        ),
                      ),
              ),
              Expanded(
                child: FutureBuilder<List<WorkListing>>(
                  future: state.listings,
                  builder: (context, snapshot) => CrossFadeSwitch(
                    switchKey: snapshot.hasError
                        ? 'error'
                        : snapshot.data == null
                        ? 'loading'
                        : '${_category?.id}|$_filters|$_sort',
                    child: Builder(
                      builder: (context) {
                        if (snapshot.hasError) {
                          return Center(child: EmptyState.error(onAction: state.reloadListings));
                        }
                        final all = snapshot.data;
                        if (all == null) return const _LoadingList();
                        final results = applyWorkFilters(
                          all,
                          query: _query,
                          category: _category,
                          filters: _filters,
                          sort: _sort,
                        );
                        return RefreshIndicator(
                          color: AppColors.forest,
                          onRefresh: () async {
                            state.reloadListings();
                            await state.listings;
                          },
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(
                                child: _ResultsBar(count: results.length, sort: _sort, onSort: _openSort),
                              ),
                              if (results.isEmpty)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: EmptyState(
                                    icon: Icons.search_off_rounded,
                                    title: 'No matching work',
                                    message: 'Try another trade or district, or clear your filters.',
                                    actionLabel: 'Clear filters',
                                    onAction: _clearAll,
                                  ),
                                )
                              else
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                    AppSpacing.screen,
                                    0,
                                    AppSpacing.screen,
                                    AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
                                  ),
                                  sliver: SliverList.separated(
                                    itemCount: results.length,
                                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                                    itemBuilder: (context, i) {
                                      final listing = results[i];
                                      return FadeSlideIn(
                                        key: ValueKey(listing.id),
                                        delay: FadeSlideIn.stagger(i),
                                        child: WorkListingCard(
                                          listing: listing,
                                          isSaved: state.isSaved(listing.id),
                                          onSaveToggle: () => state.toggleSaved(listing.id),
                                          onTap: () => AppNavigator.openWork(context, listing),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
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

class _ResultsBar extends StatelessWidget {
  const _ResultsBar({required this.count, required this.sort, required this.onSort});

  final int count;
  final WorkSort sort;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.sm, AppSpacing.sm, AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                '$count ${count == 1 ? 'opportunity' : 'opportunities'} · sample data',
                style: theme.bodySmall,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onSort,
            icon: const Icon(Icons.swap_vert_rounded, size: 18),
            label: Text(sort.label),
          ),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xl, AppSpacing.screen, 0),
      itemCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => const WorkListingCardSkeleton(),
    );
  }
}
