import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:texty/views/screens/chat_screen.dart';
import 'package:texty/views/screens/login_screen.dart';
import 'package:texty/views/screens/signup_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
      initialLocation: "/login",
      redirect: (context, state) {
        final isLoggedIn = FirebaseAuth.instance.currentUser != null;
        final isAuthRoute = state.matchedLocation == "/login" ||
            state.matchedLocation == "/signup";

        if (!isLoggedIn && !isAuthRoute) {
          return "/login";
        }

        if (isLoggedIn && isAuthRoute) {
          return "/chat/global_chat";
        }

        return null;
      },
      routes: [
        GoRoute(
          path: "/login",
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => SignupScreen(),
        ),
        GoRoute(
          path: '/chat/:chatId',
          builder: (context, state) {
            final chatId = state.pathParameters['chatId']!;
            return ChatScreen(chatId: chatId);
          },
        ),
      ]);
}
