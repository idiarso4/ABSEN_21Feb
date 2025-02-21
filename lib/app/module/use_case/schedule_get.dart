import '../../../core/network/data_state.dart';
import '../../../core/use_case/app_use_case.dart';
import '../entity/schedule.dart';
import '../repository/schedule_repository.dart';

class ScheduleGetUseCase extends AppUseCase<Future<DataState<ScheduleEntity?>>, void> {
  final ScheduleRepository _repository;

  ScheduleGetUseCase(this._repository);

  @override
  Future<DataState<ScheduleEntity?>> call({void param}) async {
    return await _repository.get();
  }
}
