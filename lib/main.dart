// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v2/pages/home/home_page.dart';

import 'model/models.dart';
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
  final int _interval = 1;

  @override
  void initState() {
    super.initState();

    /// get everything from storage.
    Future.delayed(const Duration(milliseconds: 1000), () async {
      final recordPro = ref.read(recordProvider.notifier);
      recordPro.loadRecordFromStorage();
      List<Event> todaysEvents = ref.read(storageProvider).get_events();
      if (todaysEvents.isEmpty) {
        log('No saved events today : []');
        return;
      }
      final today = DateTime.now();
      if (today.day == todaysEvents.first.st.day &&
          today.month == todaysEvents.first.st.month) {
        log('Saved Events today: ${todaysEvents.toString()}');
        ref.read(eventsProvider.notifier).updateEvents(todaysEvents);
        return;
      }
      recordPro.addDayEvents(todaysEvents);
    });

    /// start updater
    _startUpdater();
  }

  void _startUpdater() {
    final timeProvider = ref.read(timerProvider.notifier);
    _updater = Timer.periodic(Duration(seconds: _interval), (timer) {
      timeProvider.update();
      ref.read(pastDayPro.notifier).updatePastDayPoints();
    });
  }

  // void updatePastPoints(int startHour, int duration) {
  //   log('----------------------------------------------------');
  //   List<List<Event>> allEvents = ref.read(recordProvider).dayEvents;
  //   log('Number of past day ${allEvents.length.toString()}');
  //   for (int i = 0; i < allEvents.length; i++) {
  //     if (allEvents[i].isEmpty) continue;

  //     List<Event> dayEvents = allEvents[i];
  //     log('$i ::: ${dayEvents.toString()}');
  //     final viewWidth = ref.read(viewProvider);
  //     final nowDt = DateTime.now();
  //     final targetDayDt = dayEvents.first.st;
  //     List<Point> dayPoint = Utils.extractPointsFromEvents(
  //       today: false,
  //       refdt: DtUtils.getRefDt(nowDt: nowDt, targetDayDt: targetDayDt),
  //       events: dayEvents,
  //       viewDur: viewWidth,
  //     );
  //     log('$i :/: ${dayPoint.toString()}');
  //     // ref.read(recordProvider.notifier).addDayPoint(dayPoint);
  //     // List<Point> dayPoint = [];
  //     // DateTime dayStartDt = DtUtils.getDayStartdt(allEvents[i].first.st);

  //     // dayPoint.add(Point(dt: dayStartDt, point: const Offset(0, 0)));

  //     // /// add points from event list
  //     // double cumulativeDur = 0;
  //     // for (int k = 0; k < allEvents[i].length; k++) {
  //     //   Event e = allEvents[i][k];
  //     //   Point sp = Point(
  //     //     dt: e.st,
  //     //     point: Offset(
  //     //       e.st.difference(dayStartDt).inSeconds.toDouble(),
  //     //       cumulativeDur,
  //     //     ),
  //     //     duration: cumulativeDur,
  //     //   );
  //     //   dayPoint.add(sp);
  //     //   if (e.et != null) {
  //     //     cumulativeDur = cumulativeDur + e.d!.inSeconds.toDouble();
  //     //     Point ep = Point(
  //     //       dt: e.et!,
  //     //       point: Offset(
  //     //         e.et!.difference(dayStartDt).inSeconds.toDouble(),
  //     //         cumulativeDur,
  //     //       ),
  //     //       duration: cumulativeDur,
  //     //     );
  //     //     dayPoint.add(ep);
  //     //   }
  //     // }
  //     // dayPoint.add(Point(
  //     //   dt: DtUtils.getDayEnddt(dayStartDt),
  //     //   point: Offset(
  //     //     const Duration(hours: 24).inSeconds.toDouble(),
  //     //     cumulativeDur,
  //     //   ),
  //     //   duration: cumulativeDur,
  //     // ));

  //     // /// sort
  //     // dayPoint.sort((a, b) => a.dt.compareTo(b.dt));

  //     // /// add session start point
  //     // DateTime sessionStartdt = DateTime(
  //     //   dayStartDt.year,
  //     //   dayStartDt.month,
  //     //   dayStartDt.day,
  //     //   startHour,
  //     // );
  //     // for (int m = 0; m < dayPoint.length - 1; m++) {
  //     //   final bool inMiddle = sessionStartdt.isAfter(dayPoint[m].dt) &&
  //     //       sessionStartdt.isBefore(dayPoint[m + 1].dt);
  //     //   if (!inMiddle) continue;
  //     //   double y = dayPoint[m].point.dy;
  //     //   if (dayPoint[m].point.dy != dayPoint[m + 1].point.dy) {
  //     //     int dy = dayPoint[m].dt.difference(sessionStartdt).inSeconds;
  //     //     y = y + dy;
  //     //   }
  //     //   final p = Point(
  //     //     dt: sessionStartdt,
  //     //     point: Offset(
  //     //       sessionStartdt.difference(dayStartDt).inSeconds.toDouble(),
  //     //       y,
  //     //     ),
  //     //     duration: y,
  //     //   );
  //     //   dayPoint.add(p);
  //     //   break;
  //     // }
  //     // // add session end point
  //     // DateTime sessionEnddt = sessionStartdt.add(Duration(hours: duration));
  //     // for (int m = 0; m < dayPoint.length - 1; m++) {
  //     //   bool inMiddle = sessionEnddt.isAfter(dayPoint[m].dt) &&
  //     //       sessionEnddt.isBefore(dayPoint[m + 1].dt);
  //     //   if (!inMiddle) continue;

  //     //   double y = dayPoint[m].point.dy;
  //     //   if (dayPoint[m].point.dy != dayPoint[m + 1].point.dy) {
  //     //     int dy = dayPoint[m].dt.difference(sessionEnddt).inSeconds;
  //     //     y = y + dy;
  //     //   }
  //     //   final p = Point(
  //     //     dt: sessionEnddt,
  //     //     point: Offset(
  //     //       sessionEnddt.difference(dayStartDt).inSeconds.toDouble(),
  //     //       y,
  //     //     ),
  //     //     duration: y,
  //     //   );
  //     //   dayPoint.add(p);
  //     //   break;
  //     // }

  //     // /// sort
  //     // dayPoint.sort((a, b) => a.dt.compareTo(b.dt));

  //     // /// remove points that are outside of the session points
  //     // dayPoint = Utils.removeExtraPoints(
  //     //   dayPoint,
  //     //   sessionStartdt,
  //     //   sessionEnddt,
  //     // );
  //     // // ref.read(viewSpecProvider.notifier).checkYmax(dayPoint);
  //     // log('$i :/: ${dayPoint.toString()}');
  //     // ref.read(recordProvider.notifier).addDayPoint(dayPoint);
  //   }
  // }

  @override
  void dispose() {
    _updater.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch(pastDayPro);
    // ref.read(sessionStartTimeProvider);
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
