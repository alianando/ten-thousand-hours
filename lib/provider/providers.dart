// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/models.dart';
import '../utils/utils.dart';

class TimerNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update() {
    int undateNumber = state;
    state = undateNumber + 1;
  }
}

class PointsNotifier extends Notifier<List<Point>> {
  @override
  List<Point> build() {
    final events = ref.watch(eventsProvider);
    final timer = ref.watch(timerProvider);
    log('::: $timer :::');
    // log('----------- update Points due to events change');
    /// extract points from events and radius.
    return Utils.extract_points(events, const Duration(hours: 2));
    // return [];
  }

//   void updatePoints() {
//     // DateTime temp1 = DateTime.now();
//     // log('#### ${temp1.toString()}');
//     // Event e1 = Event(
//     //   st: temp1.subtract(const Duration(hours: 4)),
//     //   et: temp1.subtract(const Duration(hours: 3)),
//     //   d: const Duration(hours: 1),
//     // );
//     state = Utils.extract_points([], const Duration(hours: 2));
//   }
}

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
    for (int i = 0; i < val.length; i++) {
      events.add(Event.fromJson(jsonDecode(val[i])));
    }
    return events;
  }

  void save_events(List<Event> events) {
    if (events.isEmpty) return;
    List<Map<String, dynamic>> eventsJson = [];
    for (int i = 0; i < events.length; i++) {
      eventsJson.add(events[i].toJson());
    }
    sharedPreferences.setString(eventLstKey, jsonEncode(eventsJson));
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

  void get_events_from_stg() {
    state = ref.read(storageProvider).get_events();
  }

  void addNewStartt(DateTime dt) {
    List<Event> events = List.from(state);
    events = EventsUtils.addStartTime(events, dt);
    state = events;
  }

  void addEndt(DateTime dt) {
    List<Event> events = List.from(state);
    events = EventsUtils.addEndTime(events, dt);
    state = events;
  }

  bool isActive() {
    return EventsUtils.isActive(state);
  }
}

final pointsProvider = NotifierProvider<PointsNotifier, List<Point>>(
  PointsNotifier.new,
);
final timerProvider = NotifierProvider<TimerNotifier, int>(TimerNotifier.new);
final eventsProvider = NotifierProvider<EventsNotifier, List<Event>>(
  EventsNotifier.new,
);
