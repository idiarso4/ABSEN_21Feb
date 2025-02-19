import 'package:absen_smkn1_punggelan/app/module/entity/auth.dart';
import 'package:absen_smkn1_punggelan/core/network/data_state.dart';

abstract class AuthRepository {
  Future<DataState<void>> login(AuthEntity param);
}
