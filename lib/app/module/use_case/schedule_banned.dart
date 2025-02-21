import '../../../core/network/data_state.dart';
import '../../../core/use_case/app_use_case.dart';
import '../repository/schedule_repository.dart';

class ScheduleBannedUseCase extends AppUseCase<Future<DataState>, void> {
  final ScheduleRepository _repository;

  ScheduleBannedUseCase(this._repository);

  @override
  Future<DataState> call({void param}) async {
    return await _repository.banned();
  }
}
