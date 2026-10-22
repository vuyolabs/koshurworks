import '../mock/mock_categories.dart';
import '../mock/mock_listings.dart';
import '../models/work_category.dart';
import '../models/work_listing.dart';

/// Source of work listings and reference data.
///
/// Screens depend on this interface only, so the mock can later be replaced
/// with an HTTP-backed implementation without touching the UI.
abstract interface class WorkRepository {
  List<WorkCategory> get categories;
  List<String> get districts;
  Future<List<WorkListing>> fetchListings();
}

/// In-memory implementation with a short artificial delay so loading states
/// are visible in the prototype.
class MockWorkRepository implements WorkRepository {
  MockWorkRepository({this.latency = const Duration(milliseconds: 650)})
    : _listings = buildMockListings(DateTime.now());

  final Duration latency;
  final List<WorkListing> _listings;

  @override
  List<WorkCategory> get categories => MockCategories.all;

  @override
  List<String> get districts => MockDistricts.all;

  @override
  Future<List<WorkListing>> fetchListings() async {
    await Future<void>.delayed(latency);
    return List.unmodifiable(_listings);
  }
}
