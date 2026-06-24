import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/catch/catch_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'widgets/admin_shell.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      if (!loggedIn && state.uri.toString() != '/login') return '/login';
      if (loggedIn && state.uri.toString() == '/login') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),
          GoRoute(path: '/orders', builder: (c, s) => const AdminOrdersScreen()),
          GoRoute(path: '/products', builder: (c, s) => const ProductsScreen()),
          GoRoute(path: '/catch', builder: (c, s) => const CatchScreen()),
          GoRoute(path: '/categories', builder: (c, s) => const CategoriesScreen()),
          GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
