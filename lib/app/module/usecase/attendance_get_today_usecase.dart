import '../../../core/network/data_state.dart';
import '../entity/attendance.dart';
import '../repository/attendance_repository.dart';

class AttendanceGetTodayUseCase {
  final AttendanceRepository _repository;

  AttendanceGetTodayUseCase(this._repository);

  Future<DataState<AttendanceEntity?>> call() async {
    return await _repository.getToday();
  }
}
