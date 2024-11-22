import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2/provider/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings  '),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.clear),
            title: const Text('Clear todays events'),
            subtitle: const Text('delete todays event parmanently'),
            onTap: () {
              ref.read(eventsProvider.notifier).deleteEvents();
            },
          )
        ],
      ),
    );
  }
}
