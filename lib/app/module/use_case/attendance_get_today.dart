import '../../../core/network/data_state.dart';
import '../../../core/use_case/app_use_case.dart';
import '../entity/attendance.dart';
import '../repository/attendance_repository.dart';

class AttendanceGetTodayUseCase extends AppUseCase<Future<DataState<AttendanceEntity?>>, void> {
  final AttendanceRepository _repository;

  AttendanceGetTodayUseCase(this._repository);

  @override
  Future<DataState<AttendanceEntity?>> call({void param}) async {
    return await _repository.getToday();
  }
}
