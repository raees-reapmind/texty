import 'package:firebase_core/firebase_core.dart';
import 'package:texty/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texty/blocs/auth/auth_bloc.dart';
import 'package:texty/core/utils/app_router.dart';
import 'package:texty/data/datasources/firebase_auth_datasource.dart';
import 'package:texty/data/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(AuthRepository(FirebaseAuthDatasource())),
      child: MaterialApp.router(
        title: 'Texty',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
