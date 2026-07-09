import 'package:json_annotation/json_annotation.dart';

part 'auth_token.g.dart';

/// `data` of `POST /api/auth/login` and `/api/auth/refresh`.
///
/// The contract marks only `accessToken`, `tokenType` and `expiresIn` as
/// required, so `refreshToken` is nullable here even though every documented
/// example carries one.
@JsonSerializable()
class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int expiresIn;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenToJson(this);
}
