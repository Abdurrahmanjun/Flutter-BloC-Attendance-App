import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/presentation/bloc/notification/notification_bloc.dart';
import 'package:attendance/presentation/bloc/profile/profile_bloc.dart';

/// Avatar, greeting, and the bell. The avatar is not a tap target — Profil has
/// its own tab, and the design gives the greeting row only one action.
class GreetingRow extends StatelessWidget {
  final VoidCallback onBellTap;

  const GreetingRow({super.key, required this.onBellTap});

  /// The greeting tracks the clock, not the shift.
  static String greetingFor(int hour) {
    if (hour < 11) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 19) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state is ProfileLoaded ? state.user : null;

        return Row(
          children: [
            _Avatar(name: user?.name, url: user?.avatarUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greetingFor(DateTime.now().hour),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: T.ink400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.name ?? ' ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.38, // -0.02em
                      color: T.ink900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _BellButton(onTap: onBellTap),
          ],
        );
      },
    );
  }
}

/// 46x46 radius-16 brand tile with the user's initial. The contract's example
/// avatarUrl is on cdn.example.com and does not resolve, so the initial is the
/// real case rather than the fallback.
class _Avatar extends StatelessWidget {
  final String? name;
  final String? url;

  const _Avatar({required this.name, required this.url});

  @override
  Widget build(BuildContext context) {
    final initial = (name == null || name!.isEmpty)
        ? '·'
        : name![0].toUpperCase();

    final tile = Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: T.brand600,
        borderRadius: BorderRadius.circular(T.rInput),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );

    if (url == null) return tile;

    return ClipRRect(
      borderRadius: BorderRadius.circular(T.rInput),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        placeholder: (_, __) => tile,
        errorWidget: (_, __, ___) => tile,
      ),
    );
  }
}

/// 42x42 white button with the unread dot from `GET /api/notifications`.
class _BellButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BellButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      buildWhen: (previous, current) => current is NotificationLoaded,
      builder: (context, state) {
        final unread =
            state is NotificationLoaded && state.unreadCount > 0;

        return GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: T.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: T.border),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 21,
                    color: T.ink700,
                  ),
                ),
                if (unread)
                  Positioned(
                    top: 9,
                    right: 10,
                    // An 8px dot with the ring *outside* it, so the dot itself
                    // is the specified size — Flutter draws borders inward.
                    child: Container(
                      width: 12,
                      height: 12,
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: T.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: T.danger500,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
