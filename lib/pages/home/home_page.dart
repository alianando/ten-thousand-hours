// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2/model/models.dart';
import 'package:v2/pages/home/graph_view.dart';
import 'package:v2/pages/home/labels_painter.dart';
import 'package:v2/pages/home/past_days_view.dart';
import 'package:v2/pages/settings/settings.dart';
import '../../provider/providers.dart';
import '../../utils/utils.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double width = MediaQuery.sizeOf(context).width;
    final points = ref.watch(pointsProvider);
    final events = ref.watch(eventsProvider);
    final viewSpec = ref.watch(viewSpecProvider);
    bool eventOngoing = false;
    if (events.isNotEmpty) {
      if (events.last.et == null) {
        eventOngoing = true;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dash Board'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: ListView(
        children: [
          const ViewSelector(),
          Stack(
            children: [
              const LabelsPainter(),
              const PastDaysView(),
              GraphWrapper(
                child: CustomPaint(
                  painter: GraphPainter(
                    dxMax: viewSpec.xMax,
                    dyMax: viewSpec.yMax,
                    points: points,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 70),
          const Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: StatsWidget(),
          ),
          // const Buttons(),
          const SizedBox(height: 20),
          const EventsWidgets(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FittedBox(
          child: InkWell(
            onTap: () {
              if (ref.read(eventsProvider.notifier).isActive()) {
                ref.read(eventsProvider.notifier).addEndt(DateTime.now());
              } else {
                ref.read(eventsProvider.notifier).addNewStartt(DateTime.now());
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amberAccent,
                border: Border.all(
                  color: Colors.red, // red as border color
                ),
              ),
              height: 50,
              width: width - 50,
              // width: width - 10,
              child: Center(
                child: Text(eventOngoing ? 'Pause' : 'Start'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ViewSelector extends ConsumerWidget {
  const ViewSelector({super.key});

  Widget item(
    Function() onTap,
    Duration Ownduration,
    Duration activeDuration,
    String title,
  ) {
    Color color = Colors.black;
    if (Ownduration == activeDuration) {
      color = Colors.blueAccent;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: TextStyle(color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double width = MediaQuery.sizeOf(context).width;
    final viewSpec = ref.watch(viewProvider);
    return SizedBox(
      height: 40,
      width: width,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            item(
              () => ref
                  .read(viewProvider.notifier)
                  .chageView(const Duration(minutes: 1)),
              const Duration(minutes: 1),
              viewSpec,
              '1min',
            ),
            item(
              () => ref
                  .read(viewProvider.notifier)
                  .chageView(const Duration(hours: 1)),
              const Duration(hours: 1),
              viewSpec,
              '1hour',
            ),
            item(
              () => ref
                  .read(viewProvider.notifier)
                  .chageView(const Duration(hours: 12)),
              const Duration(hours: 12),
              viewSpec,
              '12hour',
            ),
            item(
              () => ref
                  .read(viewProvider.notifier)
                  .chageView(const Duration(days: 1)),
              const Duration(days: 1),
              viewSpec,
              '1day',
            ),
            // item(() {}, '1hour'),
            // item(() {}, '12hour'),
            // item(() {}, '1day'),
          ],
        ),
      ),
    );
  }
}

class GraphWrapper extends ConsumerWidget {
  final Widget child;
  const GraphWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: height * .25,
      width: width,
      child: Padding(padding: const EdgeInsets.all(10.0), child: child),
    );
  }
}

class StatsWidget extends ConsumerWidget {
  const StatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);
    final record = ref.watch(recordProvider);
    Duration duration = const Duration();
    for (int i = 0; i < events.length; i++) {
      if (events[i].et != null) {
        duration = duration + events[i].et!.difference(events[i].st);
      }
    }
    Duration allDuration = const Duration();
    for (int i = 0; i < record.dayEvents.length; i++) {
      for (int j = 0; j < record.dayEvents[i].length; j++) {
        if (record.dayEvents[i][j].et != null) {
          allDuration = allDuration +
              record.dayEvents[i][j].et!.difference(
                record.dayEvents[i][j].st,
              );
        }
      }
    }
    double avgMin = 0;
    if (record.dayEvents.isNotEmpty) {
      avgMin = allDuration.inMinutes / record.dayEvents.length;
    }
    return ListView(
      shrinkWrap: true,
      children: [
        Text('Focused Minutes today : ${duration.inMinutes.toDouble()}'),
        Text('Avg Focused Minute/Day : $avgMin'),
      ],
    );
  }
}

class Buttons extends ConsumerWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    // final events = ref.watch(EventsProvider);
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (ref.read(eventsProvider.notifier).isActive()) return;
                ref.read(eventsProvider.notifier).addNewStartt(DateTime.now());
              },
              child: const Text('Start'),
            ),
            const SizedBox(width: 50),
            ElevatedButton(
              onPressed: () {
                if (ref.read(eventsProvider.notifier).isActive()) {
                  ref.read(eventsProvider.notifier).addEndt(DateTime.now());
                }
              },
              child: const Text('End'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class EventsWidgets extends ConsumerWidget {
  const EventsWidgets({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        reverse: true,
        shrinkWrap: true,
        itemCount: events.length,
        itemBuilder: (_, index) {
          String st = DtUtils.getTimeString(events[index].st);
          String et = '-';
          String dur = 'On going';
          if (events[index].et != null) {
            et = DtUtils.getTimeString(events[index].et!);
            dur = '${events[index].d!.inMinutes.toString()} min';
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: ListTile(
              title: Text(dur),
              subtitle: Text('From $st to $et'),
              shape: Border.all(),
            ),
          );
        },
      ),
    );
  }
}

class PainterWithTransform extends CustomPainter {
  List<Point> points;

  PainterWithTransform(this.points);

  // Float64List matrix = Float64List.fromList(
  //   [
  //     1,
  //     1,
  //     1,
  //     1,
  //     //
  //     1,
  //     1,
  //     1,
  //     1,
  //     //
  //     1,
  //     1,
  //     1,
  //     1,
  //     //
  //     1,
  //     1,
  //     1,
  //     1,
  //   ],
  // );
  Float64List matrix = Float64List.fromList(Matrix4.skewX(3).storage);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.transform(matrix);
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    // for (int i = 0; i < points.length; i++) {
    //   canvas.drawCircle(points[i].point, 5, paint);
    // }
    if (points.isNotEmpty) {
      canvas.drawLine(points.first.point, points.last.point, paint);
    }

    // if (points.isNotEmpty) {
    //   // scale menas zooming
    //   canvas.scale(.000001);
    // }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
