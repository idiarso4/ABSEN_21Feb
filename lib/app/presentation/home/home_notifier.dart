import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../core/helper/notification_helper.dart';
import '../../../core/helper/shared_preferences_helper.dart';
import '../../../core/network/data_state.dart';
import '../../../core/provider/app_provider.dart';
import '../../module/entity/attendance.dart';
import '../../module/entity/schedule.dart';
import '../../module/usecase/attendance_get_month_usecase.dart';
import '../../module/usecase/attendance_get_today_usecase.dart';
import '../../module/usecase/schedule_banned_usecase.dart';
import '../../module/usecase/schedule_get_usecase.dart';
import '../../../core/utils/constants.dart';

class HomeNotifier extends AppProvider {
  bool _disposed = false;
  Timer? _timer;
  bool get isClosed => _disposed;

  final AttendanceGetTodayUseCase _attendanceGetTodayUseCase;
  final AttendanceGetMonthUseCase _attendanceGetMonthUseCase;
  final ScheduleGetUseCase _scheduleGetUseCase;
  final ScheduleBannedUseCase _scheduleBannedUseCase;

  String? _name;
  String get name => _name ?? '';
  
  bool _isPhysicDevice = false;
  bool get isPhysicDevice => _isPhysicDevice;

  bool _isGrantedNotificationPresmission = false;
  bool get isGrantedNotificationPresmission => _isGrantedNotificationPresmission;

  int _timeNotification = 30;
  int get timeNotification => _timeNotification;

  AttendanceEntity? _attendanceToday;
  AttendanceEntity? get attendanceToday => _attendanceToday;

  List<AttendanceEntity> _listAttendanceThisMonth = [];
  List<AttendanceEntity> get listAttendanceThisMonth => _listAttendanceThisMonth;

  ScheduleEntity? _schedule;
  ScheduleEntity? get schedule => _schedule;

  bool _isLeaves = false;
  bool get isLeaves => _isLeaves;

  List<DropdownMenuEntry<int>> get listEditNotification => [
    const DropdownMenuEntry(value: 5, label: '5 Minutes'),
    const DropdownMenuEntry(value: 10, label: '10 Minutes'),
    const DropdownMenuEntry(value: 15, label: '15 Minutes'),
    const DropdownMenuEntry(value: 30, label: '30 Minutes'),
  ];

  HomeNotifier(
    this._attendanceGetTodayUseCase,
    this._attendanceGetMonthUseCase,
    this._scheduleGetUseCase,
    this._scheduleBannedUseCase,
  );

  @override 
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }

  Future<void> init() async {
    try {
      if (isClosed) return;
      
      showLoading();
      await _getUserDetail();
      if (!isClosed) {
        await _getDeviceInfo();
        if (!isClosed) {
          await _getNotificationPermission();
          if (!isClosed) {
            await _getAttendanceToday();
            if (!isClosed) {
              await _getAttendanceThisMonth();
              if (!isClosed) {
                await _getSchedule();
              }
            }
          }
        }
      }
      if (!isClosed) hideLoading();
    } catch (e) {
      if (!isClosed) {
        hideLoading();
        errorMessage = e.toString();
      }
    }
  }

  Future<void> _getUserDetail() async {
    try {
      if (isClosed) return;
      
      _name = await SharedPreferencesHelper.getString(Constants.PREF_NAME);
      final prefNotif = await SharedPreferencesHelper.getInt(Constants.PREF_NOTIF_SETTING);
      if (!isClosed) {
        if (prefNotif != null) {
          _timeNotification = prefNotif;
        } else {
          await SharedPreferencesHelper.setInt(
              Constants.PREF_NOTIF_SETTING, _timeNotification);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _getDeviceInfo() async {
    try {
      if (isClosed) return;
      
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (!isClosed) {
        _isPhysicDevice = deviceInfo.isPhysicalDevice ?? false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _getNotificationPermission() async {
    try {
      if (isClosed) return;

      if (await Permission.notification.isGranted) {
        _isGrantedNotificationPresmission = true;
      } else {
        final status = await Permission.notification.status;
        if (!isClosed) {
          if (status.isPermanentlyDenied) {
            openAppSettings();
          }
          _isGrantedNotificationPresmission = status.isGranted;
        }
      }
    } catch (e) {
      _isGrantedNotificationPresmission = false;
      rethrow;
    }
  }

  Future<void> _getAttendanceToday() async {
    try {
      if (isClosed) return;

      if (_isGrantedNotificationPresmission && _schedule != null) {
        await NotificationHelper.setScheduledNotification(
          _timeNotification,
          _schedule!,
        );
      }

      final result = await _attendanceGetTodayUseCase.call();
      if (!isClosed) {
        result.fold(
          (failure) {
            errorMessage = failure.message;
          },
          (data) {
            _attendanceToday = data;
          },
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _getAttendanceThisMonth() async {
    try {
      if (isClosed) return;

      final result = await _attendanceGetMonthUseCase.call();
      if (!isClosed) {
        result.fold(
          (failure) {
            errorMessage = failure.message;
          },
          (data) {
            _listAttendanceThisMonth = data;
          },
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _getSchedule() async {
    try {
      if (isClosed) return;

      showLoading();
      final result = await _scheduleGetUseCase.call();
      if (!isClosed) {
        result.fold(
          (failure) {
            errorMessage = failure.message;
          },
          (data) {
            _schedule = data;
          },
        );
      }
    } catch (e) {
      if (!isClosed) {
        errorMessage = e.toString();
      }
    } finally {
      if (!isClosed) hideLoading();
    }
  }

  Future<void> setTimeNotification(int param) async {
    try {
      if (isClosed) return;

      await SharedPreferencesHelper.setInt(Constants.PREF_NOTIF_SETTING, param);
      if (!isClosed) {
        _timeNotification = param;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
