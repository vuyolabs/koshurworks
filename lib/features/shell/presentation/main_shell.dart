import 'package:flutter/material.dart';

import '../../../app/app_state.dart';
import '../../../app/router.dart';
import '../../../core/widgets/motion.dart';
import '../../account/presentation/account_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../work_discovery/presentation/work_discovery_screen.dart';
import '../../worker_discovery/presentation/worker_discovery_screen.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/tab_switcher.dart';

/// Primary app frame: four tabs plus a prominent Post Work action.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  AppTab? _lastTab;
  final Map<AppTab, int> _visits = {};

  static const _pages = <AppTab, Widget>{
    AppTab.home: HomeScreen(),
    AppTab.findWork: WorkDiscoveryScreen(),
    AppTab.findWorkers: WorkerDiscoveryScreen(),
    AppTab.account: AccountScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final tab = state.tab;
    if (_lastTab != tab) {
      _visits[tab] = (_visits[tab] ?? 0) + 1;
    }
    _lastTab = tab;

    return PopScope(
      canPop: tab == AppTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) state.selectTab(AppTab.home);
      },
      child: Scaffold(
        extendBody: true,
        body: TabSwitcher(
          index: AppTab.values.indexOf(tab),
          children: [
            for (final t in AppTab.values)
              TabVisitScope(
                active: t == tab,
                visit: _visits[t] ?? 0,
                child: _pages[t] ?? const SizedBox.shrink(),
              ),
          ],
        ),
        bottomNavigationBar: FloatingNavBar(
          current: tab,
          onSelect: state.selectTab,
          onPost: () => AppNavigator.openPostWork(context),
        ),
      ),
    );
  }
}
