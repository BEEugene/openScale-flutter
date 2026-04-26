import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/models/user.dart';
import 'package:openscale/core/bloc/user/user_bloc.dart';
import 'package:openscale/core/bloc/user/user_state.dart';

class FakeUserRepository extends UserRepository {
  List<User> _users = [];
  Object? _getAllError;
  Object? _getByIdError;
  Object? _insertError;
  Object? _updateError;
  Object? _deleteError;

  void setUsers(List<User> users) => _users = List.from(users);

  void setGetAllError(Object error) => _getAllError = error;
  void setGetByIdError(Object error) => _getByIdError = error;
  void setInsertError(Object error) => _insertError = error;
  void setUpdateError(Object error) => _updateError = error;
  void setDeleteError(Object error) => _deleteError = error;

  void clearErrors() {
    _getAllError = null;
    _getByIdError = null;
    _insertError = null;
    _updateError = null;
    _deleteError = null;
  }

  @override
  Future<List<User>> getAllUsers() async {
    if (_getAllError != null) throw _getAllError!;
    return List.from(_users);
  }

  @override
  Future<User?> getUserById(String id) async {
    if (_getByIdError != null) throw _getByIdError!;
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> insertUser(User user) async {
    if (_insertError != null) throw _insertError!;
    final inserted = user.copyWith(id: 'gen-${_users.length}');
    _users.add(inserted);
    return inserted.id;
  }

  @override
  Future<void> updateUser(User user) async {
    if (_updateError != null) throw _updateError!;
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      _users[index] = user;
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    if (_deleteError != null) throw _deleteError!;
    _users.removeWhere((u) => u.id == id);
  }
}

User _makeUser({
  String id = 'u-1',
  String name = 'Alice',
  double height = 170.0,
  double goalWeight = 60.0,
  double initialWeight = 65.0,
  Gender gender = Gender.female,
  UnitType unit = UnitType.kg,
  ActivityLevel activity = ActivityLevel.moderate,
}) {
  return User(
    id: id,
    name: name,
    birthday: DateTime(1990, 6, 15),
    bodyHeight: height,
    gender: gender,
    initialWeight: initialWeight,
    goalWeight: goalWeight,
    scaleUnit: unit,
    activityLevel: activity,
  );
}

void main() {
  group('UserBloc', () {
    late FakeUserRepository repository;
    late UserBloc bloc;

    setUp(() {
      repository = FakeUserRepository();
      bloc = UserBloc(repository);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<UserBloc, UserState>(
      'initial state has empty users list, no selectedUser, not loading',
      build: () => bloc,
      verify: (bloc) {
        expect(bloc.state.users, isEmpty);
        expect(bloc.state.selectedUser, isNull);
        expect(bloc.state.isLoading, false);
        expect(bloc.state.error, isNull);
      },
    );

    blocTest<UserBloc, UserState>(
      'LoadUsers emits loading then loaded with users',
      build: () => bloc,
      setUp: () {
        repository.setUsers([
          _makeUser(id: 'u-1', name: 'Alice'),
          _makeUser(id: 'u-2', name: 'Bob'),
        ]);
      },
      act: (bloc) => bloc.add(const LoadUsers()),
      expect: () => [
        const UserState(isLoading: true),
        UserState(
          users: [
            _makeUser(id: 'u-1', name: 'Alice'),
            _makeUser(id: 'u-2', name: 'Bob'),
          ],
          selectedUser: _makeUser(id: 'u-1', name: 'Alice'),
          isLoading: false,
        ),
      ],
    );

    blocTest<UserBloc, UserState>(
      'LoadUsers with empty list selects no user',
      build: () => bloc,
      setUp: () {
        repository.setUsers([]);
      },
      act: (bloc) => bloc.add(const LoadUsers()),
      expect: () => [
        const UserState(isLoading: true),
        const UserState(isLoading: false),
      ],
    );

    blocTest<UserBloc, UserState>(
      'LoadUsers sets error when repository throws',
      build: () => bloc,
      setUp: () {
        repository.setGetAllError(Exception('db error'));
      },
      act: (bloc) => bloc.add(const LoadUsers()),
      expect: () => [
        const UserState(isLoading: true),
        const UserState(isLoading: false, error: 'Exception: db error'),
      ],
    );

    blocTest<UserBloc, UserState>(
      'SelectUser emits state with selected user',
      build: () => bloc,
      setUp: () {
        repository.setUsers([
          _makeUser(id: 'u-1', name: 'Alice'),
          _makeUser(id: 'u-2', name: 'Bob'),
        ]);
      },
      act: (bloc) => bloc
        ..add(const LoadUsers())
        ..add(const SelectUser('u-2')),
      skip: 2, // skip initial + LoadUsers loading + LoadUsers loaded
      expect: () => [
        UserState(
          users: [
            _makeUser(id: 'u-1', name: 'Alice'),
            _makeUser(id: 'u-2', name: 'Bob'),
          ],
          selectedUser: _makeUser(id: 'u-2', name: 'Bob'),
          isLoading: false,
        ),
      ],
    );

    blocTest<UserBloc, UserState>(
      'SelectUser sets error when repository throws',
      build: () => bloc,
      setUp: () {
        repository.setGetByIdError(Exception('not found'));
      },
      act: (bloc) => bloc..add(const SelectUser('u-missing')),
      expect: () => [UserState(error: 'Exception: not found')],
    );

    blocTest<UserBloc, UserState>(
      'AddUser creates user and reloads list',
      build: () => bloc,
      act: (bloc) => bloc.add(
        AddUser(
          name: 'Charlie',
          height: 180.0,
          goalWeight: 75.0,
          birthday: DateTime(1985, 1, 20),
        ),
      ),
      expect: () => [
        isA<UserState>()
            .having((s) => s.users.length, 'users count', 1)
            .having((s) => s.users.first.name, 'user name', 'Charlie')
            .having((s) => s.selectedUser?.name, 'selected name', 'Charlie'),
      ],
    );

    blocTest<UserBloc, UserState>(
      'AddUser sets error when repository throws',
      build: () => bloc,
      setUp: () {
        repository.setInsertError(Exception('insert failed'));
      },
      act: (bloc) => bloc.add(
        AddUser(
          name: 'Dave',
          height: 175.0,
          goalWeight: 70.0,
          birthday: DateTime(1995, 3, 10),
        ),
      ),
      expect: () => [
        isA<UserState>().having(
          (s) => s.error,
          'error',
          'Exception: insert failed',
        ),
      ],
    );

    blocTest<UserBloc, UserState>(
      'UpdateUser updates existing user and reloads',
      build: () => bloc,
      setUp: () {
        repository.setUsers([_makeUser(id: 'u-1', name: 'Alice')]);
      },
      act: (bloc) => bloc
        ..add(const LoadUsers())
        ..add(
          UpdateUser(
            id: 'u-1',
            name: 'Alicia',
            height: 171.0,
            goalWeight: 59.0,
            birthday: DateTime(1990, 6, 15),
          ),
        ),
      skip: 3, // skip LoadUsers loading + loaded + UpdateUser internal
      verify: (bloc) {
        expect(bloc.state.users.any((u) => u.name == 'Alicia'), true);
      },
    );

    blocTest<UserBloc, UserState>(
      'UpdateUser sets error when repository throws',
      build: () => bloc,
      setUp: () {
        repository.setUpdateError(Exception('update failed'));
      },
      act: (bloc) => bloc.add(
        UpdateUser(
          id: 'u-1',
          name: 'Alicia',
          height: 171.0,
          goalWeight: 59.0,
          birthday: DateTime(1990, 6, 15),
        ),
      ),
      expect: () => [
        isA<UserState>().having(
          (s) => s.error,
          'error',
          'Exception: update failed',
        ),
      ],
    );

    blocTest<UserBloc, UserState>(
      'DeleteUser removes user and selects next',
      build: () => bloc,
      setUp: () {
        repository.setUsers([
          _makeUser(id: 'u-1', name: 'Alice'),
          _makeUser(id: 'u-2', name: 'Bob'),
        ]);
      },
      act: (bloc) => bloc
        ..add(const LoadUsers())
        ..add(const DeleteUser('u-1')),
      skip: 3,
      verify: (bloc) {
        expect(bloc.state.users.length, 1);
        expect(bloc.state.users.first.name, 'Bob');
      },
    );

    blocTest<UserBloc, UserState>(
      'DeleteUser when deleting selected user selects first remaining',
      build: () => bloc,
      setUp: () {
        repository.setUsers([
          _makeUser(id: 'u-1', name: 'Alice'),
          _makeUser(id: 'u-2', name: 'Bob'),
        ]);
      },
      act: (bloc) => bloc
        ..add(const LoadUsers())
        ..add(const SelectUser('u-1'))
        ..add(const DeleteUser('u-1')),
      skip: 4,
      verify: (bloc) {
        expect(bloc.state.selectedUser?.id, 'u-2');
      },
    );

    blocTest<UserBloc, UserState>(
      'DeleteUser sets error when repository throws',
      build: () => bloc,
      setUp: () {
        repository.setDeleteError(Exception('delete failed'));
      },
      act: (bloc) => bloc.add(const DeleteUser('u-1')),
      expect: () => [
        isA<UserState>().having(
          (s) => s.error,
          'error',
          'Exception: delete failed',
        ),
      ],
    );
  });
}
