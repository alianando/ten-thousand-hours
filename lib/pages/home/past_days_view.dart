import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2/pages/home/home_page.dart';

import '../../model/models.dart';
import '../../provider/providers.dart';

class PastDaysView extends ConsumerWidget {
  const PastDaysView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 
    final viewSpec = ref.watch(viewSpecProvider);
    // final record = ref.watch(recordProvider);
    final pastDays = ref.watch(pastDayPro);
    bool noDays = pastDays.isEmpty;
    if (noDays) return Container();
    List<Point> points = pastDays.first.dayPoints;
    return GraphWrapper(
      child: CustomPaint(
        painter: PastDayPainter(
          dxMax: viewSpec.xMax,
          dyMax: viewSpec.yMax,
          points: points,
        ),
        // child: Text(record.dayPoints.toString()),
      ),
    );
  }
}

class PastDayPainter extends CustomPainter {
  final double dxMax;
  final double dyMax;
  final List<Point> points;

  PastDayPainter({
    required this.dxMax,
    required this.dyMax,
    required this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double dx = size.width / dxMax;
    double dy = size.height / dyMax;
    dayLine(canvas, dx, dy, size);
  }

  void dayLine(Canvas canvas, double dx, double dy, Size size) {
    if (points.isEmpty) return;

    Paint pastpaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    Path p = Path();
    p.moveTo(
      points.first.point.dx * dx,
      size.height - points.first.point.dy * dy,
    );
    for (int i = 1; i < points.length; i++) {
      p.lineTo(
        points[i].point.dx * dx,
        size.height - points[i].point.dy * dy,
      );
    }
    canvas.drawPath(p, pastpaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
