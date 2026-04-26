import 'package:openscale/core/bloc/user/user_bloc.dart';
import 'package:openscale/core/database/dao/user_dao.dart';
import 'package:openscale/core/models/user.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _dao;

  UserRepositoryImpl(this._dao);

  @override
  Future<List<User>> getAllUsers() => _dao.getAll();

  @override
  Future<User?> getUserById(String id) => _dao.getById(id);

  @override
  Future<String> insertUser(User user) => _dao.insert(user);

  @override
  Future<void> updateUser(User user) => _dao.update(user);

  @override
  Future<void> deleteUser(String id) => _dao.delete(id);
}
