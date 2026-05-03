import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_out_use_case.dart';
import 'package:social_app/features/auth/domain/usecases/watch_auth_state_changes_use_case.dart';

part 'app_user_state.dart';

/// App-level cubit that exposes the **current authentication session**
/// to the entire application.
///
/// Responsibilities:
/// - listen to `WatchAuthStateChanges`
/// - expose whether a user is signed in or signed out
/// - provide a global `signOut()` intent
///
/// This cubit does NOT handle authentication flows (sign-in / sign-up).
/// It only reflects session state and is safe to use across all features.
class AppUserCubit extends Cubit<AppUserState> {
  /// Creates a [AppUserCubit].
  AppUserCubit({
    required UserSignOutUseCase userSignOut,
    required WatchAuthStateChanges watchAuthStateChanges,
  }) : _userSignOut = userSignOut,
       _watchAuthStateChanges = watchAuthStateChanges,
       super(AppUserLoading()) {
    _subscribeToAuthStateChanges();
  }
  final UserSignOutUseCase _userSignOut;
  late final StreamSubscription<Either<Failure, UserEntity?>>
  _authStateChangesSub;
  final WatchAuthStateChanges _watchAuthStateChanges;

  @override
  Future<void> close() async {
    try {
      await _authStateChangesSub.cancel();
    } finally {
      await super.close();
    }
  }

  void _subscribeToAuthStateChanges() {
    _authStateChangesSub = _watchAuthStateChanges().listen((
      event,
    ) {
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

    final result = await _userSignOut();
    result.fold(
      (failure) => emit(AppUserFailure(failure.message)),
      (_) => emit(AppUserSignedOut()),
    );
  }
}
