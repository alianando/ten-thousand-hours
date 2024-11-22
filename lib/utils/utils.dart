// ignore_for_file: non_constant_identifier_names

import 'dart:developer';
import 'dart:ui';

import '../model/models.dart';

class EventsUtils {
  const EventsUtils._();

  static List<Event> addStartTime(List<Event> events, DateTime dt) {
    events.add(Event(st: dt));
    log('added event start time');
    return events;
  }

  static List<Event> addEndTime(List<Event> events, DateTime dt) {
    //  events.add(Event(st: dt));
    events.last = Event(
      st: events.last.st,
      et: dt,
      d: dt.difference(events.last.st),
    );
    log('added event end time');
    return events;
  }

  static bool isActive(List<Event> events) {
    if (events.isEmpty) return false;
    if (events.last.et == null) return true;
    return false;
  }
}

class Utils {
  const Utils._();

  static List<Point> extractPointsFromEvents({
    required bool today,
    required DateTime refdt,
    required List<Event> events,
    required Duration viewDur,
  }) {
    List<Point> points = [];
    final DateTime nowDt = refdt;
    final dayStartDt = DtUtils.getDayStartdt(nowDt);

    /// add 0.00 a.m. point (day start point).
    points.add(Point(dt: dayStartDt, point: const Offset(0, 0)));

    /// add points from [events]
    double cumulativeDur = 0; // in seconds.
    bool eventOngoing = false;
    for (int i = 0; i < events.length; i++) {
      final Event e = events[i];
      if (e.st != dayStartDt) {
        points.add(Point(
          dt: e.st,
          point: Offset(
            e.st.difference(dayStartDt).inSeconds.toDouble(),
            cumulativeDur,
          ),
          duration: cumulativeDur,
        ));
      }
      if (e.et == null) {
        eventOngoing = true;
      } else {
        cumulativeDur = cumulativeDur + e.d!.inSeconds;
        points.add(Point(
          dt: e.et!,
          point: Offset(
            e.et!.difference(dayStartDt).inSeconds.toDouble(),
            cumulativeDur,
          ),
          duration: e.d!.inSeconds.toDouble(),
        ));
      }
    }

    if (eventOngoing) {
      final currentDuration = nowDt.difference(events.last.st).inSeconds;
      cumulativeDur = cumulativeDur + currentDuration;
    }

    /// add now point.
    if (today) {
      points.add(
        Point(
          dt: nowDt,
          point: Offset(
            nowDt.difference(dayStartDt).inSeconds.toDouble(),
            cumulativeDur,
          ),
          duration: cumulativeDur,
        ),
      );
    }

    /// sort
    points.sort((a, b) => a.dt.compareTo(b.dt));

    /// add session start point
    final sessionStartdt = DtUtils.getSessionStartTime(
      refDt: refdt,
      viewWidth: viewDur,
    );
    // if viewDur is 1 day or 12 hours we may not need to add session start dt.
    if (sessionStartdt != dayStartDt) {
      for (int i = 0; i < points.length - 1; i++) {
        bool inMiddle = sessionStartdt.isAfter(points[i].dt) &&
            sessionStartdt.isBefore(points[i + 1].dt);
        if (!inMiddle) continue;

        double y = points[i].point.dy;
        if (points[i].point.dy != points[i + 1].point.dy) {
          y = y + points[i].dt.difference(sessionStartdt).inSeconds.toDouble();
        }
        points.add(Point(
          dt: sessionStartdt,
          point: Offset(
            sessionStartdt.difference(dayStartDt).inSeconds.toDouble(),
            y,
          ),
          duration: y,
        ));
      }
    }

    /// add session end point
    final sessionEnddt = sessionStartdt.add(viewDur);

    if (sessionEnddt.isBefore(dayStartDt.add(const Duration(hours: 24)))) {
      cumulativeDur = cumulativeDur + sessionEnddt.difference(nowDt).inSeconds;
      points.add(Point(
        dt: sessionEnddt,
        point: Offset(
          sessionEnddt.difference(dayStartDt).inSeconds.toDouble(),
          cumulativeDur,
        ),
        duration: cumulativeDur,
      ));
    } else {
      final difference = DtUtils.getDayEnddt(refdt).difference(nowDt).inSeconds;
      cumulativeDur = cumulativeDur + difference;
    }

    /// add day end point.
    points.add(
      Point(
        dt: DtUtils.getDayEnddt(refdt),
        point: Offset(
          const Duration(hours: 24).inSeconds.toDouble(),
          cumulativeDur,
        ),
        duration: cumulativeDur,
      ),
    );

    /// sort
    points.sort((a, b) => a.dt.compareTo(b.dt));

    /// remove points that are outside of the session points
    points = removeExtraPoints(points, sessionStartdt, sessionEnddt);

    /// add relative positions
    points = updateRelativePositions(points, refdt);
    // log('${refdt.toString()}: ${points.toList().toString()}');
    return points;
  }

