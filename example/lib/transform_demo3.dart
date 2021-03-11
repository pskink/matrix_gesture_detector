import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class TransformDemo3 extends StatefulWidget {
  @override
  _TransformDemo3State createState() => _TransformDemo3State();
}

class _TransformDemo3State extends State<TransformDemo3> {
  static const Color color0 = Color(0xff00aa00);
  static const Color color1 = Color(0xffeeaa00);
  static const Color color2 = Color(0xffaa0000);
  static const double radius0 = 0.0;

  Matrix4 matrix = Matrix4.identity();
  double radius = radius0;
  Color? color = color0;
  ValueNotifier<int> notifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TransformDemo Demo 3'),
      ),
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          Size s = constraints.biggest;
          double side = s.shortestSide * 0.666;
          matrix.leftTranslate((s.width - side) / 2, (s.height - side) / 2);
          TweenSequence colorTween = TweenSequence([
            TweenSequenceItem(
                tween: ColorTween(begin: color0, end: color1), weight: 1),
            TweenSequenceItem(
                tween: ColorTween(begin: color1, end: color2), weight: 1),
          ]);
          Tween radiusTween = Tween<double>(begin: radius0, end: side / 2);
          return MatrixGestureDetector(
            onMatrixUpdate: (m, tm, sm, rm) {
              matrix = MatrixGestureDetector.compose(matrix, tm, sm, null);

              var angle = MatrixGestureDetector.decomposeToValues(m).rotation;
              double t = (1 - cos(2 * angle)) / 2;

              radius = radiusTween.transform(t);
              color = colorTween.transform(t);
              notifier.value++;
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.topLeft,
              color: Color(0xff444444),
              child: AnimatedBuilder(
                animation: notifier,
                builder: (ctx, child) {
                  return Transform(
                    transform: matrix,
                    child: Container(
                      width: side,
                      height: side,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: Colors.white30,
                          width: 20,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(radius)),
                      ),
                      child: Center(
                        child: Text(
                          'you can move & scale me (and "rotate" too)',
                          textAlign: TextAlign.center,
                          style: Theme.of(ctx).textTheme.display1!.apply(
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
