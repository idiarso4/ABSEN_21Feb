import '../../../core/network/data_state.dart';
import '../../../core/use_case/app_use_case.dart';
import '../entity/attendance.dart';
import '../repository/attendance_repository.dart';

class AttendanceGetMonthUseCase extends AppUseCase<Future<DataState<List<AttendanceEntity>>>, void> {
  final AttendanceRepository _repository;

  AttendanceGetMonthUseCase(this._repository);

  @override
  Future<DataState<List<AttendanceEntity>>> call({void param}) async {
    return await _repository.getThisMonth();
  }
}
