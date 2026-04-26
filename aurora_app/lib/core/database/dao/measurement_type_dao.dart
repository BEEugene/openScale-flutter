import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/models/measurement_type.dart';

class MeasurementTypeDao {
  final Database _db;
  static final _uuid = Uuid();

  static const String _selectAll =
      'SELECT * FROM measurement_types ORDER BY sort_order';
  static const String _selectById =
      'SELECT * FROM measurement_types WHERE id = ?';
  static const String _insert =
      'INSERT INTO measurement_types (id, key, name, unit, color, icon, is_enabled, is_pinned, is_derived, sort_order, input_type, is_on_right_y_axis) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
  static const String _update =
      'UPDATE measurement_types SET key = ?, name = ?, unit = ?, color = ?, icon = ?, is_enabled = ?, is_pinned = ?, is_derived = ?, sort_order = ?, input_type = ?, is_on_right_y_axis = ? WHERE id = ?';
  static const String _updateOrder =
      'UPDATE measurement_types SET sort_order = ? WHERE id = ?';
  static const String _count = 'SELECT COUNT(*) as cnt FROM measurement_types';

  MeasurementTypeDao(this._db);

  Future<List<MeasurementType>> getAll() async {
    final rows = await _db.rawQuery(_selectAll);
    return rows.map(MeasurementType.fromMap).toList();
  }

  Future<MeasurementType?> getById(String id) async {
    final rows = await _db.rawQuery(_selectById, [id]);
    if (rows.isEmpty) return null;
    return MeasurementType.fromMap(rows.first);
  }

  Future<String> insert(MeasurementType type) async {
    final id = type.id.isEmpty ? _uuid.v4() : type.id;
    await _db.rawInsert(_insert, [
      id,
      type.key.name,
      type.name,
      type.unit.name,
      type.color,
      type.icon,
      type.isEnabled ? 1 : 0,
      type.isPinned ? 1 : 0,
      type.isDerived ? 1 : 0,
      type.sortOrder,
      type.inputType.name,
      type.isOnRightYAxis ? 1 : 0,
    ]);
    return id;
  }

  Future<void> update(MeasurementType type) async {
    await _db.rawUpdate(_update, [
      type.key.name,
      type.name,
      type.unit.name,
      type.color,
      type.icon,
      type.isEnabled ? 1 : 0,
      type.isPinned ? 1 : 0,
      type.isDerived ? 1 : 0,
      type.sortOrder,
      type.inputType.name,
      type.isOnRightYAxis ? 1 : 0,
      type.id,
    ]);
  }

  Future<void> updateOrder(String id, int sortOrder) async {
    await _db.rawUpdate(_updateOrder, [sortOrder, id]);
  }

  Future<bool> hasDefaults() async {
    final rows = await _db.rawQuery(_count);
    final count = (rows.first['cnt'] as int?) ?? 0;
    return count > 0;
  }

  Future<void> seedDefaults() async {
    if (await hasDefaults()) return;

    final defaults = _buildDefaults();
    for (final type in defaults) {
      await insert(type);
    }
  }

  List<MeasurementType> _buildDefaults() {
    int order = 0;
    return [
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.weight,
        name: 'Weight',
        unit: UnitType.kg,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.bmi,
        name: 'BMI',
        unit: UnitType.none,
        isDerived: true,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.bodyFat,
        name: 'Body Fat',
        unit: UnitType.percent,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.water,
        name: 'Body Water',
        unit: UnitType.percent,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.muscle,
        name: 'Muscle',
        unit: UnitType.percent,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.lbm,
        name: 'Lean Body Mass',
        unit: UnitType.kg,
        isDerived: true,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.bone,
        name: 'Bone Mass',
        unit: UnitType.kg,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.waist,
        name: 'Waist',
        unit: UnitType.cm,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.whr,
        name: 'Waist-Hip Ratio',
        unit: UnitType.none,
        isDerived: true,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.whtr,
        name: 'Waist-Height Ratio',
        unit: UnitType.none,
        isDerived: true,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.hips,
        name: 'Hips',
        unit: UnitType.cm,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.visceralFat,
        name: 'Visceral Fat',
        unit: UnitType.none,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.chest,
        name: 'Chest',
        unit: UnitType.cm,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.thigh,
        name: 'Thigh',
        unit: UnitType.cm,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.biceps,
        name: 'Biceps',
        unit: UnitType.cm,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.neck,
        name: 'Neck',
        unit: UnitType.cm,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.caliper1,
        name: 'Caliper 1',
        unit: UnitType.cm,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.caliper2,
        name: 'Caliper 2',
        unit: UnitType.cm,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.caliper3,
        name: 'Caliper 3',
        unit: UnitType.cm,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.caliper,
        name: 'Body Fat Caliper',
        unit: UnitType.percent,
        isDerived: true,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.bmr,
        name: 'BMR',
        unit: UnitType.kcal,
        isDerived: true,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.tdee,
        name: 'TDEE',
        unit: UnitType.kcal,
        isDerived: true,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.heartRate,
        name: 'Heart Rate',
        unit: UnitType.bpm,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.calories,
        name: 'Calories',
        unit: UnitType.kcal,
        isEnabled: false,
        sortOrder: order++,
      ),
      MeasurementType(
        id: '',
        key: MeasurementTypeKey.comment,
        name: 'Comment',
        unit: UnitType.none,
        inputType: InputFieldType.text,
        isEnabled: false,
        sortOrder: order++,
      ),
    ];
  }
}
