import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texty/blocs/profile/profile_event.dart';
import 'package:texty/blocs/profile/profile_state.dart';
import 'package:texty/data/repositories/user_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc(this.userRepository) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      debugPrint("ProfileBloc: Loading profile for ${event.uid}");
      await emit.forEach(
        userRepository.getUserStream(event.uid),
        onData: (user) {
          debugPrint("ProfileBloc: Received user update: $user");
          if (user != null) {
            return ProfileLoaded(user);
          } else {
            return const ProfileError("User not found");
          }
        },
        onError: (e, stack) => ProfileError(e.toString()),
      );
    });

    on<UpdateProfile>((event, emit) async {
      emit(ProfileUpdating());
      try {
        final Map<String, dynamic> updateData = {
          'name': event.name,
          'searchName': event.name.toLowerCase(),
        };

        if (event.profilePictureBase64 != null) {
          updateData['profilePictureUrl'] = event.profilePictureBase64;
        }

        await userRepository.updateUserProfile(event.uid, updateData);

        // Reload fresh data after update
        final user = await userRepository.getUserData(event.uid);
        if (user != null) {
          emit(ProfileUpdated(user));
        } else {
          emit(const ProfileError("Failed to reload profile after update"));
        }
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
