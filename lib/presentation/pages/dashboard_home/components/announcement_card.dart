import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/data/models/reference/announcement.dart';
import 'package:attendance/presentation/bloc/announcement/announcement_bloc.dart';

/// `GET /api/announcements`, as the design's single image card.
///
/// The redesign replaces the swipeable carousel with one card: the newest
/// announcement, its cover image behind a scrim. The handoff's stripe texture
/// is explicitly a placeholder for that image, so it is used only when the
/// image is missing or fails to load.
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key});

  static const _height = 150.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnnouncementBloc, AnnouncementState>(
      builder: (context, state) {
        // An empty or failed announcement is decoration, not an error state.
        // Collapse it and leave the rest of the screen alone.
        if (state is! AnnouncementLoaded || state.announcements.isEmpty) {
          return const SizedBox.shrink();
        }

        return _Card(announcement: state.announcements.first);
      },
    );
  }
}

class _Card extends StatelessWidget {
  final Announcement announcement;

  const _Card({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // TODO(api): `linkUrl` has no in-app destination yet.
      onTap: announcement.linkUrl == null ? null : () {},
      child: Container(
        height: AnnouncementCard._height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: T.announcementBase,
          borderRadius: BorderRadius.circular(T.rCard),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: announcement.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const _StripeTexture(),
              errorWidget: (_, __, ___) => const _StripeTexture(),
            ),
            // Bottom scrim, so the copy stays legible over any cover image.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xE6061626), Colors.transparent],
                  stops: [0, 0.65],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PENGUMUMAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.32, // 0.12em
                            color: T.accent500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          announcement.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDate(announcement.publishedAt.toLocal()),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The handoff's placeholder: 115-degree repeating white-5% stripes on the
/// announcement base colour. Stands in until a cover image loads.
class _StripeTexture extends StatelessWidget {
  const _StripeTexture();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: T.announcementBase,
        gradient: LinearGradient(
          begin: Alignment(-1, -0.47), // ~115 degrees
          end: Alignment(1, 0.47),
          tileMode: TileMode.repeated,
          colors: [
            Color(0x0DFFFFFF),
            Color(0x0DFFFFFF),
            Colors.transparent,
            Colors.transparent,
          ],
          stops: [0, 0.02, 0.02, 0.045],
        ),
      ),
    );
  }
}
