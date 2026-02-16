import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texty/blocs/users/users_event.dart';
import 'package:texty/blocs/users/users_state.dart';
import 'package:texty/data/repositories/user_repository.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UserRepository userRepository;

  UsersBloc(this.userRepository) : super(UsersInitial()) {
    on<SearchUsers>((event, emit) async {
      print("UsersBloc: Received SearchUsers event with query: ${event.query}");
      emit(UsersLoading());
      await emit.forEach(
        userRepository.searchUsers(event.query),
        onData: (users) {
          print("UsersBloc: Emitting UsersLoaded with ${users.length} users");
          return UsersLoaded(users);
        },
        onError: (error, stackTrace) {
          print("UsersBloc: Error searching users: $error");
          return UsersError(error.toString());
        },
      );
    });

    on<ClearSearch>((event, emit) {
      print(
          "UsersBloc: Received ClearSearch event. Resetting to UsersInitial.");
      emit(UsersInitial());
    });
  }
}
