import 'package:presensi_smkn1_punggelan/app/module/entity/auth.dart';
import 'package:presensi_smkn1_punggelan/core/network/data_state.dart';

abstract class AuthRepository {
  Future<DataState<Map<String, dynamic>>> login(AuthEntity param);
}
