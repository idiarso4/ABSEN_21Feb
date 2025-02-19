import '../../../core/network/data_state.dart';
import '../entity/attendance.dart';
import '../repository/attendance_repository.dart';

class AttendanceGetMonthUseCase {
  final AttendanceRepository _repository;

  AttendanceGetMonthUseCase(this._repository);

  Future<DataState<List<AttendanceEntity>>> call() async {
    return await _repository.getThisMonth();
  }
}
