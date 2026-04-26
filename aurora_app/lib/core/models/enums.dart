enum Gender {
  male('Male'),
  female('Female');

  const Gender(this.displayName);

  final String displayName;

  static Gender fromName(String name) => Gender.values.firstWhere(
    (e) => e.name == name,
    orElse: () => Gender.male,
  );
}

enum UnitType {
  kg('kg'),
  lb('lb'),
  st('st'),
  percent('%'),
  cm('cm'),
  inch('in'),
  kcal('kcal'),
  bpm('bpm'),
  none('');

  const UnitType(this.displayName);

  final String displayName;

  bool get isWeightUnit =>
      this == UnitType.kg || this == UnitType.lb || this == UnitType.st;

  static UnitType fromName(String name) => UnitType.values.firstWhere(
    (e) => e.name == name,
    orElse: () => UnitType.none,
  );
}

enum ActivityLevel {
  sedentary(0),
  mild(1),
  moderate(2),
  heavy(3),
  extreme(4);

  const ActivityLevel(this.value);

  final int value;

  static ActivityLevel fromInt(int value) => ActivityLevel.values.firstWhere(
    (e) => e.value == value,
    orElse: () => ActivityLevel.sedentary,
  );
}

enum InputFieldType {
  float,
  int,
  text,
  date,
  time,
  user;

  static InputFieldType fromName(String name) => InputFieldType.values
      .firstWhere((e) => e.name == name, orElse: () => InputFieldType.float);
}

enum MeasurementTypeKey {
  weight(1, [UnitType.kg, UnitType.lb, UnitType.st], [InputFieldType.float]),
  bmi(2, [UnitType.none], [InputFieldType.float]),
  bodyFat(
    3,
    [UnitType.percent, UnitType.kg, UnitType.lb, UnitType.st],
    [InputFieldType.float],
  ),
  water(
    4,
    [UnitType.percent, UnitType.kg, UnitType.lb, UnitType.st],
    [InputFieldType.float],
  ),
  muscle(
    5,
    [UnitType.percent, UnitType.kg, UnitType.lb, UnitType.st],
    [InputFieldType.float],
  ),
  lbm(6, [UnitType.kg, UnitType.lb, UnitType.st], [InputFieldType.float]),
  bone(7, [UnitType.kg, UnitType.lb], [InputFieldType.float]),
  waist(8, [UnitType.cm, UnitType.inch], [InputFieldType.float]),
  whr(9, [UnitType.none], [InputFieldType.float]),
  whtr(10, [UnitType.none], [InputFieldType.float]),
  hips(11, [UnitType.cm, UnitType.inch], [InputFieldType.float]),
  visceralFat(12, [UnitType.none], [InputFieldType.float]),
  chest(13, [UnitType.cm, UnitType.inch], [InputFieldType.float]),
  thigh(14, [UnitType.cm, UnitType.inch], [InputFieldType.float]),
  biceps(15, [UnitType.cm, UnitType.inch], [InputFieldType.float]),
  neck(16, [UnitType.cm, UnitType.inch], [InputFieldType.float]),
  caliper1(17, [UnitType.cm, UnitType.inch], [InputFieldType.float]),
  caliper2(18, [UnitType.cm, UnitType.inch], [InputFieldType.float]),
  caliper3(19, [UnitType.cm, UnitType.inch], [InputFieldType.float]),
  caliper(20, [UnitType.percent], [InputFieldType.float]),
  bmr(21, [UnitType.kcal], [InputFieldType.float]),
  tdee(22, [UnitType.kcal], [InputFieldType.float]),
  heartRate(23, [UnitType.bpm], [InputFieldType.int]),
  calories(24, [UnitType.kcal], [InputFieldType.float]),
  date(25, [UnitType.none], [InputFieldType.date]),
  time(26, [UnitType.none], [InputFieldType.time]),
  comment(27, [UnitType.none], [InputFieldType.text]),
  user(28, [UnitType.none], [InputFieldType.user]),
  custom(
    99,
    [
      UnitType.kg,
      UnitType.lb,
      UnitType.st,
      UnitType.percent,
      UnitType.cm,
      UnitType.inch,
      UnitType.kcal,
      UnitType.bpm,
      UnitType.none,
    ],
    [
      InputFieldType.float,
      InputFieldType.int,
      InputFieldType.text,
      InputFieldType.date,
      InputFieldType.time,
    ],
  );

  const MeasurementTypeKey(
    this.id,
    this.allowedUnitTypes,
    this.allowedInputTypes,
  );

  final int id;
  final List<UnitType> allowedUnitTypes;
  final List<InputFieldType> allowedInputTypes;

  static MeasurementTypeKey fromId(int id) => MeasurementTypeKey.values
      .firstWhere((e) => e.id == id, orElse: () => MeasurementTypeKey.custom);

  static MeasurementTypeKey fromName(String name) =>
      MeasurementTypeKey.values.firstWhere(
        (e) => e.name == name,
        orElse: () => MeasurementTypeKey.custom,
      );
}
