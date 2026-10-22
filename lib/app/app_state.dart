import 'package:flutter/widgets.dart';

import '../data/models/work_category.dart';
import '../data/models/work_listing.dart';
import '../data/models/worker_profile.dart';
import '../data/repositories/work_repository.dart';
import '../data/repositories/worker_repository.dart';

/// Which side of the marketplace the prototype user is acting as.
enum UserRole {
  worker('Worker', 'Find work near you'),
  hirer('Hirer', 'Find skilled people');

  const UserRole(this.label, this.tagline);
  final String label;
  final String tagline;
}

enum NotificationPref {
  nearbyWork('New work near me', 'When matching work is posted in your district'),
  messages('Messages from hirers', 'Replies to your interest'),
  updates('Application updates', 'When a hirer views your interest'),
  safetyTips('Tips and safety', 'Occasional guidance on working safely');

  const NotificationPref(this.title, this.description);
  final String title;
  final String description;
}

/// Primary tabs of the main shell. Post Work is an action, not a tab.
enum AppTab { home, findWork, findWorkers, account }

/// A one-off request to pre-filter a discovery screen, for example after
/// tapping a category on the home screen.
@immutable
class DiscoverySeed {
  const DiscoverySeed({required this.token, this.category, this.query});
  final int token;
  final WorkCategory? category;
  final String? query;
}

/// In-memory prototype state. Nothing here is persisted or sent anywhere.
///
/// Kept as a single [ChangeNotifier] because the prototype is small; it can be
/// split into feature controllers when real APIs arrive.
class AppState extends ChangeNotifier {
  AppState({required this.workRepository, required this.workerRepository})
    : _profile = workerRepository.currentUserProfile,
      _district = workerRepository.currentUserProfile.district;

  final WorkRepository workRepository;
  final WorkerRepository workerRepository;

  // ---- Data loading -------------------------------------------------------

  Future<List<WorkListing>>? _listings;
  Future<List<WorkerProfile>>? _workers;

  Future<List<WorkListing>> get listings => _listings ??= workRepository.fetchListings();
  Future<List<WorkerProfile>> get workers => _workers ??= workerRepository.fetchWorkers();

  void reloadListings() {
    _listings = workRepository.fetchListings();
    notifyListeners();
  }

  void reloadWorkers() {
    _workers = workerRepository.fetchWorkers();
    notifyListeners();
  }

  // ---- Role and navigation -----------------------------------------------

  UserRole _role = UserRole.worker;
  UserRole get role => _role;
  set role(UserRole value) {
    if (value == _role) return;
    _role = value;
    notifyListeners();
  }

  AppTab _tab = AppTab.home;
  AppTab get tab => _tab;
  void selectTab(AppTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    notifyListeners();
  }

  int _seedCounter = 0;
  DiscoverySeed? _workSeed;
  DiscoverySeed? _workerSeed;
  DiscoverySeed? get workSeed => _workSeed;
  DiscoverySeed? get workerSeed => _workerSeed;

  void openFindWork({WorkCategory? category, String? query}) {
    _workSeed = DiscoverySeed(token: ++_seedCounter, category: category, query: query);
    _tab = AppTab.findWork;
    notifyListeners();
  }

  void openFindWorkers({WorkCategory? category, String? query}) {
    _workerSeed = DiscoverySeed(token: ++_seedCounter, category: category, query: query);
    _tab = AppTab.findWorkers;
    notifyListeners();
  }

  // ---- Location -----------------------------------------------------------

  String _district;
  String get district => _district;
  set district(String value) {
    if (value == _district) return;
    _district = value;
    notifyListeners();
  }

  // ---- Saved work and interest -------------------------------------------

  final Set<String> _saved = {};
  final Set<String> _interested = {};

  Set<String> get savedIds => Set.unmodifiable(_saved);
  bool isSaved(String listingId) => _saved.contains(listingId);
  bool isInterested(String listingId) => _interested.contains(listingId);
  int get interestedCount => _interested.length;

  void toggleSaved(String listingId) {
    if (!_saved.remove(listingId)) _saved.add(listingId);
    notifyListeners();
  }

  void markInterested(String listingId) {
    if (_interested.add(listingId)) notifyListeners();
  }

  void withdrawInterest(String listingId) {
    if (_interested.remove(listingId)) notifyListeners();
  }

  // ---- Profile ------------------------------------------------------------

  WorkerProfile _profile;
  WorkerProfile get profile => _profile;
  void updateProfile(WorkerProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  // ---- Notification preferences ------------------------------------------

  final Map<NotificationPref, bool> _notifications = {
    for (final p in NotificationPref.values) p: p != NotificationPref.updates,
  };
  bool notificationEnabled(NotificationPref pref) => _notifications[pref] ?? false;
  void setNotification(NotificationPref pref, bool enabled) {
    _notifications[pref] = enabled;
    notifyListeners();
  }

  // ---- Prototype posts ----------------------------------------------------

  final List<WorkListing> _posted = [];
  List<WorkListing> get postedThisSession => List.unmodifiable(_posted);
  void addPrototypePost(WorkListing listing) {
    _posted.insert(0, listing);
    notifyListeners();
  }

  /// Resets session state, used by the sign-out placeholder.
  void resetSession() {
    _saved.clear();
    _interested.clear();
    _posted.clear();
    _tab = AppTab.home;
    _role = UserRole.worker;
    _profile = workerRepository.currentUserProfile;
    _district = _profile.district;
    _workSeed = null;
    _workerSeed = null;
    notifyListeners();
  }
}

/// Exposes [AppState] to the widget tree and rebuilds dependents on change.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  /// Reads state and subscribes to changes.
  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }

  /// Reads state without subscribing; use inside callbacks.
  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }
}
