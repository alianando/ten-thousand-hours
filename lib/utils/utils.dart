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
      }
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
    // add session start point
    DateTime sessionStartdt = nowDt.subtract(viewWidth);

    if (sessionStartdt.isAfter(dayStartDt)) {
      for (int i = 0; i < ps.length - 1; i++) {
        final bool inMiddle = sessionStartdt.isAfter(ps[i].dt) &&
            sessionStartdt.isBefore(ps[i + 1].dt);
        if (inMiddle) {
          double y = ps[i].point.dy;
          if (ps[i].point.dy != ps[i + 1].point.dy) {
            y = dayStartDt.difference(sessionStartdt).inSeconds.toDouble();
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

    if (sessionEnddt.isBefore(dayStartDt.add(const Duration(hours: 24)))) {
      // we need to insert the point
      cumulativeDur = cumulativeDur + viewWidth.inSeconds.toDouble();
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
    // ps = removeExtraPoints(ps, sessionStartdt, sessionEnddt);
    // List<Point> newP = List.from(ps);
    // newP.remove(newP.length);

    /// add relative positions
    ps = updateRelativePositions(ps, nowDt);
    log(ps.toList().toString());
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
    return finalPoints;
  }

  static double getXmax(List<Point> ps) {
    if (ps.length <= 1) {
      return 100;
    }
    return (ps.last.point.dx - ps.first.point.dx) + ps.last.point.dx * 0.00;
  }

  static double getYmax(List<Point> ps) {
    if (ps.length <= 1) {
      return 100;
    }
    return (ps.last.point.dy - ps.first.point.dy) + 1000;
  }
}
