import 'dart:async';

import 'package:bloc_app/core/usecases/usecase.dart';
import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:bloc_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bloc_app/features/auth/domain/usecases/user_sign_out.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_user_state.dart';

/// Stores the current authenticated user information
/// And make it available throughout the app
class AppUserCubit extends Cubit<AppUserState> {
  final UserSignOut _userSignOut;
  late final StreamSubscription _authStateChangesSub;
  AuthRepository _authRepository;
  AppUserCubit({
    required UserSignOut userSignOut,
    required AuthRepository authRepository,
  }) : _userSignOut = userSignOut,
       _authRepository = authRepository,
       super(AppUserLoading()) {
    _subscribeToAuthStateChanges();
  }

  @override
  Future<void> close() {
    _authStateChangesSub.cancel();
    return super.close();
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
    await _userSignOut(NoParams());
  }
}
