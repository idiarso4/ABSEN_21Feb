import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';
part 'attendance.freezed.dart';

@freezed
@JsonSerializable()
class AttendanceEntity with _$AttendanceEntity {
  const factory AttendanceEntity({
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    String? date
  }) = _AttendanceEntity;

  factory AttendanceEntity.fromJson(Map<String, dynamic> json) =>
      _$AttendanceEntityFromJson(json);
}

@freezed
@JsonSerializable()
class AttendanceParamEntity with _$AttendanceParamEntity {
  const factory AttendanceParamEntity({
    required double latitude,
    required double longitude
  }) = _AttendanceParamEntity;

  factory AttendanceParamEntity.fromJson(Map<String, dynamic> json) =>
      _$AttendanceParamEntityFromJson(json);
}

@freezed
@JsonSerializable()
class AttendanceParamGetEntity with _$AttendanceParamGetEntity {
  const factory AttendanceParamGetEntity({
    required int month,
    required int year
  }) = _AttendanceParamGetEntity;

  factory AttendanceParamGetEntity.fromJson(Map<String, dynamic> json) =>
      _$AttendanceParamGetEntityFromJson(json);
}
