/// Represents a single measurement record from a scale,
/// potentially combined from multiple BLE packets.
///
/// All weights in kg, percentages in %, lengths in kg, rates in bpm.
class ScaleMeasurement {
  final int userId;
  final DateTime dateTime;
  final double weight; // kg
  final double fat; // %
  final double water; // %
  final double muscle; // %
  final double visceralFat; // %
  final double bone; // kg
  final double lbm; // kg
  final double bmr; // kcal
  final int heartRate; // bpm
  final double impedance; // Ohms
  final String? comment;

  ScaleMeasurement({
    this.userId = 0xFF,
    DateTime? dateTime,
    this.weight = 0.0,
    this.fat = 0.0,
    this.water = 0.0,
    this.muscle = 0.0,
    this.visceralFat = 0.0,
    this.bone = 0.0,
    this.lbm = 0.0,
    this.bmr = 0.0,
    this.heartRate = 0,
    this.impedance = 0.0,
    this.comment,
  }) : dateTime = dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);

  bool hasWeight() => weight > 0;

  /// Merge fields from [other] into this measurement.
  /// Only overwrites fields that are zero/missing in this measurement.
  ScaleMeasurement mergeWith(ScaleMeasurement other) {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    return ScaleMeasurement(
      userId: other.userId != 0xFF && (userId == 0xFF || userId == -1)
          ? other.userId
          : userId,
      dateTime: dateTime == epoch ? other.dateTime : dateTime,
      weight: other.weight > 0 && weight <= 0 ? other.weight : weight,
      fat: other.fat > 0 && fat <= 0 ? other.fat : fat,
      water: other.water > 0 && water <= 0 ? other.water : water,
      muscle: other.muscle > 0 && muscle <= 0 ? other.muscle : muscle,
      visceralFat: other.visceralFat > 0 && visceralFat <= 0
          ? other.visceralFat
          : visceralFat,
      bone: other.bone > 0 && bone <= 0 ? other.bone : bone,
      lbm: other.lbm > 0 && lbm <= 0 ? other.lbm : lbm,
      bmr: other.bmr > 0 && bmr <= 0 ? other.bmr : bmr,
      heartRate: other.heartRate > 0 && heartRate <= 0
          ? other.heartRate
          : heartRate,
      impedance: other.impedance > 0 && impedance <= 0
          ? other.impedance
          : impedance,
      comment: comment ?? other.comment,
    );
  }

  ScaleMeasurement copyWith({
    int? userId,
    DateTime? dateTime,
    double? weight,
    double? fat,
    double? water,
    double? muscle,
    double? visceralFat,
    double? bone,
    double? lbm,
    double? bmr,
    int? heartRate,
    double? impedance,
    String? comment,
  }) {
    return ScaleMeasurement(
      userId: userId ?? this.userId,
      dateTime: dateTime ?? this.dateTime,
      weight: weight ?? this.weight,
      fat: fat ?? this.fat,
      water: water ?? this.water,
      muscle: muscle ?? this.muscle,
      visceralFat: visceralFat ?? this.visceralFat,
      bone: bone ?? this.bone,
      lbm: lbm ?? this.lbm,
      bmr: bmr ?? this.bmr,
      heartRate: heartRate ?? this.heartRate,
      impedance: impedance ?? this.impedance,
      comment: comment ?? this.comment,
    );
  }

  @override
  String toString() =>
      'ScaleMeasurement(userId=$userId, weight=$weight kg, fat=$fat%, '
      'water=$water%, muscle=$muscle%, bone=$bone kg, lbm=$lbm kg, '
      'dateTime=$dateTime)';
}
