import 'package:firebase_core/firebase_core.dart';
import 'package:texty/blocs/chat/chat_bloc.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(AuthRepository(FirebaseAuthDatasource())),
        ),
        BlocProvider(
          create: (context) =>
              UsersBloc(UserRepository(FirebaseUserDatasource())),
        ),
        BlocProvider(
          create: (context) =>
              ChatBloc(ChatRepository(FirebaseChatDatasource())),
        ),
      ],
      child: MaterialApp.router(
        title: 'Texty',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
