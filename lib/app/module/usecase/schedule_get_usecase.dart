import '../../../core/network/data_state.dart';
import '../entity/schedule.dart';
import '../repository/schedule_repository.dart';

class ScheduleGetUseCase {
  final ScheduleRepository _repository;

  ScheduleGetUseCase(this._repository);

  Future<DataState<ScheduleEntity?>> call() async {
    return await _repository.get();
  }
}
