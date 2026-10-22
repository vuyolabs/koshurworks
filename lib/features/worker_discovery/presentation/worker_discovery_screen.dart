import 'package:flutter/material.dart';

import '../../../app/app_state.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/cross_fade_switch.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_sheet.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/search_field.dart';
import '../../../data/models/work_category.dart';
import '../../../data/models/worker_profile.dart';
import '../../common/contact_sheet.dart';
import '../widgets/worker_card.dart';
import '../worker_filters.dart';

/// Lets hirers find tradespeople by skill, trade and district.
class WorkerDiscoveryScreen extends StatefulWidget {
  const WorkerDiscoveryScreen({super.key});

  @override
  State<WorkerDiscoveryScreen> createState() => _WorkerDiscoveryScreenState();
}

class _WorkerDiscoveryScreenState extends State<WorkerDiscoveryScreen> {
  final _search = TextEditingController();
  String _query = '';
  WorkCategory? _category;
  FilterSelection _filters = const {};
  int? _seedToken;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final seed = AppScope.of(context).workerSeed;
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

  bool get _availableOnly =>
      _filters[WorkerFilterKeys.availability]?.contains(WorkerAvailability.available.label) ?? false;

  void _toggleAvailableOnly() {
    setState(() {
      final next = {
        for (final e in _filters.entries) e.key: {...e.value},
      };
      final set = next[WorkerFilterKeys.availability] ??= {};
      if (!set.remove(WorkerAvailability.available.label)) set.add(WorkerAvailability.available.label);
      _filters = next;
    });
  }

  Future<void> _openFilters(AppState state) async {
    final result = await showFilterSheet(
      context,
      title: 'Filter workers',
      groups: workerFilterGroups(state.workRepository.districts),
      initial: _filters,
    );
    if (result != null) setState(() => _filters = result);
  }

  void _clearAll() => setState(() {
    _filters = const {};
    _category = null;
    _query = '';
    _search.clear();
  });

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.screen,
        toolbarHeight: 72,
        title: const HeaderTitle(
          title: 'Find Workers',
          subtitle: 'Skilled tradespeople and helpers near you',
        ),
        bottom: HeaderBottom(
          child: AppSearchField(
            controller: _search,
            hintText: 'Search by name or skill',
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
                    label: 'Available now',
                    icon: Icons.bolt_rounded,
                    selected: _availableOnly,
                    onTap: _toggleAvailableOnly,
                  ),
                  CategoryChip(
                    label: 'All trades',
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
              Expanded(
                child: FutureBuilder<List<WorkerProfile>>(
                  future: state.workers,
                  builder: (context, snapshot) => CrossFadeSwitch(
                    switchKey: snapshot.hasError
                        ? 'error'
                        : snapshot.data == null
                        ? 'loading'
                        : '${_category?.id}|$_filters',
                    child: Builder(
                      builder: (context) {
                        if (snapshot.hasError) {
                          return Center(child: EmptyState.error(onAction: state.reloadWorkers));
                        }
                        final all = snapshot.data;
                        if (all == null) {
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screen,
                              AppSpacing.xl,
                              AppSpacing.screen,
                              0,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (_, _) => const WorkerCardSkeleton(),
                          );
                        }
                        final results = applyWorkerFilters(
                          all,
                          query: _query,
                          category: _category,
                          filters: _filters,
                        );
                        return CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.screen,
                                  AppSpacing.md,
                                  AppSpacing.screen,
                                  AppSpacing.sm,
                                ),
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    '${results.length} ${results.length == 1 ? 'professional' : 'professionals'}'
                                    ' · sample profiles',
                                    style: theme.bodySmall,
                                  ),
                                ),
                              ),
                            ),
                            if (results.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: EmptyState(
                                  icon: Icons.person_search_outlined,
                                  title: 'No workers match',
                                  message: 'Try a nearby district, another trade or remove filters.',
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
                                    final worker = results[i];
                                    return FadeSlideIn(
                                      key: ValueKey(worker.id),
                                      delay: FadeSlideIn.stagger(i),
                                      child: WorkerCard(
                                        worker: worker,
                                        onTap: () => AppNavigator.openWorker(context, worker),
                                        onContact: () => showPrototypeContactSheet(
                                          context,
                                          name: worker.name,
                                          subtitle: '${worker.category.name} · ${worker.district}',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
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
