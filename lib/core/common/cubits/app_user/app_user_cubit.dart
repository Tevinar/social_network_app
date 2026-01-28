import 'package:bloc_app/core/common/entities/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_user_state.dart';

/// Stores the current authenticated user information
/// And make it available throughout the app
class AppUserCubit extends Cubit<AppUserState> {
  AppUserCubit() : super(AppUserLoading());

  void updateUser(User? user) {
    if (user == null) {
      emit(AppUserSignedOut());
    } else {
      emit(AppUserSignedIn(user));
    }
  }

  void userLoading() {
    emit(AppUserLoading());
  }

  void userFailure(String error) {
    emit(AppUserFailure(error));
  }
}
