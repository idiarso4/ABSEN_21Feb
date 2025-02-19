class BaseResponse {
  final bool success;
  final String? message;
  final dynamic data;

  const BaseResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      success: json['success'] ?? false,
      message: json['message'] as String?,
      data: json['data'],
    );
  }
}
