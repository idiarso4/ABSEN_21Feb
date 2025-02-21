import '../entity/auth.dart';
import '../../data/repository/auth_repository.dart';
import '../../../core/network/data_state.dart';

class AuthLoginUseCase {
  final AuthRepositoryImpl _authRepository;

  AuthLoginUseCase(this._authRepository);

  Future<DataState<Map<String, dynamic>>> call({AuthEntity? param}) async {
    try {
      if (param == null) {
        return DataState.error('Email dan password harus diisi');
      }
      
      final response = await _authRepository.login(param);
      return response;
    } catch (e) {
      return DataState.error(e.toString());
    }
  }
}
