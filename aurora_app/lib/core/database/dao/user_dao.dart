import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:openscale/core/models/user.dart';

class UserDao {
  final Database _db;
  static final _uuid = Uuid();

  static const String _selectAll = 'SELECT * FROM users ORDER BY name';
  static const String _selectById = 'SELECT * FROM users WHERE id = ?';
  static const String _insert =
      'INSERT INTO users (id, name, birthday, body_height, gender, initial_weight, goal_weight, scale_unit, activity_level) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';
  static const String _update =
      'UPDATE users SET name = ?, birthday = ?, body_height = ?, gender = ?, initial_weight = ?, goal_weight = ?, scale_unit = ?, activity_level = ? WHERE id = ?';
  static const String _delete = 'DELETE FROM users WHERE id = ?';

  UserDao(this._db);

  Future<List<User>> getAll() async {
    final rows = await _db.rawQuery(_selectAll);
    return rows.map(User.fromMap).toList();
  }

  Future<User?> getById(String id) async {
    final rows = await _db.rawQuery(_selectById, [id]);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<String> insert(User user) async {
    final id = user.id.isEmpty ? _uuid.v4() : user.id;
    final withId = user.copyWith(id: id);
    await _db.rawInsert(_insert, [
      withId.id,
      withId.name,
      withId.birthday.millisecondsSinceEpoch,
      withId.bodyHeight,
      withId.gender.name,
      withId.initialWeight,
      withId.goalWeight,
      withId.scaleUnit.name,
      withId.activityLevel.value,
    ]);
    return id;
  }

  Future<void> update(User user) async {
    await _db.rawUpdate(_update, [
      user.name,
      user.birthday.millisecondsSinceEpoch,
      user.bodyHeight,
      user.gender.name,
      user.initialWeight,
      user.goalWeight,
      user.scaleUnit.name,
      user.activityLevel.value,
      user.id,
    ]);
  }

  Future<void> delete(String id) async {
    await _db.rawDelete(_delete, [id]);
  }
}
