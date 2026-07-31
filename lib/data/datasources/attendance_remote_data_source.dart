import 'package:dio/dio.dart';

import 'package:attendance/common/network/api_response.dart';
import 'package:attendance/data/models/attendance/attendance_entry.dart';
import 'package:attendance/data/models/attendance/attendance_history.dart';
import 'package:attendance/data/models/attendance/attendance_punch.dart';
import 'package:attendance/data/models/attendance/monthly_summary.dart';
import 'package:attendance/data/models/attendance/today_attendance.dart';

/// Every method throws [DioException] on a non-2xx; the repository turns that
/// into a Failure via the shared mapper. Nothing here interprets status codes.
///
/// The punches return the whole envelope because their `message` ("Checked in
/// at 09:03. You are 3 minutes late.") is the text the UI shows, and it exists
/// nowhere in `data`.
abstract class AttendanceRemoteDataSource {
  Future<TodayAttendance> today();
  Future<ApiResponse<AttendanceEntry>> checkIn(AttendancePunch punch);
  Future<ApiResponse<AttendanceEntry>> checkOut(AttendancePunch punch);
  Future<AttendanceHistory> history({
    String? from,
    String? to,
    int page,
    int perPage,
  });
  Future<MonthlySummary> summary(String month);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSourceImpl({required this.dio});

  @override
  Future<TodayAttendance> today() => _get(
        '/api/attendance/today',
        (data) => TodayAttendance.fromJson(data as Map<String, dynamic>),
      );

  @override
  Future<ApiResponse<AttendanceEntry>> checkIn(AttendancePunch punch) =>
      _post('/api/attendance/check-in', punch.toJson());

  @override
  Future<ApiResponse<AttendanceEntry>> checkOut(AttendancePunch punch) =>
      _post('/api/attendance/check-out', punch.toJson());

  @override
  Future<AttendanceHistory> history({
    String? from,
    String? to,
    int page = 1,
    int perPage = 20,
  }) =>
      _get(
        '/api/attendance/history',
        (data) => AttendanceHistory.fromJson(data as Map<String, dynamic>),
        query: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
          'page': page,
          'perPage': perPage,
        },
      );

  @override
  Future<MonthlySummary> summary(String month) => _get(
        '/api/attendance/summary',
        (data) => MonthlySummary.fromJson(data as Map<String, dynamic>),
        query: {'month': month},
      );

  Future<T> _get<T>(
    String path,
    T Function(Object) fromData, {
    Map<String, dynamic>? query,
  }) async {
    final response =
        await dio.get<Map<String, dynamic>>(path, queryParameters: query);
    final envelope = ApiResponse<T>.fromJson(response.data!, fromData);

    final data = envelope.data;
    if (data == null) throw _missingData(response, envelope.message);
    return data;
  }

  Future<ApiResponse<AttendanceEntry>> _post(String path, Object body) async {
    final response = await dio.post<Map<String, dynamic>>(path, data: body);
    final envelope = ApiResponse<AttendanceEntry>.fromJson(
      response.data!,
      (data) => AttendanceEntry.fromJson(data as Map<String, dynamic>),
    );

    if (envelope.data == null) throw _missingData(response, envelope.message);
    return envelope;
  }

  /// A 2xx envelope must carry `data`. If it does not, that is a contract
  /// violation, not an empty result — surface it as an error.
  DioException _missingData(Response<Object?> response, String message) =>
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: message,
      );
}
