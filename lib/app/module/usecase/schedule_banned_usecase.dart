import '../../../core/network/data_state.dart';
import '../repository/schedule_repository.dart';

class ScheduleBannedUseCase {
  final ScheduleRepository _repository;

  ScheduleBannedUseCase(this._repository);

  Future<DataState<void>> call() async {
    return await _repository.banned();
  }
}
