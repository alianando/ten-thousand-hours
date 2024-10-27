// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2/model/models.dart';
import 'package:v2/pages/home/graph_view.dart';
import '../../provider/providers.dart';
import '../../utils/utils.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = MediaQuery.sizeOf(context).height;
    final points = ref.watch(pointsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: ListView(
        children: [
          Container(
            color: Colors.greenAccent,
            height: height * .25,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomPaint(
                painter: GraphPainter(
                  dxMax: Utils.getXmax(points),
                  dyMax: Utils.getYmax(points),
                  points: points,
                ),
                child: Center(child: Text(points.length.toString())),
              ),
            ),
          ),
          const SizedBox(height: 50),
          const Buttons(),
          const SizedBox(height: 20),
          const EventsWidgets(),
          // painter with transform
          //   Container(
          //     color: Colors.black54,
          //     height: height * .25,
          //     // width: width * .5,
          //     child: Padding(
          //       padding: const EdgeInsets.all(10.0),
          //       child: CustomPaint(
          //         painter: PainterWithTransform(
          //           allPoints2,
          //         ),
          //         child: const Center(child: Text('Painter 2')),
          //       ),
          //     ),
          //   )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          DateTime temp1 = DateTime.now();
          Event e1 = Event(
            st: temp1.subtract(const Duration(hours: 4)),
            et: temp1.subtract(const Duration(hours: 3)),
            d: const Duration(hours: 1),
          );
          Event e2 = Event(st: temp1.subtract(const Duration(hours: 1)));
          List<Map<String, dynamic>> eventsJson = [];
          eventsJson.add(e1.toJson());
          eventsJson.add(e2.toJson());
          String val = jsonEncode(eventsJson);
          var val2 = jsonDecode(val);
          log('##_ -------------- ${val2}');
        },
        child: const Icon(Icons.refresh),
      ),
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
    return ListView.builder(
      shrinkWrap: true,
      itemCount: events.length,
      itemBuilder: (_, index) {
        return ListTile(
          leading: Text(events[index].st.toString()),
          subtitle: Text('${events[index].et?.toString()}'),
        );
      },
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
