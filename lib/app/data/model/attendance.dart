import 'package:presensi_smkn1_punggelan/app/module/entity/attendance.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';
part 'attendance.freezed.dart';

AttendanceEntity? _attendanceFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return AttendanceEntity.fromJson(json);
}

Map<String, dynamic>? _attendanceToJson(AttendanceEntity? entity) {
  if (entity == null) return null;
  return entity.toJson();
}

List<AttendanceEntity> _attendanceListFromJson(List<dynamic> json) {
  return json.map((e) => AttendanceEntity.fromJson(e as Map<String, dynamic>)).toList();
}

List<Map<String, dynamic>> _attendanceListToJson(List<AttendanceEntity> entities) {
  return entities.map((e) => e.toJson()).toList();
}

@freezed
class AttendanceModel with _$AttendanceModel {
  const factory AttendanceModel({
    @JsonKey(fromJson: _attendanceFromJson, toJson: _attendanceToJson)
    AttendanceEntity? today,
    @JsonKey(name: 'this_month', fromJson: _attendanceListFromJson, toJson: _attendanceListToJson)
    required List<AttendanceEntity> thisMonth,
  }) = _AttendanceModel;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);
}
