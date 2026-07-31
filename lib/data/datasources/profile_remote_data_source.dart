import 'package:dio/dio.dart';

import 'package:attendance/common/network/api_response.dart';
import 'package:attendance/data/models/leave/leave_balance.dart';
import 'package:attendance/data/models/notification/app_notification.dart';
import 'package:attendance/data/models/reference/announcement.dart';
import 'package:attendance/data/models/reference/office.dart';
import 'package:attendance/data/models/user/user.dart';

/// The endpoints that fill the profile, notification feed, home carousel, and
/// the local geofence check. Throws [DioException] on non-2xx.
abstract class ProfileRemoteDataSource {
  Future<User> me();
  Future<NotificationFeed> notifications({bool unreadOnly});
  Future<void> markNotificationRead(int id);
  Future<List<Announcement>> announcements();
  Future<List<Office>> offices();
  Future<List<LeaveBalance>> leaveBalance();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<User> me() => _get(
        '/api/me',
        (data) => User.fromJson(data as Map<String, dynamic>),
      );

  @override
  Future<NotificationFeed> notifications({bool unreadOnly = false}) => _get(
        '/api/notifications',
        (data) => NotificationFeed.fromJson(data as Map<String, dynamic>),
        query: {'unreadOnly': unreadOnly},
      );

  @override
  Future<void> markNotificationRead(int id) =>
      dio.post<Map<String, dynamic>>('/api/notifications/$id/read');

  @override
  Future<List<Announcement>> announcements() => _get(
        '/api/announcements',
        (data) => (data as List<dynamic>)
            .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  Future<List<Office>> offices() => _get(
        '/api/office/locations',
        (data) => (data as List<dynamic>)
            .map((e) => Office.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  Future<List<LeaveBalance>> leaveBalance() => _get(
        '/api/leave/balance',
        (data) => (data as List<dynamic>)
            .map((e) => LeaveBalance.fromJson(e as Map<String, dynamic>))
            .toList(),
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
    if (data == null) {
      // A 2xx envelope must carry `data`; a null one is a contract violation,
      // not an empty result.
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: envelope.message,
      );
    }
    return data;
  }
}
