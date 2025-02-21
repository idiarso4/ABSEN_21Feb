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

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) {
  return _AttendanceModel.fromJson(json);
}

/// @nodoc
mixin _$AttendanceModel {
  @JsonKey(fromJson: _attendanceFromJson, toJson: _attendanceToJson)
  AttendanceEntity? get today => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'this_month',
      fromJson: _attendanceListFromJson,
      toJson: _attendanceListToJson)
  List<AttendanceEntity> get thisMonth => throw _privateConstructorUsedError;

  /// Serializes this AttendanceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceModelCopyWith<AttendanceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceModelCopyWith<$Res> {
  factory $AttendanceModelCopyWith(
          AttendanceModel value, $Res Function(AttendanceModel) then) =
      _$AttendanceModelCopyWithImpl<$Res, AttendanceModel>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _attendanceFromJson, toJson: _attendanceToJson)
      AttendanceEntity? today,
      @JsonKey(
          name: 'this_month',
          fromJson: _attendanceListFromJson,
          toJson: _attendanceListToJson)
      List<AttendanceEntity> thisMonth});

  $AttendanceEntityCopyWith<$Res>? get today;
}

/// @nodoc
class _$AttendanceModelCopyWithImpl<$Res, $Val extends AttendanceModel>
    implements $AttendanceModelCopyWith<$Res> {
  _$AttendanceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? today = freezed,
    Object? thisMonth = null,
  }) {
    return _then(_value.copyWith(
      today: freezed == today
          ? _value.today
          : today // ignore: cast_nullable_to_non_nullable
              as AttendanceEntity?,
      thisMonth: null == thisMonth
          ? _value.thisMonth
          : thisMonth // ignore: cast_nullable_to_non_nullable
              as List<AttendanceEntity>,
    ) as $Val);
  }

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceEntityCopyWith<$Res>? get today {
    if (_value.today == null) {
      return null;
    }

    return $AttendanceEntityCopyWith<$Res>(_value.today!, (value) {
      return _then(_value.copyWith(today: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AttendanceModelImplCopyWith<$Res>
    implements $AttendanceModelCopyWith<$Res> {
  factory _$$AttendanceModelImplCopyWith(_$AttendanceModelImpl value,
          $Res Function(_$AttendanceModelImpl) then) =
      __$$AttendanceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _attendanceFromJson, toJson: _attendanceToJson)
      AttendanceEntity? today,
      @JsonKey(
          name: 'this_month',
          fromJson: _attendanceListFromJson,
          toJson: _attendanceListToJson)
      List<AttendanceEntity> thisMonth});

  @override
  $AttendanceEntityCopyWith<$Res>? get today;
}

/// @nodoc
class __$$AttendanceModelImplCopyWithImpl<$Res>
    extends _$AttendanceModelCopyWithImpl<$Res, _$AttendanceModelImpl>
    implements _$$AttendanceModelImplCopyWith<$Res> {
  __$$AttendanceModelImplCopyWithImpl(
      _$AttendanceModelImpl _value, $Res Function(_$AttendanceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? today = freezed,
    Object? thisMonth = null,
  }) {
    return _then(_$AttendanceModelImpl(
      today: freezed == today
          ? _value.today
          : today // ignore: cast_nullable_to_non_nullable
              as AttendanceEntity?,
      thisMonth: null == thisMonth
          ? _value._thisMonth
          : thisMonth // ignore: cast_nullable_to_non_nullable
              as List<AttendanceEntity>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceModelImpl implements _AttendanceModel {
  const _$AttendanceModelImpl(
      {@JsonKey(fromJson: _attendanceFromJson, toJson: _attendanceToJson)
      this.today,
      @JsonKey(
          name: 'this_month',
          fromJson: _attendanceListFromJson,
          toJson: _attendanceListToJson)
      required final List<AttendanceEntity> thisMonth})
      : _thisMonth = thisMonth;

  factory _$AttendanceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceModelImplFromJson(json);

  @override
  @JsonKey(fromJson: _attendanceFromJson, toJson: _attendanceToJson)
  final AttendanceEntity? today;
  final List<AttendanceEntity> _thisMonth;
  @override
  @JsonKey(
      name: 'this_month',
      fromJson: _attendanceListFromJson,
      toJson: _attendanceListToJson)
  List<AttendanceEntity> get thisMonth {
    if (_thisMonth is EqualUnmodifiableListView) return _thisMonth;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_thisMonth);
  }

  @override
  String toString() {
    return 'AttendanceModel(today: $today, thisMonth: $thisMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceModelImpl &&
            (identical(other.today, today) || other.today == today) &&
            const DeepCollectionEquality()
                .equals(other._thisMonth, _thisMonth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, today, const DeepCollectionEquality().hash(_thisMonth));

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceModelImplCopyWith<_$AttendanceModelImpl> get copyWith =>
      __$$AttendanceModelImplCopyWithImpl<_$AttendanceModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceModelImplToJson(
      this,
    );
  }
}

abstract class _AttendanceModel implements AttendanceModel {
  const factory _AttendanceModel(
      {@JsonKey(fromJson: _attendanceFromJson, toJson: _attendanceToJson)
      final AttendanceEntity? today,
      @JsonKey(
          name: 'this_month',
          fromJson: _attendanceListFromJson,
          toJson: _attendanceListToJson)
      required final List<AttendanceEntity> thisMonth}) = _$AttendanceModelImpl;

  factory _AttendanceModel.fromJson(Map<String, dynamic> json) =
      _$AttendanceModelImpl.fromJson;

  @override
  @JsonKey(fromJson: _attendanceFromJson, toJson: _attendanceToJson)
  AttendanceEntity? get today;
  @override
  @JsonKey(
      name: 'this_month',
      fromJson: _attendanceListFromJson,
      toJson: _attendanceListToJson)
  List<AttendanceEntity> get thisMonth;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceModelImplCopyWith<_$AttendanceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
