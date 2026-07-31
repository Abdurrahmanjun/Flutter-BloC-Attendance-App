import 'package:flutter/material.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';

/// The four request shortcuts.
///
/// The original screen used the same calendar icon for all four actions; giving
/// each a distinct icon and tint is a deliberate part of this redesign, not
/// decoration.
///
/// TODO(api): there are no request endpoints in the contract yet — no
/// `POST /api/requests`, no history. Each tile is wired to [onUnavailable]
/// until they exist; swapping in a route is a one-line change per entry.
class PengajuanGrid extends StatelessWidget {
  final void Function(String label) onUnavailable;
  final VoidCallback onHistory;

  const PengajuanGrid({
    super.key,
    required this.onUnavailable,
    required this.onHistory,
  });

  static const _items = <_Pengajuan>[
    _Pengajuan(
      label: 'Lembur',
      icon: Icons.schedule_rounded,
      chip: T.brand100,
      stroke: T.brand600,
    ),
    _Pengajuan(
      label: 'Sakit',
      icon: Icons.monitor_heart_outlined,
      chip: T.dangerChip,
      stroke: T.danger500,
    ),
    _Pengajuan(
      label: 'Reimburs',
      icon: Icons.receipt_long_rounded,
      chip: T.successChip,
      stroke: T.success500,
    ),
    _Pengajuan(
      label: 'Terlambat',
      icon: Icons.warning_amber_rounded,
      chip: T.accent50,
      stroke: T.accent700,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Pengajuan',
          actionLabel: 'Riwayat',
          onAction: onHistory,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _items.length; i++) ...[
              if (i > 0) const SizedBox(width: 9),
              Expanded(
                child: _Tile(
                  item: _items[i],
                  onTap: () => onUnavailable(_items[i].label),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Pengajuan {
  final String label;
  final IconData icon;
  final Color chip;
  final Color stroke;

  const _Pengajuan({
    required this.label,
    required this.icon,
    required this.chip,
    required this.stroke,
  });
}

class _Tile extends StatelessWidget {
  final _Pengajuan item;
  final VoidCallback onTap;

  const _Tile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: T.surface,
          borderRadius: BorderRadius.circular(T.rRow),
          border: Border.all(color: T.border),
        ),
        child: Column(
          children: [
            IconChip(
              icon: item.icon,
              background: item.chip,
              foreground: item.stroke,
            ),
            const SizedBox(height: 9),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: T.ink700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
