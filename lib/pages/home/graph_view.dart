import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2/model/models.dart';

class GraphView extends ConsumerWidget {
  final List<Offset> points;
  const GraphView({super.key, required this.points});

  double getXmax(List<Offset> ps) {
    if (ps.isEmpty || ps.length == 1) {
      return 100;
    }
    return (ps.last.dx - ps.first.dx) + 10000;
  }

  double getYmax(List<Offset> ps) {
    if (ps.isEmpty || ps.length == 1) {
      return 100;
    }
    return (ps.last.dy - ps.first.dy) + 10000;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // final DateTime now = DateTime.now();

    return Container(
      color: Colors.greenAccent,
      height: height * .25,
      // width: width * .5,
      // child: CustomPaint(
      //   painter: GraphPainter(
      //     dxMax: getXmax(points),
      //     dyMax: getYmax(points),
      //     points: points,
      //   ),
      //   child: const Center(child: Text('paint here')),
      // ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final double dxMax;
  final double dyMax;
  final List<Point> points;

  GraphPainter({
    required this.dxMax,
    required this.dyMax,
    required this.points,
  });

  final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  @override
  void paint(Canvas canvas, Size size) {
    double dx = size.width / dxMax;
    double dy = size.height / dyMax;
    Path p = Path();
    for (int i = 0; i < points.length; i++) {
      // log('${points[i].toString()}');
      if (i == 0) {
        p.moveTo(
          points[i].point.dx * dx,
          size.height - points[i].point.dy * dy,
        );
      }
      p.lineTo(points[i].point.dx * dx, size.height - points[i].point.dy * dy);
    }
    p.close();
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(p, paint);

    // drawCircle(canvas, dx, dy, size);

    // drawText(canvas, dx, dy);
    // drawXlabels(canvas, dx, dy, size);
    // drawCurrentTimeVLine(canvas, dx, dy, size);
    // drawCurrentTimeTxt(canvas, dx, dy, size);
  }

  void drawCurrentTimeTxt(Canvas canvas, double dx, double dy, Size s) {
    if (points.isEmpty) return;

    List<Point> ps = points.where((a) => a.relativePosition == 0).toList();
    if (ps.isEmpty) return;
    Point p = ps.first;
    // Paint paint = Paint()
    //   ..color = Colors.blue
    //   ..strokeWidth = 2
    //   ..style = PaintingStyle.stroke;
    TextStyle textStyle = const TextStyle(color: Colors.black);

    String text = '${p.dt.hour}:${p.dt.minute}:${p.dt.second}';

    _textPainter.text = TextSpan(
      text: text,
      style: textStyle,
    );
    _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);
    Size textSize = _textPainter.size;
    _textPainter.paint(
      canvas,
      Offset(
        p.point.dx * dx - textSize.width / 2,
        s.height + 32,
      ),
    );
  }

  void drawCurrentTimeVLine(Canvas canvas, double dx, double dy, Size s) {
    if (points.isEmpty) return;
    List<Point> ps = points.where((a) => a.relativePosition == 0).toList();
    if (ps.isEmpty) return;
    Point p = ps.first;
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(p.point.dx * dx, s.height - p.point.dy * dy),
      Offset(p.point.dx * dx, s.height + 30),
      paint,
    );
  }

  void drawXlabels(Canvas canvas, double dx, double dy, Size s) {
    TextStyle textStyle = const TextStyle(color: Colors.black);

    if (points.isEmpty) return;
    for (int i = 0; i < points.length; i++) {
      String text = '${points[i].dt.hour} h';

      _textPainter.text = TextSpan(
        text: text,
        style: textStyle,
      );
      _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);
      Size textSize = _textPainter.size;
      _textPainter.paint(
        canvas,
        Offset(
          points[i].point.dx * dx - textSize.width / 2,
          s.height,
        ),
      );
    }
  }

  void drawText(Canvas canvas, double dx, double dy) {
    TextStyle textStyle = const TextStyle(
      color: Colors.black,
    );

    String duration = '0 h';
    if (points.isNotEmpty) {
      duration = "${Duration(
        milliseconds: points.last.point.dy.toInt(),
      ).inHours} h";
    }
    _textPainter.text = TextSpan(text: duration, style: textStyle);
    _textPainter.layout(
      minWidth: 0,
      maxWidth: double.maxFinite,
    );
    Size textSize = _textPainter.size;
    if (points.isNotEmpty) {
      _textPainter.paint(
        canvas,
        Offset(
          points.last.point.dx * dx - textSize.width - 30,
          0 - textSize.height / 2,
        ),
      );
    }
  }

  void drawCircle(Canvas canvas, double dx, double dy, Size size) {
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(
        Offset(points[i].point.dx * dx, size.height - points[i].point.dy * dy),
        5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // if (points.isEmpty) {
    //   return true;
    // }
    // bool shouldRepaint = false;
    // for (int i = 0; i < points.length; i++) {
    //   if (points[i] != oldDelegate.points[i]) {
    //     shouldRepaint = true;
    //   }
    // }
    // return shouldRepaint;
    return true;
  }
}
