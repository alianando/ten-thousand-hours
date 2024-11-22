import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2/pages/home/home_page.dart';
import '../../provider/providers.dart';

class LabelsPainter extends ConsumerWidget {
  const LabelsPainter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewSpec = ref.watch(viewSpecProvider);
    return GraphWrapper(
      child: CustomPaint(
        painter: _painter(
          dxMax:viewSpec.xMax,
          dyMax: viewSpec.yMax,
        ),
      ),
    );
  }
}

class _painter extends CustomPainter {
  final double dxMax;
  final double dyMax;

  _painter({
    required this.dxMax,
    required this.dyMax,
  });

  final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  @override
  void paint(Canvas canvas, Size size) {
    double dx = size.width / dxMax;
    double dy = size.height / dyMax;
    yLines(canvas, dx, dy, size);
    // drawTexts(canvas, dx, dy, size);
  }

  void yLines(Canvas canvas, double dx, double dy, Size size) {
    Paint pastpaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    int numberOfLinesY = 3;
    double y = size.height / numberOfLinesY;
    Path p = Path();
    for (int i = 0; i <= numberOfLinesY; i++) {
      p.moveTo(0, (y * i).toDouble());
      p.lineTo(size.width, (y * i).toDouble());
    }
    int numberOfLinesX = 5;
    double x = size.width / numberOfLinesX;
    for (int i = 0; i <= numberOfLinesX; i++) {
      p.moveTo((x * i).toDouble(), 0);
      p.lineTo((x * i).toDouble(), size.height);
    }
    // p.moveTo(0, 0);
    // p.lineTo(0, size.height);
    // p.moveTo(size.width, 0);
    // p.lineTo(size.width, size.height);
    canvas.drawPath(p, pastpaint);
  }

  void drawTexts(Canvas canvas, double dx, double dy, Size s) {
    TextStyle textStyle = const TextStyle(color: Colors.black);

    String text = dyMax.toString();

    _textPainter.text = TextSpan(
      text: text,
      style: textStyle,
    );
    _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);
    // Size textSize = _textPainter.size;
    _textPainter.paint(
      canvas,
      const Offset(0, 0),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
