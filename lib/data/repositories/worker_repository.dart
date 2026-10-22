import '../mock/mock_workers.dart';
import '../models/worker_profile.dart';

/// Source of worker profiles. Swap [MockWorkerRepository] for a real
/// implementation later.
abstract interface class WorkerRepository {
  Future<List<WorkerProfile>> fetchWorkers();
  WorkerProfile get currentUserProfile;
}

class MockWorkerRepository implements WorkerRepository {
  MockWorkerRepository({this.latency = const Duration(milliseconds: 550)});

  final Duration latency;

  @override
  Future<List<WorkerProfile>> fetchWorkers() async {
    await Future<void>.delayed(latency);
    return MockWorkers.all;
  }

  @override
  WorkerProfile get currentUserProfile => MockWorkers.currentUser;
}
