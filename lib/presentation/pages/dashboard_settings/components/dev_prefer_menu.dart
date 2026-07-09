import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/common/network/dev_prefer.dart';
import 'package:attendance/presentation/bloc/attendance/today_bloc.dart';

/// Debug-only. Prism is a stateless mock, so a check-in never makes the next
/// `today` return `checked_in`. These switches set the `Prefer` header the mock
/// honours, which is what makes the whole day — including the 409 and the
/// geofence 422 — walkable from inside the running app.
///
/// Renders nothing in a release build.
class DevPreferMenu extends StatelessWidget {
  const DevPreferMenu({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'MOCK (DEBUG)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
              color: Colors.black45,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 2, 16, 8),
          child: Text(
            'Prism replays fixed examples. Pick which one it returns.',
            style: TextStyle(fontSize: 11, color: Colors.black38),
          ),
        ),
        _PreferTile(
          title: 'GET /attendance/today',
          notifier: DevPrefer.today,
          options: DevPrefer.todayOptions,
          // Re-read immediately so the home screen reflects the new choice.
          onChanged: () => context.read<TodayBloc>().add(LoadTodayEvent()),
        ),
        _PreferTile(
          title: 'POST check-in / check-out',
          notifier: DevPrefer.punch,
          options: DevPrefer.punchOptions,
        ),
      ],
    );
  }
}

class _PreferTile extends StatelessWidget {
  final String title;
  final ValueNotifier<String?> notifier;
  final Map<String, String?> options;
  final VoidCallback? onChanged;

  const _PreferTile({
    required this.title,
    required this.notifier,
    required this.options,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: notifier,
      builder: (context, current, _) {
        final label = options.entries
            .firstWhere((entry) => entry.value == current,
                orElse: () => options.entries.first)
            .key;

        return ListTile(
          dense: true,
          leading: const Icon(Icons.science_outlined, color: Colors.black54),
          title: Text(title, style: const TextStyle(fontSize: 14)),
          subtitle: Text(label),
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: () async {
            final choice = await showModalBottomSheet<MapEntry<String, String?>>(
              context: context,
              builder: (sheetContext) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.entries
                      .map((entry) => ListTile(
                            title: Text(entry.key),
                            subtitle: entry.value == null
                                ? const Text('no Prefer header')
                                : Text('Prefer: ${entry.value}'),
                            selected: entry.value == current,
                            onTap: () => Navigator.pop(sheetContext, entry),
                          ))
                      .toList(),
                ),
              ),
            );

            if (choice == null) return;
            notifier.value = choice.value;
            onChanged?.call();
          },
        );
      },
    );
  }
}
