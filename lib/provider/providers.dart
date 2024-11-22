// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v2/pages/home/home_page.dart';

import '../model/models.dart';
import '../utils/utils.dart';
import 'logics.dart';

final storageProvider = Provider<SharedUtility>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  // log('Initialized SharedPreferences');
  return SharedUtility(sharedPreferences: sharedPrefs);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class SharedUtility {
  SharedUtility({
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;

  List<Event> get_events() {
    final val = sharedPreferences.getString(eventLstKey);
    if (val == null) {
      log('no Events in storage');
      return [];
    }
    List<Event> events = [];
    // log(val);
    final List<dynamic> v = jsonDecode(val);
    if (v.isEmpty) {
      return [];
    }
    for (int i = 0; i < v.length; i++) {
      events.add(Event.fromJson(v[i]));
    }
    return events;
  }

  List<List<Event>> get_record() {
    final val = sharedPreferences.getString(recordKey);
    if (val == null) {
      log('no Events in storage');
      return [];
    }
    List<List<Event>> record = [];
    for (int i = 0; i < record.length; i++) {
      List<Event> events = record[i];
      for (int j = 0; j < events.length; j++) {
        events.add(Event.fromJson(jsonDecode(val[i][j])));
      }
    }
    return record;
  }

  void save_events(List<Event> events) {
    if (events.isEmpty) return;
    List<Map<String, dynamic>> eventsJson = [];
    for (int i = 0; i < events.length; i++) {
      eventsJson.add(events[i].toJson());
    }
    sharedPreferences.setString(eventLstKey, jsonEncode(eventsJson));
  }

  void save_record(List<List<Event>> record) {
    if (record.isEmpty) return;
    List<List<Map<String, dynamic>>> recordJson = [];
    for (int i = 0; i < record.length; i++) {
      List<Event> events = record[i];
      List<Map<String, dynamic>> eventsJson = [];
      for (int j = 0; j < events.length; j++) {
        eventsJson.add(events[j].toJson());
      }
      recordJson.add(eventsJson);
    }
    sharedPreferences.setString(recordKey, jsonEncode(recordJson));
  }

  void deleteEvents() {
    sharedPreferences.remove(eventLstKey);
  }

  void deleteRecord() {
    sharedPreferences.remove(recordKey);
  }

  // bool isDarkModeEnabled() {
  //   return sharedPreferences.getBool(sharedDarkModeKey) ?? false;
  // }

  // RecordModel? get_record() {
  //   final val = sharedPreferences.getString(recordKey);
  //   if (val == null) {
  //     // log('no record in storage');
  //     return null;
  //   }

  //   RecordModel r = RecordModel.fromJson(jsonDecode(val));
  //   // log('stored data : ${r.toString()}');
  //   return r;
  // }

  // void cache_record(RecordModel record) {
  //   // log('caching record.....');
  //   String val = jsonEncode(record.toJson());
  //   // log('String val -> $val');
  //   sharedPreferences.setString(recordKey, val);
  // }

  final recordKey = 'record';
  final eventLstKey = 'eventLstKey';
}

class EventsNotifier extends Notifier<List<Event>> {
  @override
  List<Event> build() => [];

  void updateEvents(List<Event> events) {
    state = events;
  }

  void get_events_from_stg() {
    List<Event> events = ref.read(storageProvider).get_events();
    if (events.isEmpty) {
      log('Events : []');
      return;
    }
    final today = DateTime.now();
    if (today.day == events.first.st.day &&
        today.month == events.first.st.month) {
      log('Events : ${events.toString()}');
      state = events;
      return;
    }
    ref.read(recordProvider.notifier).addDayEvents(events);
    state = [];
  }

  void addNewStartt(DateTime dt) {
    List<Event> events = List.from(state);
    events = EventsUtils.addStartTime(events, dt);
    state = events;
    saveEvents();
  }

  void addEndt(DateTime dt) {
    List<Event> events = List.from(state);
    events = EventsUtils.addEndTime(events, dt);
    state = events;
    saveEvents();
  }

  void saveEvents() {
    List<Event> events = List.from(state);
    ref.read(storageProvider).save_events(events);
  }

  void deleteEvents() {
    ref.read(storageProvider).deleteEvents();
    state = [];
  }

  bool isActive() {
    return EventsUtils.isActive(state);
  }
}



final pastDayPro = NotifierProvider<PastDayNot, List<Day>>(PastDayNot.new);
final pointsProvider = NotifierProvider<PointsNotifier, List<Point>>(
  PointsNotifier.new,
);
final timerProvider = NotifierProvider<TimeNotifier, DateTime>(
  TimeNotifier.new,
);
final eventsProvider = NotifierProvider<EventsNotifier, List<Event>>(
  EventsNotifier.new,
);
final recordProvider = NotifierProvider<RecordNot, Record>(
  RecordNot.new,
);
final viewSpecProvider = NotifierProvider<ViewSpecNot, ViewSpecification>(
  ViewSpecNot.new,
);
final viewProvider = NotifierProvider<ViewSelection, Duration>(
  ViewSelection.new,
);

final sessionStartTimeProvider =
    NotifierProvider<SessionStartTimeNotifier, TimeOfDay>(
  SessionStartTimeNotifier.new,
);


