import 'dart:io';

import 'package:absen_smkn1_punggelan/app/data/source/photo_api_service.dart';
import 'package:absen_smkn1_punggelan/app/module/repository/photo_repository.dart';
import 'package:absen_smkn1_punggelan/core/constant/constant.dart';
import 'package:absen_smkn1_punggelan/core/network/data_state.dart';

class PhotoRepositoryImpl extends PhotoRepository {
  final PhotoApiService _photoApiService;

  PhotoRepositoryImpl(this._photoApiService);

  @override
  Future<DataState<String>> get() {
    return handleResponse(
      () => _photoApiService.get(),
      (p0) => p0,
    );
  }

  @override
  Future<DataState<dynamic>> getBytes(String url) async {
    try {
      final response =
          await _photoApiService.getBytes(path: url.replaceAll(BASE_URL, ''));
      if (response.response.statusCode == HttpStatus.ok) {
        return SuccessState(data: response.response.data);
      } else {
        return ErrorState(
            message:
                '${response.response.statusCode} : ${response.response.statusMessage ?? 'Unknown error'}');
      }
    } catch (e) {
      return ErrorState(message: e.toString());
    }
  }
}
