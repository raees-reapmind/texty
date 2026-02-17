import 'package:firebase_core/firebase_core.dart';
import 'package:texty/blocs/profile/profile_bloc.dart';
import 'package:texty/blocs/recent_chats/recent_chats_bloc.dart';
import 'package:texty/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texty/blocs/auth/auth_bloc.dart';
import 'package:texty/core/utils/app_router.dart';
import 'package:texty/data/datasources/firebase_auth_datasource.dart';
import 'package:texty/data/datasources/firebase_chat_datasource.dart';
import 'package:texty/data/repositories/auth_repository.dart';

import 'package:texty/blocs/users/user_bloc.dart';
import 'package:texty/data/datasources/firebase_user_datasource.dart';
import 'package:texty/data/repositories/chat_repository.dart';
import 'package:texty/data/repositories/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseAuthDatasource = FirebaseAuthDatasource();
    final firebaseUserDatasource = FirebaseUserDatasource();
    final firebaseChatDatasource = FirebaseChatDatasource();

    final authRepository = AuthRepository(firebaseAuthDatasource);
    final userRepository = UserRepository(firebaseUserDatasource);
    final chatRepository = ChatRepository(firebaseChatDatasource);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: chatRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(authRepository),
          ),
          BlocProvider(
            create: (context) => UsersBloc(userRepository),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(userRepository),
          ),
          BlocProvider(
            create: (context) => RecentChatsBloc(chatRepository),
          ),
        ],
        child: MaterialApp.router(
          title: 'Texty',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
