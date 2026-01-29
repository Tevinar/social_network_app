part of 'user_list_bloc.dart';

@immutable
sealed class UserListEvent {}

class ByPageGetUsers extends UserListEvent {
  final int? nextPage;
  ByPageGetUsers({required this.nextPage});
}
