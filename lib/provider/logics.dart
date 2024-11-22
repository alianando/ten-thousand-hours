import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/models.dart';
import '../utils/utils.dart';
import 'providers.dart';

class TimeNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void update() {
    final dt = DateTime.now();
    // log('update : ${dt.toString()}');
    state = dt;
  }
}

class PointsNotifier extends Notifier<List<Point>> {
  @override
  List<Point> build() {
    final events = ref.watch(eventsProvider);
    ref.watch(timerProvider);
    final viewWidth = ref.watch(viewProvider);
    final DateTime now = DateTime.now();
    return Utils.extractPointsFromEvents(
      today: true,
      refdt: now,
      events: events,
      viewDur: viewWidth,
    );
  }

//   List<Point> updatePoints({
//     required List<Event> events,
//     required Duration viewWidth,
//   }) {
//     List<Point> ps = [];
//     // if (events.isEmpty) return ps;
//     final nowDt = DateTime.now();
//     final dayStartDt = DtUtils.getDayStartdt(nowDt);

//     /// add 0.00 a.m. point (day start point).
//     ps.add(Point(dt: dayStartDt, point: const Offset(0, 0)));

//     /// add points from event list
//     double cumulativeDur = 0;
//     bool eventOngoing = false;
//     for (int i = 0; i < events.length; i++) {
//       Event e = events[i];
//       if (e.st != dayStartDt) {
//         Point sp = Point(
//           dt: e.st,
//           point: Offset(
//             e.st.difference(dayStartDt).inSeconds.toDouble(),
//             cumulativeDur,
//           ),
//           duration: cumulativeDur,
//         );
//         ps.add(sp);
//       }
//       if (e.et != null) {
//         cumulativeDur = cumulativeDur + e.d!.inSeconds.toDouble();
//         Point ep = Point(
//           dt: e.et!,
//           point: Offset(
//             e.et!.difference(dayStartDt).inSeconds.toDouble(),
//             cumulativeDur,
//           ),
//           duration: e.d!.inSeconds.toDouble(),
//         );
//         ps.add(ep);
//       } else {
//         eventOngoing = true;
//       }
//     }

//     if (eventOngoing) {
//       int currentDuration = nowDt.difference(events.last.st).inSeconds;
//       cumulativeDur = cumulativeDur + currentDuration;
//     }

//     // add now point.
//     ps.add(
//       Point(
//         dt: nowDt,
//         point: Offset(
//           nowDt.difference(dayStartDt).inSeconds.toDouble(),
//           cumulativeDur,
//         ),
//         duration: cumulativeDur,
//       ),
//     );

//     /// sort
//     ps.sort((a, b) => a.dt.compareTo(b.dt));

//     /// add session start point
//     DateTime sessionStartdt = DtUtils.getSessionStartTime(
//       refDt: nowDt,
//       viewWidth: viewWidth,
//     );
//     if (sessionStartdt.isBefore(dayStartDt)) {
//       sessionStartdt = dayStartDt;
//     }
//     for (int i = 0; i < ps.length - 1; i++) {
//       bool inMiddle = sessionStartdt.isAfter(ps[i].dt) &&
//           sessionStartdt.isBefore(ps[i + 1].dt);
//       if (!inMiddle) continue;

//       double y = ps[i].point.dy;
//       if (ps[i].point.dy != ps[i + 1].point.dy) {
//         //  y = dayStartDt.difference(sessionStartdt).inSeconds.toDouble();
//         y = y + ps[i].dt.difference(sessionStartdt).inSeconds.toDouble();
//       }
//       final p = Point(
//         dt: sessionStartdt,
//         point: Offset(
//           sessionStartdt.difference(dayStartDt).inSeconds.toDouble(),
//           y,
//         ),
//         duration: y,
//       );
//       ps.add(p);
//     }

//     // add session end point
//     DateTime sessionEnddt = sessionStartdt.add(viewWidth);

//     if (sessionEnddt.isBefore(dayStartDt.add(const Duration(hours: 24)))) {
//       // we need to insert the point
//       // cumulativeDur = cumulativeDur + viewWidth.inSeconds.toDouble();

//       /// this is the potential duration..
//       if (eventOngoing) {
//         cumulativeDur =
//             cumulativeDur + sessionEnddt.difference(nowDt).inSeconds;
//       }
//       ps.add(
//         Point(
//           dt: sessionEnddt,
//           point: Offset(
//             sessionEnddt.difference(dayStartDt).inSeconds.toDouble(),
//             cumulativeDur,
//           ),
//         ),
//       );
//     } else {
//       cumulativeDur = cumulativeDur +
//           dayStartDt.add(const Duration(hours: 24)).difference(nowDt).inSeconds;
//     }

//     // add day end point.
//     ps.add(
//       Point(
//         dt: dayStartDt.add(const Duration(hours: 24)),
//         point: Offset(
//           const Duration(hours: 24).inSeconds.toDouble(),
//           cumulativeDur,
//         ),
//       ),
//     );

//     /// sort
//     ps.sort((a, b) => a.dt.compareTo(b.dt));

//     /// remove points that are outside of the session points
//     ps = Utils.removeExtraPoints(ps, sessionStartdt, sessionEnddt);

//     /// add relative positions
//     ps = Utils.updateRelativePositions(ps, nowDt);
//     // ref.read(viewSpecProvider.notifier).checkYmax(ps);
//     // state = ps;
//     log(ps.toList().toString());
//     return ps;
//   }
}

