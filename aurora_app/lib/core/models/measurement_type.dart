import 'package:equatable/equatable.dart';
import 'package:openscale/core/models/enums.dart';

class MeasurementType extends Equatable {
  final String id;
  final MeasurementTypeKey key;
  final String name;
  final UnitType unit;
  final int color;
  final String icon;
  final bool isEnabled;
  final bool isPinned;
  final bool isDerived;
  final int sortOrder;
  final InputFieldType inputType;
  final bool isOnRightYAxis;

  const MeasurementType({
    required this.id,
    required this.key,
    required this.name,
    required this.unit,
    this.color = 0,
    this.icon = '',
    this.isEnabled = true,
    this.isPinned = false,
    this.isDerived = false,
    this.sortOrder = 0,
    this.inputType = InputFieldType.float,
    this.isOnRightYAxis = false,
  });

  @override
  List<Object?> get props => [
    id,
    key,
    name,
    unit,
    color,
    icon,
    isEnabled,
    isPinned,
    isDerived,
    sortOrder,
    inputType,
    isOnRightYAxis,
  ];

  MeasurementType copyWith({
    String? id,
    MeasurementTypeKey? key,
    String? name,
    UnitType? unit,
    int? color,
    String? icon,
    bool? isEnabled,
    bool? isPinned,
    bool? isDerived,
    int? sortOrder,
    InputFieldType? inputType,
    bool? isOnRightYAxis,
  }) {
    return MeasurementType(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isEnabled: isEnabled ?? this.isEnabled,
      isPinned: isPinned ?? this.isPinned,
      isDerived: isDerived ?? this.isDerived,
      sortOrder: sortOrder ?? this.sortOrder,
      inputType: inputType ?? this.inputType,
      isOnRightYAxis: isOnRightYAxis ?? this.isOnRightYAxis,
    );
  }

  factory MeasurementType.fromMap(Map<String, Object?> map) {
    return MeasurementType(
      id: map['id'] as String,
      key: MeasurementTypeKey.fromName(map['key'] as String),
      name: (map['name'] as String?) ?? '',
      unit: UnitType.fromName(map['unit'] as String),
      color: map['color'] as int,
      icon: (map['icon'] as String?) ?? '',
      isEnabled: (map['is_enabled'] as int) != 0,
      isPinned: (map['is_pinned'] as int) != 0,
      isDerived: (map['is_derived'] as int) != 0,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      inputType: InputFieldType.fromName(
        (map['input_type'] as String?) ?? 'float',
      ),
      isOnRightYAxis: ((map['is_on_right_y_axis'] as int?) ?? 0) != 0,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'key': key.name,
      'name': name,
      'unit': unit.name,
      'color': color,
      'icon': icon,
      'is_enabled': isEnabled ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
      'is_derived': isDerived ? 1 : 0,
      'sort_order': sortOrder,
      'input_type': inputType.name,
      'is_on_right_y_axis': isOnRightYAxis ? 1 : 0,
    };
  }
}
