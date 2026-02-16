import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texty/blocs/auth/auth_event.dart';
import 'package:texty/blocs/auth/auth_states.dart';
import 'package:texty/data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthStates> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      print("AuthBloc: Emitted AuthLoading");
      try {
        print(
            "AuthBloc: Calling repository.signUp with name: ${event.name}, email: ${event.email}");
        final user =
            await repository.signUp(event.name, event.email, event.password, profilePicture: event.profilePicture);
        print("AuthBloc: SignUp successful, user: ${user.uid}");
        emit(AuthAuthenticated(user));
        print("AuthBloc: Emitted AuthAuthenticated");
      } catch (e) {
        print("AuthBloc: Error during sign up: $e");
        emit(AuthError(e.toString()));
        print("AuthBloc: Emitted AuthError");
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.login(event.email, event.password);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await repository.logout();
      emit(AuthUnauthenticated());
    });
  }
}
