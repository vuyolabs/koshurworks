import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/repositories/work_repository.dart';
import '../data/repositories/worker_repository.dart';
import 'app_state.dart';
import 'router.dart';

class KoshurWorksApp extends StatefulWidget {
  const KoshurWorksApp({super.key, this.workRepository, this.workerRepository});

  /// Optional overrides, used by tests and later by real implementations.
  final WorkRepository? workRepository;
  final WorkerRepository? workerRepository;

  @override
  State<KoshurWorksApp> createState() => _KoshurWorksAppState();
}

class _KoshurWorksAppState extends State<KoshurWorksApp> {
  late final AppState _state = AppState(
    workRepository: widget.workRepository ?? MockWorkRepository(),
    workerRepository: widget.workerRepository ?? MockWorkerRepository(),
  );

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'KoshurWorks',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.welcome,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );
  }
}
