import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/app_theme.dart';
import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/injection_container.dart' as di;
import 'package:attendance/presentation/bloc/profile_detail/profile_detail_bloc.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// Profil — `GET /api/me`, plus the leave balance, office list and month
/// summary that fill the stat strip.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileDetailBloc>(
      create: (_) => di.sl<ProfileDetailBloc>()..add(LoadProfileDetailEvent()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _notYetAvailable(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('$what belum tersedia.'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ));
  }

  @override
  Widget build(BuildContext context) {
    // Brand blue behind white status-bar content on this screen.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.brandOverlay,
      child: Scaffold(
        backgroundColor: T.canvas,
        body: BlocBuilder<ProfileDetailBloc, ProfileDetailState>(
          builder: (context, state) {
            final loaded = state is ProfileDetailLoaded ? state : null;

            return Column(
              children: [
                // Fixed chrome: the blue header, with the stat card hanging 34px
                // past its lower edge.
                //
                // This block deliberately does not scroll. When it did, the
                // header slid up under the system status bar and the avatar was
                // sliced across the middle — the list clips at the status bar,
                // so there was no way to scroll it away cleanly. It is a header,
                // so it behaves like one.
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _Header(
                      state: loaded,
                      onEdit: loaded == null
                          ? null
                          : () => _notYetAvailable(context, 'Ubah profil'),
                    ),
                    if (loaded != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -34,
                        child: ScreenBody(child: _StatStrip(state: loaded)),
                      ),
                  ],
                ),
                // Clears the overhang above the first scrolling section.
                SizedBox(height: loaded == null ? T.blockGap : 34 + T.blockGap),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => context
                        .read<ProfileDetailBloc>()
                        .add(LoadProfileDetailEvent()),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 28),
                      children: switch (state) {
                        ProfileDetailLoaded() => _sections(context, state),
                        ProfileDetailFailure(:final message) => [
                            ScreenBody(
                              child: _Message(
                                text: message,
                                onRetry: () => context
                                    .read<ProfileDetailBloc>()
                                    .add(LoadProfileDetailEvent()),
                              ),
                            ),
                          ],
                        _ => const [_Spinner()],
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, ProfileDetailLoaded state) {
    final user = state.user;
    final office = state.office;

    return [
      ScreenBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionEyebrow('Kepegawaian'),
            const SizedBox(height: 11),
            _InfoCard(rows: [
              ('Email', user.email),
              (
                'Bergabung',
                user.joinedAt == null
                    ? '—'
                    : formatDate(user.joinedAt!.toLocal())
              ),
              (
                'Shift',
                '${user.shift.start} – ${user.shift.end} '
                    '${_timeZoneLabel(user.shift.timeZone)}'
              ),
              ('Kantor', office?.name ?? '—'),
            ]),
            const SizedBox(height: T.blockGap),
            const SectionEyebrow('Atasan'),
            const SizedBox(height: 11),
            _ManagerCard(
              onTap: () => _notYetAvailable(context, 'Detail atasan'),
            ),
          ],
        ),
      ),
    ];
  }

  /// `Asia/Jakarta` → `WIB`. The design writes the shift row that way, and an
  /// IANA name is not what an Indonesian employee reads off a payslip.
  static String _timeZoneLabel(String ianaName) => switch (ianaName) {
        'Asia/Jakarta' => 'WIB',
        'Asia/Makassar' => 'WITA',
        'Asia/Jayapura' => 'WIT',
        _ => ianaName,
      };
}

/// The blue header: title, edit button, avatar, name, role, NIK pill.
class _Header extends StatelessWidget {
  final ProfileDetailLoaded? state;
  final VoidCallback? onEdit;

  const _Header({required this.state, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final user = state?.user;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: T.brand600),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            // The blue bleeds behind the status bar, so the inset is added to
            // the design's own 22px rather than handed to a SafeArea — which
            // would push the whole block down by the bar's height.
            // 56px bottom, so the stat card can overlap it by 34.
            padding: EdgeInsets.fromLTRB(
              T.screenX,
              MediaQuery.paddingOf(context).top + 22,
              T.screenX,
              56,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: T.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Profil',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(T.rChip),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Avatar(name: user?.name, url: user?.avatarUrl),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? ' ',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                [user?.position, user?.department]
                                    .whereType<String>()
                                    .join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.75),
                                ),
                              ),
                              if (user != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.16),
                                    borderRadius:
                                        BorderRadius.circular(T.rPill),
                                  ),
                                  child: Text(
                                    'NIK ${user.nik}',
                                    style: AppText.numeric(const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    )),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 66x66 amber tile with the initial in brand blue — the one amber surface on
/// the screen, which is what makes it read as the subject.
class _Avatar extends StatelessWidget {
  final String? name;
  final String? url;

  const _Avatar({required this.name, required this.url});

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: 66,
      height: 66,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: T.accent500,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        (name == null || name!.isEmpty) ? '·' : name![0].toUpperCase(),
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: T.brand600,
        ),
      ),
    );

    if (url == null) return tile;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 66,
        height: 66,
        fit: BoxFit.cover,
        placeholder: (_, __) => tile,
        errorWidget: (_, __, ___) => tile,
      ),
    );
  }
}

/// Three cells split by hairlines, overlapping the header.
class _StatStrip extends StatelessWidget {
  final ProfileDetailLoaded state;

  const _StatStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final years = state.yearsOfService;
    final leave = state.remainingLeaveDays;
    final rate = state.attendanceRate;

    return AppCard(
      padding: const EdgeInsets.all(16),
      shadow: const [
        BoxShadow(
          color: Color(0x66101C2B), // rgba(16,28,43,.4)
          blurRadius: 24,
          spreadRadius: -16,
          offset: Offset(0, 8),
        ),
      ],
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Each cell reads "—" rather than 0 when its source failed.
            _cell(years == null ? '—' : formatDecimal(years), 'Tahun kerja'),
            const VerticalDivider(width: 1, color: T.borderSoft),
            _cell('${leave ?? '—'}', 'Sisa cuti'),
            const VerticalDivider(width: 1, color: T.borderSoft),
            _cell(rate == null ? '—' : '${rate.round()}%', 'Kehadiran'),
          ],
        ),
      ),
    );
  }

  Widget _cell(String value, String label) => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: AppText.numeric(const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: T.ink900,
              )),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: T.ink400,
              ),
            ),
          ],
        ),
      );
}

/// Label-left / value-right rows. The original's underlined text inputs are
/// replaced by read-only rows — editing lives behind the header's edit button.
class _InfoCard extends StatelessWidget {
  final List<(String, String)> rows;

  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: T.borderSoft),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  Text(
                    rows[i].$1,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: T.ink400,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      rows[i].$2,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.numeric(const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: T.ink900,
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// TODO(api): the contract has no manager field on `User` and no endpoint that
/// returns one. These values are the handoff's, held here so the card is a
/// one-line change once an endpoint exists.
const _stubManagerName = 'Sari Wulandari';
const _stubManagerRole = 'Engineering Manager';

class _ManagerCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ManagerCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: T.brand100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                _stubManagerName[0],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: T.brand600,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    _stubManagerName,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: T.ink900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    _stubManagerRole,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: T.ink400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: T.ink300,
            ),
          ],
        ),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
}

class _Message extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;

  const _Message({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Text(text, textAlign: TextAlign.center, style: AppText.body),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onRetry,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text('Coba lagi', style: AppText.sectionAction),
            ),
          ),
        ],
      ),
    );
  }
}
