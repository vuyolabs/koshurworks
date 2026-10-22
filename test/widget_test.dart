import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koshurworks/app/app.dart';
import 'package:koshurworks/core/utils/formatters.dart';
import 'package:koshurworks/core/widgets/motion.dart';
import 'package:koshurworks/data/mock/mock_categories.dart';
import 'package:koshurworks/data/mock/mock_listings.dart';
import 'package:koshurworks/data/mock/mock_workers.dart';
import 'package:koshurworks/data/repositories/work_repository.dart';
import 'package:koshurworks/data/repositories/worker_repository.dart';
import 'package:koshurworks/features/work_discovery/work_filters.dart';
import 'package:koshurworks/features/worker_discovery/worker_filters.dart';

Widget _app() => KoshurWorksApp(
  workRepository: MockWorkRepository(latency: Duration.zero),
  workerRepository: MockWorkerRepository(latency: Duration.zero),
);

/// Simulates a small Android phone (360 x 780 logical pixels).
void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Scrolls [finder] into view before tapping it.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  group('Formatters', () {
    test('rupees uses Indian digit grouping', () {
      expect(Formatters.rupees(900), '₹900');
      expect(Formatters.rupees(45000), '₹45,000');
      expect(Formatters.rupees(125000), '₹1,25,000');
      expect(Formatters.rupees(10000000), '₹1,00,00,000');
    });

    test('initials handles one and many words', () {
      expect(Formatters.initials('Bashir A.'), 'BA');
      expect(Formatters.initials('Aamir'), 'A');
      expect(Formatters.initials('  '), '?');
    });
  });

  group('Mock data', () {
    test('meets prototype minimums', () {
      final listings = buildMockListings(DateTime(2026, 10, 22));
      expect(listings.length, greaterThanOrEqualTo(10));
      expect(MockWorkers.all.length, greaterThanOrEqualTo(8));
      expect(MockCategories.all.length, 7);
      expect(listings.map((l) => l.id).toSet().length, listings.length);
    });
  });

  group('Filters', () {
    final now = DateTime(2026, 10, 22, 10);
    final listings = buildMockListings(now);

    test('filters work by category, district and query', () {
      final masons = applyWorkFilters(listings, category: MockCategories.mason, now: now);
      expect(masons, isNotEmpty);
      expect(masons.every((l) => l.category == MockCategories.mason), isTrue);

      final srinagar = applyWorkFilters(
        listings,
        filters: {
          WorkFilterKeys.district: {'Srinagar'},
        },
        now: now,
      );
      expect(srinagar.every((l) => l.district == 'Srinagar'), isTrue);

      final kitchen = applyWorkFilters(listings, query: 'kitchen cabinets', now: now);
      expect(kitchen.single.id, 'w02');
    });

    test('sorts by most workers needed', () {
      final sorted = applyWorkFilters(listings, sort: WorkSort.mostWorkers, now: now);
      expect(sorted.first.workersNeeded, 8);
    });

    test('filters workers by availability and experience', () {
      final result = applyWorkerFilters(
        MockWorkers.all,
        filters: {
          WorkerFilterKeys.experience: {ExperienceBand.expert.label},
        },
      );
      expect(result.every((w) => w.yearsExperience > 10), isTrue);
    });
  });

  group('App', () {
    testWidgets('welcome leads to Find Work and work details', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Hire Workers'), findsOneWidget);
      await _tap(tester, find.text('Find Work'));

      expect(find.text('Daily-wage and project work across Jammu & Kashmir'), findsOneWidget);

      // Open the first listing.
      await _tap(tester, find.text('Eight construction helpers for a project').first);
      expect(find.text("I'm Interested"), findsOneWidget);
      expect(find.text('About the work'), findsOneWidget);

      // Express interest via the confirmation sheet.
      await _tap(tester, find.text("I'm Interested"));
      await _tap(tester, find.text("Yes, I'm interested"));
      expect(find.text('Interest sent'), findsOneWidget);
    });

    testWidgets('saving a listing shows it on the saved screen', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Hire Workers'));

      // Hirer mode home shows the hirer banner.
      expect(find.text('Need skilled hands?'), findsOneWidget);

      await _tap(tester, find.byTooltip('Saved work'));
      expect(find.text('No saved work yet'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await _tap(tester, find.byTooltip('Find Work'));
      await _tap(tester, find.byIcon(Icons.bookmark_border_rounded));

      await _tap(tester, find.byTooltip('Home'));
      await _tap(tester, find.byTooltip('Saved work'));
      expect(find.text('No saved work yet'), findsNothing);
      expect(find.textContaining('1 saved'), findsOneWidget);
    });

    testWidgets('post work validates required fields', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Find Work'));

      await _tap(tester, find.byTooltip('Post work'));
      expect(find.textContaining('Work title', findRichText: true), findsOneWidget);

      await _tap(tester, find.text('Submit'));
      expect(find.text('Title should be at least 8 characters'), findsOneWidget);
      expect(find.text('Choose a trade'), findsOneWidget);
    });

    testWidgets('every tab renders without layout errors', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Find Work'));

      for (final tab in ['Home', 'Find Workers', 'Account', 'Find Work']) {
        await _tap(tester, find.byTooltip(tab));
        expect(tester.takeException(), isNull);
      }

      await _tap(tester, find.byTooltip('Find Workers'));
      await _tap(tester, find.text('Bashir A.').first);
      expect(find.text('Work history'), findsOneWidget);
    });

    testWidgets('all screens survive large text and reduced motion', (tester) async {
      _usePhoneSize(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Hire Workers'));
      expect(tester.takeException(), isNull);

      // Work details.
      await _tap(tester, find.byTooltip('Find Work'));
      await _tap(tester, find.text('Eight construction helpers for a project'));
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Worker profile.
      await _tap(tester, find.byTooltip('Find Workers'));
      await _tap(tester, find.text('Bashir A.'));
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Own profile and saved work from Account.
      await _tap(tester, find.byTooltip('Account'));
      await _tap(tester, find.text('Aamir R.'));
      expect(find.text('My profile'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Saved work'));
      expect(find.text('No saved work yet'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Post work form.
      await _tap(tester, find.byTooltip('Post work'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('entrance animations replay when a tab is opened', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Find Work'));

      Iterable<double> midAnimationOpacities() => tester
          .widgetList<Opacity>(find.descendant(of: find.byType(FadeSlideIn), matching: find.byType(Opacity)))
          .map((o) => o.opacity)
          .where((o) => o < 1);

      // Switch to Account and sample a frame mid-animation.
      await tester.tap(find.byTooltip('Account'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(midAnimationOpacities(), isNotEmpty);
      await tester.pumpAndSettle();
      expect(midAnimationOpacities(), isEmpty);

      // Coming back to Find Work replays its entrance as well.
      await tester.tap(find.byTooltip('Find Work'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(midAnimationOpacities(), isNotEmpty);
      await tester.pumpAndSettle();
    });

    testWidgets('screens and sheets open with a visible animation', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Find Work'));

      double routeProgress(Finder f) => ModalRoute.of(tester.element(f.first))!.animation!.value;

      // Page transition: part-way through after 150ms, complete when settled.
      await tester.tap(find.text('Eight construction helpers for a project'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(routeProgress(find.text('About the work')), inExclusiveRange(0.0, 1.0));
      await tester.pumpAndSettle();
      expect(routeProgress(find.text('About the work')), 1.0);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Bottom sheet: also eased in rather than appearing at once.
      await tester.tap(find.byTooltip('Filters'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(routeProgress(find.text('Filter work')), inExclusiveRange(0.0, 1.0));
      await tester.pumpAndSettle();
      expect(routeProgress(find.text('Filter work')), 1.0);
    });

    testWidgets('switching tabs slides between screens', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Find Work'));

      final oldHeader = find.text('Daily-wage and project work across Jammu & Kashmir');
      final newHeader = find.text('Profile, preferences and help');
      final startX = tester.getTopLeft(oldHeader).dx;

      await tester.tap(find.byTooltip('Account'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));

      // Mid-transition both screens are on stage and both have moved.
      expect(oldHeader, findsOneWidget);
      expect(newHeader, findsOneWidget);
      expect(tester.getTopLeft(oldHeader).dx, lessThan(startX));
      expect(tester.getTopLeft(newHeader).dx, greaterThan(startX));

      await tester.pumpAndSettle();
      expect(oldHeader, findsNothing);
      expect(tester.getTopLeft(newHeader).dx, closeTo(startX, 0.5));
    });
  });
}
