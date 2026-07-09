import 'package:equatable/equatable.dart';
import 'package:attendance/common/strings/failures.dart';

/// Every failure carries a message fit to render. For failures built from an
/// API envelope that message is the server's `message` field verbatim — the
/// contract guarantees it is human-readable and safe to surface.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class OfflineFailure extends Failure {
  const OfflineFailure([super.message = OFFLINE_FAILURE_MESSAGE]);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = SERVER_FAILURE_MESSAGE]);
}

class EmptyCacheFailure extends Failure {
  const EmptyCacheFailure([super.message = EMPTY_CACHE_FAILURE_MESSAGE]);
}

/// 401 — token missing, malformed, or expired. The UI sends the user back to
/// login rather than surfacing this as an error.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(
      [super.message = 'Sesi berakhir, silakan masuk kembali.']);
}

/// 404.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found.']);
}

/// 409 — e.g. already checked in today. Not retryable; show [message].
class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}

/// 422 — e.g. outside the office geofence. [message] carries the detail (the
/// measured distance) and is shown verbatim.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
