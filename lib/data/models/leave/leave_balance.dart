import 'package:json_annotation/json_annotation.dart';

part 'leave_balance.g.dart';

enum LeaveType {
  @JsonValue('annual')
  annual,
  @JsonValue('sick')
  sick,
  @JsonValue('unpaid')
  unpaid,
  @JsonValue('maternity')
  maternity,
}

/// One row of `GET /api/leave/balance`, which returns a balance per leave type.
///
/// "Sisa cuti" in the UI means the **annual** balance specifically — the other
/// types are not an allowance the user spends the same way.
@JsonSerializable()
class LeaveBalance {
  final LeaveType type;
  final int entitledDays;
  final int usedDays;
  final int remainingDays;

  const LeaveBalance({
    required this.type,
    required this.entitledDays,
    required this.usedDays,
    required this.remainingDays,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) =>
      _$LeaveBalanceFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveBalanceToJson(this);
}

/// Convenience over the list the endpoint returns.
extension LeaveBalances on List<LeaveBalance> {
  /// The annual allowance, or null if the server did not send one.
  LeaveBalance? get annual {
    for (final balance in this) {
      if (balance.type == LeaveType.annual) return balance;
    }
    return null;
  }
}
