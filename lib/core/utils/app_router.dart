import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:texty/blocs/chat/chat_bloc.dart';
import 'package:texty/data/datasources/firebase_chat_datasource.dart';
import 'package:texty/data/repositories/chat_repository.dart';
import 'package:texty/views/screens/chat_screen.dart';
import 'package:texty/views/screens/discover_screen.dart';
import 'package:texty/views/screens/login_screen.dart';
import 'package:texty/views/screens/recent_chat_screen.dart';
import 'package:texty/views/screens/signup_screen.dart';
import 'package:texty/views/screens/settings_screen.dart';
import 'package:texty/views/screens/search_user_screen.dart';
import 'package:texty/views/screens/photo_view_screen.dart';
import 'package:texty/views/screens/splash_screen.dart';
import 'package:texty/views/widgets/scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: "/splash",
      refreshListenable:
          GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
      redirect: (context, state) {
        final isLoggedIn = FirebaseAuth.instance.currentUser != null;
        debugPrint(
            "Auth State Changed: isLoggedIn = $isLoggedIn, location = ${state.matchedLocation}");

        if (state.matchedLocation == "/splash") {
          return null;
        }

        final isAuthRoute = state.matchedLocation == "/login" ||
            state.matchedLocation == "/signup";

        if (!isLoggedIn && !isAuthRoute) {
          return "/login";
        }

        if (isLoggedIn && isAuthRoute) {
          return "/chat";
        }

        return null;
      },
      routes: [
        GoRoute(
          path: "/splash",
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: "/photo-view",
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final Map<String, dynamic> extra =
                state.extra as Map<String, dynamic>;
            return PhotoViewScreen(
              base64Image: extra['base64Image'] as String,
              heroTag: extra['heroTag'] as String,
            );
          },
        ),
        GoRoute(
          path: "/login",
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => SignupScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return ScaffoldWithNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoverScreen(),
            ),
            GoRoute(
              path: '/chat',
              builder: (context, state) => const RecentChatScreen(),
              routes: [
                GoRoute(
                  path: 'search',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const SearchUserScreen(),
                ),
                GoRoute(
                  path: ':chatId',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final chatId = state.pathParameters['chatId']!;
                    return BlocProvider(
                      create: (context) => ChatBloc(
                        ChatRepository(FirebaseChatDatasource()),
                      ),
                      child: ChatScreen(chatId: chatId),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ]);
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
