import 'dart:convert';
import 'dart:io';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'base_response.dart';

class DataState<T> {
  final bool success;
  final String? message;
  final T? data;

  const DataState({
    required this.success,
    this.message,
    this.data,
  });

  factory DataState.success(T data) {
    return DataState(
      success: true,
      data: data,
    );
  }

  factory DataState.error(String message) {
    return DataState(
      success: false,
      message: message,
    );
  }

  R fold<R>({
    required R Function(T? data) onSuccess,
    required R Function(String? message) onError,
  }) {
    if (success) {
      return onSuccess(data);
    } else {
      return onError(message);
    }
  }
}

class SuccessState<T> extends DataState<T> {
  const SuccessState({
    String? message,
    T? data,
  }) : super(
          success: true,
          message: message,
          data: data,
        );
}

class ErrorState<T> extends DataState<T> {
  const ErrorState({
    String? message,
    T? data,
  }) : super(
          success: false,
          message: message,
          data: data,
        );
}

extension DataStateX<T> on HttpResponse<BaseResponse> {
  DataState<R> toDataState<R>(R Function(dynamic) mapDataSuccess) {
    try {
      final response = data;
      if (response.success) {
        final mappedData = mapDataSuccess(response.data);
        return SuccessState<R>(message: response.message, data: mappedData);
      } else {
        return ErrorState<R>(message: response.message ?? 'Unknown error');
      }
    } on DioException catch (e) {
      try {
        if (e.response != null) {
          final Map<String, dynamic> errorData = jsonDecode(e.response.toString());
          return ErrorState<R>(message: errorData['message'] ?? e.message ?? 'Unknown error');
        }
        return ErrorState<R>(message: e.message ?? 'Unknown error');
      } catch (_) {
        return ErrorState<R>(message: e.message ?? 'Unknown error');
      }
    } catch (e) {
      return ErrorState<R>(message: e.toString());
    }
  }
}

Future<DataState<T>> handleResponse<T>(
    Future<HttpResponse<BaseResponse>> Function() apiCall,
    T Function(dynamic) mapDataSuccess) async {
  try {
    final httpResponse = await apiCall();
    final response = httpResponse.data;
    if (response.success) {
      final mappedData = mapDataSuccess(response.data);
      return SuccessState<T>(message: response.message, data: mappedData);
    } else {
      return ErrorState<T>(message: response.message ?? 'Unknown error');
    }
  } on DioException catch (e) {
    try {
      if (e.response != null) {
        final Map<String, dynamic> errorData = jsonDecode(e.response.toString());
        return ErrorState(
            message: '${e.response?.statusCode ?? ''} ${errorData['message'] ?? e.message ?? 'Unknown error'}');
      }
      return ErrorState(
          message: '${e.response?.statusCode ?? HttpStatus.badRequest} ${e.error ?? e}');
    } catch (e1) {
      return ErrorState(
          message: '${e.response?.statusCode ?? HttpStatus.badRequest} ${e.error ?? e}');
    }
  } catch (e) {
    return ErrorState(message: e.toString());
  }
}
