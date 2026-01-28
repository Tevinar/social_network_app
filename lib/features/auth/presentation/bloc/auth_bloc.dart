import 'package:bloc_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:bloc_app/core/usecase/usecase.dart';
import 'package:bloc_app/core/common/entities/user.dart';
import 'package:bloc_app/features/auth/domain/usecases/current_user.dart';
import 'package:bloc_app/features/auth/domain/usecases/user_sign_in.dart';
import 'package:bloc_app/features/auth/domain/usecases/user_sign_out.dart';
import 'package:bloc_app/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserSignIn _userSignIn;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  final UserSignOut _userSignOut;
  AuthBloc({
    required UserSignUp userSignUp,
    required UserSignIn userSignIn,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
    required UserSignOut userSignOut,
  }) : _userSignUp = userSignUp,
       _userSignIn = userSignIn,
       _currentUser = currentUser,
       _appUserCubit = appUserCubit,
       _userSignOut = userSignOut,
       super(AuthLoading()) {
    on<AuthEvent>(_onAuthLoading);
    on<AuthSignup>(_onAuthSignUp);
    on<AuthSignIn>(_onAuthSignIn);
    on<AuthSignOut>(_onAuthSignOut);
    on<AuthCurrentUser>(_onAuthCurrentUser);
  }

  void _onAuthSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    final res = await _userSignOut(NoParams());
    res.fold(
      (l) => _emitAuthFailure(l.message, emit),
      (r) => _emitAuthSignedOut(emit),
    );
  }

  void _onAuthSignUp(AuthSignup event, Emitter<AuthState> emit) async {
    final res = await _userSignUp(
      UserSignUpParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    res.fold(
      (l) => _emitAuthFailure(l.message, emit),
      (r) => _emitAuthSignedIn(r, emit),
    );
  }

  void _onAuthSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
    final res = await _userSignIn(
      UserSignInParams(email: event.email, password: event.password),
    );

    res.fold(
      (l) => _emitAuthFailure(l.message, emit),
      (r) => _emitAuthSignedIn(r, emit),
    );
  }

  void _onAuthCurrentUser(
    AuthCurrentUser event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _currentUser(NoParams());
    res.fold(
      (_) => _emitAuthSignedOut(emit),
      (user) => _emitAuthSignedIn(user, emit),
    );
  }

  // A helper method to emit AuthSignedIn state and update AppUserCubit with user
  void _emitAuthSignedIn(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSignedIn(user));
  }

  // A helper method to emit AuthFailure state and update AppUserCubit with failure
  void _emitAuthFailure(String error, Emitter<AuthState> emit) {
    emit(AuthFailure(error));
    _appUserCubit.userFailure(error);
  }

  // A helper method to emit AuthLoading state and update AppUserCubit to loading
  void _onAuthLoading(AuthEvent event, Emitter<AuthState> emit) {
    emit(AuthLoading());
    _appUserCubit.userLoading();
  }

  void _emitAuthSignedOut(Emitter<AuthState> emit) {
    emit(AuthSignedOut());
    _appUserCubit.updateUser(null);
  }
}
