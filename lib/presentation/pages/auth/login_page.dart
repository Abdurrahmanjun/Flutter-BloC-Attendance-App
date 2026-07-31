import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart' show showInDialog, DialogAnimation;

import 'package:attendance/app_theme.dart';
import 'package:attendance/common/settings/app_settings.dart';
import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/injection_container.dart' as di;
import 'package:attendance/presentation/bloc/token/token_bloc.dart';
import 'package:attendance/presentation/pages/auth/components/forgot_password_dialog.dart';
import 'package:attendance/presentation/pages/dashboard_navigation/dashboard_navigation_page.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// `POST /api/auth/login`. The only screen without a tab bar.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _settings = di.sl<AppSettings>();

  late final _nikController =
      TextEditingController(text: _settings.savedNik ?? '');
  final _passwordController = TextEditingController();

  late bool _remember = _settings.rememberNik;
  bool _obscure = true;

  @override
  void dispose() {
    _nikController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final username = _nikController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _snack('NIK dan kata sandi wajib diisi.', T.danger500);
      return;
    }

    // Persisted before the request: the preference is the user's regardless of
    // whether these particular credentials turn out to be right.
    _settings.setRememberNik(remember: _remember, nik: username);

    context
        .read<TokenBloc>()
        .add(SetTokenEvent(username: username, password: password));
  }

  void _toggleObscure() => setState(() => _obscure = !_obscure);

  void _setRemember(bool value) => setState(() => _remember = value);

  void _snack(String message, Color background) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.brandOverlay,
      child: Scaffold(
        backgroundColor: T.brand600,
        body: BlocListener<TokenBloc, TokenState>(
          listener: (context, state) {
            if (state is LoadedGetTokenState) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeNavBarPage()),
              );
            }
            if (state is ErrorGetTokenState) {
              _snack(state.message, T.danger500);
            }
          },
          child: Column(
            children: [
              // Collapses to just the wordmark while the keyboard is up, so
              // the sheet keeps enough height to scroll the focused field into
              // view instead of being squeezed behind the keyboard.
              _Header(
                compact: MediaQuery.viewInsetsOf(context).bottom > 0,
                tight: MediaQuery.sizeOf(context).height < 800,
              ),
              Expanded(child: _Sheet(state: this)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-bleed brand blue, with the two decorative circles behind the copy.
///
/// The handoff sizes this against an 840px-tall viewport. Most phones are
/// shorter than that, where a fixed header of the specified height crowds the
/// form off the screen — so [tight] trims its vertical rhythm and [compact]
/// drops the headline entirely while the keyboard is open.
class _Header extends StatelessWidget {
  final bool compact;
  final bool tight;

  const _Header({required this.compact, required this.tight});

  @override
  Widget build(BuildContext context) {
    final topPad = compact ? 12.0 : (tight ? 28.0 : 56.0);
    final gap = tight ? 22.0 : 44.0;
    final bottomPad = compact ? 16.0 : (tight ? 26.0 : 40.0);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: T.brand600),
      child: Stack(
        children: [
          const Positioned(
            top: -90,
            right: -70,
            child: _Circle(size: 230, opacity: 0.07),
          ),
          const Positioned(
            top: 60,
            right: 20,
            child: _Circle(size: 120, opacity: 0.05),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              26,
              // The blue runs behind the status bar, so its inset is added to
              // the design's top padding rather than handed to a SafeArea.
              MediaQuery.paddingOf(context).top + topPad,
              26,
              bottomPad,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: T.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: T.accent500,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'A',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: T.brand600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Absensi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (!compact) ...[
                      SizedBox(height: gap),
                      Text(
                        'Selamat datang\nkembali',
                        style: AppText.loginHeadline.copyWith(
                          fontSize: tight ? 30 : 34,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          'Masuk dengan NIK dan kata sandi kamu untuk mulai '
                          'mencatat kehadiran.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.78),
                          ),
                        ),
                      ),
                    ],
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

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;

  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// The canvas sheet: fields, primary action, and the biometric alternative.
class _Sheet extends StatelessWidget {
  final _LoginPageState state;

  const _Sheet({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: T.canvas,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: T.maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                26,
                MediaQuery.sizeOf(context).height < 800 ? 24 : 34,
                26,
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Field(
                    label: 'Nomor Induk Karyawan',
                    icon: Icons.person_outline_rounded,
                    controller: state._nikController,
                    hint: '20240117',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'Kata sandi',
                    icon: Icons.lock_outline_rounded,
                    controller: state._passwordController,
                    hint: '••••••••',
                    obscure: state._obscure,
                    // The design's "Lihat" reveal — the original had no way to
                    // check what you had typed.
                    trailing: GestureDetector(
                      onTap: state._toggleObscure,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        state._obscure ? 'Lihat' : 'Sembunyikan',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: T.brand600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Checkbox(
                        value: state._remember,
                        onChanged: state._setRemember,
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'Ingat saya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: T.ink600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => showInDialog(
                          context,
                          dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
                          builder: (_) => ForgotPasswordDialog(),
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: const Text(
                          'Lupa sandi?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: T.brand600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<TokenBloc, TokenState>(
                    builder: (context, tokenState) => _PrimaryButton(
                      label: 'Masuk',
                      busy: tokenState is LoadingGetTokenState,
                      onTap: state._login,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _OrDivider(),
                  const SizedBox(height: 16),
                  _SecondaryButton(
                    icon: Icons.fingerprint_rounded,
                    label: 'Masuk dengan sidik jari',
                    // TODO(auth): biometric login needs both a `local_auth`
                    // dependency and a contract endpoint to exchange a device
                    // credential for a token. Neither exists yet.
                    onTap: () => state._snack(
                      'Masuk dengan sidik jari belum tersedia.',
                      T.ink700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Butuh bantuan? Hubungi HR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: T.ink300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Label over a bordered white input with a leading brand icon.
class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: T.ink600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(
            color: T.surface,
            borderRadius: BorderRadius.circular(T.rInput),
            border: Border.all(color: T.borderStrong, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A101C2B), // rgba(16,28,43,.04)
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: T.brand600),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  style: AppText.numeric(TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: T.ink900,
                    // The design tracks the password dots wide.
                    letterSpacing: obscure ? 3.5 : null,
                  )),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: T.ink300,
                    ),
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Checkbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: T.stateChange,
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: value ? T.brand600 : T.surface,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: value ? T.brand600 : T.borderStrong,
            width: 1.5,
          ),
        ),
        child: value
            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: double.infinity,
        // Fixed, so swapping in the spinner does not resize the button.
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: T.brand600,
          borderRadius: BorderRadius.circular(T.rButton),
          boxShadow: T.primaryButtonShadow,
        ),
        child: busy
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(height: 1, color: T.borderStrong)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: T.ink300,
            ),
          ),
        ),
        Expanded(child: Divider(height: 1, color: T.borderStrong)),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: T.surface,
          borderRadius: BorderRadius.circular(T.rButton),
          border: Border.all(color: T.borderStrong, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: T.ink900),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: T.ink900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
