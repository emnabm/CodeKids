import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/application/auth_controller.dart';
import 'package:frontend/features/auth/presentation/choose_pin_screen.dart';
import 'package:frontend/features/auth/presentation/create_account_screen.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/welcome_screen.dart';
import 'package:frontend/features/children/application/children_controller.dart';
import 'package:frontend/features/children/presentation/child_selection_screen.dart';
import 'package:frontend/features/children/presentation/create_child_screen.dart';
import 'package:frontend/features/map/presentation/map_screen.dart';
import 'package:frontend/features/rewards/presentation/rewards_screen.dart';
import 'package:frontend/features/stage/presentation/stage_screen.dart';
import 'package:frontend/shared/widgets/async_state_view.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String choosePin = '/choose-pin';
  static const String children = '/children';
  static const String createChild = '/children/create';
  static const String map = '/map';
  static const String rewards = '/rewards';
  static const String chart = '/chart';
  static const String profile = '/profile';
  static String stage(String id) => '/stage/$id';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this.ref) {
    ref.listen<AuthState>(authControllerProvider, (_, _) => notifyListeners());
    ref.listen<ChildrenState>(
      childrenControllerProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref ref;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final childrenState = ref.read(childrenControllerProvider);
      final location = state.matchedLocation;

      const publicRoutes = {
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.choosePin,
      };

      if (authState.status == AuthStatus.unknown) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (authState.status == AuthStatus.unauthenticated) {
        if (publicRoutes.contains(location)) return null;
        return authState.redirectToLogin
            ? AppRoutes.login
            : AppRoutes.welcome;
      }

      // Authenticated
      if (location == AppRoutes.splash || publicRoutes.contains(location)) {
        if (childrenState.activeChildId != null) return AppRoutes.map;
        return childrenState.children.isEmpty
            ? AppRoutes.createChild
            : AppRoutes.children;
      }

      final hasActiveChild = childrenState.activeChildId != null;
      final isChildManagementRoute = location == AppRoutes.children ||
          location == AppRoutes.createChild;

      if (!hasActiveChild && !isChildManagementRoute) {
        return AppRoutes.children;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _BootstrapScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.choosePin,
        builder: (context, state) => const ChoosePinScreen(),
      ),
      GoRoute(
        path: AppRoutes.children,
        builder: (context, state) => const ChildSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.createChild,
        builder: (context, state) => const CreateChildScreen(),
      ),
      GoRoute(
        path: '/stage/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final stageId = state.pathParameters['id'] ?? '';
          return StageScreen(stageId: stageId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _MainBottomNavShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.rewards,
                builder: (context, state) => const RewardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chart,
                builder: (context, state) => const _StepPlaceholderScreen(
                  title: 'Chart (Step 6)',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const _StepPlaceholderScreen(
                  title: 'Profile (Step 6)',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _BootstrapScreen extends ConsumerWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final colors = context.ckColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: AsyncStateView(
        isLoading: authState.bootstrapError == null,
        error: authState.bootstrapError,
        onRetry: () => ref.read(authControllerProvider.notifier).bootstrap(),
        child: const SizedBox.shrink(),
      ),
    );
  }
}

class _MainBottomNavShell extends StatelessWidget {
  const _MainBottomNavShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF140E3D),
          border: Border(
            top: BorderSide(color: colors.border.withValues(alpha: 0.6)),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          items: [
            _navItem(
              icon: Icons.explore_rounded,
              label: l10n.navMap,
              selected: navigationShell.currentIndex == 0,
              colors: colors,
            ),
            _navItem(
              icon: Icons.star_rounded,
              label: l10n.navRewards,
              selected: navigationShell.currentIndex == 1,
              colors: colors,
            ),
            _navItem(
              icon: Icons.bar_chart_rounded,
              label: l10n.navChart,
              selected: navigationShell.currentIndex == 2,
              colors: colors,
            ),
            _navItem(
              icon: Icons.person_rounded,
              label: l10n.navProfile,
              selected: navigationShell.currentIndex == 3,
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem({
    required IconData icon,
    required String label,
    required bool selected,
    required CodeKidsColors colors,
  }) {
    return BottomNavigationBarItem(
      label: label,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: selected
            ? BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B5CFF), Color(0xFF5D35EE)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.55),
                    blurRadius: 10,
                  ),
                ],
              )
            : null,
        child: Icon(icon, size: 22),
      ),
    );
  }
}

class _StepPlaceholderScreen extends StatelessWidget {
  const _StepPlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
