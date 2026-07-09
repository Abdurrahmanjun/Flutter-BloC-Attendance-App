import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart' hide white;

import 'package:attendance/common/utils/colors.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/data/models/user/user.dart';
import 'package:attendance/presentation/bloc/profile/profile_bloc.dart';

/// `GET /api/me`.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "Profile",
        color: context.scaffoldBackgroundColor,
        elevation: 0,
        showBack: false,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) => switch (state) {
          ProfileLoaded(:final user) => _Profile(user: user),
          ProfileFailure(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () =>
                        context.read<ProfileBloc>().add(LoadProfileEvent()),
                    child: const Text('COBA LAGI'),
                  ),
                ],
              ),
            ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  final User user;

  const _Profile({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              _Avatar(url: user.avatarUrl, name: user.name),
              const SizedBox(height: 12),
              Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: darkerText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.position ?? '—',
                style: const TextStyle(color: lightText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _Field(label: 'NIK', value: user.nik),
        _Field(label: 'Email', value: user.email),
        _Field(label: 'Departemen', value: user.department ?? '—'),
        _Field(
          label: 'Bergabung',
          value: user.joinedAt == null ? '—' : formatDate(user.joinedAt!),
        ),
        _Field(
          label: 'Shift',
          value: '${user.shift.start} – ${user.shift.end} '
              '(${user.shift.timeZone})',
        ),
        _Field(
          label: 'Kantor',
          value: user.officeId == null ? '—' : 'Office #${user.officeId}',
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;

  const _Avatar({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    const size = 96.0;
    // The contract's example avatarUrl points at cdn.example.com, which does not
    // resolve; fall back to initials rather than a broken image box.
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: navylight,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: const TextStyle(
          color: white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (url == null) return fallback;

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;

  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: lightText)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: darkerText,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
