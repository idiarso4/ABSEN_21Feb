import 'package:absen_smkn1_punggelan/core/constant/constant.dart';
import 'package:absen_smkn1_punggelan/core/network/base_response.dart';
import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'photo_api_service.g.dart';

@RestApi(baseUrl: BASE_URL)
abstract class PhotoApiService {
  factory PhotoApiService(Dio dio) {
    return _PhotoApiService(dio);
  }

  @GET('/api/get-photo')
  Future<HttpResponse<BaseResponse>> get();

  @GET('{path}')
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getBytes(
      {@Path('path') required String path});
}
