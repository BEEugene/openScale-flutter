import 'package:flutter/material.dart';
import 'package:openscale/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:openscale/ui/screens/overview/overview_screen.dart';
import 'package:openscale/ui/screens/graph/graph_screen.dart';
import 'package:openscale/ui/screens/table/table_screen.dart';
import 'package:openscale/ui/screens/statistics/statistics_screen.dart';
import 'package:openscale/ui/screens/insights/insights_screen.dart';
import 'package:openscale/ui/screens/settings/settings_screen.dart';
import 'package:openscale/ui/screens/overview/measurement_detail_screen.dart';
import 'package:openscale/ui/screens/measurement_detail/add_measurement_screen.dart';
import 'package:openscale/ui/screens/settings/user_management_screen.dart';
import 'package:openscale/ui/screens/settings/bluetooth_screen.dart';
import 'package:openscale/ui/screens/settings/data_management_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.overview,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.overview,
              builder: (context, state) => const OverviewScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.graph,
              builder: (context, state) => const GraphScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.table,
              builder: (context, state) => const TableScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.statistics,
              builder: (context, state) => const StatisticsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.insights,
              builder: (context, state) => const InsightsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.settings,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.userManagement,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const UserManagementScreen(),
    ),
    GoRoute(
      path: AppRoutes.bluetooth,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BluetoothScreen(),
    ),
    GoRoute(
      path: AppRoutes.dataManagement,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DataManagementScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.measurementDetail}/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return MeasurementDetailScreen(measurementId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.measurementNew,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddMeasurementScreen(),
    ),
  ],
);

class AppRoutes {
  const AppRoutes._();

  static const overview = '/';
  static const graph = '/graph';
  static const table = '/table';
  static const statistics = '/statistics';
  static const insights = '/insights';
  static const settings = '/settings';
  static const measurementDetail = '/measurement';
  static const measurementNew = '/measurement/new';
  static const userManagement = '/settings/users';
  static const bluetooth = '/settings/bluetooth';
  static const dataManagement = '/settings/data';
}

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: navigationShell.currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.measurementNew),
              tooltip: AppLocalizations.of(context)!.addMeasurement,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.overview,
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_outlined),
            selectedIcon: const Icon(Icons.show_chart),
            label: AppLocalizations.of(context)!.graph,
          ),
          NavigationDestination(
            icon: const Icon(Icons.table_rows_outlined),
            selectedIcon: const Icon(Icons.table_rows),
            label: AppLocalizations.of(context)!.table,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics),
            label: AppLocalizations.of(context)!.statistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.lightbulb_outlined),
            selectedIcon: const Icon(Icons.lightbulb),
            label: AppLocalizations.of(context)!.insights,
          ),
        ],
      ),
    );
  }
}
