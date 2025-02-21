// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceEntity _$AttendanceEntityFromJson(Map<String, dynamic> json) =>
    AttendanceEntity(
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$AttendanceEntityToJson(AttendanceEntity instance) =>
    <String, dynamic>{
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'date': instance.date,
    };

AttendanceParamEntity _$AttendanceParamEntityFromJson(
        Map<String, dynamic> json) =>
    AttendanceParamEntity(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$AttendanceParamEntityToJson(
        AttendanceParamEntity instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

AttendanceParamGetEntity _$AttendanceParamGetEntityFromJson(
        Map<String, dynamic> json) =>
    AttendanceParamGetEntity(
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
    );

Map<String, dynamic> _$AttendanceParamGetEntityToJson(
        AttendanceParamGetEntity instance) =>
    <String, dynamic>{
      'month': instance.month,
      'year': instance.year,
    };

_$AttendanceEntityImpl _$$AttendanceEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$AttendanceEntityImpl(
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$$AttendanceEntityImplToJson(
        _$AttendanceEntityImpl instance) =>
    <String, dynamic>{
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'date': instance.date,
    };

_$AttendanceParamEntityImpl _$$AttendanceParamEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$AttendanceParamEntityImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$$AttendanceParamEntityImplToJson(
        _$AttendanceParamEntityImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_$AttendanceParamGetEntityImpl _$$AttendanceParamGetEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$AttendanceParamGetEntityImpl(
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
    );

Map<String, dynamic> _$$AttendanceParamGetEntityImplToJson(
        _$AttendanceParamGetEntityImpl instance) =>
    <String, dynamic>{
      'month': instance.month,
      'year': instance.year,
    };
