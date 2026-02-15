import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:texty/blocs/auth/auth_bloc.dart';
import 'package:texty/blocs/auth/auth_event.dart';
import 'package:texty/core/theme/app_colors.dart';
import 'package:texty/views/widgets/common_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            "Settings",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.logout, color: AppColors.accentPink),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      color: AppColors.accentPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    context.read<AuthBloc>().add(LogoutEvent());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
