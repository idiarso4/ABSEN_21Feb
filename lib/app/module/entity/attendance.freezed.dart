// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AttendanceEntity _$AttendanceEntityFromJson(Map<String, dynamic> json) {
  return _AttendanceEntity.fromJson(json);
}

/// @nodoc
mixin _$AttendanceEntity {
  @JsonKey(name: 'start_time')
  String get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  String get endTime => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;

  /// Serializes this AttendanceEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceEntityCopyWith<AttendanceEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceEntityCopyWith<$Res> {
  factory $AttendanceEntityCopyWith(
          AttendanceEntity value, $Res Function(AttendanceEntity) then) =
      _$AttendanceEntityCopyWithImpl<$Res, AttendanceEntity>;
  @useResult
  $Res call(
      {@JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String endTime,
      String? date});
}

/// @nodoc
class _$AttendanceEntityCopyWithImpl<$Res, $Val extends AttendanceEntity>
    implements $AttendanceEntityCopyWith<$Res> {
  _$AttendanceEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
    Object? date = freezed,
  }) {
    return _then(_value.copyWith(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AttendanceEntityImplCopyWith<$Res>
    implements $AttendanceEntityCopyWith<$Res> {
  factory _$$AttendanceEntityImplCopyWith(_$AttendanceEntityImpl value,
          $Res Function(_$AttendanceEntityImpl) then) =
      __$$AttendanceEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String endTime,
      String? date});
}

/// @nodoc
class __$$AttendanceEntityImplCopyWithImpl<$Res>
    extends _$AttendanceEntityCopyWithImpl<$Res, _$AttendanceEntityImpl>
    implements _$$AttendanceEntityImplCopyWith<$Res> {
  __$$AttendanceEntityImplCopyWithImpl(_$AttendanceEntityImpl _value,
      $Res Function(_$AttendanceEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of AttendanceEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
    Object? date = freezed,
  }) {
    return _then(_$AttendanceEntityImpl(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceEntityImpl implements _AttendanceEntity {
  const _$AttendanceEntityImpl(
      {@JsonKey(name: 'start_time') required this.startTime,
      @JsonKey(name: 'end_time') required this.endTime,
      this.date});

  factory _$AttendanceEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceEntityImplFromJson(json);

  @override
  @JsonKey(name: 'start_time')
  final String startTime;
  @override
  @JsonKey(name: 'end_time')
  final String endTime;
  @override
  final String? date;

  @override
  String toString() {
    return 'AttendanceEntity(startTime: $startTime, endTime: $endTime, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceEntityImpl &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, startTime, endTime, date);

  /// Create a copy of AttendanceEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceEntityImplCopyWith<_$AttendanceEntityImpl> get copyWith =>
      __$$AttendanceEntityImplCopyWithImpl<_$AttendanceEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceEntityImplToJson(
      this,
    );
  }
}

abstract class _AttendanceEntity implements AttendanceEntity {
  const factory _AttendanceEntity(
      {@JsonKey(name: 'start_time') required final String startTime,
      @JsonKey(name: 'end_time') required final String endTime,
      final String? date}) = _$AttendanceEntityImpl;

  factory _AttendanceEntity.fromJson(Map<String, dynamic> json) =
      _$AttendanceEntityImpl.fromJson;

  @override
  @JsonKey(name: 'start_time')
  String get startTime;
  @override
  @JsonKey(name: 'end_time')
  String get endTime;
  @override
  String? get date;

  /// Create a copy of AttendanceEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceEntityImplCopyWith<_$AttendanceEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AttendanceParamEntity _$AttendanceParamEntityFromJson(
    Map<String, dynamic> json) {
  return _AttendanceParamEntity.fromJson(json);
}

/// @nodoc
mixin _$AttendanceParamEntity {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this AttendanceParamEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceParamEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceParamEntityCopyWith<AttendanceParamEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceParamEntityCopyWith<$Res> {
  factory $AttendanceParamEntityCopyWith(AttendanceParamEntity value,
          $Res Function(AttendanceParamEntity) then) =
      _$AttendanceParamEntityCopyWithImpl<$Res, AttendanceParamEntity>;
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class _$AttendanceParamEntityCopyWithImpl<$Res,
        $Val extends AttendanceParamEntity>
    implements $AttendanceParamEntityCopyWith<$Res> {
  _$AttendanceParamEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceParamEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(_value.copyWith(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AttendanceParamEntityImplCopyWith<$Res>
    implements $AttendanceParamEntityCopyWith<$Res> {
  factory _$$AttendanceParamEntityImplCopyWith(
          _$AttendanceParamEntityImpl value,
          $Res Function(_$AttendanceParamEntityImpl) then) =
      __$$AttendanceParamEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class __$$AttendanceParamEntityImplCopyWithImpl<$Res>
    extends _$AttendanceParamEntityCopyWithImpl<$Res,
        _$AttendanceParamEntityImpl>
    implements _$$AttendanceParamEntityImplCopyWith<$Res> {
  __$$AttendanceParamEntityImplCopyWithImpl(_$AttendanceParamEntityImpl _value,
      $Res Function(_$AttendanceParamEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of AttendanceParamEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(_$AttendanceParamEntityImpl(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceParamEntityImpl implements _AttendanceParamEntity {
  const _$AttendanceParamEntityImpl(
      {required this.latitude, required this.longitude});

  factory _$AttendanceParamEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceParamEntityImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'AttendanceParamEntity(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceParamEntityImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  /// Create a copy of AttendanceParamEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceParamEntityImplCopyWith<_$AttendanceParamEntityImpl>
      get copyWith => __$$AttendanceParamEntityImplCopyWithImpl<
          _$AttendanceParamEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceParamEntityImplToJson(
      this,
    );
  }
}

abstract class _AttendanceParamEntity implements AttendanceParamEntity {
  const factory _AttendanceParamEntity(
      {required final double latitude,
      required final double longitude}) = _$AttendanceParamEntityImpl;

  factory _AttendanceParamEntity.fromJson(Map<String, dynamic> json) =
      _$AttendanceParamEntityImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of AttendanceParamEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceParamEntityImplCopyWith<_$AttendanceParamEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}

AttendanceParamGetEntity _$AttendanceParamGetEntityFromJson(
    Map<String, dynamic> json) {
  return _AttendanceParamGetEntity.fromJson(json);
}

/// @nodoc
mixin _$AttendanceParamGetEntity {
  int get month => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;

  /// Serializes this AttendanceParamGetEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceParamGetEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceParamGetEntityCopyWith<AttendanceParamGetEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceParamGetEntityCopyWith<$Res> {
  factory $AttendanceParamGetEntityCopyWith(AttendanceParamGetEntity value,
          $Res Function(AttendanceParamGetEntity) then) =
      _$AttendanceParamGetEntityCopyWithImpl<$Res, AttendanceParamGetEntity>;
  @useResult
  $Res call({int month, int year});
}

/// @nodoc
class _$AttendanceParamGetEntityCopyWithImpl<$Res,
        $Val extends AttendanceParamGetEntity>
    implements $AttendanceParamGetEntityCopyWith<$Res> {
  _$AttendanceParamGetEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceParamGetEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? year = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AttendanceParamGetEntityImplCopyWith<$Res>
    implements $AttendanceParamGetEntityCopyWith<$Res> {
  factory _$$AttendanceParamGetEntityImplCopyWith(
          _$AttendanceParamGetEntityImpl value,
          $Res Function(_$AttendanceParamGetEntityImpl) then) =
      __$$AttendanceParamGetEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int month, int year});
}

/// @nodoc
class __$$AttendanceParamGetEntityImplCopyWithImpl<$Res>
    extends _$AttendanceParamGetEntityCopyWithImpl<$Res,
        _$AttendanceParamGetEntityImpl>
    implements _$$AttendanceParamGetEntityImplCopyWith<$Res> {
  __$$AttendanceParamGetEntityImplCopyWithImpl(
      _$AttendanceParamGetEntityImpl _value,
      $Res Function(_$AttendanceParamGetEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of AttendanceParamGetEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? year = null,
  }) {
    return _then(_$AttendanceParamGetEntityImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceParamGetEntityImpl implements _AttendanceParamGetEntity {
  const _$AttendanceParamGetEntityImpl(
      {required this.month, required this.year});

  factory _$AttendanceParamGetEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceParamGetEntityImplFromJson(json);

  @override
  final int month;
  @override
  final int year;

  @override
  String toString() {
    return 'AttendanceParamGetEntity(month: $month, year: $year)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceParamGetEntityImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.year, year) || other.year == year));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, month, year);

  /// Create a copy of AttendanceParamGetEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceParamGetEntityImplCopyWith<_$AttendanceParamGetEntityImpl>
      get copyWith => __$$AttendanceParamGetEntityImplCopyWithImpl<
          _$AttendanceParamGetEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceParamGetEntityImplToJson(
      this,
    );
  }
}

abstract class _AttendanceParamGetEntity implements AttendanceParamGetEntity {
  const factory _AttendanceParamGetEntity(
      {required final int month,
      required final int year}) = _$AttendanceParamGetEntityImpl;

  factory _AttendanceParamGetEntity.fromJson(Map<String, dynamic> json) =
      _$AttendanceParamGetEntityImpl.fromJson;

  @override
  int get month;
  @override
  int get year;

  /// Create a copy of AttendanceParamGetEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceParamGetEntityImplCopyWith<_$AttendanceParamGetEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
