import 'package:absen_smkn1_punggelan/app/module/entity/schedule.dart';
import 'package:absen_smkn1_punggelan/core/network/data_state.dart';

abstract class ScheduleRepository {
  Future<DataState<ScheduleEntity?>> get();
  Future<DataState> banned();
}
