// ignore_for_file: non_constant_identifier_names

import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v2/pages/home/home_page.dart';


import 'provider/providers.dart';

final helloWorldProvider = Provider((_) => 'Hello world');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final String value = ref.watch(helloWorldProvider);

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Root(),
    );
  }
}

class Root extends ConsumerStatefulWidget {
  const Root({super.key});

  @override
  ConsumerState<Root> createState() => _RootState();
}

class _RootState extends ConsumerState<Root> {
  late Timer _updater;
  int _interval = 5;

  @override
  void initState() {
    super.initState();
    _startUpdater();

    // get events from storage.
    Future.delayed(const Duration(seconds: 3), () async {
      ref.read(eventsProvider.notifier).get_events_from_stg();
    });
  }

  void _startUpdater() {
    final timeProvider = ref.read(timerProvider.notifier);
    _updater = Timer.periodic(Duration(seconds: _interval), (timer) {
      timeProvider.update();
    });
  }

  void _changeInterval(int newInterval) {
    _interval = newInterval;
    _updater.cancel();
    _startUpdater();
  }

  void _stopUpdater() {
    _updater.cancel();
  }

  @override
  void dispose() {
    _updater.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}






// class Root extends ConsumerStatefulWidget {
//   const Root({super.key});

//   @override
//   ConsumerState<Root> createState() => _RootState();
// }

// class _RootState extends ConsumerState<Root> {
//   late StreamController<int> _streamController;
//   late Timer _timer;
//   int _counter = 0;
//   int _interval = 5;

//   @override
//   void initState() {
//     super.initState();
//     _streamController = StreamController<int>();
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(Duration(seconds: _interval), (timer) {
//       _counter++;
//       _streamController.add(_counter);
//     });
//   }

//   void _changeInterval(int newInterval) {
//     _interval = newInterval;
//     _timer.cancel();
//     _startTimer();
//   }

//   void _stopStream() {
//     _timer.cancel();
//     _streamController.close();
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     _streamController.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
