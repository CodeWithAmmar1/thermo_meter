import 'dart:ui';

import 'package:flutter/material.dart';

class ThermoTest extends StatefulWidget {
  @override
  State<ThermoTest> createState() => _ThermoTestState();
}

class _ThermoTestState extends State<ThermoTest> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 25,
                  top: 50,
                  width: 125,
                  height: 400,
                  child: Card(
                    elevation: 6,
                    child: Thermo(
                      duration: const Duration(milliseconds: 1250),
                      color: i.isOdd? Colors.red : Colors.green,
                      value: i.isOdd? 0.9 : 0.1,
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
                Positioned(
                  left: 150,
                  top: 75,
                  width: 50,
                  height: 150,
                  child: Card(
                    elevation: 6,
                    child: Thermo(
                      duration: const Duration(milliseconds: 1250),
                      color: i.isOdd? Colors.indigo : Colors.teal,
                      value: i.isOdd? 0.2 : 0.7,
                      curve: Curves.elasticOut,
                    ),
                  ),
                ),
                Positioned(
                  left: 175,
                  top: 225,
                  width: 100,
                  height: 200,
                  child: Card(
                    elevation: 6,
                    child: Thermo(
                      duration: const Duration(milliseconds: 750),
                      color: i.isOdd? Colors.orange : Colors.deepPurple,
                      value: i.isOdd? 0.3 : 1.0,
                      curve: Curves.bounceOut,
                    ),
                  ),
                ),
              ],
            ),
          ),
         Padding(
  padding: const EdgeInsets.all(32.0),
  child: GestureDetector(
    onTap: () {
      setState(() => i++);
    },
    child: Container(

      height: 50,
      width: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.lightBlueAccent,
            blurRadius: 8,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'PUSH ME',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
)

        ],
      ),
    );
  }
}
class Thermo extends ImplicitlyAnimatedWidget {
  const Thermo({
    super.key,
    super.curve,
    required this.color,
    required this.value,
    required super.duration,
    super.onEnd,
  });

  final Color color;
  final double value;

  @override
  AnimatedWidgetBaseState<Thermo> createState() => _ThermoState();
}

class _ThermoState extends AnimatedWidgetBaseState<Thermo> {
  ColorTween? _color;
  Tween<double>? _value;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        child: CustomPaint(
          size: const Size(18, 63),
          painter: _ThermoPainter(
            color: _color!.evaluate(animation)!,
            value: _value!.evaluate(animation),
          ),
        ),
      ),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _color = visitor(_color, widget.color, (dynamic v) => ColorTween(begin: v)) as ColorTween?;
    _value = visitor(_value, widget.value, (dynamic v) => Tween<double>(begin: v)) as Tween<double>?;
  }
}

class _ThermoPainter extends CustomPainter {
  _ThermoPainter({
    required this.color,
    required this.value,
  });

  final Color color;
  final double value;

  @override
  void paint(Canvas canvas, Size size) {

    const bulbRadius = 6.0;
    const smallRadius = 3.0;
    const border = 1.0;
    final rect = (Offset.zero & size);
    final innerRect = rect.deflate(size.width / 2 - bulbRadius);
    final r1 = Alignment.bottomCenter.inscribe(const Size(2 * smallRadius, bulbRadius * 2), innerRect);
    final r2 = Alignment.center.inscribe(Size(2 * smallRadius, innerRect.height), innerRect);

    final bulb = Path()..addOval(Alignment.bottomCenter.inscribe(Size.square(innerRect.width), innerRect));
    final outerPath = Path()
      ..addOval(Alignment.bottomCenter.inscribe(Size.square(innerRect.width), innerRect).inflate(border))
      ..addRRect(RRect.fromRectAndRadius(r2, const Radius.circular(smallRadius)).inflate(border));

    final scaleRect = Rect.fromPoints(innerRect.topLeft, innerRect.bottomRight - const Offset(0, 2 * bulbRadius));
    Iterable<Offset> generatePoints() sync* {
      for (int i = 0; i < 11; i++) {
        final t = i / 10;
        final point = i.isOdd?
          Offset.lerp(scaleRect.bottomLeft, scaleRect.topLeft, t)! :
          Offset.lerp(scaleRect.bottomRight, scaleRect.topRight, t)!;
        yield point;
        yield point.translate(i.isOdd? 2 : -2, 0);
      }
    }

    final valueRect = Rect.lerp(r1, r2, value)!;
    final valuePaint = Paint()..color = color;

    canvas
      ..save()
      // draw scale
      ..drawPoints(PointMode.lines, generatePoints().toList(), Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
      )
      // draw shadow
      ..drawPath(outerPath.shift(const Offset(1, 1)), Paint()
        ..color = Colors.black54
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1)
      )
      ..clipPath(outerPath)
      // draw background
      ..drawPaint(Paint()..color = Color.alphaBlend(Colors.white60, color))
      // draw foreground
      ..drawPath(bulb, valuePaint)
      ..drawRRect(RRect.fromRectAndRadius(valueRect, const Radius.circular(smallRadius)), valuePaint)
      ..restore();

    // debug only:

    // canvas.drawRect(rect, Paint()..color = Colors.black38);
    // canvas.drawRect(innerRect, Paint()..color = Colors.black38);
    // canvas.drawRect(valueRect, Paint()..color = Colors.black38);
    // canvas.drawRect(scaleRect, Paint()..color = Colors.black38);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}