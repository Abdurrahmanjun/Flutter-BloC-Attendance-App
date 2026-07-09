import 'package:dio/dio.dart';

import 'package:attendance/common/error/failures.dart';

/// The one place a thrown network error becomes a [Failure].
///
/// Status codes carry the meaning; the envelope's `message` carries the text.
/// Per the contract that text is human-readable and safe to render, so 409 and
/// 422 failures pass it through verbatim rather than substituting a generic
/// string — a geofence rejection's distance ("You are 340m from Jakarta HQ")
/// only exists in that field.
Failure mapError(Object error) {
  if (error is! DioException) return const ServerFailure();

  switch (error.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const OfflineFailure();
    case DioExceptionType.badResponse:
      break;
    default:
      return const ServerFailure();
  }

  final status = error.response?.statusCode;
  final message = _envelopeMessage(error.response?.data);

  switch (status) {
    case 401:
      return message == null
          ? const UnauthorizedFailure()
          : UnauthorizedFailure(message);
    case 404:
      return message == null ? const NotFoundFailure() : NotFoundFailure(message);
    case 409:
      return ConflictFailure(message ?? 'Request conflicts with current state.');
    case 422:
      return ValidationFailure(message ?? 'Request could not be processed.');
    default:
      return message == null ? const ServerFailure() : ServerFailure(message);
  }
}

/// Pulls `message` out of an error envelope. Returns null when the body is not
/// a well-formed envelope (a proxy's HTML error page, say), so callers fall
/// back to their own default rather than rendering garbage.
String? _envelopeMessage(Object? body) {
  if (body is! Map) return null;
  final message = body['message'];
  return message is String && message.isNotEmpty ? message : null;
}
