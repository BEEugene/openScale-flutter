import 'package:equatable/equatable.dart';
import 'package:openscale/core/models/user.dart';

class UserState extends Equatable {
  final List<User> users;
  final User? selectedUser;
  final bool isLoading;
  final String? error;

  const UserState({
    this.users = const [],
    this.selectedUser,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    List<User>? users,
    User? selectedUser,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      users: users ?? this.users,
      selectedUser: selectedUser ?? this.selectedUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [users, selectedUser, isLoading, error];
}
