import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/models/user.dart';
import 'package:openscale/core/bloc/user/user_state.dart';

export 'user_state.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserEvent {
  const LoadUsers();
}

class SelectUser extends UserEvent {
  final String userId;

  const SelectUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddUser extends UserEvent {
  final String name;
  final double height;
  final double goalWeight;
  final DateTime birthday;

  const AddUser({
    required this.name,
    required this.height,
    required this.goalWeight,
    required this.birthday,
  });

  @override
  List<Object?> get props => [name, height, goalWeight, birthday];
}

class UpdateUser extends UserEvent {
  final String id;
  final String name;
  final double height;
  final double goalWeight;
  final DateTime birthday;

  const UpdateUser({
    required this.id,
    required this.name,
    required this.height,
    required this.goalWeight,
    required this.birthday,
  });

  @override
  List<Object?> get props => [id, name, height, goalWeight, birthday];
}

class DeleteUser extends UserEvent {
  final String userId;

  const DeleteUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

abstract class UserRepository {
  Future<List<User>> getAllUsers();
  Future<User?> getUserById(String id);
  Future<String> insertUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String id);
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;

  UserBloc(this._repository) : super(const UserState()) {
    on<LoadUsers>(_onLoadUsers);
    on<SelectUser>(_onSelectUser);
    on<AddUser>(_onAddUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final users = await _repository.getAllUsers();
      final selectedUser = users.isNotEmpty ? users.first : null;
      emit(
        state.copyWith(
          users: users,
          selectedUser: selectedUser,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSelectUser(SelectUser event, Emitter<UserState> emit) async {
    try {
      final user = await _repository.getUserById(event.userId);
      emit(state.copyWith(selectedUser: user));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAddUser(AddUser event, Emitter<UserState> emit) async {
    try {
      final user = User(
        id: '',
        name: event.name,
        birthday: event.birthday,
        bodyHeight: event.height,
        gender: Gender.male,
        initialWeight: 0,
        goalWeight: event.goalWeight,
        scaleUnit: UnitType.kg,
        activityLevel: ActivityLevel.sedentary,
      );
      await _repository.insertUser(user);
      final users = await _repository.getAllUsers();
      final added = users.where((u) => u.name == event.name).lastOrNull;
      emit(state.copyWith(users: users, selectedUser: added));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    try {
      final existing = await _repository.getUserById(event.id);
      final user =
          (existing ??
                  User(
                    id: event.id,
                    name: event.name,
                    birthday: event.birthday,
                    bodyHeight: event.height,
                    gender: Gender.male,
                    initialWeight: 0,
                    goalWeight: event.goalWeight,
                    scaleUnit: UnitType.kg,
                    activityLevel: ActivityLevel.sedentary,
                  ))
              .copyWith(
                name: event.name,
                bodyHeight: event.height,
                goalWeight: event.goalWeight,
                birthday: event.birthday,
              );
      await _repository.updateUser(user);
      final users = await _repository.getAllUsers();
      emit(state.copyWith(users: users, selectedUser: user));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    try {
      await _repository.deleteUser(event.userId);
      final users = await _repository.getAllUsers();
      final selectedUser = state.selectedUser?.id == event.userId
          ? (users.isNotEmpty ? users.first : null)
          : state.selectedUser;
      emit(state.copyWith(users: users, selectedUser: selectedUser));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
