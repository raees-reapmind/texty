import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String uid;
  const LoadProfile(this.uid);

  @override
  List<Object?> get props => [uid];
}

class UpdateProfile extends ProfileEvent {
  final String uid;
  final String name;
  final String? profilePictureBase64;

  const UpdateProfile({
    required this.uid,
    required this.name,
    this.profilePictureBase64,
  });

  @override
  List<Object?> get props => [uid, name, profilePictureBase64];
}
