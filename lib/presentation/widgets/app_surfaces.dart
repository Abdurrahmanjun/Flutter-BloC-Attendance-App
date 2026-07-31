import 'package:flutter/material.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// The standard white card: 1px [T.border], radius 24 by default.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color? borderColor;
  final List<BoxShadow>? shadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = T.rCard,
    this.color = T.surface,
    this.borderColor = T.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}

/// An uppercase section eyebrow — "MINGGU INI", "BELUM DIBACA", "PREFERENSI".
class SectionEyebrow extends StatelessWidget {
  final String label;

  /// Sits to the right of the label: the unread count pill, the DEBUG chip.
  final Widget? trailing;

  const SectionEyebrow(this.label, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final text = Text(label.toUpperCase(), style: AppText.eyebrow);
    if (trailing == null) return text;

    return Row(
      children: [
        text,
        const SizedBox(width: 8),
        trailing!,
      ],
    );
  }
}

/// A header row: title on the left, an optional text action on the right.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Sits immediately after the title — "22 hari kerja" on the summary card.
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppText.sectionHeader),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: T.ink400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(actionLabel!, style: AppText.sectionAction),
          ),
      ],
    );
  }
}

/// A rounded status pill — "Hadir", "Terlambat", "Menunggu", "Bekerja".
class StatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.fontSize = 11.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(T.rPill),
      ),
      child: Text(
        label,
        style: AppText.badge.copyWith(fontSize: fontSize, color: foreground),
      ),
    );
  }
}

/// A tinted rounded-square holding a single icon — the 38x38 chips on the
/// Pengajuan grid and the notification rows.
class IconChip extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;
  final double iconSize;
  final double radius;

  const IconChip({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 38,
    this.iconSize = 19,
    this.radius = T.rChip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, size: iconSize, color: foreground),
    );
  }
}

/// One cell of a 3-up stat row: a large value over a small label, on a tint.
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color background;
  final Color valueColor;
  final Color labelColor;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.background,
    required this.valueColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(T.rInput),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppText.numeric(TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: valueColor,
            )),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// The screen body wrapper: canvas background, 20px sides, and the tablet
/// content cap the handoff asks for (~520px, centred).
class ScreenBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ScreenBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: T.screenX),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: T.maxContentWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
