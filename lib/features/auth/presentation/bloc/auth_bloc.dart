import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_in.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_up.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Feature BLoC responsible for **authentication flows**.
///
/// Responsibilities:
/// - handle user intents (sign up, sign in)
/// - execute auth use cases
/// - react to auth session changes from the repository
///
/// This bloc owns **authentication logic**, but not global session state.
/// Global access to the current user is handled by `AppUserCubit`.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates a [AuthBloc].
  AuthBloc({
    required UserSignUp userSignUp,
    required UserSignIn userSignIn,
    required AuthRepository authRepository,
  }) : _authRepository = authRepository,
       _userSignUp = userSignUp,
       _userSignIn = userSignIn,
       super(AuthLoading()) {
    on<AuthSignup>(_onAuthSignUp);
    on<AuthSignIn>(_onAuthSignIn);
    on<_AuthStateChanged>(_onAuthStateChanged);

    _subscribeToAuthStateChanges();
  }
  final UserSignUp _userSignUp;
  final UserSignIn _userSignIn;
  final AuthRepository _authRepository;
  late final StreamSubscription<Either<Failure, User?>> _authStateChangesSub;

  @override
  Future<void> close() async {
    try {
      await _authStateChangesSub.cancel();
    } finally {
      await super.close();
    }
  }

  void _onAuthStateChanged(_AuthStateChanged event, Emitter<AuthState> emit) {
    event.authState.fold((failure) => emit(AuthFailure(failure.message)), (
      user,
    ) {
      if (user == null) {
        emit(AuthSignedOut());
      } else {
        emit(AuthSignedIn(user));
      }
    });
  }

  void _subscribeToAuthStateChanges() {
    _authStateChangesSub = _authRepository.authStateChanges().listen(
      (event) => add(_AuthStateChanged(event)),
    );
  }

  Future<void> _onAuthSignUp(AuthSignup event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignUp(
      UserSignUpParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSignedIn(user)),
    );
  }

  Future<void> _onAuthSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignIn(
      UserSignInParams(email: event.email, password: event.password),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSignedIn(user)),
    );
  }
}