class RecordNot extends Notifier<Record> {
  @override
  Record build() {
    return Record(dayEvents: List.empty());
  }

  void loadRecordFromStorage() {
    final record = Record(dayEvents: ref.read(storageProvider).get_record());
    log('Saved Record: [${record.toString()}]');
    state = record;
  }

  void addDayEvents(List<Event> events) {
    List<List<Event>> dayEvents = List.from(state.dayEvents);
    dayEvents.add(events);
    state = Record(dayEvents: dayEvents);
    log('Events added to the record::');
    log(':: [${events.toString()}]');
    ref.read(storageProvider).save_record(dayEvents);
  }

  bool isEmpty() {
    return state.dayEvents.isEmpty;
  }
}

class PastDayNot extends Notifier<List<Day>> {
  @override
  List<Day> build() {
    return [];
  }

  updatePastDayPoints() {
    ///
    log('//////');
    final record = ref.read(recordProvider);
    final recordEmpty = record.dayEvents.isEmpty;
    if (recordEmpty) {
      log('record empty. Dont change past days');
      return;
    }
    DateTime dt = ref.read(timerProvider);
    final graphWidth = ref.read(viewProvider);
    final currentSessionStartT = TimeOfDay.fromDateTime(
      DtUtils.getSessionStartTime(
        refDt: dt,
        viewWidth: graphWidth,
      ),
    );
    final sessionST = ref.read(sessionStartTimeProvider);

    final sessionUnchanged = sessionST == currentSessionStartT;
    if (sessionUnchanged) {
      return;
    }
    List<Day> days = [];
    for (int i = 0; i < record.dayEvents.length; i++) {
      Day d = Day(
        dayPoints: Utils.extractPointsFromEvents(
          today: false,
          refdt: DtUtils.getRefDt(
            nowDt: dt,
            targetDayDt: record.dayEvents[i].first.st,
          ),
          events: record.dayEvents[i],
          viewDur: graphWidth,
        ),
      );
      days.add(d);
      log(i.toString());
      if (record.dayEvents[i].isNotEmpty) {
        debugPrint(record.dayEvents[i].first.st.toString());
        debugPrint(record.dayEvents[i].toString());
        debugPrint(d.toString());
      }
    }
    // debugPrint(days.toString());
    state = days;
    ref
        .read(sessionStartTimeProvider.notifier)
        .updateTOfD(currentSessionStartT);
  }
}

class SessionStartTimeNotifier extends Notifier<TimeOfDay> {
  @override
  TimeOfDay build() {
    // final dt = ref.watch(timerProvider);
    // final graphWidth = ref.watch(viewProvider);
    // // log('update session start time');
    // return TimeOfDay.fromDateTime(DtUtils.getSessionStartTime(
    //   refDt: dt,
    //   viewWidth: graphWidth,
    // ));
    return TimeOfDay.now();
  }

  void updateTOfD(TimeOfDay t) {
    state = t;
  }
}

class ViewSelection extends Notifier<Duration> {
  @override
  Duration build() {
    return const Duration(minutes: 1);
  }

  void chageView(Duration newDuration) {
    state = newDuration;
  }
}

class ViewSpecNot extends Notifier<ViewSpecification> {
  @override
  build() {
    final points = ref.watch(pointsProvider);
    final pastDays = ref.watch(pastDayPro);
    double yMax = 1;
    double xMax = 1;
    if (points.isNotEmpty) xMax = points.last.point.dx;
    for (int i = 0; i < points.length; i++) {
      if (points[i].point.dy > yMax) yMax = points[i].point.dy;
    }
    for (int i = 0; i < pastDays.length; i++) {
      for (int j = 0; j < pastDays[i].dayPoints.length; j++) {
        if (pastDays[i].dayPoints[j].point.dy > yMax) {
          yMax = pastDays[i].dayPoints[j].point.dy;
        }
      }
    }
    // yMax = yMax + yMax;
    return ViewSpecification(xMax: xMax, yMax: yMax);
  }
}

class ViewSpecification {
  double xMax;
  double yMax;

  ViewSpecification({
    this.xMax = 1,
    this.yMax = 1,
  });
}
