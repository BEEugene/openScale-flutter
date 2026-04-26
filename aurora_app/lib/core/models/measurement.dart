import 'package:equatable/equatable.dart';

class Measurement extends Equatable {
  final String id;
  final String userId;
  final DateTime dateTime;
  final String? comment;

  const Measurement({
    required this.id,
    required this.userId,
    required this.dateTime,
    this.comment,
  });

  @override
  List<Object?> get props => [id, userId, dateTime, comment];

  Measurement copyWith({
    String? id,
    String? userId,
    DateTime? dateTime,
    String? comment,
  }) {
    return Measurement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateTime: dateTime ?? this.dateTime,
      comment: comment ?? this.comment,
    );
  }

  factory Measurement.fromMap(Map<String, Object?> map) {
    return Measurement(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['date_time'] as int),
      comment: map['comment'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date_time': dateTime.millisecondsSinceEpoch,
      'comment': comment,
    };
  }
}
