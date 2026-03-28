import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_out.dart';

part 'app_user_state.dart';

/// App-level cubit that exposes the **current authentication session**
/// to the entire application.
///
/// Responsibilities:
/// - listen to `AuthRepository.authStateChanges()`
/// - expose whether a user is signed in or signed out
/// - provide a global `signOut()` intent
///
/// This cubit does NOT handle authentication flows (sign-in / sign-up).
/// It only reflects session state and is safe to use across all features.
class AppUserCubit extends Cubit<AppUserState> {
  /// Creates a [AppUserCubit].
  AppUserCubit({
    required UserSignOut userSignOut,
    required AuthRepository authRepository,
  }) : _userSignOut = userSignOut,
       _authRepository = authRepository,
       super(AppUserLoading()) {
    _subscribeToAuthStateChanges();
  }
  final UserSignOut _userSignOut;
  late final StreamSubscription<Either<Failure, User?>> _authStateChangesSub;
  final AuthRepository _authRepository;

  @override
  Future<void> close() async {
    try {
      await _authStateChangesSub.cancel();
    } finally {
      await super.close();
    }
  }

  void _subscribeToAuthStateChanges() {
    _authStateChangesSub = _authRepository.authStateChanges().listen((event) {
      event.fold((failure) => emit(AppUserFailure(failure.message)), (user) {
        if (user == null) {
          emit(AppUserSignedOut());
        } else {
          emit(AppUserSignedIn(user));
        }
      });
    });
  }

  /// Global sign-out intent
  Future<void> signOut() async {
    emit(AppUserLoading());

    final result = await _userSignOut(NoParams());
    result.fold(
      (failure) => emit(AppUserFailure(failure.message)),
      (_) => emit(AppUserSignedOut()),
    );
  }
}
