// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceModelImpl _$$AttendanceModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AttendanceModelImpl(
      today: _attendanceFromJson(json['today'] as Map<String, dynamic>?),
      thisMonth: _attendanceListFromJson(json['this_month'] as List),
    );

Map<String, dynamic> _$$AttendanceModelImplToJson(
        _$AttendanceModelImpl instance) =>
    <String, dynamic>{
      'today': _attendanceToJson(instance.today),
      'this_month': _attendanceListToJson(instance.thisMonth),
    };
