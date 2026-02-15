import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texty/blocs/users/users_event.dart';
import 'package:texty/blocs/users/users_state.dart';
import 'package:texty/data/repositories/user_repository.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UserRepository userRepository;

  UsersBloc(this.userRepository) : super(UsersInitial()) {
    on<SearchUsers>((event, emit) async {
      userRepository.searchUsers(event.query).listen((users) {
        emit(UsersLoaded(users));
      });
    });
  }
}
