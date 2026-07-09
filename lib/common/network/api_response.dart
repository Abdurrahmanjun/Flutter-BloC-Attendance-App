/// The envelope every endpoint wraps its payload in: `{code, success, message,
/// data}`. `code` mirrors the HTTP status and `data` is null on error.
///
/// Deliberately hand-written rather than generated: json_serializable's generic
/// support needs a `fromJsonT` callback passed in anyway, so the generator
/// would buy nothing here.
class ApiResponse<T> {
  final int code;
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({
    required this.code,
    required this.success,
    required this.message,
    this.data,
  });

  /// [fromData] is only invoked when `data` is non-null, so callers never have
  /// to null-check inside it.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object json) fromData,
  ) {
    final raw = json['data'];
    return ApiResponse<T>(
      code: json['code'] as int,
      success: json['success'] as bool,
      message: json['message'] as String,
      data: raw == null ? null : fromData(raw),
    );
  }

  /// For endpoints whose success payload is `null` by design (logout, mark-read).
  factory ApiResponse.empty(Map<String, dynamic> json) => ApiResponse<T>(
        code: json['code'] as int,
        success: json['success'] as bool,
        message: json['message'] as String,
      );
}
