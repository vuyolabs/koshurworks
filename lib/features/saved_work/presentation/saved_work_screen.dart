import 'package:flutter/material.dart';

import '../../../app/app_state.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/sheets.dart';
import '../../../data/models/work_listing.dart';
import '../../work_discovery/widgets/work_listing_card.dart';

/// Work the user has bookmarked in this session.
class SavedWorkScreen extends StatelessWidget {
  const SavedWorkScreen({super.key});

  void _unsave(BuildContext context, AppState state, WorkListing listing) {
    state.toggleSaved(listing.id);
    showAppSnack(
      context,
      'Removed from saved work.',
      icon: Icons.bookmark_remove_outlined,
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          if (!state.isSaved(listing.id)) state.toggleSaved(listing.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final savedIds = state.savedIds;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved work')),
      body: ContentWidth(
        child: FutureBuilder<List<WorkListing>>(
          future: state.listings,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: EmptyState.error(onAction: state.reloadListings));
            }
            final all = snapshot.data;
            if (all == null) {
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screen),
                itemCount: 2,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, _) => const WorkListingCardSkeleton(),
              );
            }
            final saved = [...state.postedThisSession, ...all].where((l) => savedIds.contains(l.id)).toList();

            return AnimatedSwitcher(
              duration: AppMotion.of(context, AppMotion.medium),
              child: saved.isEmpty
                  ? Center(
                      key: const ValueKey('empty'),
                      child: SingleChildScrollView(
                        child: EmptyState(
                          icon: Icons.bookmark_border_rounded,
                          title: 'No saved work yet',
                          message: 'Tap the bookmark on any listing to keep it here for later.',
                          actionLabel: 'Browse work',
                          onAction: () {
                            state.openFindWork();
                            AppNavigator.backToShell(context);
                          },
                        ),
                      ),
                    )
                  : ListView.separated(
                      key: const ValueKey('list'),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.xs,
                        AppSpacing.screen,
                        AppSpacing.xxl,
                      ),
                      itemCount: saved.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return Text(
                            '${saved.length} saved · stored on this device for this session',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        }
                        final listing = saved[i - 1];
                        return FadeSlideIn(
                          key: ValueKey(listing.id),
                          delay: FadeSlideIn.stagger(i - 1),
                          child: WorkListingCard(
                            listing: listing,
                            isSaved: true,
                            onSaveToggle: () => _unsave(context, state, listing),
                            onTap: () => AppNavigator.openWork(context, listing),
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
