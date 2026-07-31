import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/app_theme.dart';
import 'package:attendance/common/settings/app_settings.dart';
import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/injection_container.dart' as di;
import 'package:attendance/presentation/bloc/token/token_bloc.dart';
import 'package:attendance/presentation/pages/auth/login_page.dart';
import 'package:attendance/presentation/pages/dashboard_settings/components/dev_prefer_menu.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// Pengaturan — local preferences, account shortcuts, the debug mock switches,
/// and logout.
///
/// Nothing here is server state: the contract has no preferences endpoint, so
/// the switches persist to `SharedPreferences` via [AppSettings].
class DashboardSettingsPage extends StatelessWidget {
  const DashboardSettingsPage({super.key});

  /// TODO(build): read from package_info_plus once it is a dependency. This is
  /// the real pubspec version, not the handoff's demo string — a version number
  /// is the one label that must never be decorative.
  static const _version = 'Absensi v1.0.0 (build 1)';

  /// Always off; hoisted out of build so it is not rebuilt each frame.
  static final _darkModeOff = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final settings = di.sl<AppSettings>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.canvasOverlay,
      child: Scaffold(
        backgroundColor: T.canvas,
        body: SafeArea(
          bottom: false,
          child: BlocListener<TokenBloc, TokenState>(
            listener: (context, state) {
              if (state is LoggedOutState) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const SizedBox(height: 14),
                const ScreenBody(
                  child: Text('Pengaturan', style: AppText.screenTitle),
                ),
                const SizedBox(height: T.blockGap),

                ScreenBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionEyebrow('Preferensi'),
                      const SizedBox(height: 11),
                      AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          children: [
                            _ToggleRow(
                              icon: Icons.notifications_none_rounded,
                              label: 'Pengingat check-in',
                              notifier: settings.checkInReminder,
                              onChanged: settings.setCheckInReminder,
                            ),
                            const Divider(height: 1, color: T.borderSoft),
                            _ToggleRow(
                              icon: Icons.place_outlined,
                              label: 'Lokasi saat check-in',
                              notifier: settings.locationOnCheckIn,
                              onChanged: settings.setLocationOnCheckIn,
                            ),
                            const Divider(height: 1, color: T.borderSoft),
                            // Deliberately inert: the redesign is light-only and
                            // shipped no dark tokens, so flipping this would
                            // reveal the old, undesigned dark theme.
                            _ToggleRow(
                              icon: Icons.dark_mode_outlined,
                              label: 'Mode gelap',
                              notifier: _darkModeOff,
                              onChanged: (_) async => _notYetAvailable(
                                context,
                                'Mode gelap',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: T.blockGap),

                      const SectionEyebrow('Akun'),
                      const SizedBox(height: 11),
                      AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          children: [
                            // TODO(api): no change-password endpoint.
                            _LinkRow(
                              label: 'Ubah kata sandi',
                              onTap: () =>
                                  _notYetAvailable(context, 'Ubah kata sandi'),
                            ),
                            const Divider(height: 1, color: T.borderSoft),
                            // TODO(i18n): the app is Indonesian-only for now.
                            _LinkRow(
                              label: 'Bahasa',
                              value: 'Indonesia',
                              onTap: () =>
                                  _notYetAvailable(context, 'Ganti bahasa'),
                            ),
                            const Divider(height: 1, color: T.borderSoft),
                            _LinkRow(
                              label: 'Bantuan & dukungan',
                              onTap: () => _notYetAvailable(
                                context,
                                'Bantuan & dukungan',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: T.blockGap),

                      // Compiles out of release builds.
                      const DevPreferMenu(),
                    ],
                  ),
                ),

                const SizedBox(height: T.blockGap),
                ScreenBody(
                  child: _LogoutButton(onTap: () => _confirmLogout(context)),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    _version,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: T.ink300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _notYetAvailable(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('$what belum tersedia.'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ));
  }

  static void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TokenBloc>().add(LogoutEvent());
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: T.dangerStrong),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon, label, and the design's 44x26 pill switch.
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final ValueNotifier<bool> notifier;
  final Future<void> Function(bool) onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.notifier,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, value, _) => GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              Icon(icon, size: 19, color: T.ink700),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: T.ink900,
                  ),
                ),
              ),
              _Switch(value: value),
            ],
          ),
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool value;

  const _Switch({required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: T.stateChange,
      width: 44,
      height: 26,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? T.brand600 : T.toggleOff,
        borderRadius: BorderRadius.circular(T.rPill),
      ),
      child: AnimatedAlign(
        duration: T.stateChange,
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// A label with an optional trailing value and a chevron.
class _LinkRow extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _LinkRow({required this.label, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: T.ink900,
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value!,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: T.ink400,
                ),
              ),
              const SizedBox(width: 6),
            ],
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

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: T.dangerSurface,
          borderRadius: BorderRadius.circular(T.rButton),
          border: Border.all(color: T.dangerBorder, width: 1.5),
        ),
        child: const Text(
          'Keluar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: T.dangerStrong,
          ),
        ),
      ),
    );
  }
}
