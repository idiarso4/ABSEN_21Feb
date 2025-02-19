import 'package:absen_smkn1_punggelan/app/data/model/auth.dart';
import 'package:absen_smkn1_punggelan/app/data/source/auth_api_service.dart';
import 'package:absen_smkn1_punggelan/app/module/entity/auth.dart';
import 'package:absen_smkn1_punggelan/app/module/repository/auth_repository.dart';
import 'package:absen_smkn1_punggelan/core/constant/constant.dart';
import 'package:absen_smkn1_punggelan/core/helper/shared_preferences_helper.dart';
import 'package:absen_smkn1_punggelan/core/network/data_state.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  @override
  Future<DataState> login(AuthEntity param) {
    return handleResponse(
      () => _authApiService.login(body: param.toJson()),
      (json) async {
        final authModel = AuthModel.fromJson(json);
        await SharedPreferencesHelper.setString(
            PREF_AUTH, '${authModel.tokenType} ${authModel.accessToken}');
        await SharedPreferencesHelper.setInt(PREF_ID, authModel.user.id);
        await SharedPreferencesHelper.setString(PREF_NAME, authModel.user.name);
        await SharedPreferencesHelper.setString(
            PREF_EMAIL, authModel.user.email);
        return null;
      },
    );
  }
}
