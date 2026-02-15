import 'package:equatable/equatable.dart';
import 'package:texty/models/user_model.dart';

abstract class AuthStates extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthStates {}

class AuthLoading extends AuthStates {}

class AuthAuthenticated extends AuthStates {
  final UserModel userModel;
  AuthAuthenticated(this.userModel);
  @override
  List<Object?> get props => [userModel];
}

class AuthError extends AuthStates {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [];
}

class AuthUnauthenticated extends AuthStates {}
