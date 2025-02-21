import 'package:absen_smkn1_punggelan/core/constant/constant.dart';
import 'package:absen_smkn1_punggelan/core/network/base_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

part 'attendance_api_service.g.dart';

@RestApi(baseUrl: BASE_URL)
abstract class AttendanceApiService {
  factory AttendanceApiService(Dio dio) {
    return _AttendanceApiService(dio);
  }

  @GET('/api/get-attendance-today')
  Future<HttpResponse<BaseResponse>> getAttendanceToday();

  @POST('/api/store-attendance')
  Future<HttpResponse<BaseResponse>> sendAttendance(
      {@Body() required Map<String, dynamic> body});

  @GET('/api/get-attendance-by-month-year/{month}/{year}')
  Future<HttpResponse<BaseResponse>> getAttendanceByMonthYear(
      {@Path('month') required String month,
      @Path('year') required String year});
}