  static List<Point> extract_points(
    List<Event> events,
    Duration viewWidth,
  ) {
    List<Point> ps = [];
    final nowDt = DateTime.now();
    final dayStartDt = DateTime(nowDt.year, nowDt.month, nowDt.day);

    /// add 0.00 a.m. point (day start point).
    ps.add(Point(dt: dayStartDt, point: const Offset(0, 0)));

    /// add points from event list
    double cumulativeDur = 0;
    bool eventOngoing = false;
    for (int i = 0; i < events.length; i++) {
      Event e = events[i];
      if (e.st != dayStartDt) {
        Point sp = Point(
          dt: e.st,
          point: Offset(
            e.st.difference(dayStartDt).inSeconds.toDouble(),
            cumulativeDur,
          ),
          duration: cumulativeDur,
        );
        ps.add(sp);
      }
      if (e.et != null) {
        cumulativeDur = cumulativeDur + e.d!.inSeconds.toDouble();
        Point ep = Point(
          dt: e.et!,
          point: Offset(
            e.et!.difference(dayStartDt).inSeconds.toDouble(),
            cumulativeDur,
          ),
          duration: e.d!.inSeconds.toDouble(),
        );
        ps.add(ep);
      } else {
        eventOngoing = true;
      }
    }

    if (eventOngoing) {
      double currentDuration =
          nowDt.difference(events.last.st).inSeconds.toDouble();
      cumulativeDur = cumulativeDur + currentDuration;
    }

    // add now point.
    ps.add(
      Point(
        dt: nowDt,
        point: Offset(
          nowDt.difference(dayStartDt).inSeconds.toDouble(),
          cumulativeDur,
        ),
        duration: cumulativeDur,
      ),
    );

    /// sort
    ps.sort((a, b) => a.dt.compareTo(b.dt));

    /// add session start point
    /// DateTime sessionStartdt = nowDt.subtract(viewWidth);
    DateTime sessionStartdt = DateTime(
      nowDt.year,
      nowDt.month,
      nowDt.day,
      nowDt.hour,
      0,
      0,
      0,
    );

    if (sessionStartdt.isAfter(dayStartDt)) {
      for (int i = 0; i < ps.length - 1; i++) {
        final bool inMiddle = sessionStartdt.isAfter(ps[i].dt) &&
            sessionStartdt.isBefore(ps[i + 1].dt);
        if (inMiddle) {
          double y = ps[i].point.dy;
          if (ps[i].point.dy != ps[i + 1].point.dy) {
            //  y = dayStartDt.difference(sessionStartdt).inSeconds.toDouble();
            y = y + ps[i].dt.difference(sessionStartdt).inSeconds.toDouble();
          }
          final p = Point(
            dt: sessionStartdt,
            point: Offset(
              sessionStartdt.difference(dayStartDt).inSeconds.toDouble(),
              y,
            ),
            duration: y,
          );
          ps.add(p);
          break;
        }
        if (sessionStartdt.isAfter(ps[i + 1].dt)) {
          break;
        }
      }
    }
    // add session end point
    DateTime sessionEnddt = nowDt.add(viewWidth);

    sessionEnddt = DateTime(nowDt.year, nowDt.month, nowDt.day, nowDt.hour + 1);

    if (sessionEnddt.isBefore(dayStartDt.add(const Duration(hours: 24)))) {
      // we need to insert the point
      // cumulativeDur = cumulativeDur + viewWidth.inSeconds.toDouble();
      cumulativeDur =
          cumulativeDur + sessionEnddt.difference(nowDt).inSeconds.toDouble();
      ps.add(
        Point(
          dt: sessionEnddt,
          point: Offset(
            sessionEnddt.difference(dayStartDt).inSeconds.toDouble(),
            cumulativeDur,
          ),
        ),
      );
    } else {
      cumulativeDur = cumulativeDur +
          dayStartDt
              .add(const Duration(hours: 24))
              .difference(nowDt)
              .inSeconds
              .toDouble();
    }
    // add day end point.
    ps.add(
      Point(
        dt: dayStartDt.add(const Duration(hours: 24)),
        point: Offset(
          const Duration(hours: 24).inSeconds.toDouble(),
          cumulativeDur,
        ),
      ),
    );

    /// sort
    ps.sort((a, b) => a.dt.compareTo(b.dt));

    /// remove points that are outside of the session points
    ps = removeExtraPoints(ps, sessionStartdt, sessionEnddt);

    /// add relative positions
    ps = updateRelativePositions(ps, nowDt);
    // log(ps.toList().toString());
    return ps;
  }

