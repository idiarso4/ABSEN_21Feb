import 'dart:async';

import 'package:absen_smkn1_punggelan/app/module/entity/attendance.dart';
import 'package:absen_smkn1_punggelan/app/module/entity/schedule.dart';
import 'package:absen_smkn1_punggelan/app/module/use_case/attendance_send.dart';
import 'package:absen_smkn1_punggelan/app/module/use_case/schedule_banned.dart';
import 'package:absen_smkn1_punggelan/app/module/use_case/schedule_get.dart';
import 'package:absen_smkn1_punggelan/core/helper/date_time_helper.dart';
import 'package:absen_smkn1_punggelan/core/helper/location_helper.dart';
import 'package:absen_smkn1_punggelan/core/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';

class MapNotifier extends AppProvider {
  final ScheduleGetUseCase _scheduleGetUseCase;
  final AttendanceSendUseCase _attendanceSendUseCase;
  final ScheduleBannedUseCase _scheduleBannedUseCase;

  MapNotifier(
    this._scheduleGetUseCase,
    this._attendanceSendUseCase,
    this._scheduleBannedUseCase,
  ) {
    init();
  }

  bool _isSuccess = false;
  bool _isEnableSubmitButton = false;
  MapController _mapController = MapController.withPosition(
    initPosition: GeoPoint(latitude: -6.17549964024, longitude: 106.827149391),
  );
  ScheduleEntity? _schedule;
  late CircleOSM _circle;
  bool _isGrantedLocation = false;
  bool _isEnabledLocation = false;
  late StreamSubscription<Position> _streamCurrentLocation;
  GeoPoint? _currentLocation;

  bool get isSuccess => _isSuccess;
  bool get isEnableSubmitButton => _isEnableSubmitButton;
  MapController get mapController => _mapController;
  ScheduleEntity? get schedule => _schedule;
  bool get isGrantedLocation => _isGrantedLocation;
  bool get isEnabledLocation => _isEnabledLocation;

  @override
  void init() async {
    await _getEnableAndPermission();
    await _getSchedule();
    if (errorMessage == null || (errorMessage?.isEmpty ?? true)) _checkShift();
  }

  Future<void> _getEnableAndPermission() async {
    showLoading();
    _isGrantedLocation = await LocationHelper.isGrantedLocationPermission();
    if (_isGrantedLocation) {
      _isEnabledLocation = await LocationHelper.isEnabledLocationService();
      if (!_isEnabledLocation) {
        errorMessage = 'Harap mengaktifkan GPS';
      }
    } else {
      errorMessage = 'Harap menyetujui permission';
    }
    hideLoading();
  }

  Future<void> _getSchedule() async {
    showLoading();
    final response = await _scheduleGetUseCase();
    if (response.success) {
      _schedule = response.data!;
      _circle = CircleOSM(
        key: 'Center-Point',
        centerPoint: GeoPoint(
          latitude: _schedule!.office.latitude,
          longitude: _schedule!.office.longitude,
        ),
        radius: _schedule!.office.radius,
        color: Colors.red.withOpacity(0.5),
        strokeWidth: 2,
        borderColor: Colors.red,
      );
    } else {
      errorMessage = response.message ?? 'Unknown error';
    }
    hideLoading();
  }

  void _checkShift() {
    final now = DateTime.now();
    final startTimeShift = _schedule!.shift.startTime.split(':');
    final dateTimeShift = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(startTimeShift[0]),
      int.parse(startTimeShift[1]),
      int.parse(startTimeShift[2]),
    );
    if (DateTimeHelper.getDifference(a: now, b: dateTimeShift) >
        const Duration(minutes: 30)) {
      errorMessage =
          'Kehadiran dapat dibuat paling cepat 30 menit sebelum shift dimulai';
    }
  }

  Future<void> checkLocationPermission() async {
    _isGrantedLocation = await LocationHelper.isGrantedLocationPermission();
    if (!_isGrantedLocation && !isDispose) {
      checkLocationPermission();
    } else {
      errorMessage = '';
      init();
    }
  }

  Future<void> checkLocationService() async {
    _isEnabledLocation = await LocationHelper.isEnabledLocationService();
    if (!_isEnabledLocation && !isDispose) {
      checkLocationService();
    } else {
      errorMessage = '';
      init();
    }
  }

  Future<void> mapIsReady() async {
    _openStreamCurrentLocation();
    await mapController.drawCircle(_circle);
  }

  void _openStreamCurrentLocation() {
    _streamCurrentLocation = Geolocator.getPositionStream().listen(
      (position) {
        if (position.isMocked) {
          _closeStreamCurrentLocation();
          _sendBanned();
        } else {
          if (!isDispose && !isLoading) {
            if (_currentLocation != null) {
              _mapController.removeMarker(_currentLocation!);
            }
            _currentLocation = GeoPoint(
              latitude: position.latitude,
              longitude: position.longitude,
            );
            _mapController.addMarker(
              _currentLocation!,
              markerIcon: MarkerIcon(
                icon: const Icon(
                  Icons.account_circle,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            );
            _mapController.moveTo(_currentLocation!, animate: true);
            _validationSubmitButton();
          } else {
            _closeStreamCurrentLocation();
          }
        }
      },
    );
  }

  void _closeStreamCurrentLocation() {
    _streamCurrentLocation.cancel();
  }

  void _validationSubmitButton() {
    if (_currentLocation != null && _schedule != null) {
      final distance = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _schedule!.office.latitude,
        _schedule!.office.longitude,
      );
      _isEnableSubmitButton = distance <= _schedule!.office.radius;
      notifyListeners();
    }
  }

  Future<void> _sendBanned() async {
    showLoading();
    final response = await _scheduleBannedUseCase();
    if (response.success) {
      _isSuccess = true;
    } else {
      errorMessage = response.message ?? 'Unknown error';
    }
    hideLoading();
  }

  Future<void> send() async {
    showLoading();
    final attendance = Attendance.paramEntity(
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
    );
    final response = await _attendanceSendUseCase.call(
      param: attendance.map(
        entity: (_) => throw Exception('Invalid type'),
        paramEntity: (param) => param,
        paramGetEntity: (_) => throw Exception('Invalid type'),
      ),
    );
    if (response.success) {
      _isSuccess = true;
    } else {
      errorMessage = response.message ?? 'Unknown error';
    }
    hideLoading();
  }

  @override
  void dispose() {
    _closeStreamCurrentLocation();
    _mapController.dispose();
    super.dispose();
  }
}
