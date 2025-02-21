import 'package:presensi_smkn1_punggelan/app/data/model/auth.dart';
import 'package:presensi_smkn1_punggelan/app/data/source/auth_api_service.dart';
import 'package:presensi_smkn1_punggelan/app/module/entity/auth.dart';
import 'package:presensi_smkn1_punggelan/app/module/repository/auth_repository.dart';
import 'package:presensi_smkn1_punggelan/core/constant/constant.dart';
import 'package:presensi_smkn1_punggelan/core/helper/shared_preferences_helper.dart';
import 'package:presensi_smkn1_punggelan/core/network/data_state.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  @override
  Future<DataState<Map<String, dynamic>>> login(AuthEntity param) async {
    try {
      final response = await _authApiService.login(body: param.toJson());
      final data = response.data;
      
      if (data.success && data.data != null) {
        final authModel = AuthModel.fromJson(data.data as Map<String, dynamic>);
        
        await SharedPreferencesHelper.setString(
          PREF_AUTH, '${authModel.tokenType} ${authModel.accessToken}');
        await SharedPreferencesHelper.setInt(PREF_ID, authModel.user.id);
        await SharedPreferencesHelper.setString(PREF_NAME, authModel.user.name);
        await SharedPreferencesHelper.setString(PREF_EMAIL, authModel.user.email);
        
        return DataState.success({
          'token': authModel.accessToken,
          'user': {
            'id': authModel.user.id,
            'name': authModel.user.name,
            'email': authModel.user.email,
          }
        });
      }
      
      return DataState.error(data.message ?? 'Login failed');
    } catch (e) {
      return DataState.error(e.toString());
    }
  }
}
