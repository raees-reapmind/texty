import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:texty/core/theme/app_colors.dart';

class StoryAvatar extends StatelessWidget {
  final String name;
  final String image; // URL or asset path
  final bool isAddStory;
  final String? profilePictureUrl; // Add this field

  const StoryAvatar({
    Key? key,
    required this.name,
    this.image = '',
    this.isAddStory = false,
    this.profilePictureUrl, // Add it to constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: isAddStory
                      ? Border.all(color: Colors.transparent)
                      : Border.all(color: Colors.white, width: 2), // White gap
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0), // Gap if needed
                  child: CircleAvatar(
                    backgroundColor: isAddStory
                        ? AppColors.primaryBlue.withOpacity(0.1)
                        : Colors.grey[200],
                    // backgroundImage: !isAddStory && image.isNotEmpty
                    //     ? NetworkImage(image)
                    //     : null,
                    backgroundImage:
                        (base64Decode(profilePictureUrl ?? '')).isNotEmpty
                            ? MemoryImage(base64Decode(profilePictureUrl!))
                            : null,
                    child: isAddStory
                        ? const Icon(Icons.add, color: AppColors.primaryBlue)
                        : (image.isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary),
                              )
                            : null),
                  ),
                ),
              ),
              if (isAddStory)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
