import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texty/blocs/auth/auth_event.dart';
import 'package:texty/blocs/auth/auth_states.dart';
import 'package:texty/data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthStates> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>((event, emit) async {
      print("AuthBloc: Checking auth status...");
      try {
        final user = await repository.getCurrentUser();
        if (user != null) {
          print("AuthBloc: Found existing session for user: ${user.uid}");
          emit(AuthAuthenticated(user));
        } else {
          print("AuthBloc: No existing session found");
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        print("AuthBloc: Error checking auth status: $e");
        emit(AuthUnauthenticated());
      }
    });

    // Check for existing session on startup
    add(CheckAuthStatusEvent());

    on<SignUpEvent>((event, emit) async {
      // Fail-safe validation
      final emailRegex = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
      if (!emailRegex.hasMatch(event.email)) {
        emit(AuthError("Invalid email format"));
        return;
      }

      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(event.name.trim())) {
        emit(AuthError("Name can only contain alphabets and spaces"));
        return;
      }

      if (event.password.length < 6 ||
          !RegExp(r'[A-Z]').hasMatch(event.password) ||
          !RegExp(r'[a-z]').hasMatch(event.password) ||
          !RegExp(r'[0-9]').hasMatch(event.password) ||
          !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(event.password)) {
        emit(AuthError(
            "Password does not meet complexity requirements (6+ chars, uppercase, lowercase, number, special char)"));
        return;
      }

      emit(AuthLoading());
      print("AuthBloc: Emitted AuthLoading");
      try {
        print(
            "AuthBloc: Calling repository.signUp with name: ${event.name}, email: ${event.email}");
        final user = await repository.signUp(
            event.name, event.email, event.password,
            profilePicture: event.profilePicture);
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