  // set the relative position of now_point to 0.
  // relative position helps to find the new_points or how close a point is from the now_point
  // past and future point gets negative or positive values
  static List<Point> updateRelativePositions(List<Point> ps, DateTime dt) {
    int i = ps.indexWhere((p) => p.dt == dt);
    if (i < 0) return ps;
    for (int j = i - 1; j >= 0; j--) {
      ps[j] = Point(
        dt: ps[j].dt,
        point: ps[j].point,
        duration: ps[j].duration,
        relativePosition: (j - i).toDouble(),
      );
    }
    for (int j = i + 1; j < ps.length; j++) {
      ps[j] = Point(
        dt: ps[j].dt,
        point: ps[j].point,
        duration: ps[j].duration,
        relativePosition: (j - i).toDouble(),
      );
    }
    ps[i] = Point(
      dt: ps[i].dt,
      point: ps[i].point,
      duration: ps[i].duration,
      relativePosition: 0,
    );
    return ps;
  }

  static List<Point> removeExtraPoints(
    List<Point> points,
    DateTime sessionStartdt,
    DateTime sessionEnddt,
  ) {
    List<Point> finalPoints = [];
    for (int i = 0; i < points.length; i++) {
      bool before = points[i].dt.isBefore(sessionStartdt);
      bool after = points[i].dt.isAfter(sessionEnddt);
      if (!before && !after) {
        finalPoints.add(points[i]);
      }
    }
    if (finalPoints.isNotEmpty) {
      double x = finalPoints.first.point.dx;
      for (int i = 0; i < finalPoints.length; i++) {
        Point p = Point(
          dt: finalPoints[i].dt,
          duration: finalPoints[i].duration,
          point: Offset(finalPoints[i].point.dx - x, finalPoints[i].point.dy),
        );
        finalPoints[i] = p;
      }
    }
    return finalPoints;
  }

  static double getXmax(List<Point> ps) {
    if (ps.length <= 1) {
      return 100;
    }
    return (ps.last.point.dx - ps.first.point.dx) + ps.last.point.dx * 0.00;
  }

  static double getYmax(List<Point> ps) {
    if (ps.isEmpty) return 1;
    // return (ps.last.point.dy - ps.first.point.dy);
    // double y = ps.last.point.dy;
    // y = y > 900 ? y : 900;
    if (ps.last.point.dy == 0) return 1;
    return ps.last.point.dy;
  }
}

class DtUtils {
  const DtUtils._();

  static DateTime getRefDt({
    required DateTime nowDt,
    required DateTime targetDayDt,
  }) {
    return DateTime(
      targetDayDt.year,
      targetDayDt.month,
      targetDayDt.day,
      nowDt.hour,
      nowDt.minute,
      nowDt.second,
    );
  }

  static DateTime getSessionStartTime({
    required DateTime refDt,
    required Duration viewWidth,
  }) {
    if (viewWidth == const Duration(hours: 1)) {
      return DateTime(
        refDt.year,
        refDt.month,
        refDt.day,
        refDt.hour,
        0,
        0,
        0,
      );
    }
    if (viewWidth == const Duration(hours: 12)) {
      int hour = 0;

      if (refDt.hour >= 12) {
        hour = 12;
      }
      return DateTime(
        refDt.year,
        refDt.month,
        refDt.day,
        hour,
        0,
        0,
        0,
      );
    }
    if (viewWidth == const Duration(days: 1)) {
      return DateTime(refDt.year, refDt.month, refDt.day, 0, 0, 0, 0);
    }
    if (viewWidth == const Duration(minutes: 1)) {
      return DateTime(
        refDt.year,
        refDt.month,
        refDt.day,
        refDt.hour,
        refDt.minute,
        0,
        0,
      );
    }
    return refDt;
  }

  static DateTime getDayStartdt(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day, 0, 0, 0, 0, 0);
  }

  static DateTime getDayEnddt(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day, 24, 0, 0, 0, 0).subtract(
      const Duration(microseconds: 1),
    );
  }

  static String getTimeString(DateTime dt) {
    int hour = dt.hour;
    String identifier = 'am';
    if (hour > 12) {
      hour = hour - 12;
      identifier = 'pm';
    }

    return '$hour:${dt.minute}:${dt.second} $identifier';
  }
}
