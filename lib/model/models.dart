// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class Point {
  DateTime dt;
  Offset point;
  double duration;

  /// how far from the now point
  // -99 means unassigned.
  double relativePosition;

  Point({
    required this.dt,
    required this.point,
    this.duration = 0,
    this.relativePosition = -99,
  });

  bool same(Point p) {
    if (p.dt == dt) {
      return true;
    }
    return false;
  }

  @override
  String toString() {
    // String dt = "dt:!${dt.hour}:${dt.minute}:${dt.second}.${dt.microsecond}!";
    return '$relativePosition[dt: ${dt.toString()}, d_$duration, {${point.dx}, ${point.dy}}]_';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Point &&
        other.point.dx == point.dx &&
        other.point.dy == point.dy;
  }

  @override
  int get hashCode => point.dx.toInt() * point.dy.toInt();
}

class Event {
  DateTime st;
  DateTime? et;
  Duration? d;

  Event({required this.st, this.et, this.d});

  void endEvent(DateTime t, Duration d_new) {
    et = t;
    d = d_new;
  }

  bool isOngoing() {
    if (et == null) {
      return true;
    }
    return false;
  }

  factory Event.fromJson(Map<String, dynamic> data) {
    return Event(
      st: DateTime.parse(data['st']),
      et: data['et'] == null ? null : DateTime.parse(data['et']),
      d: data['d'] == null ? null : Duration(seconds: int.parse(data['d'])),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['st'] = st.toIso8601String();
    data['et'] = et?.toIso8601String();
    data['d'] = d?.inSeconds.toString();
    return data;
  }
}

// enum SessionStatus {
//   onGoing,
//   onPause,
//   ended,
// }

// class CurSession {
//   SessionStatus status;
//   DateTime? st;
//   DateTime?
// }
