import 'package:texty/models/user_model.dart';

abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoaded extends UsersState {
  final List<UserModel> users;
  UsersLoaded(this.users);
}
