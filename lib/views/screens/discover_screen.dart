import 'package:flutter/material.dart';
import 'package:texty/core/theme/app_colors.dart';
import 'package:texty/views/widgets/common_background.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      child: Center(
        child: Text(
          "Discover Screen",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
