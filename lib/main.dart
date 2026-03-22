import 'package:firebase_auth/firebase_auth.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final AuthRepository _authRepository;
  late final UserRepository _userRepository;
  late final ChatRepository _chatRepository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final firebaseAuthDatasource = FirebaseAuthDatasource();
    final firebaseUserDatasource = FirebaseUserDatasource();
    final firebaseChatDatasource = FirebaseChatDatasource();

    _authRepository = AuthRepository(firebaseAuthDatasource);
    _userRepository = UserRepository(firebaseUserDatasource);
    _chatRepository = ChatRepository(firebaseChatDatasource);

    // Update status to online when app starts if logged in
    _updatePresence(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updatePresence(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updatePresence(true);
    } else {
      _updatePresence(false);
    }
  }

  void _updatePresence(bool isOnline) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userRepository.updateUserStatus(uid, isOnline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _userRepository),
        RepositoryProvider.value(value: _chatRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(_authRepository),
          ),
          BlocProvider(
            create: (context) => UsersBloc(_userRepository),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(_userRepository),
          ),
          BlocProvider(
            create: (context) => RecentChatsBloc(_chatRepository),
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
