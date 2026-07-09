import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/common/utils/colors.dart';
import 'package:attendance/data/models/reference/announcement.dart';
import 'package:attendance/presentation/bloc/announcement/announcement_bloc.dart';

/// `GET /api/announcements` — the home carousel, replacing the bundled
/// `promoImagePaths` asset list.
class AnnouncementCarousel extends StatefulWidget {
  const AnnouncementCarousel({super.key});

  @override
  State<AnnouncementCarousel> createState() => _AnnouncementCarouselState();
}

class _AnnouncementCarouselState extends State<AnnouncementCarousel> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnnouncementBloc, AnnouncementState>(
      builder: (context, state) {
        // An empty or failed carousel is not worth an error state — it is
        // decoration. Collapse it and leave the rest of the screen alone.
        if (state is! AnnouncementLoaded || state.announcements.isEmpty) {
          return const SizedBox.shrink();
        }

        final announcements = state.announcements;
        return Column(
          children: [
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _pageController,
                itemCount: announcements.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) =>
                    _Slide(announcement: announcements[index]),
              ),
            ),
            if (announcements.length > 1) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  announcements.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: index == _page ? white : white.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Slide extends StatelessWidget {
  final Announcement announcement;

  const _Slide({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: navyDark,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The contract's example imageUrl is on cdn.example.com and does not
          // resolve; the title stays legible either way.
          CachedNetworkImage(
            imageUrl: announcement.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => const ColoredBox(color: navyDark),
            errorWidget: (_, __, ___) => const ColoredBox(color: navyDark),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                ),
              ),
              child: Text(
                announcement.title,
                style: const TextStyle(
                  color: white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
