import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2/model/models.dart';
import 'package:v2/utils/utils.dart';

class GraphView extends ConsumerWidget {
  final List<Offset> points;
  const GraphView({super.key, required this.points});

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
    dayLine(canvas, dx, dy, size);
    dashedLine(canvas, dx, dy, size);
    drawCurrentTimeCircle(canvas, dx, dy, size);
    // drawVLines(canvas, dx, dy, size);
    drawTexts(canvas, dx, dy, size);
    drawCurrentTimeTexts(canvas, dx, dy, size);
  }

  void dashedLine(Canvas canvas, double dx, double dy, Size size) {
    if (points.isEmpty) return;

    Paint futurepaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    Path p = Path();
    for (int i = 0; i < points.length; i++) {
      if (points[i].relativePosition < 0) continue;
      if (points[i].relativePosition == 0) {
        if (i == points.length - 1) continue;

        p.moveTo(
          points[i].point.dx * dx,
          size.height - points[i].point.dy * dy,
        );
        double delX = (points[i + 1].point.dx - points[i].point.dx) * dx;
        double delY = (points[i + 1].point.dy - points[i].point.dy) * dy;
        double tan = delY / delX;
        for (int k = 1; k < 500; k++) {
          double x = 8.toDouble() * k;
          double y = x * tan;

          double xp = points[i].point.dx * dx + x;
          double xpMx = points[i + 1].point.dx * dx;
          if (xp > xpMx) {
            xp = xp - xpMx;
          }
          if (k.isEven) {
            p.lineTo(
              points[i].point.dx * dx + x,
              size.height - points[i].point.dy * dy - y,
            );
          } else {
            p.moveTo(
              points[i].point.dx * dx + x,
              size.height - points[i].point.dy * dy - y,
            );
          }
          if (points[i].point.dx * dx + x >= points[i + 1].point.dx * dx) {
            break;
          }
        }
      }
    }
    canvas.drawPath(p, futurepaint);
  }

  void drawCurrentTimeCircle(Canvas canvas, double dx, double dy, Size s) {
    if (points.isEmpty) return;

    /// first line

    Paint pastpaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    /// now line
    List<Point> ps = points.where((a) => a.relativePosition == 0).toList();
    if (ps.isEmpty) return;
    Point p = ps.first;

    canvas.drawCircle(
      Offset(p.point.dx * dx, s.height - p.point.dy * dy),
      2,
      pastpaint,
    );
  }

  void dayLine(Canvas canvas, double dx, double dy, Size size) {
    if (points.isEmpty) return;
    Paint pastpaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Paint futurepaint = Paint()
    //   ..color = Colors.blue
    //   ..strokeWidth = 2
    //   ..style = PaintingStyle.stroke;
    Path p = Path();
    p.moveTo(
      points.first.point.dx * dx,
      size.height - points.first.point.dy * dy,
    );
    for (int i = 1; i < points.length; i++) {
      if (points[i].relativePosition <= 0) {
        p.lineTo(
          points[i].point.dx * dx,
          size.height - points[i].point.dy * dy,
        );
      }
    }
    canvas.drawPath(p, pastpaint);
    // p.reset();
    // // Path p2 = Path();
    // Point presentPoint = points.where((tp) => tp.relativePosition == 0).first;
    // p.moveTo(
    //   presentPoint.point.dx * dx,
    //   size.height - presentPoint.point.dy * dy,
    // );
    // for (int i = 0; i < points.length; i++) {
    //   if (points[i].relativePosition >= 0) {
    //     p.lineTo(
    //       points[i].point.dx * dx,
    //       size.height - points[i].point.dy * dy,
    //     );
    //   }
    // }
    // canvas.drawPath(p, futurepaint);
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

  void drawVLines(Canvas canvas, double dx, double dy, Size s) {
    if (points.isEmpty) return;

    /// first line
    Point p = points.first;
    Paint pastpaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(p.point.dx * dx, s.height - p.point.dy * dy),
      Offset(p.point.dx * dx, s.height + 68),
      pastpaint,
    );

    /// now line
    // List<Point> ps = points.where((a) => a.relativePosition == 0).toList();
    // if (ps.isEmpty) return;
    // p = ps.first;

    // canvas.drawLine(
    //   Offset(p.point.dx * dx, s.height - p.point.dy * dy),
    //   Offset(p.point.dx * dx, s.height + 30),
    //   pastpaint,
    // );

    /// last line
    p = points.last;

    canvas.drawLine(
      // Offset(p.point.dx * dx, s.height - p.point.dy * dy),
      Offset(p.point.dx * dx, s.height),
      Offset(p.point.dx * dx, s.height + 68),
      pastpaint,
    );
  }

  void drawCurrentTimeTexts(Canvas canvas, double dx, double dy, Size s) {
    if (points.isEmpty) return;
    TextStyle textStyle = const TextStyle(color: Colors.black);

    /// now point
    List<Point> ps = points.where((a) => a.relativePosition == 0).toList();
    if (ps.isEmpty) return;
    Point p = ps.first;

    String text = DtUtils.getTimeString(p.dt);

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
        s.height - p.point.dy * dy - 30,
      ),
    );
  }

  void drawTexts(Canvas canvas, double dx, double dy, Size s) {
    if (points.isEmpty) return;
    TextStyle textStyle = const TextStyle(color: Colors.black);

    /// first point
    Point p = points.first;

    String text = DtUtils.getTimeString(p.dt);

    _textPainter.text = TextSpan(
      text: text,
      style: textStyle,
    );
    _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);
    _textPainter.paint(
      canvas,
      Offset(
        p.point.dx * dx,
        s.height,
      ),
    );

    /// now point
    // List<Point> ps = points.where((a) => a.relativePosition == 0).toList();
    // if (ps.isEmpty) return;
    // Point p = ps.first;
    //

    // String text = '${p.dt.hour}:${p.dt.minute}:${p.dt.second}';

    // _textPainter.text = TextSpan(
    //   text: text,
    //   style: textStyle,
    // );
    // _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);
    // Size textSize = _textPainter.size;
    // _textPainter.paint(
    //   canvas,
    //   Offset(
    //     p.point.dx * dx - textSize.width / 2,
    //     s.height + 32,
    //   ),
    // );

    /// last point
    p = points.last;

    text = DtUtils.getTimeString(p.dt);

    _textPainter.text = TextSpan(
      text: text,
      style: textStyle,
    );
    _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);
    Size textSize = _textPainter.size;
    _textPainter.paint(
      canvas,
      Offset(
        p.point.dx * dx - textSize.width,
        s.height,
      ),
    );
  }

  void drawTriangle(Canvas canvas, double dx, double dy, Size size) {
    if (points.isEmpty) return;
    int index = -1;
    for (int i = 0; i < points.length; i++) {
      if (points[i].relativePosition == 0) {
        index = i;
        break;
      }
    }
    if (index < 1) return;
    if (points[index - 1].point.dy == points[index].point.dy) {
      return;
    }
    Path p = Path();
    p.moveTo(points[index - 1].point.dx * dx,
        size.width - points[index - 1].point.dy * dy);
    p.lineTo(points[index - 1].point.dx * dx,
        size.width - points[index - 1].point.dy * dy);
    Paint pastpaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(p, pastpaint);

    // Paint futurepaint = Paint()
    //   ..color = Colors.blue
    //   ..strokeWidth = 2
    //   ..style = PaintingStyle.stroke;
    // Path p = Path();
    // p.moveTo(
    //   points.first.point.dx * dx,
    //   size.height - points.first.point.dy * dy,
    // );
    // for (int i = 1; i < points.length; i++) {
    //   if (points[i].relativePosition <= 0) {
    //     p.lineTo(
    //       points[i].point.dx * dx,
    //       size.height - points[i].point.dy * dy,
    //     );
    //   }
    // }
    // canvas.drawPath(p, pastpaint);
    // p.reset();
    // // Path p2 = Path();
    // Point presentPoint = points.where((tp) => tp.relativePosition == 0).first;
    // p.moveTo(
    //   presentPoint.point.dx * dx,
    //   size.height - presentPoint.point.dy * dy,
    // );
    // for (int i = 0; i < points.length; i++) {
    //   if (points[i].relativePosition >= 0) {
    //     p.lineTo(
    //       points[i].point.dx * dx,
    //       size.height - points[i].point.dy * dy,
    //     );
    //   }
    // }
    // canvas.drawPath(p, futurepaint);
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

class RetroGraph extends CustomPainter {
  final double screenFactor;
  final double dxMax;
  final double dyMax;
  final List<Point> points;

  // final _textPainter = TextPainter(textDirection: TextDirection.ltr);
  RetroGraph({
    required this.screenFactor,
    required this.dxMax,
    required this.dyMax,
    required this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double dx = size.width / dxMax;
    double dy = size.height / dyMax;
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      // double numberOfIntPoint = 2;
      // double x = (points[i + 1].point.dx * dx - points[i].point.dx * dx) /
      //     numberOfIntPoint;
      double x_0 = points[i].point.dx * dx;
      double x_max = points[i + 1].point.dx * dx;
      double y = size.height - points[i].point.dy * dy;

      for (int j = 0; j <= 100; j++) {
        double x = x_0 + screenFactor * j;
        if (x > x_max) {
          break;
        }
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
      // Offset location = Offset(
      //   points[i].point.dx * dx,
      //   size.height - points[i].point.dy * dy,
      // );
      // canvas.drawCircle(location, 3, paint);
    }

    // drawCircle(canvas, dx, dy, size);

    // drawText(canvas, dx, dy);
    // drawXlabels(canvas, dx, dy, size);
    // drawCurrentTimeVLine(canvas, dx, dy, size);
    // drawCurrentTimeTxt(canvas, dx, dy, size);
    // drawFirstTimeTxt(canvas, dx, dy, size);
    // drawFirstTimeVLine(canvas, dx, dy, size);
  }

  @override
  bool shouldRepaint(RetroGraph oldDelegate) {
    bool repaint = false;
    if (points.length != oldDelegate.points.length) {
      return true;
    }
    for (int i = 0; i < points.length; i++) {
      if (points[i] != oldDelegate.points[i]) {
        repaint = true;
        debugPrint('Repaint at $i');
        break;
      }
    }
    return repaint;
  }
}
